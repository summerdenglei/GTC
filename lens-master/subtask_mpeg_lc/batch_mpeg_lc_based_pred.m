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

function batch_mpeg_lc_based_pred()
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
    output_dir = '../processed_data/subtask_mpeg_lc/pred_results/';

    filename = 'tm_3g_region_all.res0.002.bin60.sub.'; width = 120; height = 100; bw = 12; bh = 10;
    % filename = 'tm_3g_region_all.res0.004.bin60.sub.'; width = 60; height = 60; bw = 6; bh = 6;
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
    fprintf(fh, 'filename, num_frames, width, height, block_width, block_height, num_sel_blocks, option_delta, option_scope, option_sel_method, option_swap_mat, option_fill_in, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, seed\n');
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% check selected chunk for local
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for num_sel_blocks = [4 8 12 16]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'local', 'dct', 'org', 'no_fill', 'elem', 'ind', 0.4, 0.1, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'local', 'dct', 'org', 'no_fill', 'elem', 'ind', 0.4, 0.1, 1, 1, mse, mae, cc, ratio);
    % end
    

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %% check selected chunk for global
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for num_sel_blocks = [4 8 12 16]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', 0.4, 0.1, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', 0.4, 0.1, 1, 1, mse, mae, cc, ratio);
    % end

    num_sel_blocks = 10;


    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %% check for global -- fill or not
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%
    elem_frac = 0.4;
    % for loss_rate = [0.1 0.2:0.2:1]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    % end

    % %%%%

    % for loss_rate = [0.1 0.2:0.2:1]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'mse', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'mse', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    % end

    % for loss_rate = [0.1 0.2:0.2:1]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'mse', 'org', 'fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'mse', 'org', 'fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    % end


    % for loss_rate = [0.1 0.2:0.2:1]
    %     [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'lc', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1)
    %     fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
    %         filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'lc', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    % end







    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PureRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for elem_frac = [0.02 0.03 0.05 0.1 0.2 0.4 0.6 0.8]
        [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, 1, 1, 1)
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, 1, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxTimeRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    elem_frac = 0.4;
    for loss_rate = [0.1 0.2:0.2:1]
        [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1)
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% xxElemSyncLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1 0.2:0.2:1]
        [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'syn', elem_frac, loss_rate, 1, 1)
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'elem', 'syn', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% RowRandLoss
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1 0.2:0.2:1]
        [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'row', 'ind', elem_frac, loss_rate, 1, 1)
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'row', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ColRandLoss:
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for loss_rate = [0.1 0.2:0.2:1]
        [mse, mae, cc, ratio] = mpeg_lc_based_pred('../processed_data/subtask_parse_huawei_3g/region_tm/', filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'col', 'ind', elem_frac, loss_rate, 1, 1)
        fprintf(fh, '%s, %d, %d, %d, %d, %d, %d, %s, %s, %s, %s, %s, %s, %s, %f, %f, %d, %d, %f, %f, %f, %f\n', ...
            filename, 24, width, height, bw, bh, num_sel_blocks, 'diff', 'global', 'dct', 'org', 'no_fill', 'col', 'ind', elem_frac, loss_rate, 1, 1, mse, mae, cc, ratio);
    end





    fclose(fh);


end












