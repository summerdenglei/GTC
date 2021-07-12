%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.26 @ UT Austin
%%
%% - Input:
%%   @option_swap_mat: determine how to arrange rows and columns of TM
%%      'org': original matrix
%%      'rand': randomize raw and col
%%      'geo': geo -- can only be used by 4sq TM matrix
%%      'cc': correlation coefficient
%%   @option_type: determine the type of estimation
%%      'base': baseline alg
%%      'srmf'
%%      'srmf_knn'
%%      'svd'
%%      'svd_base'
%%      'lens'
%%      'nmf'
%%   @option_dim: the dimension of the input matrix
%%      '2d': convert to 2D
%%      '3d': the original tm is 3D
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
%%     [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred('../condor_data/abilene/', 'X', 100, 121, 1, 100, 10, 1, 'org', 'lens', '2d','elem', 'ind', 1, 0.6, 1, 0.05, 1, 0, 0, 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, gamma, normalized_y, y_val, best_thresh] = srmf_based_pred(input_TM_dir, filename, num_frames, width, height, group_size, r, period, option_swap_mat, option_type, option_dim, drop_ele_mode, drop_mode, elem_frac, loss_rate, burst_size, num_anomaly, sigma_magnitude, sigma_noise, thresh, seed, param1, param2, param3)
    addpath('/u/yichao/anomaly_compression/utils/lens');
    addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    addpath('/u/yichao/anomaly_compression/utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    DEBUG_WRITE = 0;

    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end


    %% --------------------
    %% Constant
    %% --------------------
    ele_size = 32;  %% size of each elements in bits
    epsilon = 0.01;
    lens_thresh = 0.07;
    % lens_thresh = 0;
    % srmf_thresh = 0.15;
    srmf_thresh = 0.15;

    if nargin < 22
        alpha = 100; lambda = 1000000000;
        %% 3G
        if strcmpi(filename, 'tm_3g_region_all.res0.002.bin60.sub.')
            alpha = 100; lambda = 1000000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g_region_all.res0.004.bin60.sub.')
            alpha = 1e-5; lambda = 1e-6;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g_region_all.res0.006.bin10.sub.')
            alpha = 100; lambda = 10000000;
            thresh_y = 600000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs0.all.bin10.txt')
            alpha = 100; lambda = 10000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs1.all.bin10.txt')
            alpha = 100; lambda = 10000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs2.all.bin10.txt')
            alpha = 100; lambda = 10000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin10.txt')
            % alpha = 100; lambda = 10000000;
            % alpha = 100; lambda = 0.00001;
            % alpha = 10000; lambda = 0.001;         %% Prediction
            alpha = 10; lambda = 0.00001;        %% interpolation?
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin60.txt')
            alpha = 100; lambda = 100000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs4.all.bin10.txt')
            alpha = 10; lambda = 10000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs6.all.bin10.txt')
            alpha = 100; lambda = 100000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs7.all.bin10.txt')
            alpha = 10; lambda = 1000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs8.all.bin10.txt')
            alpha = 100; lambda = 10000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs9.all.bin10.txt')
            alpha = 100; lambda = 1000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs10.all.bin10.txt')
            alpha = 100; lambda = 1000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.bs.bs11.all.bin10.txt')
            alpha = 1;   lambda = 100000;
            thresh_y = 300000000;

        elseif strcmpi(filename, 'tm_3g.cell.all.all.bin10.txt')
            alpha = 100; lambda = 1000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_3g.cell.load.top200.all.bin10.txt')
            alpha = 100; lambda = 1000000;
            thresh_y = 300000000;

        elseif strcmpi(filename, 'tm_3g.cell.rnc.all.bin10.txt')
            % alpha = 10; lambda = 10000000;
            alpha = 10; lambda = 0.1;
            % alpha = 100; lambda = 0;
            thresh_y = 300000000;
        
        %% GEANT
        elseif strcmpi(filename, 'tm_totem.')
            % alpha = 1; lambda = 10000;
            % alpha = 10; lambda = 0.00001;
            alpha = 10; lambda = 0.1;
            thresh_y = 600000;
        %% Abilene
        elseif strcmpi(filename, 'X')
            alpha = 10; lambda = 1000000;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_abilene.od.')
            % alpha = 10; lambda = 1000000;
            % alpha = 10; lambda = 0;
            alpha = 10; lambda = 0.01;
            % alpha = 1e-03; lambda = 0;  %% Prediction
            thresh_y = 300000000;
        %% SJTU WiFi
        elseif strcmpi(filename, 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt')
            % alpha = 100; lambda = 10000000;
            alpha = 100; lambda = 0.1;
            thresh_y = 300000000;
        %% CSI
        elseif strcmpi(filename, '128.83.158.127_file.dat0_matrix.mat.txt')
            alpha = 1000; lambda = 0.01;
            % alpha = 1000; lambda = 1e-4;
            % alpha = 10; lambda = 1e-4;     %% Prediction XX
            
            thresh_y = 300000000;
        elseif strcmpi(filename, '128.83.158.50_file.dat0_matrix.mat.txt')
            alpha = 1000; lambda = 0.01;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'Mob-Recv1run1.dat0_matrix.mat_dB.txt')
            alpha = 10; lambda = 1e-4;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'Mob-Recv1run1.dat1_matrix.mat_dB.txt')
            alpha = 10; lambda = 1e-4;
            thresh_y = 300000000;
        %% sensor
        elseif strcmpi(filename, 'tm_sensor.temp.bin600.txt')
            alpha = 1; lambda = 1e-4;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_sensor.humidity.bin600.txt')
            alpha = 1; lambda = 1e-4;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_sensor.light.bin600.txt')
            alpha = 10; lambda = 1e-4;
            % alpha = 100000; lambda = 100;  %% prediction
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_sensor.voltage.bin600.txt')
            alpha = 0.1; lambda = 1e-4;
            thresh_y = 300000000;
        %% RON
        elseif strcmpi(filename, 'tm_ron1.latency.')
            alpha = 1; lambda = 1;
            % alpha = 10000; lambda = 0.1;
            thresh_y = 300000000;
        %% RSSI - telos
        elseif strcmpi(filename, 'tm_telos_rssi.txt')
            alpha = 100; lambda = 1e-4;
            % alpha = 1000; lambda = 0;
            % alpha = 10; lambda = 0;
            %%% convert to 80*200
            % alpha = 1; lambda = 0.1;
            thresh_y = 300000000;
        %% RSSI - multi location
        elseif strcmpi(filename, 'tm_multi_loc_rssi.txt')
            alpha = 10; lambda = 0.1;
            % alpha = 10000; lambda = 0.1;    %% Prediction
            % alpha = 1; lambda = 1;
            thresh_y = 300000000;
        %% Channel CSI
        elseif strcmpi(filename, 'static_trace13.ant1.mag.txt')
            alpha = 1; lambda = 0.1;
            thresh_y = 300000000;
        %% UCSB Meshnet
        elseif strcmpi(filename, 'tm_ucsb_meshnet.connected.txt')
            alpha = 1; lambda = 10;
            thresh_y = 300000000;
        elseif strcmpi(filename, 'tm_ucsb_meshnet.')
            alpha = 1; lambda = 10;
            thresh_y = 300000000;
        %% UMich RSS
        elseif strcmpi(filename, 'tm_umich_rss.txt')
            alpha = 10; lambda = 0.1;
            thresh_y = 300000000;
        else
            error('wrong file name');
        end
    else
        alpha = param1; 
        lambda = param2;
        lens_sigma = param3;
    end


    %% --------------------
    %% Variable
    %% --------------------
    % input_4sq_dir  = '../processed_data/subtask_process_4sq/TM/';
    output_dir = '/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/pr/';
    space = 0;
    normalized_y = 0;
    y_val = 0;
    gamma = -1;


    %% --------------------
    %% Main starts
    %% --------------------
    rand('seed', seed);
    randn('seed', seed);
    num_groups = ceil(num_frames / group_size);


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

    if(strcmpi(drop_mode, 'half'))
        if(strcmpi(filename, 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt'))
            num_frames = 114 - 53 + 1;
            group_size = num_frames;
            num_groups = ceil(num_frames / group_size);

            data = zeros(height, width, num_frames);
            this_matrix_file = [input_TM_dir filename];
            
            tmp = load(this_matrix_file)';
            data(:, :, :) = tmp(:, 53:114);
        elseif(strcmpi(filename, 'tm_3g.cell.load.top200.all.bin10.txt'))
            num_frames = 144 - 60 + 1;
            group_size = num_frames;
            num_groups = ceil(num_frames / group_size);

            data = zeros(height, width, num_frames);
            this_matrix_file = [input_TM_dir filename];
            
            tmp = load(this_matrix_file)';
            data(:, :, :) = tmp(:, 60:144);
        elseif(strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin10.txt'))
            num_frames = 144 - 60 + 1;
            group_size = num_frames;
            num_groups = ceil(num_frames / group_size);

            data = zeros(height, width, num_frames);
            this_matrix_file = [input_TM_dir filename];
            
            tmp = load(this_matrix_file)';
            data(:, :, :) = tmp(:, 60:144);
        elseif(strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin60.txt'))
            num_frames = 24 - 11 + 1;
            group_size = num_frames;
            num_groups = ceil(num_frames / group_size);

            data = zeros(height, width, num_frames);
            this_matrix_file = [input_TM_dir filename];
            
            tmp = load(this_matrix_file)';
            data(:, :, :) = tmp(:, 11:24);
        % elseif(strcmpi(filename, 'tm_telos_rssi.txt'))
        %     old_nf = num_frames;
        %     num_frames = 200;
        %     group_size = num_frames;
        %     num_groups = ceil(num_frames / group_size);
        %     width = 80;

        %     data = zeros(height, width, num_frames);
        %     this_matrix_file = [input_TM_dir filename];
                
        %     tmp = load(this_matrix_file)';
        %     data(:,:,:) = reshape(tmp(:, 1:old_nf), height, width, num_frames);
        % elseif(strcmpi(filename, 'Mob-Recv1run1.dat0_matrix.mat_dB.txt'))
        %     old_nf = num_frames;
        %     num_frames = 500;
        %     group_size = num_frames;
        %     num_groups = ceil(num_frames / group_size);
        %     width = 180;

        %     data = zeros(height, width, num_frames);
        %     this_matrix_file = [input_TM_dir filename];
                
        %     tmp = load(this_matrix_file)';
        %     data(:,:,:) = reshape(tmp(:, 1:old_nf), height, width, num_frames);
        end
    end

    % if(strcmpi(filename, 'tm_abilene.od.'))
    %     %% anomaly period
    %     % from_t = 351;
    %     % to_t   = 550;
    %     %% no anomaly period
    %     from_t = 711;
    %     to_t   = 810;
    %     num_frames = to_t - from_t + 1;
    %     group_size = num_frames;
    %     num_groups = ceil(num_frames / group_size);

    %     data = zeros(height, width, num_frames);
    %     for frame = [from_t:to_t]
    %         if DEBUG0, fprintf('  frame %d\n', frame); end

    %         %% load data matrix
    %         this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
    %         if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
            
    %         tmp = load(this_matrix_file);
    %         data(:,:,frame-from_t+1) = tmp(1:height, 1:width);
    %     end
    %     fprintf('size = %d, %d, %d\n', size(data));

    % elseif(strcmpi(filename, 'Mob-Recv1run1.dat0_matrix.mat_dB.txt'))
    %     %% anomaly period
    %     from_t = 901;
    %     to_t   = 1000;
    %     from_c = 41;
    %     to_c   = 50;
    %     %% no anomaly period
    %     % from_t = 401;
    %     % to_t   = 600;
    %     % from_c = 31;
    %     % to_c   = 40;

    %     r = 4;
    %     num_frames = to_t - from_t + 1;
    %     group_size = num_frames;
    %     num_groups = ceil(num_frames / group_size);

    %     width = from_c - to_c + 1;
    %     data = data(:, from_c:to_c, from_t:to_t);

    %     fprintf('size = %d, %d, %d\n', size(data));
    % end


    % if(strcmpi(filename, 'tm_telos_rssi.txt'))
    %     num_frames = 300;
    %     group_size = num_frames;
    %     num_groups = ceil(num_frames / group_size);
    %     width = 16;

    %     data = zeros(height, width, num_frames);
    %     this_matrix_file = [input_TM_dir filename];
            
    %     tmp = load(this_matrix_file)';
    %     data(:,:,:) = tmp(:, 2001:2300);
    % end

    % if(strcmpi(filename, 'tm_telos_rssi.txt'))
    %     old_nf = num_frames;
    %     num_frames = 500;
    %     group_size = num_frames;
    %     num_groups = ceil(num_frames / group_size);
    %     width = 64;

    %     data = zeros(height, width, num_frames);
    %     this_matrix_file = [input_TM_dir filename];
            
    %     tmp = load(this_matrix_file)';
    %     data(:,:,:) = reshape(tmp(:, 1:old_nf), height, width, num_frames);
    % end
    

    %% mean centered
    data = data / mean(data(:));          %% move here on 01/29
    % size(data)
    sx = size(data(:,:,1));
    nx = prod(sx);

    % data(1, 1:10, 1:10)
    % return;


    %% --------------------
    %% drop elements
    %% --------------------
    if DEBUG2, fprintf('drop elements\n'); end

    % M = ones(size(data));
    % if loss_rate > 0
    %     %% prediction
    %     num_missing = ceil(nx * loss_rate);
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

    % M = ones(size(data));


    %% --------------------
    %% Add anomaly and noise
    %% --------------------
    if DEBUG2, fprintf('Add anomaly and noise\n'); end

    orig_data = data;
    tmp_sx = size(data);
    data_2d = reshape(data, [], tmp_sx(3));
    M_2d    = reshape(M, [], tmp_sx(3));
    [n, m] = size(data_2d);
    ny = floor(n*m*num_anomaly);

    % anomaly_base = max(data_2d(:));
    % anomaly_base = 8*std(data_2d(:));
    dif = abs(data_2d(:, 1:end-1) - data_2d(:, 2:end));
    dif = sort(dif(:), 'descend');
    anomaly_base = mean(mean(dif(1:2)));
    
    keep = 1;
    while(keep > 0 & keep < 100)
        Y = zeros(n, m);

        %% absolute size, fixed
        % Y(randsample(n*m, ny)) = sign(randn(ny, 1)) * anomaly_base * sigma_magnitude;
        %% absolute size, uniform dist
        if sigma_magnitude == 0
            Y(randsample(n*m, ny)) = 0;
            keep = -1;
        else
            % Y(randsample(n*m, ny)) = anomaly_base * sign(randn(ny, 1)) .* (sigma_magnitude + sign(randn(ny, 1)) * 1);
            Y(randsample(n*m, ny)) = anomaly_base * sign(randn(ny, 1)) .* (sigma_magnitude);
        end
        %% relative size
        % anom_entry = randsample(n*m, ny);
        % Y(anom_entry) = sign(randn(ny, 1)) .* data_2d(anom_entry) .* (rand(ny,1) * 0.5 + 0.5);
        
        %% make sure at least one anomaly is not in missing portion
        if nnz(Y .* M_2d) == 0
            keep = keep + 1;
        else
            keep = 0;
        end
    end

    Z = randn(n, m) * max(data_2d(:)) * sigma_noise;
    D = max(0, data_2d + Y + Z);

    % dlmwrite('./tmp_output/anomaly.txt', Y, 'delimiter', '\t');

    data    = reshape(D, tmp_sx);
    anomaly = reshape(Y, tmp_sx);
    noise   = reshape(Z, tmp_sx);


    %% --------------------
    %% swap matrix row and column
    %% 0: original matrix
    %% 1: randomize raw and col
    %% 2: geo
    %% 3: correlated coefficient
    %% --------------------
    % if DEBUG2, fprintf('swap matrix row and column\n'); end

    % if strcmp(option_swap_mat, 'org')
    %     %% 0: original matrix
    %     mapping_rows = [1:height];
    %     mapping_cols = [1:width];
    % elseif strcmp(option_swap_mat, 'rand')
    %     %% 1: randomize raw and col
    %     mapping_rows = randperm(height);
    %     mapping_cols = randperm(width);
    % elseif strcmp(option_swap_mat, 'geo')
    %     %% 2: geo -- only for 4sq TM
    %     % [location, mass] = get_venue_info([input_4sq_dir filename], '4sq', width, height);
    %     % if DEBUG0
    %     %     fprintf('  size of location: %d, %d\n', size(location));
    %     %     fprintf('  size of mass: %d, %d\n', size(mass));
    %     % end
        
    %     % mapping = sort_by_lat_lng(location, width, height);

    % elseif strcmp(option_swap_mat, 'cc')
    %     %% 3: correlated coefficient
        
    %     tmp_rows = reshape(data, height, []);
    %     tmp_cols = zeros(height*num_frames, width);
    %     for f = [1:num_frames]
    %         tmp_cols( (f-1)*height+1:f*height, : ) = data(:,:,f);
    %     end

    %     %% corrcoef: rows=obervations, col=features
    %     coef_rows = corrcoef(tmp_rows');
    %     coef_cols = corrcoef(tmp_cols);

    %     mapping_rows = sort_by_coef(coef_rows);
    %     mapping_cols = sort_by_coef(coef_cols);

    % elseif strcmp(option_swap_mat, 'pop')
    %     %% 4: popularity
    %     error('swap according to popularity: not done yet\n');
        
    % end

    % %% update the data matrix according to the mapping
    % for f = [1:num_frames]
    %     data(:,:,f) = map_matrix(data(:,:,f), mapping_rows, mapping_cols);
    %     M(:,:,f)    = map_matrix(M(:,:,f), mapping_rows, mapping_cols);
    % end

    if DEBUG2, fprintf('swap matrix row and column\n'); end

    orig_sx = size(data);
    % fprintf('size: %d\n',orig_sx);
    data = reshape(data, orig_sx(1) * orig_sx(2), orig_sx(3));
    M    = reshape(M,    orig_sx(1) * orig_sx(2), orig_sx(3));

    % data = [1:10; 1:5, 10:-1:6; 11:20; 11:15, 20:-1:16; 1:3,11,5:8,12,10];

    if strcmp(option_swap_mat, 'org')
        %% 0: original matrix
        mapping_rows = [1:size(data,1)];
        
    elseif strcmp(option_swap_mat, 'rand')
        %% 1: randomize raw and col
        mapping_rows = randperm(size(data,1));
    
    elseif strcmp(option_swap_mat, 'cc')
        %% 3: correlated coefficient        
        %% corrcoef: rows=obervations, col=features
        coef_rows = corrcoef(data');
        
        mapping_rows = sort_by_coef(coef_rows);
        

    elseif strcmp(option_swap_mat, 'pop')
        %% 4: popularity
        [b, mapping_rows] = sort(sum(data,2));
        
    end

    data = data(mapping_rows, :);
    M    = M(mapping_rows, :);

    data = reshape(data, orig_sx);
    M    = reshape(M,    orig_sx);
    

    if DEBUG1, fprintf('  size of data matrix: %d, %d, %d\n', size(data)); end


    compared_data = data;
    compared_data(~M) = 0;
    detect_anomaly = zeros(size(data));

    %% --------------------
    %% apply SRMF to each Group of Pictures (GoP)
    %% --------------------
    for gop = 1:num_groups
        gop_s = (gop - 1) * group_size + 1;
        gop_e = min(num_frames, gop * group_size);

        if DEBUG1, fprintf('gop %d: frame %d-%d\n', gop, gop_s, gop_e); end

        this_group   = data(:, :, gop_s:gop_e);
        this_group_M = M(:, :, gop_s:gop_e);


        %% --------------------
        %% convert to 2D
        %% --------------------
        if strcmpi(option_dim, '2d')
            orig_sx = size(this_group);
            % fprintf('size: %d\n',orig_sx);
            this_group = reshape(this_group, [], orig_sx(3));
            this_group_M = reshape(this_group_M, [], orig_sx(3));
            % size(this_group)
        end



        %% --------------------
        %  Compressive Sensing
        %% --------------------
        this_rank = r; %min(r, rank(this_group));
        

        % meanX2 = mean(this_group(:).^2);
        % meanX = mean(this_group(:));
        sx = size(this_group);
        nx = prod(sx);
        n  = length(sx);

        if strcmpi(option_type, 'base')
            %% baseline
            [A, b] = XM2Ab(this_group, this_group_M);
            est_group = EstimateBaseline(A, b, sx);

            %% space
            space = space + (prod(size(A)) + prod(size(b))) * ele_size;

        elseif strcmpi(option_type, 'srtf')
            %% SRMF
            [A, b] = XM2Ab(this_group, this_group_M);
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true, period);
            % [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, 10, 1e-1, 50);
            [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);

            est_group = tensorprod(u4, v4, w4);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) + prod(size(w4))) * ele_size;

        elseif strcmpi(option_type, 'srmf')
            % this_rank = this_rank / 2;

            [A, b] = XM2Ab(this_group, this_group_M);
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true, period);

            [u4, v4] = SRMF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            % dlmwrite('./tmp_output/srmf.txt', est_group, 'delimiter', '\t');
            

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;

        elseif strcmpi(option_type, 'srtf_knn')
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, this_group_M);
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4, w4] = SRTF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);

            est_group = tensorprod(u4, v4, w4);
            est_group = max(0, est_group);

            if strcmpi(option_dim, '3d')
                orig_f = reshape(this_group, [], sx(n))';
                est_f = reshape(est_group, [], sx(n))';
                Z = est_f;
                f_M   = reshape(this_group_M, [], sx(n))';
                % size(est_f)
                
                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:group_size
                    for j = find(f_M(i,:) == 0)
                        ind = find((f_M(i,:)==1) & (abs((1:(sx(1)*sx(2))) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_f(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_f(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(orig_f(i,ind).*w);
                        end
                    end
                end
                est_group = reshape(Z', sx(1), sx(2), sx(3));
            elseif strcmpi(option_dim, '2d')
                Z = est_group;

                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:size(Z,1)
                    for j = find(this_group_M(i,:) == 0);
                        ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_group(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_group(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(this_group(i,ind).*w);
                        end
                    end
                end
                est_group = Z;
            else
                error('wrong option_dim');
            end
                

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) + prod(size(w4))) * ele_size;

        elseif strcmpi(option_type, 'srmf_knn')
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, this_group_M);
            % this_rank = this_rank / 2;
            config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4] = SRMF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);


            if strcmpi(option_dim, '3d')
                orig_f = reshape(this_group, [], sx(n))';
                est_f = reshape(est_group, [], sx(n))';
                Z = est_f;
                f_M   = reshape(this_group_M, [], sx(n))';
                % size(est_f)
                
                maxDist = 3;
                EPS = 1e-3;
                
                for i = 1:group_size
                    for j = find(f_M(i,:) == 0)
                        ind = find((f_M(i,:)==1) & (abs((1:(sx(1)*sx(2))) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_f(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_f(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(orig_f(i,ind).*w);
                        end
                    end
                end
                est_group = reshape(Z', sx(1), sx(2), sx(3));
            elseif strcmpi(option_dim, '2d')
                
                Z = est_group;

                maxDist = 3;
                EPS = 1e-3;

                % Z            = Z';
                % this_group_M = this_group_M';
                % est_group    = est_group';
                % this_group   = this_group';

                for i = 1:size(Z,1)
                    for j = find(this_group_M(i,:) == 0);
                        ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_group(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_group(:,j));
                            w  = reshape(w,1,nc);
                            % Z(i,j) = sum(est_group(i,ind).*w);
                            Z(i,j) = sum(this_group(i,ind).*w);
                        end
                    end
                end
                
                % Z            = Z';
                % this_group_M = this_group_M';
                % est_group    = est_group';
                % this_group   = this_group';

                est_group = Z;
            else
                error('wrong option_dim');
            end                

            %% space
            space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;

        elseif strcmpi(option_type, 'lens')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end

            %% lens
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            
            est_group = x + y;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);

            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'lens_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% LENS
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            
            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(x + y, 1);



            %% KNN
            est_group = x + y;
            Z = est_group;
            
            maxDist = 3;
            EPS = 1e-3;
            
            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                    end
                end
            end

            est_group = Z;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);


            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'lens_knn2')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% lens
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            

            %% KNN
            est_group = x;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group = Z + y;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);

            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(Z + y, 1);


            %% space
            space = space + prod(size(this_group));


        elseif strcmpi(option_type, 'srmf_lens_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% LENS
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;

            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);

            
            %% KNN
            est_group = x;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end


            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(Z + y, 1);
            
            if(y_val < thresh_y)
                %% SRMF + KNN
                [A, b] = XM2Ab(this_group, this_group_M);
                config = ConfigSRTF(A, b, this_group, this_group_M, sx, this_rank, this_rank, epsilon, true, period);
                [u4, v4] = SRMF(this_group, this_rank, this_group_M, config, alpha, lambda, 50);
                
                est_group = u4 * v4';
                est_group = max(0, est_group);

                Z = est_group;


                %% KNN
                maxDist = 3;
                EPS = 1e-3;

                for i = 1:size(Z,1)
                    for j = find(this_group_M(i,:) == 0);
                        ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                        if (~isempty(ind))
                            Y  = est_group(:,ind);
                            C  = Y'*Y;
                            nc = size(C,1);
                            C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                            w  = C\(Y'*est_group(:,j));
                            w  = reshape(w,1,nc);
                            Z(i,j) = sum(this_group(i,ind).*w);
                        end
                    end
                end

                est_group = Z;
                detect_anomaly(:, :, gop_s:gop_e) = data - reshape(est_group, orig_sx);
                
                %% space
                space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;
            else

                est_group = Z + y;
                detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);

                %% space
                space = space + prod(size(this_group)) * ele_size;
            end

        
        elseif strcmpi(option_type, 'srmf_lens_knn2')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% LENS
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            

            %% KNN
            est_group = x;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group_lens = Z + y;
            detect_anomaly_lens = reshape(y, orig_sx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % dlmwrite('./tmp_output/data.txt', this_group, 'delimiter', '\t');
            % dlmwrite('./tmp_output/Y.txt', Y2, 'delimiter', '\t');

            new_M = this_group_M;
            new_M(abs(y) > 0) = 0;

            % dlmwrite('./tmp_output/M.txt', this_group_M, 'delimiter', '\t');
            % dlmwrite('./tmp_output/new_M.txt', new_M, 'delimiter', '\t');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, new_M);
            config = ConfigSRTF(A, b, this_group, new_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4] = SRMF(this_group, this_rank, new_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            Z = est_group;

            
            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(new_M(i,:) == 0);
                    ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                    end
                end
            end

            est_group_srmf = Z;
            detect_anomaly_srmf = data - reshape(est_group_srmf, orig_sx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % dlmwrite('./tmp_output/srmf_after_lens.txt', est_group_srmf, 'delimiter', '\t');
            
            tmp = size(M);
            % if (nnz(~M) / tmp(1) / tmp(2) / tmp(3) >= 0.9)
            if (loss_rate >= 0.9 | elem_frac >= 0.9)
                use_srmf = ones(tmp);
            else
                % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
                use_srmf = (abs(y) == 0);
            end
            use_lens = ~use_srmf;
            
            est_group(use_srmf) = est_group_srmf(use_srmf);
            est_group(use_lens) = est_group_lens(use_lens);

            % dlmwrite('./tmp_output/combine.txt', est_group, 'delimiter', '\t');

            tmp = zeros(size(detect_anomaly(:, :, gop_s:gop_e)));
            tmp(use_srmf) = detect_anomaly_srmf(use_srmf);
            tmp(use_lens) = detect_anomaly_lens(use_lens);
            detect_anomaly(:, :, gop_s:gop_e) = tmp;

            % dlmwrite('./tmp_output/y_srmf.txt', sort(abs(Y2(use_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_lens.txt', sort(abs(Y2(use_lens))), 'delimiter', '\t');

            % win_srmf = (abs(this_group - est_group_srmf) < abs(this_group - est_group_lens));
            % win_lens = ~win_srmf;
            % dlmwrite('./tmp_output/y_gt_srmf.txt', sort(abs(Y2(win_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_gt_lens.txt', sort(abs(Y2(win_lens))), 'delimiter', '\t');


        elseif strcmpi(option_type, 'lens_st')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% lens
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            % sigma0 = lens_sigma;
            sigma0 = [];
            F = ones(size(this_group));

            % [X,Y,Z,W,sigma] = lens(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            [x,y,z,w, u,v,s,t, sigma] = lens_st(this_group, this_rank, A,B,C, E,F, sigma0, soft);    
            
            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(x+y+s+t, 1);


            est_group = x+y+s+t;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);


            %% space
            space = space + prod(size(this_group));


        elseif strcmpi(option_type, 'lens_st_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% lens
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            % sigma0 = lens_sigma;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w, u,v,s,t, sigma] = lens_st(this_group, this_rank, A,B,C, E,F, sigma0, soft);    
            
            
            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(x+y+s+t, 1);

            
            %% KNN
            est_group = x+y+s+t;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                        % Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group = Z;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);


            %% space
            space = space + prod(size(this_group));


        elseif strcmpi(option_type, 'lens_st_knn2')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %% lens
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            % sigma0 = lens_sigma;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w, u,v,s,t, sigma] = lens_st(this_group, this_rank, A,B,C, E,F, sigma0, soft);    
            
            
            y_val        = norm(y, 1);
            normalized_y = norm(y, 1) / norm(x+y+s+t, 1);

            
            % dlmwrite(['./tmp_output/' option_type '.lr' num2str(loss_rate) '.Y.txt'], y, 'delimiter', '\t');

            %% KNN
            est_group = x+s+t;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group = Z + y;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);


            %% space
            space = space + prod(size(this_group));


        elseif strcmpi(option_type, 'srmf_lens_st_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% LENS_ST
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w, u,v,s,t, sigma] = lens_st(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            

            %% KNN
            est_group = x+s+t;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group_lens = Z + y;
            detect_anomaly_lens = reshape(y, orig_sx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            new_M = this_group_M;
            new_M(abs(y) > 0) = 0;


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, new_M);
            config = ConfigSRTF(A, b, this_group, new_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4] = SRMF(this_group, this_rank, new_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            Z = est_group;

            
            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(new_M(i,:) == 0);
                    ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                    end
                end
            end

            est_group_srmf = Z;
            detect_anomaly_srmf = data - reshape(est_group_srmf, orig_sx);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % dlmwrite('./tmp_output/srmf_after_lens.txt', est_group_srmf, 'delimiter', '\t');
            
            tmp = size(M);
            if (nnz(~M) / tmp(1) / tmp(2) / tmp(3) >= 0.9)
            % if (loss_rate >= 0.9 | elem_frac >= 0.9)
                use_srmf = ones(tmp);
            else
                % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
                use_srmf = (abs(y) == 0);
            end
            use_lens = ~use_srmf;
            
            % est_group(use_srmf) = est_group_srmf(use_srmf);
            % est_group(use_lens) = est_group_lens(use_lens);
            est_group(find(use_srmf>0)) = est_group_srmf(find(use_srmf>0));
            est_group(find(use_lens>0)) = est_group_lens(find(use_lens>0));

            % dlmwrite('./tmp_output/combine.txt', est_group, 'delimiter', '\t');

            % tmp = zeros(size(detect_anomaly(:, :, gop_s:gop_e)));
            % tmp(use_srmf) = detect_anomaly_srmf(use_srmf);
            % tmp(use_lens) = detect_anomaly_lens(use_lens);
            % detect_anomaly(:, :, gop_s:gop_e) = tmp;
            detect_anomaly = detect_anomaly_lens;

            % dlmwrite('./tmp_output/y_srmf.txt', sort(abs(Y2(use_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_lens.txt', sort(abs(Y2(use_lens))), 'delimiter', '\t');

            % win_srmf = (abs(this_group - est_group_srmf) < abs(this_group - est_group_lens));
            % win_lens = ~win_srmf;
            % dlmwrite('./tmp_output/y_gt_srmf.txt', sort(abs(Y2(win_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_gt_lens.txt', sort(abs(Y2(win_lens))), 'delimiter', '\t');


        elseif strcmpi(option_type, 'srmf_lens_st_knn2')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end

            fprintf('XXX: combine2\n');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% LENS_ST
            A = speye(size(this_group, 1));
            B = speye(size(this_group, 1));
            C = speye(size(this_group, 1));
            E = ~this_group_M;
            
            soft = 1;
            sigma0 = [];
            F = ones(size(this_group));

            [x,y,z,w, u,v,s,t, sigma] = lens_st(this_group, this_rank, A,B,C, E,F, sigma0, soft);
            

            %% KNN
            est_group = x+s+t;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            est_group_lens = Z + y;
            % est_group_lens = x + y + s + t;
            detect_anomaly_lens = reshape(y, orig_sx);
            detect_anomaly_lens = (abs(detect_anomaly_lens) > lens_thresh*max(abs(detect_anomaly_lens(:))));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            new_M = this_group_M;
            new_M(abs(y) > 0) = 0;
            % tmp_y = abs(y);
            % tmp_y = (tmp_y > lens_thresh*max(tmp_y(:)));
            % new_M(tmp_y) = 0;


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, new_M);
            config = ConfigSRTF(A, b, this_group, new_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4] = SRMF(this_group, this_rank, new_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            Z = est_group;

            
            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(new_M(i,:) == 0);
                    ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                        % Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end


            est_group_srmf = Z;
            detect_anomaly_srmf = data - reshape(est_group_srmf, orig_sx);
            detect_anomaly_srmf = (abs(detect_anomaly_srmf) > srmf_thresh*max(abs(detect_anomaly_srmf(:))));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % dlmwrite('./tmp_output/srmf_after_lens.txt', est_group_srmf, 'delimiter', '\t');
            
            tmp = size(M);
            if (nnz(~M) / tmp(1) / tmp(2) / tmp(3) >= 0.9)
            % if (loss_rate >= 0.9 | elem_frac >= 0.9)
                use_srmf = ones(tmp);
            else
                % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
                use_srmf = (abs(y) == 0);
                % use_srmf = ~tmp_y;
                % use_srmf = zeros(tmp);
            end
            use_lens = ~use_srmf;

            % est_group(use_srmf) = est_group_srmf(use_srmf);
            % est_group(use_lens) = est_group_lens(use_lens);
            est_group(find(use_srmf>0)) = est_group_srmf(find(use_srmf>0));
            est_group(find(use_lens>0)) = est_group_lens(find(use_lens>0));

            % dlmwrite('./tmp_output/combine.txt', est_group, 'delimiter', '\t');

            tmp = zeros(size(detect_anomaly(:, :, gop_s:gop_e)));
            tmp(find(use_srmf>0)) = detect_anomaly_srmf(find(use_srmf>0));
            tmp(find(use_lens>0)) = detect_anomaly_lens(find(use_lens>0));
            detect_anomaly(:, :, gop_s:gop_e) = tmp;
            % detect_anomaly = detect_anomaly_lens;

            % dlmwrite('./tmp_output/y_srmf.txt', sort(abs(Y2(use_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_lens.txt', sort(abs(Y2(use_lens))), 'delimiter', '\t');

            % win_srmf = (abs(this_group - est_group_srmf) < abs(this_group - est_group_lens));
            % win_lens = ~win_srmf;
            % dlmwrite('./tmp_output/y_gt_srmf.txt', sort(abs(Y2(win_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_gt_lens.txt', sort(abs(Y2(win_lens))), 'delimiter', '\t');



        elseif strcmpi(option_type, 'lens3')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end

            %% lens
            [n,m] = size(this_group);
            A = speye(n);
            B = speye(n);
            C = speye(n);
            E = ~this_group_M;
            F = ones(n,m);
            
            soft = 1;
            sigma0 = [];
            this_r = r * 4;
            rho = 1.01;

            CC = zeros(1, m-1); CC(1,1) = 1;
            RR = zeros(1, m); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
            P = speye(n,n);
            Q = toeplitz(CC,RR);
            K = P*zeros(n,m)*Q';
            [x,y,z,w,enable_B,sig,gamma] = lens3(D,this_r,A,B,C,E,P,Q,K,[],soft,rho);
            if (enable_B)
                est1 = x+y;
                est2 = A*x+B*y;
            else
                est1 = x;
                est2 = A*x;
            end  

            est_group = est1;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);

            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'lens3_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end

            %% lens
            [n,m] = size(this_group);
            A = speye(n);
            B = speye(n);
            C = speye(n);
            E = ~this_group_M;
            F = ones(n,m);
            
            soft = 1;
            sigma0 = [];
            this_r = r * 2;

            CC = zeros(1, m-1); CC(1,1) = 1;
            RR = zeros(1, m); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
            P = speye(n,n);
            Q = toeplitz(CC,RR);
            K = P*zeros(n,m)*Q';
            [x,y,z,w,enable_B,sig,gamma] = lens3(D,this_r,A,B,C,E,P,Q,K,[],soft);
            
            
            %% KNN
            est_group = x;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            
            if (enable_B)
                est1 = Z+y;
                est2 = A*Z+B*y;
            else
                est1 = Z;
                est2 = A*Z;
            end  
            est_group = est1;
            detect_anomaly(:, :, gop_s:gop_e) = reshape(y, orig_sx);


            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'srmf_lens3_knn')
            if strcmpi(option_dim, '3d')
                error('must be 2D for lens');
            end

            if nnz(this_group_M) == 0
                est_group = zeros(size(this_group));
                detect_anomaly(:, :, gop_s:gop_e) = zeros(orig_sx);
                continue;
            end

            %% lens
            [n,m] = size(this_group);
            A = speye(n);
            B = speye(n);
            C = speye(n);
            E = ~this_group_M;
            F = ones(n,m);
            
            soft = 1;
            sigma0 = [];
            this_r = r * 2;

            CC = zeros(1, m-1); CC(1,1) = 1;
            RR = zeros(1, m); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
            P = speye(n,n);
            Q = toeplitz(CC,RR);
            K = P*zeros(n,m)*Q';
            [x,y,z,w,enable_B,sig,gamma] = lens3(D,this_r,A,B,C,E,P,Q,K,[],soft);
            
            
            %% KNN
            est_group = x;
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        % Z(i,j) = sum(this_group(i,ind).*w);
                        Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end

            
            if (enable_B)
                est1 = Z+y;
                est2 = A*Z+B*y;
            else
                est1 = Z;
                est2 = A*Z;
            end  
            est_group_lens = est1;
            
            detect_anomaly_lens = reshape(y, orig_sx);
            detect_anomaly_lens = (abs(detect_anomaly_lens) > lens_thresh*max(abs(detect_anomaly_lens(:))));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            new_M = this_group_M;
            new_M(abs(y) > 0) = 0;
            % tmp_y = abs(y);
            % tmp_y = (tmp_y > lens_thresh*max(tmp_y(:)));
            % new_M(tmp_y) = 0;


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% SRMF + KNN
            [A, b] = XM2Ab(this_group, new_M);
            config = ConfigSRTF(A, b, this_group, new_M, sx, this_rank, this_rank, epsilon, true, period);
            [u4, v4] = SRMF(this_group, this_rank, new_M, config, alpha, lambda, 50);
            
            est_group = u4 * v4';
            est_group = max(0, est_group);

            Z = est_group;

            
            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(new_M(i,:) == 0);
                    ind = find((new_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                        % Z(i,j) = sum(est_group(i,ind).*w);
                    end
                end
            end


            est_group_srmf = Z;
            detect_anomaly_srmf = data - reshape(est_group_srmf, orig_sx);
            detect_anomaly_srmf = (abs(detect_anomaly_srmf) > srmf_thresh*max(abs(detect_anomaly_srmf(:))));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % dlmwrite('./tmp_output/srmf_after_lens.txt', est_group_srmf, 'delimiter', '\t');
            
            tmp = size(M);
            if (nnz(~M) / tmp(1) / tmp(2) / tmp(3) >= 0.9)
            % if (loss_rate >= 0.9 | elem_frac >= 0.9)
                use_srmf = ones(tmp);
            else
                % this_thresh = mean(abs(y(:))) + 2 * std(abs(y(:)));
                use_srmf = (abs(y) == 0);
                % use_srmf = ~tmp_y;
                % use_srmf = zeros(tmp);
            end
            use_lens = ~use_srmf;

            % est_group(use_srmf) = est_group_srmf(use_srmf);
            % est_group(use_lens) = est_group_lens(use_lens);
            est_group(find(use_srmf>0)) = est_group_srmf(find(use_srmf>0));
            est_group(find(use_lens>0)) = est_group_lens(find(use_lens>0));

            % dlmwrite('./tmp_output/combine.txt', est_group, 'delimiter', '\t');

            tmp = zeros(size(detect_anomaly(:, :, gop_s:gop_e)));
            tmp(find(use_srmf>0)) = detect_anomaly_srmf(find(use_srmf>0));
            tmp(find(use_lens>0)) = detect_anomaly_lens(find(use_lens>0));
            detect_anomaly(:, :, gop_s:gop_e) = tmp;
            % detect_anomaly = detect_anomaly_lens;

            % dlmwrite('./tmp_output/y_srmf.txt', sort(abs(Y2(use_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_lens.txt', sort(abs(Y2(use_lens))), 'delimiter', '\t');

            % win_srmf = (abs(this_group - est_group_srmf) < abs(this_group - est_group_lens));
            % win_lens = ~win_srmf;
            % dlmwrite('./tmp_output/y_gt_srmf.txt', sort(abs(Y2(win_srmf))), 'delimiter', '\t');
            % dlmwrite('./tmp_output/y_gt_lens.txt', sort(abs(Y2(win_lens))), 'delimiter', '\t');


            %% space
            space = space + prod(size(this_group));

        elseif strcmpi(option_type, 'svd')
            %% svd
            % this_rank = this_rank / 2;
            [u,v,w] = FactTensorACLS(this_group, this_rank, this_group_M, false, epsilon, 50, 1e-8, 0);
            
            est_group = tensorprod(u,v,w);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;

        elseif strcmpi(option_type, 'svd_base')
            %% svd_base
            % this_rank = this_rank / 2;
            [A, b] = XM2Ab(this_group, this_group_M);
            BaseX = EstimateBaseline(A, b, sx);
            [u,v,w] = FactTensorACLS(this_group-BaseX, this_rank, this_group_M, false, epsilon, 50, 1e-8, 0);

            est_group = tensorprod(u,v,w) + BaseX;
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;

            % tmp = this_group - est_group;
            % fprintf('mean=%f\n', mean(tmp(:)) );

        elseif strcmpi(option_type, 'svd_base_knn')
            %% svd_base
            % this_rank = this_rank / 2;
            [A, b] = XM2Ab(this_group, this_group_M);
            BaseX = EstimateBaseline(A, b, sx);
            [u,v,w] = FactTensorACLS(this_group-BaseX, this_rank, this_group_M, false, epsilon, 50, 1e-8, 0);

            est_group = tensorprod(u,v,w) + BaseX;
            est_group = max(0, est_group);

            %% KNN
            Z = est_group;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = est_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*est_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                    end
                end
            end
            
            est_group = Z;


            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;

        elseif strcmpi(option_type, 'knn')

            Z = this_group;
            Z(~this_group_M) = 0;

            maxDist = 3;
            EPS = 1e-3;

            for i = 1:size(Z,1)
                for j = find(this_group_M(i,:) == 0);
                    ind = find((this_group_M(i,:)==1) & (abs((1:size(Z,2)) - j) <= maxDist));
                    if (~isempty(ind))
                        Y  = this_group(:,ind);
                        C  = Y'*Y;
                        nc = size(C,1);
                        C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
                        w  = C\(Y'*this_group(:,j));
                        w  = reshape(w,1,nc);
                        Z(i,j) = sum(this_group(i,ind).*w);
                    end
                end
            end
            
            est_group = Z;
        

            %% space
            % space = space + (prod(size(u4)) + prod(size(v4)) ) * ele_size;

        elseif strcmpi(option_type, 'nmf')
            %% nmf
            % this_rank = this_rank / 2;
            [u,v,w] = ntf(this_group, this_rank, this_group_M, 'L2', 200, epsilon);
            est_group = tensorprod(u,v,w);
            est_group = max(0, est_group);

            %% space
            space = space + (prod(size(u)) + prod(size(v)) + prod(size(w))) * ele_size;
        else
            error('wrong option type');
        end


        % dlmwrite(['./tmp_output/' option_type '.lr' num2str(loss_rate) '.txt'], est_group, 'delimiter', '\t');
        % dlmwrite(['./tmp_output/data.txt'], this_group, 'delimiter', '\t');
        % dlmwrite(['./tmp_output/missing.lr' num2str(loss_rate) '.txt'], ~this_group_M, 'delimiter', '\t');
        

        if strcmpi(option_dim, '3d')
            compared_data(:, :, gop_s:gop_e) = est_group;
        elseif strcmpi(option_dim, '2d')
            compared_data(:, :, gop_s:gop_e) = reshape(est_group, orig_sx);
        else
            error(['wrong option_dim: ' option_type]);
        end


        % tmp = abs(compared_data - data);
        % fprintf('mean=%f\n', mean(tmp(:)) );
    end


    %% --------------------
    %% Error
    %% --------------------
    % data = orig_data;
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

    fprintf('mse=%f, mae=%f, cc=%f, ratio=%f\n', mse, mae, cc, ratio);


    % mae_ts = zeros(1, num_frames);
    % for f = 1:num_frames
    %     data_f          = data(:,:,f);
    %     M_f             = M(:,:,f);
    %     compared_data_f = compared_data(:,:,f);

    %     mae_ts(f) = mean(abs((data_f(~M_f) - max(0,compared_data_f(~M_f))))) / meanX;
    %     % fprintf('%f (%f, %f)\n', mae_ts(f), )
    % end
    % dlmwrite('./tmp_output/err_ts.txt', mae_ts, 'delimiter', '\n');
    




    %% --------------------
    %% detect anomaly
    %% --------------------
    % if strcmpi(option_type, 'lens') ~= 1 & strcmpi(option_type, 'lens_knn') ~= 1 & strcmpi(option_type, 'lens_knn2') ~= 1 & strcmpi(option_type, 'srmf_lens_knn') ~= 1
    %     % detect_anomaly = (abs(data - compared_data) > thresh*std(data(:)));
    %     detect_anomaly = data - compared_data;
    % end
    if strcmpi(option_type, 'lens') | ...
       strcmpi(option_type, 'lens_knn') | ...
       strcmpi(option_type, 'lens_knn2') | ...
       strcmpi(option_type, 'srmf_lens_knn') | ...
       strcmpi(option_type, 'srmf_lens_knn2') | ...
       strcmpi(option_type, 'lens_st') | ...
       strcmpi(option_type, 'lens_st_knn') | ...
       strcmpi(option_type, 'lens_st_knn2') | ...
       strcmpi(option_type, 'srmf_lens_st_knn') | ...
       strcmpi(option_type, 'srmf_lens_st_knn2') | ...
       strcmpi(option_type, 'lens_no_st') | ...
       strcmpi(option_type, 'lens3') | ...
       strcmpi(option_type, 'lens3_knn') | ...
       strcmpi(option_type, 'srmf_lens3_knn')
        if thresh > -1
            thresh = lens_thresh;
        end

        if nnz(detect_anomaly) < 10
            detect_anomaly = data - compared_data;
        end
    elseif strcmpi(option_type, 'srmf') | ...
       strcmpi(option_type, 'srmf_knn') | ...
       strcmpi(option_type, 'svd') | ...
       strcmpi(option_type, 'svd_base') | ...
       strcmpi(option_type, 'svd_base_knn') | ...
       strcmpi(option_type, 'nmf') | ...
       strcmpi(option_type, 'knn') | ...
       strcmpi(option_type, 'base')

        detect_anomaly = data - compared_data;
        if thresh > -1
            thresh = srmf_thresh;
        end

    else
        error(['wrong option type:' option_type]);
    end

    anomaly = (anomaly ~= 0);
    % detect_anomaly = (detect_anomaly ~= 0);
    % mean_det_anom = mean(abs(detect_anomaly(:)));
    % std_det_anom  = std(abs(detect_anomaly(:)));
    % detect_anomaly = (abs(detect_anomaly) > mean_det_anom+thresh*std_det_anom);
    max_det_anom   = max(abs(detect_anomaly(:)));


    if thresh == -1
        best_thresh = -1;
        best_f1     = -1;

        ranges = [0:0.01:0.2, 0.25:0.05:1];
        precs   = zeros(1, length(ranges));
        recalls = zeros(1, length(ranges));

        for ti = [1:length(ranges)]
            thresh = ranges(ti);

            tmp = (abs(detect_anomaly) > thresh*max_det_anom);
            precision = nnz(anomaly.*tmp.*M)/nnz((tmp~=0).*M);
            recall    = nnz(anomaly.*tmp.*M)/nnz((anomaly~=0).*M);
            f1score   = 2 * precision * recall / (precision + recall);

            precs(ti)   = precision;
            recalls(ti) = recall;

            if f1score > best_f1
                best_f1 = f1score;
                best_thresh = thresh;
            end
        end

        dlmwrite([output_dir filename '.' num2str(num_frames) '.' num2str(width) '.' num2str(height) '.' num2str(group_size) '.r' num2str(r) '.period' num2str(period) '.' option_swap_mat '.' option_type '.' option_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' num2str(burst_size) '.na' num2str(num_anomaly) '.anom' num2str(sigma_magnitude) '.noise' num2str(sigma_noise) '.thresh' num2str(-1) '.seed' num2str(seed) '.txt'], [ranges', precs', recalls']);

    elseif thresh == -2
        best_thresh = -1;
        best_f1     = -1;
        
        ranges = [0:0.01:0.3, 0.35:0.05:1];
        precs   = zeros(1, length(ranges));
        recalls = zeros(1, length(ranges));
        
        for ti = [1:length(ranges)]
            thresh = ranges(ti);

            tmp = (abs(detect_anomaly) > thresh*max_det_anom);
            fp = nnz((~anomaly).*detect_anomaly.*M);
            precision = nnz(anomaly.*tmp.*M)/nnz((tmp~=0).*M);
            recall    = nnz(anomaly.*tmp.*M)/nnz((anomaly~=0).*M);
            f1score   = 2 * precision * recall / (precision + recall);

            precs(ti)   = precision;
            recalls(ti) = recall;

            if (f1score > best_f1) & (fp <= 1)
                best_f1 = f1score;
                best_thresh = thresh;
            end
        end

        dlmwrite([output_dir filename '.' num2str(num_frames) '.' num2str(width) '.' num2str(height) '.' num2str(group_size) '.r' num2str(r) '.period' num2str(period) '.' option_swap_mat '.' option_type '.' option_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' num2str(burst_size) '.na' num2str(num_anomaly) '.anom' num2str(sigma_magnitude) '.noise' num2str(sigma_noise) '.thresh' num2str(-2) '.seed' num2str(seed) '.txt'], [ranges', precs', recalls']);
        
    else
        best_thresh = thresh;
    end

    detect_anomaly = (abs(detect_anomaly) > best_thresh*max_det_anom);

    tp = nnz(anomaly.*detect_anomaly.*M);
    tn = nnz((~anomaly).*(~detect_anomaly).*M);
    fp = nnz((~anomaly).*detect_anomaly.*M);
    fn = nnz(anomaly.*(~detect_anomaly).*M);

    precision = nnz(anomaly.*detect_anomaly.*M)/nnz((detect_anomaly~=0).*M);
    recall    = nnz(anomaly.*detect_anomaly.*M)/nnz((anomaly~=0).*M);
    jaccard   = nnz(anomaly.*detect_anomaly.*M)/nnz(((anomaly~=0)|(detect_anomaly~=0)).*M);
    f1score   = 2 * precision * recall / (precision + recall);

    % fprintf('err=%f\n', error_a);
    fprintf('thresh=%f\n', best_thresh);
    fprintf('tp=%f, tn=%f, fp=%f, fn=%f\n', tp, tn, fp, fn);
    fprintf('prec=%f, recall=%f, f1=%f, jaccard=%f\n', precision, recall, f1score, jaccard);


    missing = data(~M);
    pred    = compared_data(~M);
    % size(missing)
    % nnz(missing)
    ix = find(missing > 0);
    % missing(ix(1:min(10,length(ix))))'
    % pred(ix(1:min(10,length(ix))))'


    if DEBUG_WRITE == 1
        dlmwrite('tmp.txt', [find(M==0), data(~M), max(0,compared_data(~M))]);
    end
end




%% -------------------------------------
%% map_matrix: swap row and columns according to "mapping"
%% @input mapping: 
%%    a vector to map venues to the other
%%    e.g. [4, 3, 1, 2] means mapping 4->1, 3->2, 1->3, 2->4
%%
function [new_mat] = map_matrix(mat, mapping_rows, mapping_cols)
    new_mat = zeros(size(mat));
    new_mat = mat(mapping_rows, :);
    tmp = new_mat;
    new_mat = tmp(:, mapping_cols);
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

