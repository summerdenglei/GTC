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

function batch_pca_based_pred()
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
    output_dir = '../processed_data/subtask_pca/pred_results/';
    

    filename = 'tm_3g_region_all.res0.002.bin60.sub.'; width = 120; height = 100;
    % filename = 'tm_3g_region_all.res0.004.bin60.sub.'; width = 60; height = 60;
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
    fprintf(fh, 'filename, num_frames, width, height, block_width, block_height, r, option_swap_mat, option_dim, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed, mse, mae, cc, compression ratio\n');
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% check rank
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for r = [1 2 3 5 7 10 20 30 40 50 60 70 80 90 100]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', 0.4, 0.1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', 0.4, 0.1, 1, 1, mse, mae, cc, ratio);
    end

    r = 60;
    % error('here');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PureRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for elem_frac = [0.01 0.02 0.03 0.05 0.1 0.2 0.4 0.6 0.8]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', elem_frac, 1, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', elem_frac, 1, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxTimeRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    elem_frac = 0.4;
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxElemSyncLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'syn', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'elem', 'syn', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% RowRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'row', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'row', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ColRandLoss:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1:0.1:1]
        [mse, mae, cc, ratio] = pca_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, width, height, r, 'org', '2d', 'col', 'ind', elem_frac, loss_rate, 1, 1);
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, width, height, r, 'org', '2d', 'col', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    fclose(fh);


end












