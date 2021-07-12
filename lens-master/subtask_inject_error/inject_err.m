%% functionname: function description
%% e.g.
%%    inject_err('TM_Airport_period5_', 0, 12, 300, 300, 15)
function inject_err(filename, expnum, num_frames, width, height, num_errs)
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    input_dir = '../processed_data/subtask_process_4sq/TM/';
    output_TM_dir = '../processed_data/subtask_inject_error/TM_err/';
    output_err_dir = '../processed_data/subtask_inject_error/errs/';

    % seed = 'shuffle';
    % rng(seed);


    for frame = [0:num_frames-1]
        this_filename = [filename int2str(frame) '.txt'];

        if DEBUG1
            fprintf('file: %s\n', this_filename);
        end
        
        %% load original TM
        orig_TM = load([input_dir this_filename]);
        orig_TM = orig_TM(1:width, 1:height);
        sz = size(orig_TM);

        if DEBUG1
            fprintf('  size of TM = (%d, %d)\n', sz);
        end


        %% mean and stdev
        meanTM   = mean(orig_TM(:));
        stdTM    = std(orig_TM(:));
        maxTM    = max(orig_TM(:));
        medianTM = median(orig_TM(:));

        if DEBUG1
            fprintf('  mean=%f, stdev=%f, max=%f, median=%f\n', meanTM, stdTM, maxTM, medianTM);
        end


        %% index of errors
        tmp = randperm(prod(sz));
        err_ind = tmp(1:num_errs);
        err = zeros(1, num_errs);

        err_mean = maxTM;

        %% inject 2 * mean +- 1 std error
        range = 1:floor(num_errs/3);
        err(range) = 2*err_mean + stdTM .* randn(1, length(range));

        %% inject 3 * mean +- 1 std error
        range = floor(num_errs/3)+1:floor(num_errs*2/3);
        err(range) = 3*err_mean + stdTM .* randn(1, length(range));

        %% inject 5 * mean +- 1 std error
        range = floor(num_errs*2/3)+1:num_errs;
        err(range) = 5*err_mean + stdTM .* randn(1, length(range));

        
        %% output TM with errors
        orig_TM(err_ind) = err;
        dlmwrite([output_TM_dir filename '.exp' int2str(expnum) '.' int2str(frame) '.txt'], orig_TM);
        dlmwrite([output_err_dir filename '.exp' int2str(expnum) '.' int2str(frame) '.err.txt'], [err_ind; err]);

    end
end
