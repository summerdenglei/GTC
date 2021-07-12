%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.11.07 @ UT Austin
%%
%% - Input:
%%   @option_delta: options to calculate delta
%%      'diff': sum of absolute diff
%%      'mse': mean square error (MSE)
%%      'mae': mean absolute error (MAE)
%%   @option_scope: 
%%      'local' : for each block, find k blocks from candidate blocks 
%%                 whose linear combination minimizes the MSE to the current block.
%%      'global': Find k blocks from candidate blocks whose linear combination minimizes MSE to all blocks. 
%%   @option_sel_method:
%%      'lc': select blocks whose linear combination minimize MSE
%%      'mse': select blocks whose MSE is smallest
%%      'mae': select blocks whose MAE is smallest
%%      'dct': select blocks whose DCT's MSE (only need the first few elements) is smallest
%%      'cc': select blocks whose CC is highest
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      'org': original matrix
%%      'rand': randomize raw and col
%%      'geo': geo -- can only be used by 4sq TM matrix
%%      'cc': correlation coefficient
%%   @option_fill_in:
%%      'fill': fill in the missing values
%%      'no_fill': skip the missing values
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
%%     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.', 8, 217, 400, 22, 40, 16, 'diff', 'local', 'dct', 'org', 'fill', 'elem', 'ind', 0.2, 0.5, 1, 1)
%%     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.002.bin60.sub.', 24, 120, 100, 12, 10, 16, 'diff', 'local', 'dct', 'org', 'no_fill', 'elem', 'ind', 0.2, 0.5, 1, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc, ratio] = mpeg_lc_based_pred(input_TM_dir, filename, num_frames, width, height, block_width, block_height, num_sel_blocks, option_delta, option_scope, option_sel_method, option_swap_mat, option_fill_in, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed)
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils/zigzag');
    addpath('/u/yichao/anomaly_compression/utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    warning off;
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    DEBUG4 = 0; %% global
    DEBUG5 = 0; %% running time
    DEBUG6 = 0; %% local, opt_sel_method=1
    DEBUG_WRITE = 0;
    DEBUG_SEL_BLOCK = 0;

    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end

    % a = reshape([1:12], 3, 4)
    % b = mirt_dctn(a)
    % c = zigzag(b)
    % error('stop');


    %% --------------------
    %% Constant
    %% --------------------
    group_size = 4;
    num_groups = ceil(num_frames / group_size);
    num_dct_element = ceil(block_width * block_height / 2);
    ele_size = 32;  %% size of each elements in bits


    %% --------------------
    %% Variable
    %% --------------------
    output_dir = './tmp_output/';
    space = 0;


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    
    num_blocks = [ceil(height/block_height), ceil(width/block_width)];
    
    if strcmp(option_scope, 'local') == 1
        %% local
        stat_sel_bit_map = zeros(2*(num_blocks(1)-1)+1, 2*(num_blocks(2)-1)+1, 2*(num_frames-1)+1);
    elseif strcmp(option_scope, 'global') == 1
        %% global
        stat_sel_bit_map = zeros(num_blocks(1), num_blocks(2), group_size);
    else
        error('wrong option_scope');
    end
        


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
        data(:,:,frame+1) = tmp(1:height, 1:width);
    end
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    % M = ones(size(data));
    % if drop_rate > 0
    %     %% prediction
    %     num_missing = ceil(nx * drop_rate);
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
    % exit;
            


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
    elseif strcmp(option_swap_mat, 'rand') == 1
        %% 1: randomize raw and col
        mapping_rows = randperm(height);
        mapping_cols = randperm(width);
    elseif strcmp(option_swap_mat, 'geo') == 1
        %% 2: geo -- only for 4sq TM
        % [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
        % if DEBUG0
        %     fprintf('  size of location: %d, %d\n', size(location));
        %     fprintf('  size of mass: %d, %d\n', size(mass));
        % end
        
        % mapping = sort_by_lat_lng(location, width, height);

    elseif strcmp(option_swap_mat, 'cc') == 1
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

    elseif strcmp(option_swap_mat, 'pop') == 1
        %% 4: popularity
        error('swap according to popularity: not done yet\n');

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
    %% for each block, find the linear combination of other blocks
    %% --------------------
    if DEBUG2, fprintf('for each block, find the linear combination of other blocks\n'); end

    sel_bit_map = zeros(num_frames, num_blocks(1), num_blocks(2));

    if strcmp(option_scope, 'local') == 1
        %% local

        %% --------------------
        %% for each block        
        for f1 = [1:num_frames]
            if DEBUG0, fprintf('  frame %d\n', f1); end

            for w1 = [1:num_blocks(2)]
                w1_s = (w1-1)*block_width + 1;
                w1_e = min(w1*block_width, width);
                for h1 = [1:num_blocks(1)]
                    h1_s = (h1-1)*block_height + 1;
                    h1_e = min(h1*block_height, height);
                    if DEBUG3, fprintf('  block: [%d,%d]\n', h1, w1); end

                    tic;
                    this_block = zeros(block_height, block_width);
                    this_block(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = compared_data(h1_s:h1_e, w1_s:w1_e, f1);
                    this_block_M = zeros(block_height, block_width);
                    this_block_M(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = M(h1_s:h1_e, w1_s:w1_e, f1);
                    elapse = toc;
                    if DEBUG5, fprintf('  copy block time=%f\n', elapse); end


                    %% skip if this block is just 0s
                    if nnz(this_block) == 0
                        % compared_data(h1_s:h1_e, w1_s:w1_e, f1) = 0;
                        continue;
                    end


                    %% DCT
                    if strcmp(option_sel_method, 'dct')
                        this_block_dct = mirt_dctn(this_block);
                        this_block_dct_zigzag = zigzag(this_block_dct);
                        % this_block_dct_zigzag(num_dct_element+1:end) = 0;
                        % this_block_dct_izigzag = izigzag(this_block_dct_zigzag, block_height, block_width);
                        % this_block = mirt_idctn(this_block_dct_izigzag);
                    end


                    meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                    meanX = mean(reshape(this_block(this_block_M==1), [], 1));


                    %% for linear regression
                    objective   = reshape(this_block, [], 1);
                    objective_M = reshape(this_block_M, [], 1);
                    predictors   = [];
                    predictors_M = [];


                    f_s = max(1, f1-2);
                    f_e = min(num_frames, f1+2);
                    this_num_sel_blocks = min(num_sel_blocks, (f_e-f_s+1)*prod(num_blocks));

                    this_sel_bit_map = zeros(num_frames, num_blocks(1), num_blocks(2));

                    if strcmp(option_sel_method, 'lc')
                        %% --------------------
                        %% 0: select blocks whose linear combination minimize MSE
                        %% --------------------


                        %% ------------
                        %% Among "candidate blocks", Select "num_sel_blocks" blocks 
                        %%   whose linear combination minimizes the MSE/MAE to the current block
                        %% Candidate blocks: all blocks in previous 2 ~ next 2 frames
                        %% Greedy algorithm: find one block at a time
                        for k = [1:this_num_sel_blocks] 

                            %% running time
                            tic_k = tic;
                            regress_time = 0;

                            
                            min_delta = -1;    
                            min_predictors = [];
                            min_predictors_M = [];
                            min_f = -1;
                            min_w = -1;
                            min_h = -1;
                            %% --------------------
                            %% among candidate blocks
                            for f2 = [f_s:f_e]
                                for w2 = [1:num_blocks(2)]
                                    w2_s = (w2-1)*block_width + 1;
                                    w2_e = min(w2*block_width, width);
                                    for h2 = [1:num_blocks(1)]
                                        %% skip the current block
                                        if (f2 == f1) & (w2 == w1) & (h2 == h1)
                                            continue;
                                        end
                                        %% skip blocks which have been selected
                                        if this_sel_bit_map(f2, h2, w2) == 1
                                            continue;
                                        end

                                        h2_s = (h2-1)*block_height + 1;
                                        h2_e = min(h2*block_height, height);
                                        if DEBUG0, fprintf('    candidate block: [%d,%d]\n', h2, w2); end

                                        cand_block = zeros(block_height, block_width);
                                        cand_block(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = compared_data(h2_s:h2_e, w2_s:w2_e, f2);
                                        cand_block_M = zeros(block_height, block_width);
                                        cand_block_M(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = M(h2_s:h2_e, w2_s:w2_e, f2);
                                        

                                        %% for linear regression
                                        this_predictors   = reshape(cand_block, [], 1);
                                        this_predictors_M = reshape(cand_block_M, [], 1);
                                        tmp_predictors   = [predictors, this_predictors];
                                        tmp_predictors_M = [predictors_M, this_predictors_M];


                                        tic;
                                        if strcmp(option_fill_in, 'fill')
                                            [coefficients, bint, residuals] = regress(objective, tmp_predictors);
                                            residuals(isnan(residuals)) = 0;  %% just in case..
                                        elseif strcmp(option_fill_in, 'no_fill')

                                            %% find rows with all 1s
                                            num = size(tmp_predictors, 2) + 1;
                                            ix = find(sum([objective_M, tmp_predictors_M], 2) == num);
                                            
                                            if length(ix) == 0
                                                residuals = abs(objective);
                                            else
                                                no_fill_obj = objective(ix);
                                                no_fill_prd = tmp_predictors(ix, :);
                                                [coefficients, bint, residuals] = regress(no_fill_obj, no_fill_prd);
                                                residuals(isnan(residuals)) = 0;  %% just in case..    
                                            end
                                        elseif strcmp(option_fill_in, 'fill_est')
                                            ix = find(objective_M == 1);
                                            
                                            if length(ix) == 0
                                                residuals = abs(objective);
                                            else
                                                no_fill_obj = objective(ix);
                                                no_fill_prd = tmp_predictors(ix, :);
                                                [coefficients, bint, residuals] = regress(no_fill_obj, no_fill_prd);
                                                residuals(isnan(residuals)) = 0;  %% just in case..    
                                            end
                                        else
                                            error('wrong option fill in');
                                        end 
                                        elapse = toc; 
                                        regress_time = regress_time + elapse;
                                        if DEBUG0, fprintf('    regress time=%f\n', elapse); end

                                        
                                        if strcmp(option_delta, 'diff') == 1
                                            this_delta = mean(abs(residuals));
                                        elseif strcmp(option_delta, 'mse') == 1
                                            this_delta = mean(residuals.^2)/meanX2;
                                        elseif strcmp(option_delta, 'mae') == 1
                                            this_delta = mean(abs(residuals))/meanX;
                                        else
                                            error(['wrong option delta: ' option_delta]);
                                        end

                                        if (this_delta < min_delta) | (min_delta < 0)
                                            min_delta = this_delta;
                                            min_predictors = this_predictors;
                                            min_predictors_M = this_predictors_M;
                                            min_f = f2;
                                            min_w = w2;
                                            min_h = h2;
                                        end
                                    end
                                end
                            end  %% end among all candidates

                            %% have searched all candidate blocks
                            if size(min_predictors, 1) == 0
                                %% cannot find one more block whose residuals are smaller
                                % error('should find at least one block...');
                                break;
                            else
                                %% residuals are smaller
                                predictors   = [predictors, min_predictors];
                                predictors_M = [predictors_M, min_predictors_M];
                                this_sel_bit_map(min_f, min_h, min_w) = 1;

                                sel_bit_map(min_f, min_h, min_w) = 1;
                            end

                            elapse = toc(tic_k);
                            if DEBUG5, fprintf('    block %d time=%f\n', k, elapse); end
                            if DEBUG5, fprintf('     regress time=%f\n', regress_time); end
                        end  %% end of num_sel_blocks

                    else
                        %% --------------------
                        %% elsif option_sel_method == 'mse', 'mae', 'dct', 'cc', ...
                        %% --------------------
                        
                        %% --------------------
                        %% among candidate blocks, 
                        %%   find blocks with smallest MSE/MAE/etc.
                        err_bit_map = zeros(num_blocks(1), num_blocks(2), f_e-f_s+1);
                        err_bit_map(h1, w1, f1-f_s+1) = Inf;  %% shouldn't select itself
                        
                        for f2 = [f_s:f_e]
                            for w2 = [1:num_blocks(2)]
                                w2_s = (w2-1)*block_width + 1;
                                w2_e = min(w2*block_width, width);
                                for h2 = [1:num_blocks(1)]
                                    %% skip the current block
                                    if (f2 == f1) & (w2 == w1) & (h2 == h1)
                                        continue;
                                    end
                                    
                                    h2_s = (h2-1)*block_height + 1;
                                    h2_e = min(h2*block_height, height);
                                    if DEBUG0, fprintf('    candidate block: [%d,%d]\n', h2, w2); end

                                    cand_block = zeros(block_height, block_width);
                                    cand_block(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = compared_data(h2_s:h2_e, w2_s:w2_e, f2);
                                    cand_block_M = zeros(block_height, block_width);
                                    cand_block_M(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = M(h2_s:h2_e, w2_s:w2_e, f2);
                                    
                                    if strcmp(option_sel_method, 'mse') == 1
                                        %% --------------------
                                        %% 1: select blocks whose MSE is smallest
                                        %% --------------------
                                        if strcmp(option_fill_in, 'fill')
                                            this_delta = this_block(:) - cand_block(:);
                                        elseif strcmp(option_fill_in, 'no_fill')
                                            this_delta = reshape(this_block(this_block_M==1 & cand_block_M==1) - cand_block(this_block_M==1 & cand_block_M==1), [], 1);
                                        elseif strcmp(option_fill_in, 'fill_est')
                                            this_delta = reshape(this_block(this_block_M==1) - cand_block(this_block_M==1), [], 1);
                                        else
                                            error('wrong option fill in');
                                        end

                                        err_bit_map(h2, w2, f2-f_s+1) = mean(this_delta.^2) / meanX2;

                                    elseif strcmp(option_sel_method, 'mae') == 1
                                        %% --------------------
                                        %% 2: select blocks whose MAE is smallest
                                        %% --------------------
                                        if strcmp(option_fill_in, 'fill')
                                            this_delta = this_block(:) - cand_block(:);
                                        elseif strcmp(option_fill_in, 'no_fill')
                                            this_delta = reshape(this_block(this_block_M==1 & cand_block_M==1) - cand_block(this_block_M==1 & cand_block_M==1), [], 1);
                                        elseif strcmp(option_fill_in, 'fill_est')
                                            this_delta = reshape(this_block(this_block_M==1) - cand_block(this_block_M==1), [], 1);
                                        else
                                            error('wrong option fill in');
                                        end

                                        err_bit_map(h2, w2, f2-f_s+1) = mean(abs(this_delta)) / meanX;

                                    elseif strcmp(option_sel_method, 'dct') == 1
                                        %% --------------------
                                        %% 3: select blocks whose DCT's MSE (only need the first few elements) is smallest
                                        %% --------------------
                                        cand_block_dct = mirt_dctn(cand_block);
                                        cand_block_dct_zigzag = zigzag(cand_block_dct);
                                        % cand_block_dct_zigzag(num_dct_element+1:end) = 0;
                                        % cand_block_dct_izigzag = izigzag(cand_block_dct_zigzag, block_height, block_width);
                                        % cand_block_idct = mirt_idctn(cand_block_dct_izigzag);
                                        err_bit_map(h2, w2, f2-f_s+1) = mean(abs( cand_block_dct_zigzag(1:num_dct_element) - this_block_dct_zigzag(1:num_dct_element) ));

                                    elseif strcmp(option_sel_method, 'cc') == 1
                                        %% --------------------
                                        %% 4: select blocks whose CC is highest
                                        %% --------------------

                                        error('XXX: option_sel_method == cc\n');

                                    else
                                        error(['wrong option sel methods: ' option_sel_method]);
                                    end
                                end
                            end
                        end


                        %% select blocks has minimal MSE
                        [err_sort, err_ind_sort] = sort(err_bit_map(:));
                        for selected_ind = [1:this_num_sel_blocks]
                            [sel_h, sel_w, sel_f] = ind2sub([num_blocks(1), num_blocks(2), (f_e-f_s+1)], err_ind_sort(selected_ind));
                            
                            if DEBUG6, fprintf('    %d [%d, %d, %d(%d)], err = %f (%f), meanX2=%f\n', err_ind_sort(selected_ind), sel_h, sel_w, sel_f, sel_f+f_s-1, err_bit_map(err_ind_sort(selected_ind)), err_sort(selected_ind), sum(meanX2(:))); end

                            if ((sel_f+f_s-1) == f1) & (sel_h == h1) & (sel_w == w1) 
                                % error('should not here [%d,%d,%d]: %f', sel_f+f_s-1, sel_h, sel_w, err_sort(selected_ind));
                                continue;
                            end

                            sel_w_s = (sel_w-1)*block_width + 1;
                            sel_w_e = min(sel_w*block_width, width);
                            sel_h_s = (sel_h-1)*block_height + 1;
                            sel_h_e = min(sel_h*block_height, height);

                            sel_block = zeros(block_height, block_width);
                            sel_block(1:(sel_h_e-sel_h_s+1), 1:(sel_w_e-sel_w_s+1)) = compared_data(sel_h_s:sel_h_e, sel_w_s:sel_w_e, sel_f+f_s-1);
                            sel_block_M = zeros(block_height, block_width);
                            sel_block_M(1:(sel_h_e-sel_h_s+1), 1:(sel_w_e-sel_w_s+1)) = M(sel_h_s:sel_h_e, sel_w_s:sel_w_e, sel_f+f_s-1);
                            
                            %% linear regression
                            this_predictors   = reshape(sel_block, [], 1);
                            this_predictors_M = reshape(sel_block_M, [], 1);
                            predictors   = [predictors, this_predictors];
                            predictors_M = [predictors_M, this_predictors_M];


                            this_sel_bit_map(sel_f+f_s-1, sel_h, sel_w) = 1;
                            sel_bit_map(sel_f+f_s-1, sel_h, sel_w) = 1;
                        end
                    end  %% end option_scope


                    if DEBUG3
                        ob_size = size(objective);
                        pd_size = size(predictors);
                        fprintf('  frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, w1, h1, ob_size, pd_size); 
                    end


                    %% ------------
                    %% statistics: which blocks are selected?
                    %% ------------
                    for tmp_f = [f_s:f_e]
                        for tmp_h = [1:num_blocks(1)]
                            for tmp_w = [1:num_blocks(2)]
                                if(this_sel_bit_map(tmp_f,tmp_h,tmp_w) == 1)
                                    if (tmp_f == f1) & (tmp_h == h1) & (tmp_w == w1) 
                                        error('shoud not here ..');
                                    end
                                    stat_sel_bit_map(num_blocks(1)+tmp_h-h1, num_blocks(2)+tmp_w-w1, num_frames+tmp_f-f1) = stat_sel_bit_map(num_blocks(1)+tmp_h-h1, num_blocks(2)+tmp_w-w1, num_frames+tmp_f-f1) + 1; 
                                end
                            end
                        end
                    end
                    


                    %% appriximation using regression
                    % if strcmp(option_fill_in, 'fill') | strcmp(option_sel_method, 'dct')
                    %     [coefficients] = regress(objective, predictors);
                    % elseif strcmp(option_fill_in, 'no_fill')
                    %     %% find rows with all 1s
                    %     num = size(predictors, 2) + 1;
                    %     ix = find(sum([objective_M, predictors_M], 2) == num);
                        
                    %     no_fill_obj = objective(ix);
                    %     no_fill_prd = predictors(ix, :);
                    %     [coefficients] = regress(no_fill_obj, no_fill_prd);
                    % elseif strcmp(option_fill_in, 'fill_est')
                    %     %% find rows with all 1s
                    %     ix = find(objective_M == 1);
                        
                    %     no_fill_obj = objective(ix);
                    %     no_fill_prd = predictors(ix, :);
                    %     [coefficients] = regress(no_fill_obj, no_fill_prd);
                    % else
                    %     error('wrong option fill in');
                    % end
                    [coefficients] = regress(objective, predictors);


                            
                    if DEBUG3
                        fprintf('  coeff: ');
                        fprintf('%f, ', coefficients);
                        fprintf('\n');
                    end


                    if length(find(predictors == NaN)) > 0
                        error('predictor contain NaN');
                    end
                    predictors(predictors == NaN) = 0;
                    appoximate = zeros(size(objective));
                    for ind = [1:length(coefficients)]
                        appoximate = appoximate + coefficients(ind) * predictors(:, ind);
                    end
                    appoximate = reshape(appoximate, block_height, block_width);

                    if elem_frac > 0
                        %% prediction
                        %% update the missing elements of this_block in compared_data    
                        tmp = this_block;
                        tmp(~this_block_M) = appoximate(~this_block_M);
                        compared_data(h1_s:h1_e, w1_s:w1_e, f1) = tmp(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1));
                    else
                        %% compression
                        compared_data(h1_s:h1_e, w1_s:w1_e, f1) = appoximate(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1));
                    end
                end
            end
        end  %% end for each frame

    %% --------------------------------------------------------------------------------
    %% --------------------------------------------------------------------------------

    elseif strcmp(option_scope, 'global')
        %% global
        
        %% --------------------
        %% Global: select "num_sel_blocks" blocks 
        %%         whose linear combination minimizes the error to "all" blocks
        %% Candidate blocks: all blocks
        %% Greedy: select one block at a time.
        %%         e.g. select one block whose MSE to all blocks is minimal.
        %%              then select the 2nd block, 
        %%                   whose linear combination with the first one block has minimal MSE.
        %% --------------------
        for g = 1:num_groups
            f_s = (g-1)*group_size + 1;
            f_e = min(g*group_size, num_frames);
            if(DEBUG4), fprintf('group %d: frame %d-%d\n', g, f_s, f_e); end

            predictors = [];
            predictors_M = [];
            this_num_sel_blocks = min(num_sel_blocks, (f_e-f_s+1)*prod(num_blocks));


            if strcmp(option_sel_method, 'lc') == 1
                %% --------------------
                %% 0: select blocks whose linear combination minimize MSE
                %% --------------------

                for k = [1:this_num_sel_blocks]

                    min_delta = -1;
                    min_predictors   = [];
                    min_predictors_M = [];
                    min_f = -1;
                    min_w = -1;
                    min_h = -1;
            
                    %% --------------------
                    %% among candidate blocks: 
                    for f2 = [f_s:f_e]
                        for w2 = [1:num_blocks(2)]
                            w2_s = (w2-1)*block_width + 1;
                            w2_e = min(w2*block_width, width);
                            for h2 = [1:num_blocks(1)]
                                %% skip blocks which have been selected
                                if sel_bit_map(f2, h2, w2) == 1
                                    continue;
                                end

                                h2_s = (h2-1)*block_height + 1;
                                h2_e = min(h2*block_height, height);
                                if DEBUG4, fprintf('  candidate block: %d [%d,%d]\n', f2, h2, w2); end

                                cand_block = zeros(block_height, block_width);
                                cand_block(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = compared_data(h2_s:h2_e, w2_s:w2_e, f2);
                                cand_block_M = zeros(block_height, block_width);
                                cand_block_M(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = M(h2_s:h2_e, w2_s:w2_e, f2);
                                

                                %% skip if this block is just 0s
                                if nnz(cand_block) == 0
                                    continue;
                                end


                                %% for linear regression
                                this_predictors   = reshape(cand_block, [], 1);
                                this_predictors_M = reshape(cand_block_M, [], 1);
                                tmp_predictors   = [predictors, this_predictors];
                                tmp_predictors_M = [predictors_M, this_predictors_M];

                                
                                %% --------------------
                                %% calculate error if adding this candidate block
                                this_delta = 0;
                                for f1 = [f_s:f_e]
                                    for w1 = [1:num_blocks(2)]
                                        w1_s = (w1-1)*block_width + 1;
                                        w1_e = min(w1*block_width, width);
                                        for h1 = [1:num_blocks(1)]
                                            %% skip blocks which have been selected, b/c the error will be 0
                                            if sel_bit_map(f1, h1, w1) == 1
                                                continue;
                                            end
                                            %% skip currnet candidate blocks
                                            if (f1 == f2) & (w1 == w2) & (h1 == h2)
                                                continue;
                                            end

                                            h1_s = (h1-1)*block_height + 1;
                                            h1_e = min(h1*block_height, height);

                                            this_block = zeros(block_height, block_width);
                                            this_block(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = compared_data(h1_s:h1_e, w1_s:w1_e, f1);
                                            this_block_M = zeros(block_height, block_width);
                                            this_block_M(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = M(h1_s:h1_e, w1_s:w1_e, f1);
                                            

                                            %% skip if this block is just 0s
                                            if nnz(this_block) == 0
                                                continue;
                                            end


                                            meanX2 = mean(this_block(:).^2);
                                            meanX = mean(this_block(:));

                                            
                                            %% for linear regression
                                            objective   = reshape(this_block, [], 1);
                                            objective_M = reshape(this_block_M, [], 1);


                                            if DEBUG0
                                                ob_size = size(objective);
                                                pd_size = size(tmp_predictors);
                                                fprintf('    frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, h1, w1, ob_size, pd_size); 
                                            end


                                            if strcmp(option_fill_in, 'fill')
                                                [coefficients, bint, residuals] = regress(objective, tmp_predictors);
                                                residuals(isnan(residuals)) = 0;  %% just in case
                                            elseif strcmp(option_fill_in, 'no_fill')
                                                %% find rows with all 1s
                                                num = size(tmp_predictors, 2) + 1;
                                                ix = find(sum([objective_M, tmp_predictors_M], 2) == num);
                                                
                                                no_fill_obj = objective(ix);
                                                no_fill_prd = tmp_predictors(ix, :);
                                                [coefficients, bint, residuals] = regress(no_fill_obj, no_fill_prd);
                                            elseif strcmp(option_fill_in, 'fill_est')
                                                ix = find(objective_M == 1);
                                                
                                                no_fill_obj = objective(ix);
                                                no_fill_prd = tmp_predictors(ix, :);
                                                [coefficients, bint, residuals] = regress(no_fill_obj, no_fill_prd);
                                            else
                                                error('wrong option fill in');
                                            end


                                            if strcmp(option_delta, 'diff') == 1
                                                this_delta = this_delta + mean(abs(residuals));
                                            elseif strcmp(option_delta, 'mse') == 1
                                                this_delta = this_delta + mean(residuals.^2)/meanX2;
                                            elseif strcmp(option_delta, 'mae') == 1
                                                this_delta = this_delta + mean(abs(residuals))/meanX;
                                            else
                                                error(['wrong option delta: ' option_delta]);
                                            end
                                            if(DEBUG0), fprintf('    err %f\n', this_delta); end
                                        end
                                    end
                                end
                                %% end calculate error if adding this candidate block
                                %% --------------------

                                % if(DEBUG4), fprintf('    err %f\n', this_delta); end

                                if (this_delta < min_delta) | (min_delta < 0)
                                    min_delta = this_delta;
                                    min_predictors   = this_predictors;
                                    min_predictors_M = this_predictors_M;
                                    min_f = f2;
                                    min_w = w2;
                                    min_h = h2;
                                end
                            end
                        end
                    end  %% end for each f2


                    %% have searched all candidate blocks
                    if min_delta < 0
                        %% no more non 0 blocks
                        % error('should find at least one block...');
                        break;
                    else
                        %% residuals are smaller
                        predictors   = [predictors, min_predictors];
                        predictors_M = [predictors_M, min_predictors_M];
                        sel_bit_map(min_f, min_h, min_w) = 1;

                        if(DEBUG4), fprintf('  > %d select %d [%d, %d]: err=%f\n', k, min_f, min_h, min_w, min_delta); end
                    end

                end  %% end for k "sel_num_blocks"
            else
                %% --------------------
                %% elsif option_sel_method == 'mse', 'mae', 'dct', 'cc', ...
                %% --------------------

                %% --------------------
                %% among candidate blocks:
                err_bit_map = zeros(num_blocks(1), num_blocks(2), f_e-f_s+1);
                for f2 = [f_s:f_e]
                    for w2 = [1:num_blocks(2)]
                        w2_s = (w2-1)*block_width + 1;
                        w2_e = min(w2*block_width, width);
                        for h2 = [1:num_blocks(1)]
                            h2_s = (h2-1)*block_height + 1;
                            h2_e = min(h2*block_height, height);
                            if DEBUG4, fprintf('  candidate block: %d [%d,%d]\n', f2, h2, w2); end

                            cand_block = zeros(block_height, block_width);
                            cand_block(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = compared_data(h2_s:h2_e, w2_s:w2_e, f2);
                            cand_block_M = zeros(block_height, block_width);
                            cand_block_M(1:(h2_e-h2_s+1), 1:(w2_e-w2_s+1)) = M(h2_s:h2_e, w2_s:w2_e, f2);
                            

                            %% skip if this block is just 0s
                            if nnz(cand_block) == 0
                                err_bit_map(h2, w2, f2-f_s+1) = Inf;
                                continue;
                            end


                            %% DCT
                            if strcmp(option_sel_method, 'dct') == 1
                                cand_block_dct = mirt_dctn(cand_block);
                                cand_block_dct_zigzag = zigzag(cand_block_dct);
                                % cand_block_dct_zigzag(num_dct_element+1:end) = 0;
                                % cand_block_dct_izigzag = izigzag(cand_block_dct_zigzag, block_height, block_width);
                                % cand_block_idct = mirt_idctn(cand_block_dct_izigzag);
                            end


                            %% --------------------
                            %% calculate error of this candidate block to all blocks
                            for f1 = [f_s:f_e]
                                for w1 = [1:num_blocks(2)]
                                    w1_s = (w1-1)*block_width + 1;
                                    w1_e = min(w1*block_width, width);
                                    for h1 = [1:num_blocks(1)]
                                        %% skip blocks which have been selected, b/c the error will be 0
                                        if sel_bit_map(f1, h1, w1) == 1
                                            continue;
                                        end
                                        %% skip currnet candidate blocks
                                        if (f1 == f2) & (w1 == w2) & (h1 == h2)
                                            continue;
                                        end

                                        h1_s = (h1-1)*block_height + 1;
                                        h1_e = min(h1*block_height, height);

                                        this_block = zeros(block_height, block_width);
                                        this_block(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = compared_data(h1_s:h1_e, w1_s:w1_e, f1);
                                        this_block_M = zeros(block_height, block_width);
                                        this_block_M(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = M(h1_s:h1_e, w1_s:w1_e, f1);
                                        

                                        %% skip if this block is just 0s
                                        if nnz(this_block) == 0
                                            continue;
                                        end


                                        if strcmp(option_sel_method, 'mse') == 1
                                            %% --------------------
                                            %% 1: select blocks whose MSE is smallest
                                            %% --------------------
                                            if strcmp(option_fill_in, 'fill')
                                                this_delta = this_block(:) - cand_block(:);
                                                meanX2 = mean(this_block(:).^2);
                                            elseif strcmp(option_fill_in, 'no_fill')
                                                this_delta = reshape(this_block(this_block_M==1 & cand_block_M==1) - cand_block(this_block_M==1 & cand_block_M==1), [], 1);
                                                meanX2 = mean(reshape(this_block(this_block_M==1 & cand_block_M==1), [], 1).^2);
                                            elseif strcmp(option_fill_in, 'fill_est')
                                                this_delta = reshape(this_block(this_block_M==1) - cand_block(this_block_M==1), [], 1);
                                                meanX2 = mean(reshape(this_block(this_block_M==1), [], 1).^2);
                                            else
                                                error('wrong option fill in');
                                            end

                                            
                                            err_bit_map(h2, w2, f2-f_s+1) = err_bit_map(h2, w2, f2-f_s+1) + mean(this_delta.^2) / meanX2;

                                        elseif strcmp(option_sel_method, 'mae') == 1
                                            %% --------------------
                                            %% 2: select blocks whose MAE is smallest
                                            %% --------------------
                                            if strcmp(option_fill_in, 'fill')
                                                this_delta = this_block(:) - cand_block(:);
                                                meanX = mean(this_block(:));
                                            elseif strcmp(option_fill_in, 'no_fill')
                                                this_delta = reshape(this_block(this_block_M==1 & cand_block_M==1) - cand_block(this_block_M==1 & cand_block_M==1), [], 1);
                                                meanX = mean(reshape(this_block(this_block_M==1 & cand_block_M==1), [], 1));
                                            elseif strcmp(option_fill_in, 'fill_est')
                                                this_delta = reshape(this_block(this_block_M==1) - cand_block(this_block_M==1), [], 1);
                                                meanX = mean(reshape(this_block(this_block_M==1), [], 1));
                                            else
                                                error('wrong option fill in');
                                            end

                                            err_bit_map(h2, w2, f2-f_s+1) = err_bit_map(h2, w2, f2-f_s+1) + mean(abs(this_delta)) / meanX;

                                        elseif strcmp(option_sel_method, 'dct') == 1
                                            %% --------------------
                                            %% 3: select blocks whose DCT's MSE (only need the first few elements) is smallest
                                            %% --------------------
                                            this_block_dct = mirt_dctn(this_block);
                                            this_block_dct_zigzag = zigzag(this_block_dct);
                                            % this_block_dct_zigzag(num_dct_element+1:end) = 0;
                                            % this_block_dct_izigzag = izigzag(this_block_dct_zigzag, block_height, block_width);
                                            % this_block_idct = mirt_idctn(this_block_dct_izigzag);
                                            err_bit_map(h2, w2, f2-f_s+1) = err_bit_map(h2, w2, f2-f_s+1) + mean(abs( cand_block_dct_zigzag(1:num_dct_element) - this_block_dct_zigzag(1:num_dct_element) ));

                                        elseif strcmp(option_sel_method, 'cc') == 1
                                            %% --------------------
                                            %% 4: select blocks whose CC is highest
                                            %% --------------------

                                        else
                                            error(['wrong option sel methods: ' option_sel_method]);

                                        end  %% end if option_sel_method == mse, mae, dct, cc, ...

                                    end
                                end
                            end  %% end for all frames in this GoP
                        end
                    end
                end  %% end for all frames in this GoP


                %% select blocks has minimal MSE
                [err_sort, err_ind_sort] = sort(err_bit_map(:));
                for selected_ind = [1:min(this_num_sel_blocks, length(err_sort))]
                    [sel_h, sel_w, sel_f] = ind2sub([num_blocks(1), num_blocks(2), (f_e-f_s+1)], err_ind_sort(selected_ind));
                    
                    if DEBUG4, fprintf('    %d [%d, %d, %d(%d)], err = %f (%f), meanX2=%f\n', err_ind_sort(selected_ind), sel_h, sel_w, sel_f, sel_f+f_s-1, err_bit_map(err_ind_sort(selected_ind)), err_sort(selected_ind), sum(meanX2(:))); end

                    sel_w_s = (sel_w-1)*block_width + 1;
                    sel_w_e = min(sel_w*block_width, width);
                    sel_h_s = (sel_h-1)*block_height + 1;
                    sel_h_e = min(sel_h*block_height, height);

                    sel_block = zeros(block_height, block_width);
                    sel_block(1:(sel_h_e-sel_h_s+1), 1:(sel_w_e-sel_w_s+1)) = compared_data(sel_h_s:sel_h_e, sel_w_s:sel_w_e, sel_f+f_s-1);
                    sel_block_M = zeros(block_height, block_width);
                    sel_block_M(1:(sel_h_e-sel_h_s+1), 1:(sel_w_e-sel_w_s+1)) = M(sel_h_s:sel_h_e, sel_w_s:sel_w_e, sel_f+f_s-1);
                    

                    %% regression
                    this_predictors   = reshape(sel_block, [], 1);
                    this_predictors_M = reshape(sel_block_M, [], 1);
                    predictors   = [predictors, this_predictors];
                    predictors_M = [predictors_M, this_predictors_M];


                    sel_bit_map(sel_f+f_s-1, sel_h, sel_w) = 1;
                end
            end  %% end if option_sel_method
                


            %% --------------------
            %% ok, now we have found the best "num_sel_blocks" blocks which are used to approximate blocks.
            %% next we will calculate the approximation and residuals 
            %% --------------------
            for f1 = [f_s:f_e]
                if DEBUG0, fprintf('  frame %d\n', f1); end

                for w1 = [1:num_blocks(2)]
                    w1_s = (w1-1)*block_width + 1;
                    w1_e = min(w1*block_width, width);
                    for h1 = [1:num_blocks(1)]
                        h1_s = (h1-1)*block_height + 1;
                        h1_e = min(h1*block_height, height);
                        if DEBUG0, fprintf('  block: [%d,%d]\n', h1, w1); end

                        this_block = zeros(block_height, block_width);
                        this_block(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = compared_data(h1_s:h1_e, w1_s:w1_e, f1);
                        this_block_M = zeros(block_height, block_width);
                        this_block_M(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1)) = M(h1_s:h1_e, w1_s:w1_e, f1);
                        

                        %% skip if this block is just 0s
                        if nnz(this_block) == 0
                            % compared_data(h1_s:h1_e, w1_s:w1_e, f1) = 0;
                            continue;
                        end


                        %% for linear regression
                        objective   = reshape(this_block, [], 1);
                        objective_M = reshape(this_block_M, [], 1);


                        if DEBUG3
                            ob_size = size(objective);
                            pd_size = size(predictors);
                            fprintf('  frame=%d(%d,%d): objective=(%d,%d), predictor=(%d,%d)\n', f1, h1, w1, ob_size, pd_size); 
                        end


                        %% approximation using regression
                        % if strcmp(option_fill_in, 'fill') | strcmp(option_sel_method, 'dct')
                        %     [coefficients] = regress(objective, predictors);
                        % elseif strcmp(option_fill_in, 'no_fill')
                        %     %% find rows with all 1s
                        %     num = size(predictors, 2) + 1;
                        %     ix = find(sum([objective_M, predictors_M], 2) == num);
                            
                        %     no_fill_obj = objective(ix);
                        %     no_fill_prd = predictors(ix, :);
                        %     [coefficients] = regress(no_fill_obj, no_fill_prd);
                        % elseif strcmp(option_fill_in, 'fill_est')
                        %     %% find rows with all 1s
                        %     ix = find(objective_M == 1);
                            
                        %     no_fill_obj = objective(ix);
                        %     no_fill_prd = predictors(ix, :);
                        %     [coefficients] = regress(no_fill_obj, no_fill_prd);
                        % else
                        %     error('wrong option fill in');
                        % end
                        [coefficients] = regress(objective, predictors);


                        if length(find(predictors == NaN)) > 0
                            error('predictor contain NaN');
                        end
                        predictors(predictors == NaN) = 0;  %% just in case
                        appoximate = zeros(size(objective));
                        for ind = [1:length(coefficients)]
                            appoximate = appoximate + coefficients(ind) * predictors(:, ind);
                        end
                        appoximate = reshape(appoximate, block_height, block_width);
                        
                        
                        if elem_frac > 0
                            %% prediction
                            %% update the missing elements of this_block in compared_data    
                            this_block(~this_block_M) = appoximate(~this_block_M);
                            compared_data(h1_s:h1_e, w1_s:w1_e, f1) = this_block(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1));
                        else
                            %% compression
                            compared_data(h1_s:h1_e, w1_s:w1_e, f1) = appoximate(1:(h1_e-h1_s+1), 1:(w1_e-w1_s+1));
                        end

                    end
                end
            end  %% end for frames of this GoP
        end  %% end for each GoP
    else
        error(['wrong option_scope: ' option_scope]);
    end


    %% space
    if strcmp(option_sel_method, 'lc') == 1
        %% select blocks whose linear combination minimize MSE
        space = block_width*block_height*length(find(sel_bit_map == 1))*ele_size + prod(num_blocks)*num_frames*num_sel_blocks*ele_size;

    elseif strcmp(option_sel_method, 'mse') == 1
        %% 1: select blocks whose MSE is smallest
        space = block_width*block_height*length(find(sel_bit_map == 1))*ele_size + prod(num_blocks)*num_frames*num_sel_blocks*ele_size;
        
    elseif strcmp(option_sel_method, 'mae') == 1
        %% 2: select blocks whose MAE is smallest
        space = block_width*block_height*length(find(sel_bit_map == 1))*ele_size + prod(num_blocks)*num_frames*num_sel_blocks*ele_size;

    elseif strcmp(option_sel_method, 'dct') == 1
        %% 3: select blocks whose DCT's MAE (only need the first few elements) is smallest
        space = num_dct_element*length(find(sel_bit_map == 1))*ele_size + prod(num_blocks)*num_frames*num_sel_blocks*ele_size;

    elseif strcmp(option_sel_method, 'cc') == 1
        %% 4: select blocks whose CC is highest
        
        error('XXX: select blocks whose CC is highest');
    else
        error(['wrong option sel methods: ' option_sel_method]);
    end
    


    %% --------------------
    %% evaluate the prediction
    %% --------------------
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

    if DEBUG_SEL_BLOCK
        if strcmp(option_scope, 'local') == 1
            %% local
            for f = [1:2*(num_frames-1)+1]
                dlmwrite([output_dir 'tmp.local.' int2str(f) '.txt'], stat_sel_bit_map(:,:,f));
            end
        else
            %% global
            for f = [1:group_size]
                dlmwrite([output_dir 'tmp.global.' int2str(f) '.txt'], stat_sel_bit_map(:,:,f));
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


