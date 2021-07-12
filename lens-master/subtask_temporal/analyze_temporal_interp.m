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
function [sigma] = analyze_temporal_interp(input_TM_dir, filename, num_frames, width, height, itvls, num_anomaly, sigma_mag)
    addpath('../utils/mirt_dctn');
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
    output_dir = '../processed_data/subtask_temporal/temporal_stability/';


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

    if sigma_mag > 1
        anomaly_base = std(data(:));
        Y(randsample(n*m, ny)) = anomaly_base * sign(randn(ny, 1)) .* (sigma_mag + sign(randn(ny, 1)) * 1);
    else
        Y(randsample(n*m, ny)) = sign(randn(ny, 1)) * max(data(:)) * sigma_mag;
    end

    data2 = max(0, data + Y);
    data2 = data2 / max(data2(:));  %% normalization
    % data = data / mean(data(:));  %% normalization

    

    %% --------------------
    %% calculate the difference between i-th time slot vs. i+k-th time slot
    %% --------------------
    if DEBUG2, fprintf('calculate the difference between i-th time slot vs. i+k-th time slot\n'); end

    for itvl = itvls
        m1 = data2(:, 1:end-itvl);
        m2 = data2(:, 1+itvl:end);
        dif = abs(m1-m2);
        [f,x] = ecdf(dif(:)');

        sel_len = 10000;
        len_data = length(x);
        unit = max(1, floor(len_data / sel_len));
        sel_ind = [1:unit:len_data];

        %% interpolation
        % new_x = [0];
        % num_unit = 1000;
        % for ii = [-8:-1]
        %     st = 10^ii;
        %     ed = 10^(ii+1);
        %     unit = (ed - st) / num_unit;
        %     tmp = [st:unit:ed]';
        %     new_x = [new_x;  tmp(1:end-1)];
        % end
        % new_x = [new_x; 1];

        % uniq = [true, diff(x') ~= 0]';
        % y = interp1(x(uniq), f(uniq), new_x, 'linear');
        % y(isnan(y)) = 1;

        output_file = [output_dir filename '.na' num2str(num_anomaly) '.anom' num2str(sigma_mag) '.itvl' num2str(itvl) '.diff.interp.txt'];
        % dlmwrite(output_file, [new_x, y], 'delimiter', '\t');
        dlmwrite(output_file, [x(sel_ind), f(sel_ind)], 'delimiter', '\t');

        % if itvl == 1
        %     data_max = max(data(:));
        %     data_std = std(data(:));
        %     fprintf('max=%f, std=%f\n', data_max, data_std);
        %     dif_order = sort(dif(:), 'descend');
        %     fprintf('%f,', dif_order(1:20));
        %     fprintf('\n');
        % end
    end

end






