%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.26 @ UT Austin
%%
%% - Input:
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      'org': original matrix
%%      'rand': randomize raw and col
%%      'geo': geo -- can only be used by 4sq TM matrix
%%      'cc': correlation coefficient
%%   @option_type: determine the way to remove unimportant parts
%%      'single': remove those values which are close to 0
%%      'chunk':  remove chunks which cause smallest errors
%%   @drop_ele_mode:
%%      'elem': drop elements
%%      'row': drop rows
%%      'col': drop columns
%%   @drop_mode:
%%      'ind': drop independently
%%      'syn': rand loss synchronized among elem_list
%%   @elem_frac: 
%%      (0-1): the fraction of elements in a frame 
%%      0    : compression
%%   @loss_rate: 
%%      (0-1): the fraction of frames to drop
%%   @burst_size: 
%%      burst in time (i.e. frame)
%%
%% - Output:
%%
%% e.g. 
%%     [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 8, 217, 400, 4, 'org', 'chunk', 22, 40, 10, 20, 'elem', 'ind', 0.2, 0.5, 1, 1)
%%     [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.002.bin60.sub.', 24, 120, 100, 4, 'org', 'chunk', 12, 10, 10, 10, 'elem', 'ind', 0.2, 0.5, 1, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc, ratio] = dct_based_pred(input_TM_dir, filename, num_frames, width, height, group_size, option_swap_mat, option_type, chunk_width, chunk_height, selected_chunk, quantization, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed)
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    DEBUG_WRITE = 0;

    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end


    %% --------------------
    %% Constant
    %% --------------------
    % quantization = 10;
    ele_size = 32;  %% size of each elements in bits


    %% --------------------
    %% Variable
    %% --------------------
    % input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';
    space = 0;


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    num_chunks = [ceil(height/chunk_height), ceil(width/chunk_width)];
    num_groups = ceil(num_frames / group_size);


    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    data = zeros(height, width, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        if DEBUG0, fprintf('      size = [%d,%d]\n', size(tmp)); end

        data(:,:,frame+1) = tmp(1:height, 1:width);
    end
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    % M = ones(size(data));
    % if loss_rate > 0
    %     %% drop elements for prediction
    %     num_missing = ceil(nx * loss_rate);
    %     for f = [1:num_frames]
    %         if DEBUG0, fprintf('  frame %d\n', f); end

    %         ind = randperm(nx);
    %         tmp = M(:,:,f);
    %         tmp(ind(1:num_missing)) = 0;
    %         M(:,:,f) = tmp;
    %     end
    % else
    %     %% compression
    % end
    if elem_frac > 0
        %% prediction
        M = DropValues(sx(1), sx(2), num_frames, elem_frac, loss_rate, drop_ele_mode, drop_mode, burst_size);
    else
        %% compression
        M = ones(size(data));
    end


    %% --------------------
    %% swap matrix row and column
    %% 0: original matrix
    %% 1: randomize raw and col
    %% 2: geo
    %% 3: correlated coefficient
    %% --------------------
    if DEBUG2, fprintf('swap matrix row and column\n'); end

    if strcmp(option_swap_mat, 'org')
        %% 0: original matrix
        mapping_rows = [1:height];
        mapping_cols = [1:width];
    elseif strcmp(option_swap_mat, 'rand')
        %% 1: randomize raw and col
        mapping_rows = randperm(height);
        mapping_cols = randperm(width);
    elseif strcmp(option_swap_mat, 'geo')
        %% 2: geo -- only for 4sq TM
        % [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        % if DEBUG0
        %     fprintf('  size of location: %d, %d\n', size(location));
        %     fprintf('  size of mass: %d, %d\n', size(mass));
        % end
        
        % mapping = sort_by_lat_lng(location, width, height);

    elseif strcmp(option_swap_mat, 'cc')
        %% 3: correlated coefficient
        
        tmp_rows = reshape(data, height, []);
        tmp_cols = zeros(height*num_frames, width);
        for f = [1:num_frames]
            tmp_cols( (f-1)*height+1:f*height, : ) = data(:,:,f);
        end

        %% corrcoef: rows=obervations, col=features
        coef_rows = corrcoef(tmp_rows');
        coef_cols = corrcoef(tmp_cols);

        mapping_rows = sort_by_coef(coef_rows);
        mapping_cols = sort_by_coef(coef_cols);

    elseif strcmp(option_swap_mat, 'pop')
        %% 4: popularity
        error('XXX: swap according to popularity\n');
        
    end

    %% update the data matrix according to the mapping
    for f = [1:num_frames]
        data(:,:,f) = map_matrix(data(:,:,f), mapping_rows, mapping_cols);
        M(:,:,f)    = map_matrix(M(:,:,f), mapping_rows, mapping_cols);
    end

    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end
    

    %% --------------------    
    %% first guess of missing elements
    %% --------------------
    if elem_frac > 0
        %% prediction 

        %% by 0s
        % compared_data = data;
        % compared_data(~M) = 0;

        %% by mean of other elements
        % compared_data = data;
        % compared_data(~M) = mean(reshape(data(M==1), [], 1));

        %% by average of nearby elements
        compared_data = first_guess('knn', data, M);
    else
        %% compression
        compared_data = data;
    end


    %% --------------------
    %% apply 3D DCT to each Group of Pictures (GoP)
    %% --------------------
    for gop = 1:num_groups
        gop_s = (gop - 1) * group_size + 1;
        gop_e = min(num_frames, gop * group_size);

        if DEBUG1 == 0, fprintf('gop %d: frame %d-%d\n', gop, gop_s, gop_e); end

        this_group   = compared_data(:, :, gop_s:gop_e);
        this_group_M = M(:, :, gop_s:gop_e);



        if strcmp(option_type, 'single')
            %% ignore elements which are close to 0
            
            tmp = mirt_dctn(this_group);
            cut = abs(prctile(tmp(:), quantization));
            this_dct = round(tmp / cut) * cut;
            est_group  = mirt_idctn(this_dct);

            %% space required
            space = space + nx*(gop_e-gop_s+1) + length(find(this_dct ~= 0))*ele_size;
        elseif strcmp(option_type, 'chunk')
            %% ignore chunks which cause smaller errors

            %% calculate error caused by each chunk
            this_group_dct = mirt_dctn(this_group);
            err_bit_map = zeros(num_chunks(1), num_chunks(2), gop_e-gop_s+1);
            for w = 1:num_chunks(2)
                w_s = (w-1)*chunk_width + 1;
                w_e = min(w*chunk_width, width);
                
                for h = 1:num_chunks(1)
                    h_s = (h-1)*chunk_height + 1;
                    h_e = min(h*chunk_height, height);

                    for f = 1:(gop_e-gop_s+1)
                        tmp = this_group_dct;
                        tmp(h_s:h_e, w_s:w_e, f) = 0;
                        tmp_est_gp = mirt_idctn(tmp);

                        err_bit_map(h, w, f) = mean(abs(tmp_est_gp(:) - this_group(:)));

                        if DEBUG0, fprintf('  chunk [%d, %d, %d], err=%f\n', h, w, f, err_bit_map(h, w, f)); end
                    end
                end
            end

            %% select chunks which cause larger error
            est_group_dct = zeros(size(this_group_dct));
            [err_sort, err_ind_sort] = sort(err_bit_map(:), 'descend');
            for selected_ind = [1:min(selected_chunk, length(err_sort))]
                [h, w, f] = ind2sub([num_chunks(1), num_chunks(2), (gop_e-gop_s+1)], err_ind_sort(selected_ind));
                
                if DEBUG0, fprintf('%d [%d, %d, %d], err = %f (%f)\n', err_ind_sort(selected_ind), h, w, f, err_bit_map(err_ind_sort(selected_ind)), err_sort(selected_ind)); end

                w_s = (w-1)*chunk_width + 1;
                w_e = min(w*chunk_width, width);
                h_s = (h-1)*chunk_height + 1;
                h_e = min(h*chunk_height, height);
                est_group_dct(h_s:h_e, w_s:w_e, f) = this_group_dct(h_s:h_e, w_s:w_e, f);
            end

            est_group  = mirt_idctn(est_group_dct);


            %% space required
            space = space + nx*(gop_e-gop_s+1) + min(selected_chunk, length(err_sort))*chunk_width*chunk_height*ele_size;
        else
            error('wrong option type');
        end

        compared_data(:, :, gop_s:gop_e) = est_group;
    end
    

    meanX2 = mean(data(~M).^2);
    meanX = mean(data(~M));

    if elem_frac > 0
        %% prediction
        mse = mean(( data(~M) - max(0,compared_data(~M)) ).^2) / meanX2;
        mae = mean(abs((data(~M) - max(0,compared_data(~M))))) / meanX;
        cc  = corrcoef(data(~M),max(0,compared_data(~M)));
        cc  = cc(1,2);
    else
        %% compression
        mse = mean(( data(:) - max(0,compared_data(:)) ).^2) / meanX2;
        mae = mean(abs((data(:) - max(0,compared_data(:))))) / meanX;
        cc  = corrcoef(data(:),max(0,compared_data(:)));
        cc  = cc(1,2);
    end
    ratio = space / (width*height*num_frames*ele_size);

    fprintf('%f, %f, %f, %f\n', mse, mae, cc, ratio);


    if DEBUG_WRITE == 1
        dlmwrite('tmp.txt', [find(M==0), data(~M), max(0,compared_data(~M))]);
    end
end



%% -------------------------------------
%% map_matrix: swap row and columns according to "mapping"
%% @input mapping: 
%%    a vector to map venues to the other
%%    e.g. [4, 3, 1, 2] means mapping 1->4, 2->3, 3->1, 4->2
%%
function [new_mat] = map_matrix(mat, mapping_rows, mapping_cols)
    new_mat = zeros(size(mat));
    new_mat(mapping_rows, :) = mat;
    tmp = new_mat;
    new_mat(:, mapping_cols) = tmp;
end


%% find_ind: function description
% function [map_ind] = find_mapping_ind(ind, width, height, mapping)
%     y = mod(ind-1, height) + 1;
%     x = floor((ind-1)/height) + 1;

%     x2 = mapping(x);
%     y2 = mapping(y);
%     map_ind = (x2 - 1) * height + y2;
% end


%% -------------------------------------
%% sort_by_lat_lng
%% @input location: 
%%    a Nx2 matrix to represent the (lat, lng) of N venues
%%
% function [mapping] = sort_by_lat_lng(location, width, height)
%     mapping = ones(1, width);
%     tmp = 2:width;
%     src = 1;
%     src_ind = 2;
%     while length(tmp) > 0
%         min_dist = -1;
%         min_dist_dst = 0;
%         min_dist_ind = 0;

%         ind = 0;
%         for dst = tmp
%             ind = ind + 1;
%             dist = pos2dist(location(src,1), location(src,2), location(dst,1), location(dst,2), 2);

%             if (min_dist == -1) | (min_dist > dist) 
%                 min_dist = dist;
%                 min_dist_dst = dst;
%                 min_dist_ind = ind;
%             end
%         end

%         if tmp(min_dist_ind) ~= min_dist_dst
%             fprintf('min dist dst does not match: %d, %d\n', tmp(min_dist_ind), min_dist_dst);
%             return;
%         end

%         mapping(src_ind) = min_dist_dst;
%         src = min_dist_dst;
%         src_ind = src_ind + 1;
%         tmp(min_dist_ind) = [];
%     end
% end


%% -------------------------------------
%% sort_by_coef
%% @input coef: 
%%    a NxN matrix to represent the correlation coefficient of N venues
%%
function [mapping] = sort_by_coef(coef)
    sx = size(coef, 1);
    mapping = ones(1, sx);
    tmp = 2:sx;  %% list of non-selected venues
    src = 1;
    src_ind = 2; %% index to mpaaing
    while length(tmp) > 0
        max_coef = -1;
        max_coef_dst = 0;
        max_coef_ind = 0;

        ind = 0;  %% index to tmp
        for dst = tmp
            ind = ind + 1;
            this_coef = coef(src, dst);

            if (max_coef == -1) | (this_coef > max_coef) 
                max_coef = this_coef;
                max_coef_dst = dst;
                max_coef_ind = ind;
            end
        end

        if tmp(max_coef_ind) ~= max_coef_dst
            fprintf('max coef dst does not match: %d, %d\n', tmp(max_coef_ind), max_coef_dst);
            error('exit');
        end

        mapping(src_ind) = max_coef_dst;
        src = max_coef_dst;
        src_ind = src_ind + 1;
        tmp(max_coef_ind) = [];
    end
end


%% convert_3d_ind
% function [x, y, z] = convert_3d_ind(w, h, f, line_ind)
%     z = floor( (line_ind - 1) / (w*h)) + 1;
%     y = floor( (line_ind - (z-1) * (w*h) - 1 ) / w) + 1;
%     x = floor( (line_ind - (z-1) * (w*h) - (y-1) * w) );
% end


%% first_guess: fill in the missing elements
function [filled_data] = first_guess(method, data, M)
    filled_data = data;
    filled_data(~M) = 0;

    sx = size(data);
    nx = sx(1) * sx(2) * sx(3);
    nx_f = sx(1) * sx(2);


    if strcmpi(method, 'avg')
        
        for drop = [find(M == 0)]
            tmp_sum = 0;
            tmp_cnt = 0;

            if (drop + 1 < nx) & (M(drop+1) == 1)
                tmp_sum = tmp_sum + data(drop+1);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop + nx_f < nx) & (M(drop+nx_f) == 1)
                tmp_sum = tmp_sum + data(drop+nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop + 2*nx_f < nx) & (M(drop+2*nx_f) == 1)
                tmp_sum = tmp_sum + data(drop+2*nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - 1 > 0) & (M(drop-1) == 1)
                tmp_sum = tmp_sum + data(drop-1);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - nx_f > 0) & (M(drop-nx_f) == 1)
                tmp_sum = tmp_sum + data(drop-nx_f);
                tmp_cnt = tmp_cnt + 1;
            end
            if (drop - 2*nx_f > 0) & (M(drop-2*nx_f) == 1)
                tmp_sum = tmp_sum + data(drop-2*nx_f);
                tmp_cnt = tmp_cnt + 1;
            end

            if tmp_cnt > 0
                filled_data(drop) = tmp_sum / tmp_cnt;
            end
        end
    
    elseif strcmpi(method, 'knn')
        filled_data = first_guess('avg', data, M);

        orig_sx = size(filled_data);
        flat_data = reshape(filled_data, [], orig_sx(3));
        flat_M    = reshape(M,    [], orig_sx(3));

        maxDist = 3;
        EPS = 1e-3;

        Z = flat_data;
        for i = 1:size(flat_data, 1)
            for j = find(flat_M(i,:) == 0);
                ind = find((flat_M(i,:)==1) & (abs((1:size(flat_data,2)) - j) <= maxDist));
                if (~isempty(ind))
                    Y  = flat_data(:,ind);
                    C  = Y'*Y;
                    nc = size(C,1);
                    C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                    w  = C\(Y'*flat_data(:,j));
                    w  = reshape(w,1,nc);
                    Z(i,j) = sum(flat_data(i,ind).*w);
                end
            end
        end
        filled_data = reshape(Z, orig_sx);

    else
        error('wrong input method: %s\n', method);
    end
end

