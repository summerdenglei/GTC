%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.13 @ UT Austin
%%
%% - Input:
%%   @option_dect: options to do anomaly detection
%%      1: just delta
%%      2: replace anomaly by approximated value
%%      3: replace anomaly by approximated value, and use DCT for the 1st frame
%%   @option_delta: options to calculate delta
%%      1: sum of absolute diff
%%      2: mean square error (MSE)
%%      3: mean absolute error (MAE)
%%   @option_frames: determine which realted frames to compare
%%      -m: the previous m-th frame
%%      0 : current frame
%%      n : the next n-th frame
%%   @option_blocks: determine which related blocks to compare
%%      -1: all blocks
%%      0 : corresponding block
%%      4 : near by 5 blocks
%%      8 : near by 9 blocks
%%
%%      24 20 9  13 21
%%      19 8  1  5  14
%%      12 4  0  2  10
%%      18 7  3  6  15
%%      23 17 11 16 22
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      0: original matrix
%%      1: randomize raw and col
%%      2: geo
%%      3: correlated coefficient
%%
%% - Output:
%%
%% e.g. 
%%     [tp, tn, fp, fn, precision, recall, f1score] = mpeg_based('../processed_data/subtask_inject_error/TM_err/', 'TM_Airport_period5_.exp0.', 12, 300, 300, 30, 30, 50, 3, 1, [-2, -1, 0, 1, 2], [0,  8, 8, 8, 0], 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tp, tn, fp, fn, precision, recall, f1score] = mpeg_based(input_TM_dir, filename, num_frames, width, height, block_width, block_height, thresh, option_dect, option_delta, option_frames, option_blocks, option_swap_mat)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 0; %% block index check

    if width ~= height
        fprintf('width should be equal to height: %d, %d\n', width, height);
        return;
    end


    % a = int64(rand(5) .* 100)
    % % [val, ind] = max(a(:))
    % ind = find(a > 50)
    % val = a(ind)
    % mapping = randperm(size(a, 1))
    % b = map_matrix(a, mapping)
    % find_mapping_ind(ind, size(a,1), size(a,2), mapping)
    % % ind = find(b == val)
    % return;



    %% --------------------
    %% Constant
    %% --------------------
    quantization = 10;


    %% --------------------
    %% Variable
    %% --------------------
    % input_TM_dir  = '../processed_data/subtask_process_4sq/TM/';
    % input_TM_dir   = '../processed_data/subtask_inject_error/TM_err/';
    % input_TM_dir   = '../processed_data/subtask_parse_sjtu_wifi/tm/';
    input_errs_dir =  '../processed_data/subtask_inject_error/errs/';
    input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';
    % output_dir = '../processed_data/subtask_mpeg/output/';


    %% --------------------
    %% Main starts
    %% --------------------
    num_blocks = [ceil(width/block_width), ceil(height/block_height)];


    %% --------------------
    %% Read anomaly ground truth
    %%  - row 1: index
    %%  - row 2: anomaly value
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read anomalies\n'); end

    data = zeros(width, height, num_frames);
    raw_gt_frame = cell(1, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        this_err_file = [input_errs_dir filename int2str(frame) '.err.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_err_file); end

        if frame == 0
            ground_truth = load(this_err_file);
            raw_gt_frame(frame+1) = {ground_truth(1, :)};
        else
            tmp = load(this_err_file);
            raw_gt_frame(frame+1) = {tmp(1, :)};

            tmp(1, :) = tmp(1, :) + frame * width * height;
            ground_truth = [ground_truth, tmp];
        end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:width, 1:height);
    end


    %% --------------------
    %% swap matrix row and column
    %% 0: original matrix
    %% 1: randomize raw and col
    %% 2: geo
    %% 3: correlated coefficient
    %% --------------------
    if DEBUG2, fprintf('swap matrix row and column\n'); end

    if option_swap_mat == 0
        %% 0: original matrix
        mapping = [1:width];
    elseif option_swap_mat == 1
        %% 1: randomize raw and col
        mapping = randperm(width);
    elseif option_swap_mat == 2
        %% 2: geo
        [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        if DEBUG0
            fprintf('  size of location: %d, %d\n', size(location));
            fprintf('  size of mass: %d, %d\n', size(mass));
        end
        
        mapping = sort_by_lat_lng(location, width, height);

    elseif option_swap_mat == 3
        %% 3: correlated coefficient
        tmp = reshape(data, width, []);
        if DEBUG1
            fprintf('  size of the whole matrix: %d, %d\n', size(tmp));
        end
        
        coef = corrcoef(tmp');
        mapping = sort_by_coef(coef, width, height);
    end

    %% update the data matrix and ground truth according to the mapping
    for f = [1:num_frames]
        data(:,:,f) = map_matrix(data(:,:,f), mapping);

        %% update ground truth
        new_ind = find_mapping_ind(raw_gt_frame{f}, width, height, mapping);
        if f == 1
            gt_tmp = new_ind;
        else
            gt_tmp = [gt_tmp, (new_ind + (f-1) * width * height)];
        end
    end

    ground_truth(1, :) = gt_tmp;

    if DEBUG1, fprintf('  size of ground truth: %d, %d\n', size(ground_truth)); end
    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end
    

    compared_data = data;
    
    %% --------------------
    %% DCT to get clean frame for the first frame 
    %% --------------------
    if ismember(option_dect, [3])
        for w = [1:num_blocks(1)]
            w_s = (w-1)*block_width + 1;
            w_e = min(w*block_width, width);
            for h = [1:num_blocks(2)]
                h_s = (h-1)*block_height + 1;
                h_e = min(h*block_height, height);

                tmp = mirt_dctn(data(w_s:w_e, h_s:h_e, 1));
                tmp = round(tmp ./ quantization) .* quantization;
                compared_data(w_s:w_e, h_s:h_e, 1) = mirt_idctn(tmp);
            end
        end
    end


    %% --------------------
    %% calculate the difference from the previous frame
    %% --------------------
    if DEBUG2, fprintf('calculate the difference from the previous frame\n'); end

    for frame = [1:num_frames]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        for w = [1:num_blocks(1)]
            w_s = (w-1)*block_width + 1;
            w_e = min(w*block_width, width);
            for h = [1:num_blocks(2)]
                h_s = (h-1)*block_height + 1;
                h_e = min(h*block_height, height);
                if DEBUG3, fprintf('  block: [%d,%d]\n', w, h); end
                
                this_block = zeros(block_width, block_height);
                this_block(1:(w_e-w_s+1), 1:(h_e-h_s+1)) = data(w_s:w_e, h_s:h_e, frame);
                meanX2 = mean(reshape(this_block, [], 1).^2);
                meanX = mean(reshape(this_block, [], 1));

                %% ------------
                %% find the best fit block in the specified frames
                min_delta = -1;
                for ci = [1:length(option_frames)]
                    if DEBUG3, fprintf('    compare f:%d, b:%d\n', option_frames(ci), option_blocks(ci)); end

                    comp_frame = frame + option_frames(ci);
                    if (frame == 1) & (comp_frame < 1)
                        comp_frame = 1;
                    end

                    if (comp_frame < 1) | (comp_frame > num_frames)
                        continue;
                    end

                    [w2s, h2s] = find_block_ind(w, h, num_blocks, option_blocks(ci));
                    if DEBUG0, fprintf('    w2s:%d, h2s:%d\n', length(w2s), length(h2s)); end

                    for ind2 = [1:length(w2s)]
                        w2 = w2s(ind2);
                        w2_s = (w2-1)*block_width + 1;
                        w2_e = min(w2*block_width, width);

                        h2 = h2s(ind2);
                        h2_s = (h2-1)*block_height + 1;
                        h2_e = min(h2*block_height, height);

                        if (comp_frame == frame) & (w2 == w) & (h2 == h) & (frame ~= 1)
                            continue;
                        end

                        if DEBUG3
                            fprintf('    - f%d blocks [%d,%d], w=%d-%d, h=%d-%d\n', comp_frame, w2, h2, w2_s, w2_e, h2_s, h2_e);
                        end

                        prev_block = zeros(block_width, block_height);
                        prev_block(1:(w2_e-w2_s+1), 1:(h2_e-h2_s+1)) = compared_data(w2_s:w2_e, h2_s:h2_e, comp_frame);

                        delta = prev_block - this_block;

                        if option_delta == 1
                            this_delta = mean(abs(delta(:)));
                        elseif option_delta == 2
                            this_delta = mean(delta(:).^2)/meanX2;
                        elseif option_delta == 3
                            this_delta = mean(abs(delta(:)))/meanX;
                        else
                            this_delta = -1;
                        end

                        if this_delta < 0
                            fprintf('!!!!!should not < 0!!!!\n'); 
                            % tp = -1; tn = -1; fp = -1; fn = -1; precision = -1; recall = -1; f1score = -1;
                            return;
                        end

                        if this_delta < min_delta | min_delta == -1
                            min_delta = this_delta;
                            min_delta_block = prev_block;
                            min_w = w2;
                            min_h = h2;
                            min_f = comp_frame;
                        end
                    end
                end
                if DEBUG0, fprintf('    frame %d block (%d, %d) with min delta = %f\n', min_f, min_w, min_h, min_delta); end
                %% end find the best fit block in the previous frame
                %% ------------

                this_frame(w_s:w_e, h_s:h_e) = min_delta_block(1:(w_e-w_s+1), 1:(h_e-h_s+1));
            end
        end


        %% ------------
        %% detect anomaly
        err_ts = abs(reshape(data(:,:,frame),[],1) - this_frame(:));
        this_frame_err_ind = find(err_ts > thresh);
        if frame == 1
            detect_err_ind = this_frame_err_ind;
        else
            detect_err_ind = [detect_err_ind; this_frame_err_ind + (frame-1)*width*height];
        end
        if DEBUG1, fprintf('    size of detect err = %d, %d\n', size(detect_err_ind)); end
        
        
        if ismember(option_dect, [2, 3])
            nomal_frame = compared_data(:, : , frame);
            nomal_frame(this_frame_err_ind) = this_frame(this_frame_err_ind);
            compared_data(:, : , frame) = nomal_frame;
        end
    end


    tps = intersect(ground_truth(1, :), detect_err_ind);
    tp = size(tps, 2);
    fps = setdiff(detect_err_ind, ground_truth(1, :));
    fp = size(fps, 2);
    fns = setdiff(ground_truth(1, :), detect_err_ind);
    fn = size(fns, 2);
    tn = size(err_ts(:, 1), 1) - tp - fp - fn;
    
    precision = tp / (tp + fp);
    recall = tp / (tp + fn);
    f1score = 2 * precision * recall / (precision + recall);
end



function [w2s, h2s] = find_block_ind(w, h, num_blocks, blocks)
    % fprintf('find block ind: w=%d, h=%d, nw=%d, nh=%d, blocks=%d', w, h, num_blocks, blocks);
    
    if blocks == -1
        w2s = [1:num_blocks(1)];
        h2s = [1:num_blocks(2)];
        return;
    else
        if blocks >= 0
            w2s = [w];
            h2s = [h];
        end

        if blocks >= 1
            if w > 1
                w2s = [w2s, w-1];
                h2s = [h2s, h];
            end
        end

        if blocks >= 2
            if h < num_blocks(2)
                w2s = [w2s, w];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 3
            if w < num_blocks(1)
                w2s = [w2s, w+1];
                h2s = [h2s, h];
            end
        end

        if blocks >= 4
            if h > 1
                w2s = [w2s, w];
                h2s = [h2s, h-1];
            end
        end

        if blocks >= 5
            if w > 1 & h < num_blocks(2)
                w2s = [w2s, w-1];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 6
            if w < num_blocks(1) & h < num_blocks(2)
                w2s = [w2s, w+1];
                h2s = [h2s, h+1];
            end
        end

        if blocks >= 7
            if w < num_blocks(1) & h > 1
                w2s = [w2s, w+1];
                h2s = [h2s, h-1];
            end
        end

        if blocks >= 8
            if w > 1 & h > 1
                w2s = [w2s, w-1];
                h2s = [h2s, h-1];
            end
        end
    end
end


%% -------------------------------------
%% map_matrix: swap row and columns according to "mapping"
%% @input mapping: 
%%    a vector to map venues to the other
%%    e.g. [4, 3, 1, 2] means mapping 1->4, 2->3, 3->1, 4->2
%%
function [new_mat] = map_matrix(mat, mapping)
    new_mat = zeros(size(mat));
    new_mat(mapping, :) = mat;
    tmp = new_mat;
    new_mat(:, mapping) = tmp;
end


%% find_ind: function description
function [map_ind] = find_mapping_ind(ind, width, height, mapping)
    y = mod(ind-1, height) + 1;
    x = floor((ind-1)/height) + 1;

    x2 = mapping(x);
    y2 = mapping(y);
    map_ind = (x2 - 1) * height + y2;
end


%% -------------------------------------
%% sort_by_lat_lng
%% @input location: 
%%    a Nx2 matrix to represent the (lat, lng) of N venues
%%
function [mapping] = sort_by_lat_lng(location, width, height)
    mapping = ones(1, width);
    tmp = 2:width;
    src = 1;
    src_ind = 2;
    while length(tmp) > 0
        min_dist = -1;
        min_dist_dst = 0;
        min_dist_ind = 0;

        ind = 0;
        for dst = tmp
            ind = ind + 1;
            dist = pos2dist(location(src,1), location(src,2), location(dst,1), location(dst,2), 2);

            if (min_dist == -1) | (min_dist > dist) 
                min_dist = dist;
                min_dist_dst = dst;
                min_dist_ind = ind;
            end
        end

        if tmp(min_dist_ind) ~= min_dist_dst
            fprintf('min dist dst does not match: %d, %d\n', tmp(min_dist_ind), min_dist_dst);
            return;
        end

        mapping(src_ind) = min_dist_dst;
        src = min_dist_dst;
        src_ind = src_ind + 1;
        tmp(min_dist_ind) = [];
    end
end


%% -------------------------------------
%% sort_by_coef
%% @input coef: 
%%    a NxN matrix to represent the correlation coefficient of N venues
%%
function [mapping] = sort_by_coef(coef, width, height)
    mapping = ones(1, width);
    tmp = 2:width;
    src = 1;
    src_ind = 2;
    while length(tmp) > 0
        max_coef = -1;
        max_coef_dst = 0;
        max_coef_ind = 0;

        ind = 0;
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
            return;
        end

        mapping(src_ind) = max_coef_dst;
        src = max_coef_dst;
        src_ind = src_ind + 1;
        tmp(max_coef_ind) = [];
    end
end