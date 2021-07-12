%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.10 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sigma] = analyze_low_rank_2d(input_TM_dir, filename, num_frames, width, height, thresh, num_anomaly, sigma_mag)
    addpath('../utils/mirt_dctn');
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;


    %% --------------------
    %% Variable
    %% --------------------
    output_dir = '../processed_data/subtask_rank/rank_2d/';


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
    full_rank = min(size(data));


    %% --------------------
    %% Add anomalies
    %% --------------------
    if DEBUG2, fprintf('Add anomalies\n'); end

    % num_anomaly = 0.05;
    % sigma_mag = 0.4;

    [n, m] = size(data);
    ny = floor(n*m*num_anomaly);

    Y = zeros(n, m);

    % if sigma_mag > 1
    %     anomaly_base = std(data(:));
    %     Y(randsample(n*m, ny)) = anomaly_base * sign(randn(ny, 1)) .* (sigma_mag + sign(randn(ny, 1)) * 1);
    % else
    %     Y(randsample(n*m, ny)) = sign(randn(ny, 1)) * max(data(:)) * sigma_mag;
    % end
    dif = abs(data(:, 1:end-1) - data(:, 2:end));
    dif = sort(dif(:), 'descend');
    anomaly_base = mean(mean(dif(1:10)));
    Y(randsample(n*m, ny)) = anomaly_base * sign(randn(ny, 1)) .* sigma_mag;

    data2 = max(0, data + Y);
    % data2 = data2 - mean(data2(:));  %% mean centered
    
    

    %% --------------------
    %% calculate the rank for data with anomalies
    %% --------------------
    if DEBUG2, fprintf('calculate the rank for data with anomalies\n'); end

    m = data2;
    m = m - mean(m(:));
    sigma = svd(m);

    total_sum = sum(sigma);
    total_sum_sofar = cumsum(sigma);
    cdf = total_sum_sofar ./ total_sum;

    k = [1:length(cdf)]' / full_rank;
    
    %% change point
    inv_singular = [1; 1 - cdf];
    ix = find(inv_singular < thresh);
    if length(ix) > 0
        r = ix(1);
    else
        r = length(sigma);
    end

    output_file = [output_dir filename '.na' num2str(num_anomaly) '.anom' num2str(sigma_mag) '.rank.txt'];
    dlmwrite(output_file, inv_singular, 'delimiter', '\t');

    output_file = [output_dir filename '.na' num2str(num_anomaly) '.anom' num2str(sigma_mag) '.cdf.txt'];
    dlmwrite(output_file, [k, cdf], 'delimiter', '\t');

    fprintf('rand = %d, full_rank = %d\n', r, full_rank);

    
    
end


