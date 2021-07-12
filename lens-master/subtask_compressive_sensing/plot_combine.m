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

function plot_combine()
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
    input_dir  = './tmp_output/';
    output_dir = './tmp_output/figures/';
    

    %% --------------------
    %% Main starts
    %% --------------------
    
    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    real_anomaly = load([input_dir 'anomaly.txt']);
    dect_anomaly = load([input_dir 'Y.txt']);

    missing = load([input_dir 'M.txt']);
    new_missing = load([input_dir 'new_M.txt']);

    data = load([input_dir 'data.txt']);
    srmf = load([input_dir 'srmf.txt']);
    srmf_after_lens = load([input_dir 'srmf_after_lens.txt']);
    combine = load([input_dir 'combine.txt']);




    % for ix = [38, 64, 101]
    for ix = [1:121]

        tmp = real_anomaly(ix,:);
        real_anom_ix  = find(abs(tmp) > 0);
        % real_anom_val = tmp(real_anom_ix);
        real_anom_val = zeros(1, length(real_anom_ix));
        tmp = dect_anomaly(ix,:);
        dect_anom_ix  = find(abs(tmp) > 0);
        % dect_anom_val = tmp(dect_anom_ix);
        dect_anom_val = zeros(1, length(dect_anom_ix));

        if(length(real_anom_ix) > 0) 
            if(length(dect_anom_ix) > 0) 
                legends = {'data', 'SRMF', 'SRMF w/ Y', 'Combined', 'Real Anomaly', 'Detected Anomaly'};
            else 
                legends = {'data', 'SRMF', 'SRMF w/ Y', 'Combined', 'Real Anomaly'};
            end
        else
            if(length(dect_anom_ix) > 0) 
                legends = {'data', 'SRMF', 'SRMF w/ Y', 'Combined', 'Detected Anomaly'};
            else 
                legends = {'data', 'SRMF', 'SRMF w/ Y', 'Combined'};
            end
        end

        plot_my(1:size(data,2), ...
                [data(ix, :); ...
                 srmf(ix, :); ...
                 srmf_after_lens(ix, :); ...
                 combine(ix, :);], ...
                [real_anom_ix; real_anom_val], ...
                [dect_anom_ix; dect_anom_val], ...
                legends, ...
                ... %[output_dir 'abilene.pred0.6.anom0.4.row' int2str(ix)], ...
                [output_dir 'abilene.pred0.6.anom0.row' int2str(ix)], ...
                'Time', '');
    end
end





function plot_my(x, y, anom1, anom2, legends, file, x_label, y_label)

    colors  = {'r','b','g','c','m','y','k'};
    markers = {'+','o','*','.','x','s','d','^','>','<','p','h'};
    lines   = {'-','--','-.',':'};
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
        set(lh(yi), 'Color', char(colors(mod(cnt-1,length(lines))+1)));      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
        set(lh(yi), 'LineStyle', char(lines(mod(cnt-1,length(lines))+1)));
        set(lh(yi), 'LineWidth', 3);
        if yi==1, set(lh(yi), 'LineWidth', 4); end
        if yi==2, set(lh(yi), 'LineWidth', 3); end
        if yi==3, set(lh(yi), 'LineWidth', 3); end
        if yi==4, set(lh(yi), 'LineWidth', 2); end
        % set(lh(yi), 'marker', char(markers(mod(cnt-1,length(markers))+1)));
        % set(lh(yi), 'MarkerEdgeColor', 'auto');
        % set(lh(yi), 'MarkerFaceColor', 'auto');
        % set(lh(yi), 'MarkerSize', 12);

        cnt = cnt + 1;
    end

    stem(anom1(1,:), anom1(2,:), 'filled', 'm', 'LineWidth', 2, 'marker', 'o');
    stem(anom2(1,:), anom2(2,:), 'filled', 'y', 'LineWidth', 2, 'marker', '+');
    % anom1
    % anom2

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
