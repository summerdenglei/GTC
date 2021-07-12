%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.10 @ UT Austin
%%
%% - Input:
%%   
%%
%% - Output:
%%
%% e.g. 
%%     ewma_dect('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11, -1, 5, 1)
%%     ewma_dect('../data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1, -1, 5, 1)
%%     ewma_dect('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1, -1, 5, 1)
%%     ewma_dect('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 1000, 16, 1, -1, 5, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ewma_dect(input_TM_dir, filename, num_frames, width, height, alpha, thresh, seed)
    addpath('/u/yichao/anomaly_compression/utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 1;
    DEBUG3 = 0; %% block index check
    DEBUG_WRITE = 0;


    %% --------------------
    %% Constant
    %% --------------------
    

    %% --------------------
    %% Variable
    %% --------------------
    output_fig_dir = './tmp_output/';
    output_dir = '../processed_data/subtask_ewma/dect_anomaly/';
    

    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    randn('seed', seed);
    

    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    if strcmpi(filename, 'X') | strfind(filename, '.txt')
        %% load data matrix
        data = zeros(height, width, num_frames);

        this_matrix_file = [input_TM_dir filename];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file)';
        data(:, :, :) = tmp(:, 1:num_frames);

    else
        data = zeros(height, width, num_frames);
        for frame = [0:num_frames-1]
            if DEBUG0, fprintf('  frame %d\n', frame); end

            %% load data matrix
            this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
            if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
            
            tmp = load(this_matrix_file);
            data(:,:,frame+1) = tmp(1:height, 1:width);
        end
    end
    
    %% --------------------
    %% DEBUG
    %% --------------------
    if DEBUG2, fprintf('debug array\n'); end

    %% mean centered
    data = data / mean(data(:));
    % size(data)
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% Convert to 2D
    %% --------------------
    if DEBUG2, fprintf('Convert to 2D\n'); end

    orig_sx = size(data);
    data = reshape(data, [], orig_sx(3));
    fprintf('  size = %d (nodes) x %d (time)\n', size(data));


    %% --------------------
    %% alpha
    %% --------------------
    if alpha < 0
        alphas = [0:0.1:1];
    else
        alphas = [alpha];
    end
        

    %% --------------------
    %% EWMA performance for each alpha
    %% --------------------
    if DEBUG2, fprintf('EWMA performance for each alpha\n'); end

    pred_data    = zeros(length(alphas), size(data, 1), size(data, 2));
    pred_err     = zeros(length(alphas), size(data, 1), size(data, 2));
    dect_anomaly = zeros(length(alphas), size(data, 1), size(data, 2));
    pred_err_sum = zeros(length(alphas), 1);
    fprintf('  size of pred data: %d (alphas) x %d x %d (TM)\n', size(pred_data));

    for ai = [1:length(alphas)]
        alpha = alphas(ai);

        %% --------------------
        %% EWMA for each node (row)
        %% --------------------
        for row = [1:size(data, 1)]
            pred_data(ai, row, :) = ewma(data(row, :), alpha);
            pred_err(ai, row, :) = abs( reshape(pred_data(ai, row, :), 1, []) - data(row, :) );
            tmp = pred_err(ai, row, :);
            anomalies = (tmp > (mean2(tmp) + thresh*std2(tmp)) );
            dect_anomaly(ai, row, :) = anomalies;
        end
        
        tmp = pred_err(ai, :, :);
        pred_err_sum(ai) = sum(tmp(:));
    end

    [min_err, min_ind] = min(pred_err_sum);
    for ai = [1:length(alphas)]
        alpha = alphas(ai);
        fprintf('  alpha=%f: error=%f\n', alpha, pred_err_sum(ai));
    end
    fprintf('  -> minimal: alpha=%f, error=%f\n', alphas(min_ind), min_err);


    %% --------------------
    %% Output results
    %% --------------------
    if DEBUG2, fprintf('Output results\n'); end 

    dlmwrite([output_dir filename '.diff.txt'], reshape(pred_err(ai,:,:), size(data)));
    dlmwrite([output_dir filename '.anomaly.txt'], reshape(dect_anomaly(ai,:,:), size(data)));
    

    range_node = [1:min(width,40)];
    range_time = [1:50];

    tmp1 = reshape(pred_err(ai,:,:), size(data));
    tmp2 = reshape(dect_anomaly(ai,:,:), size(data));
    tmp3 = data;
    tmp4 = reshape(pred_data(ai,:,:), size(data));
    
    
    h = figure;
    imagesc(tmp1);
    print(h, '-dpsc', [output_fig_dir filename '.diff.heat.eps']);
    % print(h, '-dpng', [output_fig_dir filename '.heat.png']);
    close all;

    h = figure;
    map = zeros(2, 3);
    map(1, :) = [1 1 1];
    map(2, :) = [1 0 0];
    colormap(map);
    imagesc(tmp2);
    print(h, '-dpsc', [output_fig_dir filename '.anomaly.heat.eps']);
    % print(h, '-dpng', [output_fig_dir filename '.heat.png']);
    close all;

    h = figure;
    colormap(jet);
    bar4viacolor(struct('Z',tmp1(range_node, range_time), 'ColorScaleData', tmp2(range_node, range_time)));
    print(h, '-dpsc', [output_fig_dir filename '.diff.eps']);
    % print(h, '-dpng', [output_fig_dir filename '.diff.png']);
    close all;

    % h = figure;
    % bar4viacolor(struct('Z',tmp2(range_node, range_time)));
    % % print(h, '-dpsc', 'tmp.eps');
    % print(h, '-dpng', [output_fig_dir filename '.anomaly.png']);
    % close all;

    h = figure;
    bar4viacolor(struct('Z',tmp3(range_node, range_time), 'ColorScaleData', tmp2(range_node, range_time)));
    print(h, '-dpsc', [output_fig_dir filename '.data.eps']);
    % print(h, '-dpng', [output_fig_dir filename '.data.png']);
    close all;

    h = figure;
    bar4viacolor(struct('Z',tmp4(range_node, range_time), 'ColorScaleData', tmp2(range_node, range_time)));
    print(h, '-dpsc', [output_fig_dir filename '.pred.eps']);
    % print(h, '-dpng', [output_fig_dir filename '.pred.png']);
    close all;


end


%% ewma
function [pred_ts] = ewma(ts, alpha)
    len = length(ts);

    pred_ts = zeros(1, len);
    pred_ts(1) = ts(1);
    
    for l = 2:len
        pred_ts(l) = alpha * ts(l-1) + (1-alpha) * pred_ts(l-1);
    end
end


%% remove detected anomalies and do ewma prediction
% function [pred_ts] = ewma_anomaly(ts, alpha, thresh)
%     len = length(ts);

%     pred_ts = zeros(1, len);
%     pred_ts(1) = ts(1);

%     ts_clean = ts;  %% the time series after removing anomalies
    
%     for l = 2:len
%         pred_ts(l) = alpha * ts_clean(l-1) + (1-alpha) * pred_ts(l-1);

%         if( abs(pred_ts(l) - ts(l)) > thresh*std(ts(:)) ) 
%             ts_clean(l) = pred_ts(l);
%         end
%     end
% end


