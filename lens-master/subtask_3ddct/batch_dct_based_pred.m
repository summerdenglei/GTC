%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.18 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch_dct_based_pred()
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '';
    output_dir = '../processed_data/subtask_3ddct/pred_results/';


    % filename = 'tm_3g_region_all.res0.002.bin60.sub.'; width = 120; height = 100; bw = 12; bh = 10;
    filename = 'tm_3g_region_all.res0.004.bin60.sub.'; width = 60; height = 60; bw = 6; bh = 6;
    output_file = [filename 'results.txt'];



    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end
    fprintf('output: %s\n', [output_dir output_file]);

    %% --------------------
    %% Main starts
    %% --------------------

    fh = fopen([output_dir output_file], 'w');
    fprintf(fh, 'filename, num_frames, width, height, group_size, option_swap_mat, option_type, chunk_width, chunk_height, selcted_chunk, quantization, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed, mse, mae, cc, compression ratio\n');
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% check which selected_chunk is better
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for selected_chunk = [1 3 5 7 10 20 30 50 100 150 200 300]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', 0.4, 0.1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', 0.4, 0.1, 1, 1, mse, mae, cc, ratio);
    end
    selected_chunk = 200;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% check which quantization is better
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for quantization = [0.1 0.2 0.3 0.4 0.5 0.7 1 5 10 20 50 100]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, 30, quantization, 'elem', 'ind', 0.4, 0.1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, 30, quantization, 'elem', 'ind', 0.4, 0.1, 1, 1, mse, mae, cc, ratio);
    end
    quantization = 50;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PureRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for elem_frac = [0.02 0.03 0.05 0.1 0.2 0.4 0.6 0.8]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', elem_frac, 1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', elem_frac, 1, 1, 1, mse, mae, cc, ratio);
    end

    for elem_frac = [0.02 0.03 0.05 0.1 0.2 0.4 0.6 0.8]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'ind', elem_frac, 1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'ind', elem_frac, 1, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxTimeRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    elem_frac = 0.4;
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end

    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxElemSyncLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'syn', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'elem', 'syn', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end

    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'syn', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'elem', 'syn', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% RowRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'row', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'row', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end

    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'row', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'row', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ColRandLoss:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'col', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'chunk', bw, bh, selected_chunk, 10, 'col', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end

    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = dct_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'col', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %s, %s, %d, %d, %d, %f, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, 4, 'org', 'single', bw, bh, selected_chunk, quantization, 'col', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end





    fclose(fh);


end












