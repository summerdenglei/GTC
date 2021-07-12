%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.01.05 @ UT Austin
%%
%% - Input:
%%
%% - Output:
%%
%% e.g. 
%%     see batch_plot_anomaly_size.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plot_anomaly_size(input_TM_dir, filename, num_frames, width, height, time_bin_size)
    addpath('../utils');


    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 0;
    DEBUG2 = 0;
    DEBUG3 = 0; %% block index check
    
    % if width ~= height
    %     fprintf('width should be equal to height: %d, %d\n', width, height);
    %     return;
    % end


    %% --------------------
    %% Constant
    %% --------------------
    

    %% --------------------
    %% Variable
    %% --------------------
    output_dir = '../processed_data/subtask_plot_TM/figures/';
    

    %% --------------------
    %% Main starts
    %% --------------------
    
    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    if strcmpi(filename, 'X') | ...
       strfind(filename, '.txt')
       % strcmpi(filename, 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs0.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs1.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs2.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs4.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs5.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs6.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs7.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs8.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs9.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs10.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs11.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs0.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs1.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs2.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs3.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs4.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs5.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs6.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs7.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs8.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs9.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs10.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.bs.bs11.all.bin60.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.all.all.bin10.txt')  | ...
       % strcmpi(filename, 'tm_3g.cell.load.top200.all.bin10.txt')  | ...
       % strcmpi(filename, 'tm_3g.cell.stable.top200.all.bin10.txt') | ...
       % strcmpi(filename, 'tm_3g.cell.rnc.all.bin10.txt')


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
    %% Add anomaly
    %% --------------------
    if DEBUG2, fprintf('Add anomaly and noise\n'); end

    tmp_sx = size(data);
    data = reshape(data, [], tmp_sx(3));
    [n, m] = size(data);

    itvl = 20;
    anom_mags = [0.2, 0.4, 0.6, 0.8, 1];
    anom_ix   = [1:length(anom_mags)] * itvl;

    % data = data(:,10:end);
    max_data = max(data(:));
    % fprintf('  max anomaly = %f, itvl = %d\n', max_data, itvl);
    anomaly = sign(rand(1, length(anom_mags))) * max_data .* anom_mags;
    % noise = randn(n, m) * max_data * 0.01;
    

    %% --------------------
    %% plot for total traffic
    %% --------------------
    if DEBUG2, fprintf('plot for total traffic\n'); end

    orig_total_ts = sum(data);
    anom_total_ts = orig_total_ts;
    % anom_total_ts(anom_ix) = anom_total_ts(anom_ix) + anomaly;
    % noise_total_ts = sum(data + noise);
    
    % plot_my([1:length(orig_total_ts)], ...
    %         [anom_total_ts; orig_total_ts], ...
    %         {'w/ anomaly', 'orig'}, ...
    %         [output_dir filename '.total.w_anomaly'], ...
    %         'time', 'traffic');

    plot_my([1:length(orig_total_ts)], ...
            [orig_total_ts], ...
            {'orig'}, ...
            [output_dir filename '.total.ts'], ...
            'time', 'traffic');


    %% --------------------
    %% plot for one OD pair
    %% --------------------
    if DEBUG2, fprintf('plot for one OD pair\n'); end

    
    [c, ix] = max(data(:));
    sx = size(data);
    [a,b] = ind2sub(sx, ix(1));

    orig_one_ts = data(a, :);
    anom_one_ts = orig_one_ts;
    % anom_one_ts(anom_ix) = anom_one_ts(anom_ix) + anomaly;
    % noise_one_ts = data(a, :) + noise(a, :);
    
    % plot_my([1:length(orig_one_ts)], ...
    %         [anom_one_ts; orig_one_ts], ...
    %         {'anomaly', 'orig ts'}, ...
    %         [output_dir filename '.one.w_anomaly'], ...
    %         'time', 'traffic');

    plot_my([1:length(orig_one_ts)], ...
            [orig_one_ts], ...
            {'orig ts'}, ...
            [output_dir filename '.one.ts'], ...
            'time', 'traffic');



    %% --------------------
    %% plot load per BS
    %% --------------------
    sx = size(data);
    fprintf('size = %d, %d\n', sx);
    loads = sum(data, 2);
    plot_my(1:length(loads), ...
            sort(loads' / 1000, 'descend'), ...
            {'load'}, ...
            [output_dir filename '.load'], ...
            'BS', 'load (Kbytes)');


    %% --------------------
    %% plot ratio of non zero element
    %% --------------------
    nnz_ratio = zeros(1, size(data,2));
    for t = 1:size(data, 2)
        nnz_ratio(t) = (size(data,1)-nnz(data(:,t)))/size(data,1);
    end

    plot_my(1:length(nnz_ratio), ...
            nnz_ratio, ...
            {'zeros'}, ...
            [output_dir filename '.zero_ratio'], ...
            'time', 'ratio of 0s');

    

    %% --------------------
    %% plot for days
    %% --------------------
    num_f_per_day = 24 * 60 / time_bin_size;
    num_days = num_frames / num_f_per_day;

    % if(num_days >= 7 & num_f_per_day > 1)
    if(0)

        %% --------------------
        %% plot for total traffic
        %% --------------------
        if DEBUG2, fprintf('plot for total traffic\n'); end

        orig_total_ts = sum(data);
        plot_my2([1:num_f_per_day], ...
                [orig_total_ts(1:num_f_per_day); ...
                 orig_total_ts(1*num_f_per_day+1:2*num_f_per_day); ...
                 orig_total_ts(2*num_f_per_day+1:3*num_f_per_day); ...
                 orig_total_ts(3*num_f_per_day+1:4*num_f_per_day); ...
                 orig_total_ts(4*num_f_per_day+1:5*num_f_per_day); ...
                 orig_total_ts(5*num_f_per_day+1:6*num_f_per_day); ...
                 orig_total_ts(6*num_f_per_day+1:7*num_f_per_day)], ...
                {'day1', 'day2', 'day3', 'day4', 'day5', 'day6', 'day7'}, ...
                [output_dir filename '.days.total.ts'], ...
                'time', 'traffic');


        %% --------------------
        %% plot for one OD pair
        %% --------------------
        if DEBUG2, fprintf('plot for one OD pair\n'); end

        
        % [c, ix] = max(data(:));
        % sx = size(data);
        % [a,b] = ind2sub(sx, ix(1));

        orig_one_ts = data(a, :);
        plot_my2([1:num_f_per_day], ...
                [orig_one_ts(1:num_f_per_day); ...
                 orig_one_ts(1*num_f_per_day+1:2*num_f_per_day); ...
                 orig_one_ts(2*num_f_per_day+1:3*num_f_per_day); ...
                 orig_one_ts(3*num_f_per_day+1:4*num_f_per_day); ...
                 orig_one_ts(4*num_f_per_day+1:5*num_f_per_day); ...
                 orig_one_ts(5*num_f_per_day+1:6*num_f_per_day); ...
                 orig_one_ts(6*num_f_per_day+1:7*num_f_per_day)], ...
                {'day1', 'day2', 'day3', 'day4', 'day5', 'day6', 'day7'}, ...
                [output_dir filename '.days.one.ts'], ...
                'time', 'traffic');
    end
end





function plot_my(x, y, legends, file, x_label, y_label)

    colors  = {'r','b','g','c','m','y','k'};
    markers = {'+','o','*','.','x','s','d','^','>','<','p','h'};
    lines   = {'-','--',':','-.'};
    font_size = 18;
    cnt = 1;

    clf;
    fh = figure;
    hold all;

    lh = zeros(1, size(y, 1));
    for yi = 1:size(y, 1)
        yy = y(yi, :);

        %% line
        lh(yi) = plot(x, yy);
        set(lh(yi), 'Color', char(colors(mod(cnt-1,length(colors))+1)));      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
        set(lh(yi), 'LineStyle', char(lines(mod(cnt-1,length(lines))+1)));
        set(lh(yi), 'LineWidth', 3);
        % if yi==1, set(lh(yi), 'LineWidth', 1); end
        % set(lh(yi), 'marker', char(markers(mod(cnt-1,length(markers))+1)));
        % set(lh(yi), 'MarkerEdgeColor', 'auto');
        % set(lh(yi), 'MarkerFaceColor', 'auto');
        % set(lh(yi), 'MarkerSize', 12);

        cnt = cnt + 1;
    end

    % set(gca, 'XTick', [0:20:140]);

    set(gca, 'FontSize', font_size);
    set(fh, 'PaperUnits', 'points');
    if strcmpi(x_label, 'time'), set(fh, 'PaperPosition', [0 0 1024 300]);
    else, set(fh, 'PaperPosition', [0 0 1024 768]); end

    xlabel(x_label, 'FontSize', font_size);
    ylabel(y_label, 'FontSize', font_size);

    kh = legend(legends);
    % set(kh, 'Box', 'off');
    set(kh, 'Location', 'BestOutside');
    % set(kh, 'Orientation', 'horizontal');
    % set(kh, 'Position', [.1,.2,.1,.2]);

    grid on;

    print(fh, '-dpng', [file '.png']);
end


function plot_my2(x, y, legends, file, x_label, y_label)

    colors  = {'r','b','g','c','m','y','k'};
    markers = {'+','o','*','.','x','s','d','^','>','<','p','h'};
    lines   = {'-','-','-','-'};
    font_size = 18;
    cnt = 1;

    clf;
    fh = figure;
    hold all;

    lh = zeros(1, size(y, 1));
    for yi = 1:size(y, 1)
        yy = y(yi, :);

        %% line
        lh(yi) = plot(x, yy);
        set(lh(yi), 'Color', char(colors(mod(cnt-1,length(colors))+1)));      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
        set(lh(yi), 'LineStyle', char(lines(mod(cnt-1,length(lines))+1)));
        set(lh(yi), 'LineWidth', 2);
        % if yi==1, set(lh(yi), 'LineWidth', 1); end
        % set(lh(yi), 'marker', char(markers(mod(cnt-1,length(markers))+1)));
        % set(lh(yi), 'MarkerEdgeColor', 'auto');
        % set(lh(yi), 'MarkerFaceColor', 'auto');
        % set(lh(yi), 'MarkerSize', 12);

        cnt = cnt + 1;
    end

    % set(gca, 'XTick', [0:20:140]);

    set(gca, 'FontSize', font_size);
    set(fh, 'PaperUnits', 'points');
    if strcmpi(x_label, 'time'), set(fh, 'PaperPosition', [0 0 1024 300]);
    else, set(fh, 'PaperPosition', [0 0 1024 768]); end

    xlabel(x_label, 'FontSize', font_size);
    ylabel(y_label, 'FontSize', font_size);

    kh = legend(legends);
    % set(kh, 'Box', 'off');
    set(kh, 'Location', 'BestOutside');
    % set(kh, 'Orientation', 'horizontal');
    % set(kh, 'Position', [.1,.2,.1,.2]);

    grid on;

    print(fh, '-dpng', [file '.png']);
end
