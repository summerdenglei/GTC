%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.10 @ UT Austin
%%
%% - Input:
%%      @itvl: the difference between i-th slot and i+itvl-th slot
%%
%% - Output:
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat(input_TM_dir, filename, num_frames, width, height)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 0;


    %% --------------------
    %% Variable
    %% --------------------
    % output_dir = '../processed_data/subtask_temporal/temporal_stability/';


    %% --------------------
    %% Main starts
    %% --------------------
    % rand('seed', seed);
    

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
    sx = size(data(:,:,1));
    nx = prod(sx);


    %% --------------------
    %% Convert to 2D
    %% --------------------
    if DEBUG2, fprintf('Convert to 2D\n'); end
    
    orig_sx = size(data);
    data = reshape(data, orig_sx(1) * orig_sx(2), orig_sx(3));
    data = data / max(data(:));
    full_rank = min(size(data));
    % fprintf('  size = %dx%d\n', size(data));


    %% --------------------
    %% calculate the difference between i-th time slot vs. i+k-th time slot
    %% --------------------
    if DEBUG2, fprintf('calculate the difference between i-th time slot vs. i+k-th time slot\n'); end

    itvl = 1;
    m1 = data(:, 1:end-itvl);
    m2 = data(:, 1+itvl:end);
    dif = abs(m1-m2);
    dif = sort(dif, 'descend');

    mean_err = mean(dif(:));
    max_err  = max(dif(:));
    num_std = length(find(dif > mean_err+std(dif(:)))) / prod(size(data));
    num_3std = length(find(dif > mean_err+2*std(dif(:)))) / prod(size(data));
    num_5std = length(find(dif > mean_err+3*std(dif(:)))) / prod(size(data));
end






