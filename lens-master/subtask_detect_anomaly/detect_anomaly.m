%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
%%
%% - Input:
%%
%% - Output:
%%
%% e.g. 
%%     detect_anomaly('TM_Airport_period5_.exp0..b10.mpeg_dec.yuv.txt', 'TM_Airport_period5_.exp0.', 12, 300, 300, 30)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tp, tn, fp, fn] = detect_anomaly(errs_file, ground_truth_file, num_frames, width, height, thresh)
    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Variable
    %% --------------------
    input_errs_dir = '../processed_data/subtask_detect_anomaly/errs/';
    input_gt_dir   = '../processed_data/subtask_inject_error/errs/';
    output_dir = '';


    %% --------------------
    %% main starts
    %% --------------------

    %% --------------------
    %% read ground truth
    %% --------------------
    if DEBUG2, fprintf('read ground truth\n'); end

    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        this_gt_file = [input_gt_dir ground_truth_file int2str(frame) '.err.txt'];
        if DEBUG1, fprintf('    file = %s\n', this_gt_file); end
        
        if frame == 0
            ground_truth = load(this_gt_file);
        else
            tmp = load(this_gt_file);
            tmp(1, :) = tmp(1, :) + frame * width * height;

            ground_truth = [ground_truth, tmp];
        end
    end

    if DEBUG1, 
        fprintf('  size of ground truth: %d, %d\n', size(ground_truth)); 
    end


    %% --------------------
    %% read err time series
    %% --------------------
    if DEBUG2, fprintf('read err time series\n'); end

    if DEBUG1, fprintf('  file = %s\n', [input_errs_dir errs_file]); end
    err_ts = load([input_errs_dir errs_file]);
    meanErr = mean(err_ts(:, 1));
    stdErr  = std(err_ts(:, 1));

    if DEBUG1, 
        fprintf('    size of error time series: %d, %d\n', size(err_ts)); 
        fprintf('    err in Y: mean=%f, stdev=%f\n', meanErr, stdErr);
    end

    % err_ts(1:10, 1)'
    % meanErr + 3 * stdErr
    % find(err_ts(1:10, 1) > (meanErr + 3 * stdErr))
    % length(find(err_ts(:, 1) > (meanErr + 15 * stdErr)))
    detect_err_ind = find(err_ts(:, 1) > thresh);
    % find(err_ts(:, 1) > (meanErr + 15 * stdErr))
    % ground_truth(1, :)

    % ground_truth(1, 1:10)
    % detect_err_ind

    % err_ts(ground_truth(1, 1:10), 1)'
    tps = intersect(ground_truth(1, :), detect_err_ind);
    tp = size(tps, 2);
    fps = setdiff(detect_err_ind, ground_truth(1, :));
    fp = size(fps, 2);
    fns = setdiff(ground_truth(1, :), detect_err_ind);
    fn = size(fns, 2);
    tn = size(err_ts(:, 1), 1) - tp - fp - fn;


end