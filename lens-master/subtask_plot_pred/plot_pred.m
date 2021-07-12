%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
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

function plot_pred()
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;

    PLOT_PCA_RANK  = 0;
    PLOT_DCT_VAR   = 0;
    PLOT_SRMF_RANK = 0;
    PLOT_LC_VAR    = 0;
    PLOT_PURE_RAND = 1;
    PLOT_TIME_RAND = 1;
    PLOT_ELEM_RAND = 1;
    PLOT_ELEM_SYNC = 1;
    PLOT_ROW_RAND  = 1;
    PLOT_COL_RAND  = 1;

    PLOT_FORMAL    = 1;


    %% --------------------
    %% Variable
    %% --------------------
    pca_dir     = '../condor_data/subtask_pca/condor/output/';
    dct_dir     = '../condor_data/subtask_3ddct/condor/output/';
    srmf_dir    = '../condor_data/subtask_compressive_sensing/condor/output/';
    mpeg_dir    = '../condor_data/subtask_mpeg/condor/output/';
    mpeg_lc_dir = '../condor_data/subtask_mpeg_lc/condor/output/';
    output_dir = '../processed_data/subtask_plot_pred/figures/';

    seeds  = [1:5];


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% PCA, rank
    %% --------------------
    if(PLOT_PCA_RANK)
        fprintf('PCA, rank\n');

        scheme = 'pca_based_pred';

        % 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.'
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')

                num_frames = 24;
                width      = 120;
                height     = 100;

                block_w    = 120;
                block_h    = 100;
                ranks      = [1, 3, 5, 10, 20, 24];

                opt_swap_mat = 'org';
                opt_dim      = '2d';

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                block_w    = 60;
                block_h    = 60;
                ranks      = [1, 3, 5, 10, 20, 24];

                opt_swap_mat = 'org';
                opt_dim      = '2d';

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                block_w    = 217;
                block_h    = 400;
                ranks      = [1, 3, 10, 20];

                opt_swap_mat = 'org';
                opt_dim      = '2d';

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                block_w    = 23;
                block_h    = 23;
                ranks      = [1 3 5 10 30 50 100];

                opt_swap_mat = 'org';
                opt_dim      = '2d';

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            end
                    

            cnts   = zeros(size(ranks));
            mses   = zeros(size(ranks));
            maes   = zeros(size(ranks));
            ccs    = zeros(size(ranks));
            ratios = zeros(size(ranks));
            for i = [1:length(ranks)]
                r = ranks(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([pca_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [pca_dir filename]);
                    data = load([pca_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end

            clf;
            fh = figure;
            font_size = 28;

            bh1 = bar(ranks, ratios);
            set(bh1, 'BarWidth', 0.6);
            set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh1, 'FaceColor', 'g');
            set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh1, 'LineWidth', 2);
            hold on;

            lh1 = plot(ranks, mses);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 10);
            hold on;

            lh2 = plot(ranks, maes);
            set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(ranks, ccs);
            set(lh3, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);        
            
            kh = legend([lh1, lh2, lh3, bh1], 'MSE', 'MAE', 'CC', 'space');
            set(kh, 'Box', 'off');
            set(kh, 'Location', 'NorthOutside');
            set(kh, 'Orientation', 'horizontal');
            % set(kh, 'Position', [.1,.2,.1,.2]);

            set(fh, 'PaperUnits', 'points');
            set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [0 Inf]);
            set(gca, 'YLim', [0 1]);

            xlabel('rank', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            set(gca, 'FontSize', font_size);
            

            print(fh, '-dpng', [output_dir file '.pca.rank.png']);
        end
    end %% end of plot


    %% --------------------
    %% DCT - single, chunk, gop=4
    %% --------------------
    if(PLOT_DCT_VAR)
        fprintf('\nDCT - single, chunk\n');

        scheme = 'dct_based_pred';
        
        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')

                num_frames = 24;
                width      = 120;
                height     = 100;

                opt_swap_mat = 'org';
                chunk_w    = 12;
                chunk_h    = 10;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                opt_swap_mat = 'org';
                chunk_w    = 6;
                chunk_h    = 6;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                opt_swap_mat = 'org';
                chunk_w    = 22;
                chunk_h    = 40;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;
                quantizations = [1 50 100];

                opt_swap_mat = 'org';
                chunk_w    = 4;
                chunk_h    = 4;

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            end

            
            num_lines = 6;
            gop = 4;
            cnts   = zeros(1, num_lines);
            mses   = zeros(1, num_lines);
            maes   = zeros(1, num_lines);
            ccs    = zeros(1, num_lines);
            ratios = zeros(1, num_lines);
            ix = 1;

            %% single, quantizations=(0.1 50 100)
            opt_type = 'single';
            for quan = quantizations
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        % fprintf(' %s%s not exist\n', dct_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(ix)   = mses(ix) + data(1);
                    maes(ix)   = maes(ix) + data(2);
                    ccs(ix)    = ccs(ix) + data(3);
                    ratios(ix) = ratios(ix) + data(4);
                    cnts(ix) = cnts(ix) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(ix) > 1)
                    mses(ix)   = mses(ix) / cnts(ix);
                    maes(ix)   = maes(ix) / cnts(ix);
                    ccs(ix)    = ccs(ix) / cnts(ix);
                    ratios(ix) = ratios(ix) / cnts(ix);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', ix, mses(ix), maes(ix), ccs(ix), ratios(ix));

                ix = ix + 1;
            end

            %% chunk, sel_chunkss=(1 50 200)
            opt_type = 'chunk';
            sel_chunkss = [1 50 200];
            for sel_chunks = sel_chunkss
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(ix)   = mses(ix) + data(1);
                    maes(ix)   = maes(ix) + data(2);
                    ccs(ix)    = ccs(ix) + data(3);
                    ratios(ix) = ratios(ix) + data(4);
                    cnts(ix) = cnts(ix) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(ix) > 1)
                    mses(ix)   = mses(ix) / cnts(ix);
                    maes(ix)   = maes(ix) / cnts(ix);
                    ccs(ix)    = ccs(ix) / cnts(ix);
                    ratios(ix) = ratios(ix) / cnts(ix);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', ix, mses(ix), maes(ix), ccs(ix), ratios(ix));

                ix = ix + 1;
            end

            clf;
            fh = figure;
            font_size = 28;

            bh1 = bar(ratios);
            set(bh1, 'BarWidth', 0.6);
            set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh1, 'FaceColor', 'g');
            set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh1, 'LineWidth', 2);
            hold on;

            lh1 = plot(mses);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 10);
            hold on;

            lh2 = plot(maes);
            set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(ccs);
            set(lh3, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);        
            
            set(gca, 'FontSize', font_size);
            set(gca, 'Position', [0.1 0.2 0.8 0.8]);
            
            kh = legend([lh1, lh2, lh3, bh1], 'MSE', 'MAE', 'CC', 'space');
            set(kh, 'Box', 'off');
            set(kh, 'Location', 'NorthOutside');
            set(kh, 'Orientation', 'horizontal');
            % set(kh, 'Position', [.1,.2,.1,.2]);

            set(fh, 'PaperUnits', 'points');
            set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [0 Inf]);
            % set(gca, 'YLim', [0 1]);

            set(gca, 'XTickLabel', {'quan=1', 'quan=50', 'quan=100', '#chunks=1', '#chunks=50', '#chunks=200'});
            XTickLabel = get(gca,'XTickLabel');
            set(gca,'XTickLabel',' ');
            XTick = get(gca,'XTick');
            y = repmat(-0.1,length(XTick),1) + 0.03;
            fs = get(gca,'fontsize');
            hText = text(XTick, y, XTickLabel,'fontsize',fs);
            set(hText,'Rotation',-45,'HorizontalAlignment','left');

            
            % xlabel('rank', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            print(fh, '-dpng', [output_dir file '.dct.gop4.png']);
        end
    end %% end of plot


    %% --------------------
    %% DCT - single, chunk, gop=max
    %% --------------------
    if(PLOT_DCT_VAR)
        fprintf('\nDCT - single, chunk\n');

        scheme = 'dct_based_pred';
        
        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')

                num_frames = 24;
                width      = 120;
                height     = 100;

                opt_swap_mat = 'org';
                chunk_w    = 12;
                chunk_h    = 10;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                opt_swap_mat = 'org';
                chunk_w    = 6;
                chunk_h    = 6;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                opt_swap_mat = 'org';
                chunk_w    = 22;
                chunk_h    = 40;
                quantizations = [0.1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                opt_swap_mat = 'org';
                chunk_w    = 4;
                chunk_h    = 4;
                quantizations = [1 50 100];

                drop_ele_mode = 'elem';
                drop_mode     = 'ind';
                elem_frac     = 0.3;
                loss_rate     = 0.1;
                burst_size    = 1;
            end

            
            num_lines = 6;
            gop = num_frames;
            cnts   = zeros(1, num_lines);
            mses   = zeros(1, num_lines);
            maes   = zeros(1, num_lines);
            ccs    = zeros(1, num_lines);
            ratios = zeros(1, num_lines);
            ix = 1;

            %% single, quantizations=(0.1 50 100)
            opt_type = 'single';
            for quan = quantizations
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        % fprintf(' %s%s not exist\n', dct_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(ix)   = mses(ix) + data(1);
                    maes(ix)   = maes(ix) + data(2);
                    ccs(ix)    = ccs(ix) + data(3);
                    ratios(ix) = ratios(ix) + data(4);
                    cnts(ix) = cnts(ix) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(ix) > 1)
                    mses(ix)   = mses(ix) / cnts(ix);
                    maes(ix)   = maes(ix) / cnts(ix);
                    ccs(ix)    = ccs(ix) / cnts(ix);
                    ratios(ix) = ratios(ix) / cnts(ix);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', ix, mses(ix), maes(ix), ccs(ix), ratios(ix));

                ix = ix + 1;
            end

            %% chunk, sel_chunkss=(1 50 200)
            opt_type = 'chunk';
            sel_chunkss = [1 50 200];
            for sel_chunks = sel_chunkss
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(ix)   = mses(ix) + data(1);
                    maes(ix)   = maes(ix) + data(2);
                    ccs(ix)    = ccs(ix) + data(3);
                    ratios(ix) = ratios(ix) + data(4);
                    cnts(ix) = cnts(ix) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(ix) > 1)
                    mses(ix)   = mses(ix) / cnts(ix);
                    maes(ix)   = maes(ix) / cnts(ix);
                    ccs(ix)    = ccs(ix) / cnts(ix);
                    ratios(ix) = ratios(ix) / cnts(ix);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', ix, mses(ix), maes(ix), ccs(ix), ratios(ix));

                ix = ix + 1;
            end

            clf;
            fh = figure;
            font_size = 28;

            bh1 = bar(ratios);
            set(bh1, 'BarWidth', 0.6);
            set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh1, 'FaceColor', 'g');
            set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh1, 'LineWidth', 2);
            hold on;

            lh1 = plot(mses);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 10);
            hold on;

            lh2 = plot(maes);
            set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(ccs);
            set(lh3, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);        
            
            set(gca, 'FontSize', font_size);
            set(gca, 'Position', [0.1 0.2 0.8 0.8]);
            
            kh = legend([lh1, lh2, lh3, bh1], 'MSE', 'MAE', 'CC', 'space');
            set(kh, 'Box', 'off');
            set(kh, 'Location', 'NorthOutside');
            set(kh, 'Orientation', 'horizontal');
            % set(kh, 'Position', [.1,.2,.1,.2]);

            set(fh, 'PaperUnits', 'points');
            set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [0 Inf]);
            % set(gca, 'YLim', [0 1]);

            set(gca, 'XTickLabel', {'quan=1', 'quan=50', 'quan=100', '#chunks=1', '#chunks=50', '#chunks=200'});
            XTickLabel = get(gca,'XTickLabel');
            set(gca,'XTickLabel',' ');
            XTick = get(gca,'XTick');
            y = repmat(-0.1,length(XTick),1) + 0.03;
            fs = get(gca,'fontsize');
            hText = text(XTick, y, XTickLabel,'fontsize',fs);
            set(hText,'Rotation',-45,'HorizontalAlignment','left');

            
            % xlabel('rank', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            print(fh, '-dpng', [output_dir file '.dct.gop' int2str(gop) '.png']);
        end
    end %% end of plot


    %% --------------------
    %% SRMF, RANK
    %% --------------------
    if(PLOT_SRMF_RANK)
        fprintf('\nSRMF, RANK\n');

        scheme = 'srmf_based_pred';
        
        
        opt_types = {'srmf', 'srmf_knn', 'svd', 'lens'};
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                ranks      = [1, 5, 10, 20, 24];

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                ranks      = [1, 5, 10, 20, 24];

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                ranks      = [1 5 10 50 100];

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                ranks      = [1 5 10 30 50 100];

            end

            gop          = num_frames;
            opt_swap_mat = 'org';
            opt_dim      = '2d';

            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_frac     = 0.3;
            loss_rate     = 0.1;
            burst_size    = 1;
                    

            for opt_type = opt_types
                opt_type = char(opt_type);

                cnts   = zeros(size(ranks));
                mses   = zeros(size(ranks));
                maes   = zeros(size(ranks));
                ccs    = zeros(size(ranks));
                ratios = zeros(size(ranks));
                for i = [1:length(ranks)]
                    r = ranks(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end

                clf;
                fh = figure;
                font_size = 28;

                bh1 = bar(ranks, ratios);
                set(bh1, 'BarWidth', 0.6);
                set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(bh1, 'FaceColor', 'g');
                set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(bh1, 'LineWidth', 2);
                hold on;

                lh1 = plot(ranks, mses);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(ranks, maes);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(ranks, ccs);
                set(lh3, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);        
                
                kh = legend([lh1, lh2, lh3, bh1], 'MSE', 'MAE', 'CC', 'space');
                set(kh, 'Box', 'off');
                set(kh, 'Location', 'NorthOutside');
                set(kh, 'Orientation', 'horizontal');
                % set(kh, 'Position', [.1,.2,.1,.2]);

                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('rank', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                

                print(fh, '-dpng', [output_dir file '.srmf.' opt_type '.rank.png']);
            end  %% end of types
        end
    end %% end of plot


    %% --------------------
    %% Linear Combination - local
    %% --------------------
    if(PLOT_LC_VAR)
        fprintf('\nLinear Combination\n');

        scheme = 'mpeg_lc_based_pred';
        
        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')

                num_frames = 24;
                width      = 120;
                height     = 100;

                block_w    = 12;
                block_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                block_w    = 6;
                block_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                block_w    = 22;
                block_h    = 40;
                
            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                block_w    = 4;
                block_h    = 4;
                
            end

            % num_sel_blocks_globals = [16 32 64 128];
            num_sel_blocks_locals  = [8 16 64];

            opt_swap_mat    = 'org';
            opt_delta       = 'diff';
            % opt_fill_ins    = {'fill', 'no_fill'};
            % opt_scopes      = {'local', 'global'};
            % opt_sel_methods = {'mae', 'dct'};
            opt_scope = 'local';

            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_frac     = 0.3;
            loss_rate     = 0.1;
            burst_size    = 1;

            
            %% mae - fill
            opt_fill_in    = 'fill';
            opt_sel_method = 'mae';
            mae_cnts1   = zeros(1, length(num_sel_blocks_locals));
            mae_mses1   = zeros(1, length(num_sel_blocks_locals));
            mae_maes1   = zeros(1, length(num_sel_blocks_locals));
            mae_ccs1    = zeros(1, length(num_sel_blocks_locals));
            mae_ratios1 = zeros(1, length(num_sel_blocks_locals));
            
            cnts   = zeros(1, length(num_sel_blocks_locals));
            mses   = zeros(1, length(num_sel_blocks_locals));
            maes   = zeros(1, length(num_sel_blocks_locals));
            ccs    = zeros(1, length(num_sel_blocks_locals));
            ratios = zeros(1, length(num_sel_blocks_locals));
            
            for i = [1:length(num_sel_blocks_locals)]
                num_sel_blocks_local = num_sel_blocks_locals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_local) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            mae_cnts1   = cnts;
            mae_mses1   = mses;
            mae_maes1   = maes;
            mae_ccs1    = ccs;
            mae_ratios1 = ratios;


            %% mae - no fill
            opt_fill_in    = 'no_fill';
            opt_sel_method = 'mae';
            mae_cnts2   = zeros(1, length(num_sel_blocks_locals));
            mae_mses2   = zeros(1, length(num_sel_blocks_locals));
            mae_maes2   = zeros(1, length(num_sel_blocks_locals));
            mae_ccs2    = zeros(1, length(num_sel_blocks_locals));
            mae_ratios2 = zeros(1, length(num_sel_blocks_locals));
            
            cnts   = zeros(1, length(num_sel_blocks_locals));
            mses   = zeros(1, length(num_sel_blocks_locals));
            maes   = zeros(1, length(num_sel_blocks_locals));
            ccs    = zeros(1, length(num_sel_blocks_locals));
            ratios = zeros(1, length(num_sel_blocks_locals));
            
            for i = [1:length(num_sel_blocks_locals)]
                num_sel_blocks_local = num_sel_blocks_locals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_local) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            mae_cnts2   = cnts;
            mae_mses2   = mses;
            mae_maes2   = maes;
            mae_ccs2    = ccs;
            mae_ratios2 = ratios;


            %% dct
            opt_fill_in    = 'fill';
            opt_sel_method = 'dct';
            dct_cnts1   = zeros(1, length(num_sel_blocks_locals));
            dct_mses1   = zeros(1, length(num_sel_blocks_locals));
            dct_maes1   = zeros(1, length(num_sel_blocks_locals));
            dct_ccs1    = zeros(1, length(num_sel_blocks_locals));
            dct_ratios1 = zeros(1, length(num_sel_blocks_locals));
            
            cnts   = zeros(1, length(num_sel_blocks_locals));
            mses   = zeros(1, length(num_sel_blocks_locals));
            maes   = zeros(1, length(num_sel_blocks_locals));
            ccs    = zeros(1, length(num_sel_blocks_locals));
            ratios = zeros(1, length(num_sel_blocks_locals));
            
            for i = [1:length(num_sel_blocks_locals)]
                num_sel_blocks_local = num_sel_blocks_locals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_local) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            dct_cnts1   = cnts;
            dct_mses1   = mses;
            dct_maes1   = maes;
            dct_ccs1    = ccs;
            dct_ratios1 = ratios;


            clf;
            fh = figure;
            font_size = 20;

            bh1 = bar(num_sel_blocks_locals, mae_ratios1);
            set(bh1, 'BarWidth', 0.6);
            set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh1, 'FaceColor', 'r');
            set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh1, 'LineWidth', 2);
            hold on;

            bh2 = bar(num_sel_blocks_locals, mae_ratios2);
            set(bh2, 'BarWidth', 0.6);
            set(bh2, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh2, 'FaceColor', 'g');
            set(bh2, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh2, 'LineWidth', 2);
            hold on;

            bh3 = bar(num_sel_blocks_locals, dct_ratios1);
            set(bh3, 'BarWidth', 0.6);
            set(bh3, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh3, 'FaceColor', 'b');
            set(bh3, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh3, 'LineWidth', 2);
            hold on;

            lh1 = plot(num_sel_blocks_locals, mae_mses1);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 12);
            hold on;

            lh2 = plot(num_sel_blocks_locals, mae_maes1);
            set(lh2, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(num_sel_blocks_locals, mae_ccs1);
            set(lh3, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);

            %% mae - fill
            lh4 = plot(num_sel_blocks_locals, mae_mses2);
            set(lh4, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh4, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh4, 'LineWidth', 4);
            set(lh4, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh4, 'MarkerEdgeColor', 'auto');
            set(lh4, 'MarkerFaceColor', 'auto');
            set(lh4, 'MarkerSize', 12);
            hold on;

            lh5 = plot(num_sel_blocks_locals, mae_maes2);
            set(lh5, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh5, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh5, 'LineWidth', 4);
            set(lh5, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh5, 'MarkerEdgeColor', 'auto');
            set(lh5, 'MarkerFaceColor', 'auto');
            set(lh5, 'MarkerSize', 12);
            hold on;

            lh6 = plot(num_sel_blocks_locals, mae_ccs2);
            set(lh6, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh6, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh6, 'LineWidth', 4);
            set(lh6, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh6, 'MarkerEdgeColor', 'auto');
            set(lh6, 'MarkerFaceColor', 'auto');
            set(lh6, 'MarkerSize', 12);

            %% dct
            lh7 = plot(num_sel_blocks_locals, dct_mses1);
            set(lh7, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh7, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh7, 'LineWidth', 4);
            set(lh7, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh7, 'MarkerEdgeColor', 'auto');
            set(lh7, 'MarkerFaceColor', 'auto');
            set(lh7, 'MarkerSize', 12);
            hold on;

            lh8 = plot(num_sel_blocks_locals, dct_maes1);
            set(lh8, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh8, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh8, 'LineWidth', 4);
            set(lh8, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh8, 'MarkerEdgeColor', 'auto');
            set(lh8, 'MarkerFaceColor', 'auto');
            set(lh8, 'MarkerSize', 12);
            hold on;

            lh9 = plot(num_sel_blocks_locals, dct_ccs1);
            set(lh9, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh9, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh9, 'LineWidth', 4);
            set(lh9, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh9, 'MarkerEdgeColor', 'auto');
            set(lh9, 'MarkerFaceColor', 'auto');
            set(lh9, 'MarkerSize', 12);
            

            set(gca, 'FontSize', font_size);
            % set(gca, 'Position', [0.1 0.2 0.8 0.8]);
            
            if(1)
                set(bh1, 'Visible', 'off');
                set(bh2, 'Visible', 'off');
                set(bh3, 'Visible', 'off');

                kh = legend([lh1, lh2, lh3, ...
                             lh4, lh5, lh6, ...
                             lh7, lh8, lh9], ...
                             'MSE:MAE-Fill', 'MAE:MAE-Fill', 'CC:MAE-Fill', ...
                             'MSE:MAE-NoFill', 'MAE:MAE-NoFill', 'CC:MAE-NoFill', ...
                             'MSE:DCT', 'MAE:DCT', 'CC:DCT');
            else
                kh = legend([lh1, lh2, lh3, bh1, ...
                             lh4, lh5, lh6, bh2, ...
                             lh7, lh8, lh9, bh3], ...
                             'MSE:MAE-Fill', 'MAE:MAE-Fill', 'CC:MAE-Fill', 'Space:MAE-Fill', ...
                             'MSE:MAE-NoFill', 'MAE:MAE-NoFill', 'CC:MAE-NoFill', 'Space:MAE-NoFill', ...
                             'MSE:DCT', 'MAE:DCT', 'CC:DCT', 'Space:DCT');
            end
            % set(kh, 'Box', 'off');
            set(kh, 'Location', 'BestOutside');
            % set(kh, 'Orientation', 'horizontal');
            % set(kh, 'Position', [.1,.2,.1,.2]);

            % set(fh, 'PaperUnits', 'points');
            % set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [1 Inf]);
            set(gca, 'YLim', [0 1]);

            % set(gca, 'XTickLabel', {'quan=0.1', 'quan=50', 'quan=100', '#chunks=1', '#chunks=50', '#chunks=200'});
            % XTickLabel = get(gca,'XTickLabel');
            % set(gca,'XTickLabel',' ');
            % XTick = get(gca,'XTick');
            % y = repmat(-0.1,length(XTick),1) + 0.03;
            % fs = get(gca,'fontsize');
            % hText = text(XTick, y, XTickLabel,'fontsize',fs);
            % set(hText,'Rotation',-45,'HorizontalAlignment','left');

            
            xlabel('# blocks', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            print(fh, '-dpng', [output_dir file '.mpeg_lc.local.png']);
        end
    end %% end of plot


    %% --------------------
    %% Linear Combination - global
    %% --------------------
    if(PLOT_LC_VAR)
        fprintf('\nLinear Combination\n');

        scheme = 'mpeg_lc_based_pred';
        
        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')

                num_frames = 24;
                width      = 120;
                height     = 100;

                block_w    = 12;
                block_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                block_w    = 6;
                block_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                block_w    = 22;
                block_h    = 40;
                
            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                block_w    = 4;
                block_h    = 4;
                
            end

            num_sel_blocks_globals = [16 32 64 128];
            % num_sel_blocks_locals  = [8 16 64];

            opt_swap_mat    = 'org';
            opt_delta       = 'diff';
            % opt_fill_ins    = {'fill', 'no_fill'};
            % opt_scopes      = {'local', 'global'};
            % opt_sel_methods = {'mae', 'dct'};
            opt_scope = 'global';

            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_frac     = 0.3;
            loss_rate     = 0.1;
            burst_size    = 1;

            
            %% mae - fill
            opt_fill_in    = 'fill';
            opt_sel_method = 'mae';
            mae_cnts1   = zeros(1, length(num_sel_blocks_globals));
            mae_mses1   = zeros(1, length(num_sel_blocks_globals));
            mae_maes1   = zeros(1, length(num_sel_blocks_globals));
            mae_ccs1    = zeros(1, length(num_sel_blocks_globals));
            mae_ratios1 = zeros(1, length(num_sel_blocks_globals));
            
            cnts   = zeros(1, length(num_sel_blocks_globals));
            mses   = zeros(1, length(num_sel_blocks_globals));
            maes   = zeros(1, length(num_sel_blocks_globals));
            ccs    = zeros(1, length(num_sel_blocks_globals));
            ratios = zeros(1, length(num_sel_blocks_globals));
            
            for i = [1:length(num_sel_blocks_globals)]
                num_sel_blocks_global = num_sel_blocks_globals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_global) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            mae_cnts1   = cnts;
            mae_mses1   = mses;
            mae_maes1   = maes;
            mae_ccs1    = ccs;
            mae_ratios1 = ratios;


            %% mae - no fill
            opt_fill_in    = 'no_fill';
            opt_sel_method = 'mae';
            mae_cnts2   = zeros(1, length(num_sel_blocks_globals));
            mae_mses2   = zeros(1, length(num_sel_blocks_globals));
            mae_maes2   = zeros(1, length(num_sel_blocks_globals));
            mae_ccs2    = zeros(1, length(num_sel_blocks_globals));
            mae_ratios2 = zeros(1, length(num_sel_blocks_globals));
            
            cnts   = zeros(1, length(num_sel_blocks_globals));
            mses   = zeros(1, length(num_sel_blocks_globals));
            maes   = zeros(1, length(num_sel_blocks_globals));
            ccs    = zeros(1, length(num_sel_blocks_globals));
            ratios = zeros(1, length(num_sel_blocks_globals));
            
            for i = [1:length(num_sel_blocks_globals)]
                num_sel_blocks_global = num_sel_blocks_globals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_global) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            mae_cnts2   = cnts;
            mae_mses2   = mses;
            mae_maes2   = maes;
            mae_ccs2    = ccs;
            mae_ratios2 = ratios;


            %% dct
            opt_fill_in    = 'fill';
            opt_sel_method = 'dct';
            dct_cnts1   = zeros(1, length(num_sel_blocks_globals));
            dct_mses1   = zeros(1, length(num_sel_blocks_globals));
            dct_maes1   = zeros(1, length(num_sel_blocks_globals));
            dct_ccs1    = zeros(1, length(num_sel_blocks_globals));
            dct_ratios1 = zeros(1, length(num_sel_blocks_globals));
            
            cnts   = zeros(1, length(num_sel_blocks_globals));
            mses   = zeros(1, length(num_sel_blocks_globals));
            maes   = zeros(1, length(num_sel_blocks_globals));
            ccs    = zeros(1, length(num_sel_blocks_globals));
            ratios = zeros(1, length(num_sel_blocks_globals));
            
            for i = [1:length(num_sel_blocks_globals)]
                num_sel_blocks_global = num_sel_blocks_globals(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.' int2str(num_sel_blocks_global) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            dct_cnts1   = cnts;
            dct_mses1   = mses;
            dct_maes1   = maes;
            dct_ccs1    = ccs;
            dct_ratios1 = ratios;


            clf;
            fh = figure;
            font_size = 20;

            bh1 = bar(num_sel_blocks_globals, mae_ratios1);
            set(bh1, 'BarWidth', 0.6);
            set(bh1, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh1, 'FaceColor', 'r');
            set(bh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh1, 'LineWidth', 2);
            hold on;

            bh2 = bar(num_sel_blocks_globals, mae_ratios2);
            set(bh2, 'BarWidth', 0.6);
            set(bh2, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh2, 'FaceColor', 'g');
            set(bh2, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh2, 'LineWidth', 2);
            hold on;

            bh3 = bar(num_sel_blocks_globals, dct_ratios1);
            set(bh3, 'BarWidth', 0.6);
            set(bh3, 'EdgeColor', 'none');  %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(bh3, 'FaceColor', 'b');
            set(bh3, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(bh3, 'LineWidth', 2);
            hold on;

            lh1 = plot(num_sel_blocks_globals, mae_mses1);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 12);
            hold on;

            lh2 = plot(num_sel_blocks_globals, mae_maes1);
            set(lh2, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(num_sel_blocks_globals, mae_ccs1);
            set(lh3, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);

            %% mae - fill
            lh4 = plot(num_sel_blocks_globals, mae_mses2);
            set(lh4, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh4, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh4, 'LineWidth', 4);
            set(lh4, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh4, 'MarkerEdgeColor', 'auto');
            set(lh4, 'MarkerFaceColor', 'auto');
            set(lh4, 'MarkerSize', 12);
            hold on;

            lh5 = plot(num_sel_blocks_globals, mae_maes2);
            set(lh5, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh5, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh5, 'LineWidth', 4);
            set(lh5, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh5, 'MarkerEdgeColor', 'auto');
            set(lh5, 'MarkerFaceColor', 'auto');
            set(lh5, 'MarkerSize', 12);
            hold on;

            lh6 = plot(num_sel_blocks_globals, mae_ccs2);
            set(lh6, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh6, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh6, 'LineWidth', 4);
            set(lh6, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh6, 'MarkerEdgeColor', 'auto');
            set(lh6, 'MarkerFaceColor', 'auto');
            set(lh6, 'MarkerSize', 12);

            %% dct
            lh7 = plot(num_sel_blocks_globals, dct_mses1);
            set(lh7, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh7, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh7, 'LineWidth', 4);
            set(lh7, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh7, 'MarkerEdgeColor', 'auto');
            set(lh7, 'MarkerFaceColor', 'auto');
            set(lh7, 'MarkerSize', 12);
            hold on;

            lh8 = plot(num_sel_blocks_globals, dct_maes1);
            set(lh8, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh8, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh8, 'LineWidth', 4);
            set(lh8, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh8, 'MarkerEdgeColor', 'auto');
            set(lh8, 'MarkerFaceColor', 'auto');
            set(lh8, 'MarkerSize', 12);
            hold on;

            lh9 = plot(num_sel_blocks_globals, dct_ccs1);
            set(lh9, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh9, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh9, 'LineWidth', 4);
            set(lh9, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh9, 'MarkerEdgeColor', 'auto');
            set(lh9, 'MarkerFaceColor', 'auto');
            set(lh9, 'MarkerSize', 12);
            

            set(gca, 'FontSize', font_size);
            % set(gca, 'Position', [0.1 0.2 0.8 0.8]);
            
            if(1)
                set(bh1, 'Visible', 'off');
                set(bh2, 'Visible', 'off');
                set(bh3, 'Visible', 'off');

                kh = legend([lh1, lh2, lh3, ...
                             lh4, lh5, lh6, ...
                             lh7, lh8, lh9], ...
                             'MSE:MAE-Fill', 'MAE:MAE-Fill', 'CC:MAE-Fill', ...
                             'MSE:MAE-NoFill', 'MAE:MAE-NoFill', 'CC:MAE-NoFill', ...
                             'MSE:DCT', 'MAE:DCT', 'CC:DCT');
            else
                kh = legend([lh1, lh2, lh3, bh1, ...
                             lh4, lh5, lh6, bh2, ...
                             lh7, lh8, lh9, bh3], ...
                             'MSE:MAE-Fill', 'MAE:MAE-Fill', 'CC:MAE-Fill', 'Space:MAE-Fill', ...
                             'MSE:MAE-NoFill', 'MAE:MAE-NoFill', 'CC:MAE-NoFill', 'Space:MAE-NoFill', ...
                             'MSE:DCT', 'MAE:DCT', 'CC:DCT', 'Space:DCT');
            end
            % set(kh, 'Box', 'off');
            set(kh, 'Location', 'BestOutside');
            % set(kh, 'Orientation', 'horizontal');
            % set(kh, 'Position', [.1,.2,.1,.2]);

            % set(fh, 'PaperUnits', 'points');
            % set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [1 Inf]);
            set(gca, 'YLim', [0 1]);

            % set(gca, 'XTickLabel', {'quan=0.1', 'quan=50', 'quan=100', '#chunks=1', '#chunks=50', '#chunks=200'});
            % XTickLabel = get(gca,'XTickLabel');
            % set(gca,'XTickLabel',' ');
            % XTick = get(gca,'XTick');
            % y = repmat(-0.1,length(XTick),1) + 0.03;
            % fs = get(gca,'fontsize');
            % hText = text(XTick, y, XTickLabel,'fontsize',fs);
            % set(hText,'Rotation',-45,'HorizontalAlignment','left');

            
            xlabel('# blocks', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            print(fh, '-dpng', [output_dir file '.mpeg_lc.global.png']);
        end
    end %% end of plot


    %% --------------------
    %% PureRandLoss
    %% --------------------
    if(PLOT_PURE_RAND)
        fprintf('\nPureRandLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% PureRandLoss
            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_frac     = 1;
            loss_rates    = [0.05 0.1 0.2 0.4 0.6 0.8];
            burst_size    = 1;


            %% pca1
            r = 10;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            pca_cnts1   = zeros(size(loss_rates));
            pca_mses1   = zeros(size(loss_rates));
            pca_maes1   = zeros(size(loss_rates));
            pca_ccs1    = zeros(size(loss_rates));
            pca_ratios1 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds

                    filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([pca_dir filename]))
                        % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [pca_dir filename]);
                    data = load([pca_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            pca_cnts1   = cnts;
            pca_mses1   = mses;
            pca_maes1   = maes;
            pca_ccs1    = ccs;
            pca_ratios1 = ratios;


            %% pca2
            r = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            pca_cnts2   = zeros(size(loss_rates));
            pca_mses2   = zeros(size(loss_rates));
            pca_maes2   = zeros(size(loss_rates));
            pca_ccs2    = zeros(size(loss_rates));
            pca_ratios2 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds

                    filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([pca_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [pca_dir filename]);
                    data = load([pca_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            pca_cnts2   = cnts;
            pca_mses2   = mses;
            pca_maes2   = maes;
            pca_ccs2    = ccs;
            pca_ratios2 = ratios;


            %% DCT, quan = 50
            scheme = 'dct_based_pred';
            opt_type = 'single';
            gop = 4;
            quan = 50;
            opt_swap_mat = 'org';
            
            dct_cnts1   = zeros(size(loss_rates));
            dct_mses1   = zeros(size(loss_rates));
            dct_maes1   = zeros(size(loss_rates));
            dct_ccs1    = zeros(size(loss_rates));
            dct_ratios1 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        % fprintf(' %s%s not exist\n', dct_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            dct_cnts1   = cnts;
            dct_mses1   = mses;
            dct_maes1   = maes;
            dct_ccs1    = ccs;
            dct_ratios1 = ratios;

            
            %% DCT, # chunks = 200
            scheme = 'dct_based_pred';
            opt_type = 'chunk';
            sel_chunks = 200;
            gop = 4;
            opt_swap_mat = 'org';
            
            dct_cnts2   = zeros(size(loss_rates));
            dct_mses2   = zeros(size(loss_rates));
            dct_maes2   = zeros(size(loss_rates));
            dct_ccs2    = zeros(size(loss_rates));
            dct_ratios2 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([dct_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [dct_dir filename]);
                    data = load([dct_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            dct_cnts2   = cnts;
            dct_mses2   = mses;
            dct_maes2   = maes;
            dct_ccs2    = ccs;
            dct_ratios2 = ratios;


            %% srmf - r24
            scheme = 'srmf_based_pred';
            opt_type = 'srmf';
            r = num_frames;
            gop = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            srmf_cnts1   = zeros(size(loss_rates));
            srmf_mses1   = zeros(size(loss_rates));
            srmf_maes1   = zeros(size(loss_rates));
            srmf_ccs1    = zeros(size(loss_rates));
            srmf_ratios1 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([srmf_dir filename]))
                        % fprintf('  %s%s\n', srmf_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [srmf_dir filename]);
                    data = load([srmf_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            srmf_cnts1   = cnts;
            srmf_mses1   = mses;
            srmf_maes1   = maes;
            srmf_ccs1    = ccs;
            srmf_ratios1 = ratios;


            %% srmf+knn - r24
            opt_type = 'srmf_knn';
            r = num_frames;
            gop = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            srmf_cnts2   = zeros(size(loss_rates));
            srmf_mses2   = zeros(size(loss_rates));
            srmf_maes2   = zeros(size(loss_rates));
            srmf_ccs2    = zeros(size(loss_rates));
            srmf_ratios2 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([srmf_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [srmf_dir filename]);
                    data = load([srmf_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            srmf_cnts2   = cnts;
            srmf_mses2   = mses;
            srmf_maes2   = maes;
            srmf_ccs2    = ccs;
            srmf_ratios2 = ratios;


            %% svd - r1
            opt_type = 'svd';
            r = 1;
            gop = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            srmf_cnts3   = zeros(size(loss_rates));
            srmf_mses3   = zeros(size(loss_rates));
            srmf_maes3   = zeros(size(loss_rates));
            srmf_ccs3    = zeros(size(loss_rates));
            srmf_ratios3 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([srmf_dir filename]))
                        continue;
                    end

                    % fprintf(' %s\n', [srmf_dir filename]);
                    data = load([srmf_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            srmf_cnts3   = cnts;
            srmf_mses3   = mses;
            srmf_maes3   = maes;
            srmf_ccs3    = ccs;
            srmf_ratios3 = ratios;


            %% nearby - fill in
            scheme = 'mpeg_based_pred';
            opt_delta = 'diff';
            opt_f_b = 18;
            opt_fill_in = 'fill';
            opt_swap_mat = 'org';
            
            mpeg_cnts1   = zeros(size(loss_rates));
            mpeg_mses1   = zeros(size(loss_rates));
            mpeg_maes1   = zeros(size(loss_rates));
            mpeg_ccs1    = zeros(size(loss_rates));
            mpeg_ratios1 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_dir filename]))
                        % fprintf('  %s%s\n', mpeg_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_dir filename]);
                    data = load([mpeg_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            mpeg_cnts1   = cnts;
            mpeg_mses1   = mses;
            mpeg_maes1   = maes;
            mpeg_ccs1    = ccs;
            mpeg_ratios1 = ratios;


            %% nearby - no fill in
            scheme = 'mpeg_based_pred';
            opt_delta = 'diff';
            opt_f_b = 18;
            opt_fill_in = 'no_fill';
            opt_swap_mat = 'org';
            
            mpeg_cnts2   = zeros(size(loss_rates));
            mpeg_mses2   = zeros(size(loss_rates));
            mpeg_maes2   = zeros(size(loss_rates));
            mpeg_ccs2    = zeros(size(loss_rates));
            mpeg_ratios2 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_dir filename]))
                        % fprintf('  %s%s\n', mpeg_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_dir filename]);
                    data = load([mpeg_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            mpeg_cnts2   = cnts;
            mpeg_mses2   = mses;
            mpeg_maes2   = maes;
            mpeg_ccs2    = ccs;
            mpeg_ratios2 = ratios;


            %% lc - local, #blocks=64
            scheme = 'mpeg_lc_based_pred';
            opt_scope      = 'local';
            opt_fill_in    = 'fill';
            opt_sel_method = 'mae';
            num_sel_blocks = 64;
            opt_swap_mat   = 'org';
            opt_delta      = 'diff';
            
            lc_cnts1   = zeros(1, length(loss_rates));
            lc_mses1   = zeros(1, length(loss_rates));
            lc_maes1   = zeros(1, length(loss_rates));
            lc_ccs1    = zeros(1, length(loss_rates));
            lc_ratios1 = zeros(1, length(loss_rates));

            cnts   = zeros(1, length(loss_rates));
            mses   = zeros(1, length(loss_rates));
            maes   = zeros(1, length(loss_rates));
            ccs    = zeros(1, length(loss_rates));
            ratios = zeros(1, length(loss_rates));

            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);

                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            lc_cnts1   = cnts;
            lc_mses1   = mses;
            lc_maes1   = maes;
            lc_ccs1    = ccs;
            lc_ratios1 = ratios;


            %% lc - global, #blocks=128
            scheme = 'mpeg_lc_based_pred';
            opt_scope      = 'global';
            opt_fill_in    = 'no_fill';
            opt_sel_method = 'mae';
            num_sel_blocks = 128;
            opt_swap_mat   = 'org';
            opt_delta      = 'diff';
            
            lc_cnts2   = zeros(1, length(loss_rates));
            lc_mses2   = zeros(1, length(loss_rates));
            lc_maes2   = zeros(1, length(loss_rates));
            lc_ccs2    = zeros(1, length(loss_rates));
            lc_ratios2 = zeros(1, length(loss_rates));

            cnts   = zeros(1, length(loss_rates));
            mses   = zeros(1, length(loss_rates));
            maes   = zeros(1, length(loss_rates));
            ccs    = zeros(1, length(loss_rates));
            ratios = zeros(1, length(loss_rates));

            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);

                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([mpeg_lc_dir filename]))
                        % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [mpeg_lc_dir filename]);
                    data = load([mpeg_lc_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

            end
            lc_cnts2   = cnts;
            lc_mses2   = mses;
            lc_maes2   = maes;
            lc_ccs2    = ccs;
            lc_ratios2 = ratios;


            %% lens - r20
            scheme = 'srmf_based_pred';
            opt_type = 'lens';
            r = num_frames;
            gop = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            lens_cnts1   = zeros(size(loss_rates));
            lens_mses1   = zeros(size(loss_rates));
            lens_maes1   = zeros(size(loss_rates));
            lens_ccs1    = zeros(size(loss_rates));
            lens_ratios1 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([srmf_dir filename]))
                        fprintf('  %s%s\n', srmf_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [srmf_dir filename]);
                    data = load([srmf_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            lens_cnts1   = cnts;
            lens_mses1   = mses;
            lens_maes1   = maes;
            lens_ccs1    = ccs;
            lens_ratios1 = ratios;


            %% lens+knn - r20
            scheme = 'srmf_based_pred';
            opt_type = 'lens_knn';
            r = 10;
            gop = num_frames;
            opt_swap_mat = 'org';
            opt_dim = '2d';
            
            lens_cnts2   = zeros(size(loss_rates));
            lens_mses2   = zeros(size(loss_rates));
            lens_maes2   = zeros(size(loss_rates));
            lens_ccs2    = zeros(size(loss_rates));
            lens_ratios2 = zeros(size(loss_rates));

            cnts   = zeros(size(loss_rates));
            mses   = zeros(size(loss_rates));
            maes   = zeros(size(loss_rates));
            ccs    = zeros(size(loss_rates));
            ratios = zeros(size(loss_rates));
            for i = [1:length(loss_rates)]
                loss_rate = loss_rates(i);
                
                for seed = seeds
                    filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                    if ~(exist([srmf_dir filename]))
                        fprintf('  %s%s\n', srmf_dir, filename);
                        continue;
                    end

                    % fprintf(' %s\n', [srmf_dir filename]);
                    data = load([srmf_dir filename]);
                    mses(i)   = mses(i) + data(1);
                    maes(i)   = maes(i) + data(2);
                    ccs(i)    = ccs(i) + data(3);
                    ratios(i) = ratios(i) + data(4);
                    cnts(i) = cnts(i) + 1;
                    % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                end

                if(cnts(i) > 1)
                    mses(i)   = mses(i) / cnts(i);
                    maes(i)   = maes(i) / cnts(i);
                    ccs(i)    = ccs(i) / cnts(i);
                    ratios(i) = ratios(i) / cnts(i);
                end
                fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
            end
            lens_cnts2   = cnts;
            lens_mses2   = mses;
            lens_maes2   = maes;
            lens_ccs2    = ccs;
            lens_ratios2 = ratios;


            %% plot mse
            clf;
            fh = figure;
            font_size = 28;

            lh1 = plot(loss_rates, pca_mses1);
            set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh1, 'LineWidth', 4);
            set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh1, 'MarkerEdgeColor', 'auto');
            set(lh1, 'MarkerFaceColor', 'auto');
            set(lh1, 'MarkerSize', 10);
            hold on;

            lh2 = plot(loss_rates, pca_mses2);
            set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh2, 'LineWidth', 4);
            set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh2, 'MarkerEdgeColor', 'auto');
            set(lh2, 'MarkerFaceColor', 'auto');
            set(lh2, 'MarkerSize', 12);
            hold on;

            lh3 = plot(loss_rates, dct_mses1);
            set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh3, 'LineWidth', 4);
            set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh3, 'MarkerEdgeColor', 'auto');
            set(lh3, 'MarkerFaceColor', 'auto');
            set(lh3, 'MarkerSize', 12);
            hold on;

            lh4 = plot(loss_rates, dct_mses2);
            set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
            set(lh4, 'LineWidth', 4);
            set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh4, 'MarkerEdgeColor', 'auto');
            set(lh4, 'MarkerFaceColor', 'auto');
            set(lh4, 'MarkerSize', 12);
            hold on;

            lh5 = plot(loss_rates, srmf_mses1);
            set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh5, 'LineWidth', 4);
            set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh5, 'MarkerEdgeColor', 'auto');
            set(lh5, 'MarkerFaceColor', 'auto');
            set(lh5, 'MarkerSize', 12);
            hold on;

            lh6 = plot(loss_rates, srmf_mses2);
            set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh6, 'LineWidth', 4);
            set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh6, 'MarkerEdgeColor', 'auto');
            set(lh6, 'MarkerFaceColor', 'auto');
            set(lh6, 'MarkerSize', 12);
            hold on;

            lh7 = plot(loss_rates, mpeg_mses1);
            set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh7, 'LineWidth', 4);
            set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh7, 'MarkerEdgeColor', 'auto');
            set(lh7, 'MarkerFaceColor', 'auto');
            set(lh7, 'MarkerSize', 12);
            hold on;

            lh8 = plot(loss_rates, mpeg_mses2);
            set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
            set(lh8, 'LineWidth', 4);
            set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh8, 'MarkerEdgeColor', 'auto');
            set(lh8, 'MarkerFaceColor', 'auto');
            set(lh8, 'MarkerSize', 12);
            hold on;

            lh9 = plot(loss_rates, srmf_mses3);
            set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
            set(lh9, 'LineWidth', 4);
            set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh9, 'MarkerEdgeColor', 'auto');
            set(lh9, 'MarkerFaceColor', 'auto');
            set(lh9, 'MarkerSize', 12);
            hold on;

            lh10 = plot(loss_rates, lc_mses1);
            set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh10, 'LineWidth', 4);
            set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh10, 'MarkerEdgeColor', 'auto');
            set(lh10, 'MarkerFaceColor', 'auto');
            set(lh10, 'MarkerSize', 12);
            hold on;

            lh11 = plot(loss_rates, lc_mses2);
            set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
            set(lh11, 'LineWidth', 4);
            set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh11, 'MarkerEdgeColor', 'auto');
            set(lh11, 'MarkerFaceColor', 'auto');
            set(lh11, 'MarkerSize', 12);
            hold on;

            lh12 = plot(loss_rates, lens_mses1);
            set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
            set(lh12, 'LineWidth', 4);
            set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh12, 'MarkerEdgeColor', 'auto');
            set(lh12, 'MarkerFaceColor', 'auto');
            set(lh12, 'MarkerSize', 12);
            hold on;

            lh13 = plot(loss_rates, lens_mses2);
            set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
            set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
            set(lh13, 'LineWidth', 4);
            set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
            set(lh13, 'MarkerEdgeColor', 'auto');
            set(lh13, 'MarkerFaceColor', 'auto');
            set(lh13, 'MarkerSize', 12);
            hold on;


            if PLOT_FORMAL
                set(lh2, 'Visible', 'off');
                set(lh5, 'Visible', 'off');
                set(lh8, 'Visible', 'off');
                set(lh9, 'Visible', 'off');

                kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
            else
                kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
            end
            
            set(kh, 'Location', 'BestOutside');
            
            set(fh, 'PaperUnits', 'points');
            set(fh, 'PaperPosition', [0 0 1024 768]);

            set(gca, 'XLim', [0 Inf]);
            set(gca, 'YLim', [0 1]);

            xlabel('Loss Rate', 'FontSize', font_size);
            ylabel('MSE', 'FontSize', font_size);

            set(gca, 'FontSize', font_size);
            
            print(fh, '-dpng', [output_dir file '.PureRandLoss.mse.png']);
        end
    end   %% end of plot


    %% --------------------
    %% TimeRandLoss
    %% --------------------
    if(PLOT_TIME_RAND)
        fprintf('\nTimeRandLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% TimeRandLoss
            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_fracs    = [0.1 0.3 0.5 0.7 1];
            loss_rates    = [0.05 0.1 0.2 0.4 0.6 0.8];
            burst_size    = 1;


            for loss_rate = loss_rates
                %% pca1
                r = 10;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts1   = zeros(size(elem_fracs));
                pca_mses1   = zeros(size(elem_fracs));
                pca_maes1   = zeros(size(elem_fracs));
                pca_ccs1    = zeros(size(elem_fracs));
                pca_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts1   = cnts;
                pca_mses1   = mses;
                pca_maes1   = maes;
                pca_ccs1    = ccs;
                pca_ratios1 = ratios;


                %% pca2
                r = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts2   = zeros(size(elem_fracs));
                pca_mses2   = zeros(size(elem_fracs));
                pca_maes2   = zeros(size(elem_fracs));
                pca_ccs2    = zeros(size(elem_fracs));
                pca_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts2   = cnts;
                pca_mses2   = mses;
                pca_maes2   = maes;
                pca_ccs2    = ccs;
                pca_ratios2 = ratios;


                %% DCT, quan = 50
                scheme = 'dct_based_pred';
                opt_type = 'single';
                gop = 4;
                quan = 50;
                opt_swap_mat = 'org';
                
                dct_cnts1   = zeros(size(elem_fracs));
                dct_mses1   = zeros(size(elem_fracs));
                dct_maes1   = zeros(size(elem_fracs));
                dct_ccs1    = zeros(size(elem_fracs));
                dct_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s not exist\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts1   = cnts;
                dct_mses1   = mses;
                dct_maes1   = maes;
                dct_ccs1    = ccs;
                dct_ratios1 = ratios;

                
                %% DCT, # chunks = 200
                scheme = 'dct_based_pred';
                opt_type = 'chunk';
                sel_chunks = 200;
                gop = 4;
                opt_swap_mat = 'org';
                
                dct_cnts2   = zeros(size(elem_fracs));
                dct_mses2   = zeros(size(elem_fracs));
                dct_maes2   = zeros(size(elem_fracs));
                dct_ccs2    = zeros(size(elem_fracs));
                dct_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            fprintf(' %s%s\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts2   = cnts;
                dct_mses2   = mses;
                dct_maes2   = maes;
                dct_ccs2    = ccs;
                dct_ratios2 = ratios;


                %% srmf - r24
                scheme = 'srmf_based_pred';
                opt_type = 'srmf';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts1   = zeros(size(elem_fracs));
                srmf_mses1   = zeros(size(elem_fracs));
                srmf_maes1   = zeros(size(elem_fracs));
                srmf_ccs1    = zeros(size(elem_fracs));
                srmf_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            % fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts1   = cnts;
                srmf_mses1   = mses;
                srmf_maes1   = maes;
                srmf_ccs1    = ccs;
                srmf_ratios1 = ratios;


                %% srmf+knn - r24
                opt_type = 'srmf_knn';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts2   = zeros(size(elem_fracs));
                srmf_mses2   = zeros(size(elem_fracs));
                srmf_maes2   = zeros(size(elem_fracs));
                srmf_ccs2    = zeros(size(elem_fracs));
                srmf_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts2   = cnts;
                srmf_mses2   = mses;
                srmf_maes2   = maes;
                srmf_ccs2    = ccs;
                srmf_ratios2 = ratios;


                %% svd - r1
                opt_type = 'svd';
                r = 1;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts3   = zeros(size(elem_fracs));
                srmf_mses3   = zeros(size(elem_fracs));
                srmf_maes3   = zeros(size(elem_fracs));
                srmf_ccs3    = zeros(size(elem_fracs));
                srmf_ratios3 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts3   = cnts;
                srmf_mses3   = mses;
                srmf_maes3   = maes;
                srmf_ccs3    = ccs;
                srmf_ratios3 = ratios;


                %% nearby - fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts1   = zeros(size(elem_fracs));
                mpeg_mses1   = zeros(size(elem_fracs));
                mpeg_maes1   = zeros(size(elem_fracs));
                mpeg_ccs1    = zeros(size(elem_fracs));
                mpeg_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts1   = cnts;
                mpeg_mses1   = mses;
                mpeg_maes1   = maes;
                mpeg_ccs1    = ccs;
                mpeg_ratios1 = ratios;


                %% nearby - no fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'no_fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts2   = zeros(size(elem_fracs));
                mpeg_mses2   = zeros(size(elem_fracs));
                mpeg_maes2   = zeros(size(elem_fracs));
                mpeg_ccs2    = zeros(size(elem_fracs));
                mpeg_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts2   = cnts;
                mpeg_mses2   = mses;
                mpeg_maes2   = maes;
                mpeg_ccs2    = ccs;
                mpeg_ratios2 = ratios;


                %% lc - local, #blocks=64
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'local';
                opt_fill_in    = 'fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 64;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts1   = zeros(1, length(elem_fracs));
                lc_mses1   = zeros(1, length(elem_fracs));
                lc_maes1   = zeros(1, length(elem_fracs));
                lc_ccs1    = zeros(1, length(elem_fracs));
                lc_ratios1 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts1   = cnts;
                lc_mses1   = mses;
                lc_maes1   = maes;
                lc_ccs1    = ccs;
                lc_ratios1 = ratios;


                %% lc - global, #blocks=128
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'global';
                opt_fill_in    = 'no_fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 128;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts2   = zeros(1, length(elem_fracs));
                lc_mses2   = zeros(1, length(elem_fracs));
                lc_maes2   = zeros(1, length(elem_fracs));
                lc_ccs2    = zeros(1, length(elem_fracs));
                lc_ratios2 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts2   = cnts;
                lc_mses2   = mses;
                lc_maes2   = maes;
                lc_ccs2    = ccs;
                lc_ratios2 = ratios;


                %% LENS - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts1   = zeros(size(elem_fracs));
                lens_mses1   = zeros(size(elem_fracs));
                lens_maes1   = zeros(size(elem_fracs));
                lens_ccs1    = zeros(size(elem_fracs));
                lens_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts1   = cnts;
                lens_mses1   = mses;
                lens_maes1   = maes;
                lens_ccs1    = ccs;
                lens_ratios1 = ratios;


                %% LENS+KNN - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens_knn';
                r = 10;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts2   = zeros(size(elem_fracs));
                lens_mses2   = zeros(size(elem_fracs));
                lens_maes2   = zeros(size(elem_fracs));
                lens_ccs2    = zeros(size(elem_fracs));
                lens_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts2   = cnts;
                lens_mses2   = mses;
                lens_maes2   = maes;
                lens_ccs2    = ccs;
                lens_ratios2 = ratios;


                %% plot mse
                clf;
                fh = figure;
                font_size = 28;

                lh1 = plot(elem_fracs, pca_mses1);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(elem_fracs, pca_mses2);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(elem_fracs, dct_mses1);
                set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);
                hold on;

                lh4 = plot(elem_fracs, dct_mses2);
                set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh4, 'LineWidth', 4);
                set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh4, 'MarkerEdgeColor', 'auto');
                set(lh4, 'MarkerFaceColor', 'auto');
                set(lh4, 'MarkerSize', 12);
                hold on;

                lh5 = plot(elem_fracs, srmf_mses1);
                set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh5, 'LineWidth', 4);
                set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh5, 'MarkerEdgeColor', 'auto');
                set(lh5, 'MarkerFaceColor', 'auto');
                set(lh5, 'MarkerSize', 12);
                hold on;

                lh6 = plot(elem_fracs, srmf_mses2);
                set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh6, 'LineWidth', 4);
                set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh6, 'MarkerEdgeColor', 'auto');
                set(lh6, 'MarkerFaceColor', 'auto');
                set(lh6, 'MarkerSize', 12);
                hold on;

                lh7 = plot(elem_fracs, mpeg_mses1);
                set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh7, 'LineWidth', 4);
                set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh7, 'MarkerEdgeColor', 'auto');
                set(lh7, 'MarkerFaceColor', 'auto');
                set(lh7, 'MarkerSize', 12);
                hold on;

                lh8 = plot(elem_fracs, mpeg_mses2);
                set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh8, 'LineWidth', 4);
                set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh8, 'MarkerEdgeColor', 'auto');
                set(lh8, 'MarkerFaceColor', 'auto');
                set(lh8, 'MarkerSize', 12);
                hold on;

                lh9 = plot(elem_fracs, srmf_mses3);
                set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh9, 'LineWidth', 4);
                set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh9, 'MarkerEdgeColor', 'auto');
                set(lh9, 'MarkerFaceColor', 'auto');
                set(lh9, 'MarkerSize', 12);
                hold on;

                lh10 = plot(elem_fracs, lc_mses1);
                set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh10, 'LineWidth', 4);
                set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh10, 'MarkerEdgeColor', 'auto');
                set(lh10, 'MarkerFaceColor', 'auto');
                set(lh10, 'MarkerSize', 12);
                hold on;

                lh11 = plot(elem_fracs, lc_mses2);
                set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh11, 'LineWidth', 4);
                set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh11, 'MarkerEdgeColor', 'auto');
                set(lh11, 'MarkerFaceColor', 'auto');
                set(lh11, 'MarkerSize', 12);
                hold on;

                lh12 = plot(elem_fracs, lens_mses1);
                set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh12, 'LineWidth', 4);
                set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh12, 'MarkerEdgeColor', 'auto');
                set(lh12, 'MarkerFaceColor', 'auto');
                set(lh12, 'MarkerSize', 12);
                hold on;

                lh13 = plot(elem_fracs, lens_mses2);
                set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh13, 'LineWidth', 4);
                set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh13, 'MarkerEdgeColor', 'auto');
                set(lh13, 'MarkerFaceColor', 'auto');
                set(lh13, 'MarkerSize', 12);
                hold on;


                if PLOT_FORMAL
                    set(lh2, 'Visible', 'off');
                    set(lh5, 'Visible', 'off');
                    set(lh8, 'Visible', 'off');
                    set(lh9, 'Visible', 'off');

                    kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                else
                    kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                end
                
                set(kh, 'Location', 'BestOutside');
                
                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('Loss Rate', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                
                print(fh, '-dpng', [output_dir file '.' num2str(loss_rate*100) 'TimeRandLoss.mse.png']);
            end
        end
    end   %% end of plot


    %% --------------------
    %% ElemRandLoss
    %% --------------------
    if(PLOT_ELEM_RAND)
        fprintf('\nElemRandLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% ElemRandLoss
            drop_ele_mode = 'elem';
            drop_mode     = 'ind';
            elem_fracs    = [0.1 0.3 0.5 0.7];
            loss_rates    = [0.05 0.1 0.2 0.4 0.6 0.8];
            burst_size    = 1;


            for elem_frac = elem_fracs
                %% pca1
                r = 10;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts1   = zeros(size(loss_rates));
                pca_mses1   = zeros(size(loss_rates));
                pca_maes1   = zeros(size(loss_rates));
                pca_ccs1    = zeros(size(loss_rates));
                pca_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts1   = cnts;
                pca_mses1   = mses;
                pca_maes1   = maes;
                pca_ccs1    = ccs;
                pca_ratios1 = ratios;


                %% pca2
                r = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts2   = zeros(size(loss_rates));
                pca_mses2   = zeros(size(loss_rates));
                pca_maes2   = zeros(size(loss_rates));
                pca_ccs2    = zeros(size(loss_rates));
                pca_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts2   = cnts;
                pca_mses2   = mses;
                pca_maes2   = maes;
                pca_ccs2    = ccs;
                pca_ratios2 = ratios;


                %% DCT, quan = 50
                scheme = 'dct_based_pred';
                opt_type = 'single';
                gop = 4;
                quan = 50;
                opt_swap_mat = 'org';
                
                dct_cnts1   = zeros(size(loss_rates));
                dct_mses1   = zeros(size(loss_rates));
                dct_maes1   = zeros(size(loss_rates));
                dct_ccs1    = zeros(size(loss_rates));
                dct_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s not exist\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts1   = cnts;
                dct_mses1   = mses;
                dct_maes1   = maes;
                dct_ccs1    = ccs;
                dct_ratios1 = ratios;

                
                %% DCT, # chunks = 200
                scheme = 'dct_based_pred';
                opt_type = 'chunk';
                sel_chunks = 200;
                gop = 4;
                opt_swap_mat = 'org';
                
                dct_cnts2   = zeros(size(loss_rates));
                dct_mses2   = zeros(size(loss_rates));
                dct_maes2   = zeros(size(loss_rates));
                dct_ccs2    = zeros(size(loss_rates));
                dct_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            fprintf(' %s%s\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts2   = cnts;
                dct_mses2   = mses;
                dct_maes2   = maes;
                dct_ccs2    = ccs;
                dct_ratios2 = ratios;


                %% srmf - r24
                scheme = 'srmf_based_pred';
                opt_type = 'srmf';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts1   = zeros(size(loss_rates));
                srmf_mses1   = zeros(size(loss_rates));
                srmf_maes1   = zeros(size(loss_rates));
                srmf_ccs1    = zeros(size(loss_rates));
                srmf_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            % fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts1   = cnts;
                srmf_mses1   = mses;
                srmf_maes1   = maes;
                srmf_ccs1    = ccs;
                srmf_ratios1 = ratios;


                %% srmf+knn - r24
                opt_type = 'srmf_knn';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts2   = zeros(size(loss_rates));
                srmf_mses2   = zeros(size(loss_rates));
                srmf_maes2   = zeros(size(loss_rates));
                srmf_ccs2    = zeros(size(loss_rates));
                srmf_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts2   = cnts;
                srmf_mses2   = mses;
                srmf_maes2   = maes;
                srmf_ccs2    = ccs;
                srmf_ratios2 = ratios;


                %% svd - r1
                opt_type = 'svd';
                r = 1;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts3   = zeros(size(loss_rates));
                srmf_mses3   = zeros(size(loss_rates));
                srmf_maes3   = zeros(size(loss_rates));
                srmf_ccs3    = zeros(size(loss_rates));
                srmf_ratios3 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts3   = cnts;
                srmf_mses3   = mses;
                srmf_maes3   = maes;
                srmf_ccs3    = ccs;
                srmf_ratios3 = ratios;


                %% nearby - fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts1   = zeros(size(loss_rates));
                mpeg_mses1   = zeros(size(loss_rates));
                mpeg_maes1   = zeros(size(loss_rates));
                mpeg_ccs1    = zeros(size(loss_rates));
                mpeg_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts1   = cnts;
                mpeg_mses1   = mses;
                mpeg_maes1   = maes;
                mpeg_ccs1    = ccs;
                mpeg_ratios1 = ratios;


                %% nearby - no fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'no_fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts2   = zeros(size(loss_rates));
                mpeg_mses2   = zeros(size(loss_rates));
                mpeg_maes2   = zeros(size(loss_rates));
                mpeg_ccs2    = zeros(size(loss_rates));
                mpeg_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts2   = cnts;
                mpeg_mses2   = mses;
                mpeg_maes2   = maes;
                mpeg_ccs2    = ccs;
                mpeg_ratios2 = ratios;


                %% lc - local, #blocks=64
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'local';
                opt_fill_in    = 'fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 64;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts1   = zeros(1, length(loss_rates));
                lc_mses1   = zeros(1, length(loss_rates));
                lc_maes1   = zeros(1, length(loss_rates));
                lc_ccs1    = zeros(1, length(loss_rates));
                lc_ratios1 = zeros(1, length(loss_rates));

                cnts   = zeros(1, length(loss_rates));
                mses   = zeros(1, length(loss_rates));
                maes   = zeros(1, length(loss_rates));
                ccs    = zeros(1, length(loss_rates));
                ratios = zeros(1, length(loss_rates));

                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts1   = cnts;
                lc_mses1   = mses;
                lc_maes1   = maes;
                lc_ccs1    = ccs;
                lc_ratios1 = ratios;


                %% lc - global, #blocks=128
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'global';
                opt_fill_in    = 'no_fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 128;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts2   = zeros(1, length(loss_rates));
                lc_mses2   = zeros(1, length(loss_rates));
                lc_maes2   = zeros(1, length(loss_rates));
                lc_ccs2    = zeros(1, length(loss_rates));
                lc_ratios2 = zeros(1, length(loss_rates));

                cnts   = zeros(1, length(loss_rates));
                mses   = zeros(1, length(loss_rates));
                maes   = zeros(1, length(loss_rates));
                ccs    = zeros(1, length(loss_rates));
                ratios = zeros(1, length(loss_rates));

                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts2   = cnts;
                lc_mses2   = mses;
                lc_maes2   = maes;
                lc_ccs2    = ccs;
                lc_ratios2 = ratios;


                %% LENS - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts1   = zeros(size(loss_rates));
                lens_mses1   = zeros(size(loss_rates));
                lens_maes1   = zeros(size(loss_rates));
                lens_ccs1    = zeros(size(loss_rates));
                lens_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts1   = cnts;
                lens_mses1   = mses;
                lens_maes1   = maes;
                lens_ccs1    = ccs;
                lens_ratios1 = ratios;


                %% lens+knn - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens_knn';
                r = 10;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts2   = zeros(size(loss_rates));
                lens_mses2   = zeros(size(loss_rates));
                lens_maes2   = zeros(size(loss_rates));
                lens_ccs2    = zeros(size(loss_rates));
                lens_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts2   = cnts;
                lens_mses2   = mses;
                lens_maes2   = maes;
                lens_ccs2    = ccs;
                lens_ratios2 = ratios;


                %% plot mse
                clf;
                fh = figure;
                font_size = 28;

                lh1 = plot(loss_rates, pca_mses1);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(loss_rates, pca_mses2);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(loss_rates, dct_mses1);
                set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);
                hold on;

                lh4 = plot(loss_rates, dct_mses2);
                set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh4, 'LineWidth', 4);
                set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh4, 'MarkerEdgeColor', 'auto');
                set(lh4, 'MarkerFaceColor', 'auto');
                set(lh4, 'MarkerSize', 12);
                hold on;

                lh5 = plot(loss_rates, srmf_mses1);
                set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh5, 'LineWidth', 4);
                set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh5, 'MarkerEdgeColor', 'auto');
                set(lh5, 'MarkerFaceColor', 'auto');
                set(lh5, 'MarkerSize', 12);
                hold on;

                lh6 = plot(loss_rates, srmf_mses2);
                set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh6, 'LineWidth', 4);
                set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh6, 'MarkerEdgeColor', 'auto');
                set(lh6, 'MarkerFaceColor', 'auto');
                set(lh6, 'MarkerSize', 12);
                hold on;

                lh7 = plot(loss_rates, mpeg_mses1);
                set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh7, 'LineWidth', 4);
                set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh7, 'MarkerEdgeColor', 'auto');
                set(lh7, 'MarkerFaceColor', 'auto');
                set(lh7, 'MarkerSize', 12);
                hold on;

                lh8 = plot(loss_rates, mpeg_mses2);
                set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh8, 'LineWidth', 4);
                set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh8, 'MarkerEdgeColor', 'auto');
                set(lh8, 'MarkerFaceColor', 'auto');
                set(lh8, 'MarkerSize', 12);
                hold on;

                lh9 = plot(loss_rates, srmf_mses3);
                set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh9, 'LineWidth', 4);
                set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh9, 'MarkerEdgeColor', 'auto');
                set(lh9, 'MarkerFaceColor', 'auto');
                set(lh9, 'MarkerSize', 12);
                hold on;

                lh10 = plot(loss_rates, lc_mses1);
                set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh10, 'LineWidth', 4);
                set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh10, 'MarkerEdgeColor', 'auto');
                set(lh10, 'MarkerFaceColor', 'auto');
                set(lh10, 'MarkerSize', 12);
                hold on;

                lh11 = plot(loss_rates, lc_mses2);
                set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh11, 'LineWidth', 4);
                set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh11, 'MarkerEdgeColor', 'auto');
                set(lh11, 'MarkerFaceColor', 'auto');
                set(lh11, 'MarkerSize', 12);
                hold on;

                lh12 = plot(loss_rates, lens_mses1);
                set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh12, 'LineWidth', 4);
                set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh12, 'MarkerEdgeColor', 'auto');
                set(lh12, 'MarkerFaceColor', 'auto');
                set(lh12, 'MarkerSize', 12);
                hold on;

                lh13 = plot(loss_rates, lens_mses2);
                set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh13, 'LineWidth', 4);
                set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh13, 'MarkerEdgeColor', 'auto');
                set(lh13, 'MarkerFaceColor', 'auto');
                set(lh13, 'MarkerSize', 12);
                hold on;


                if PLOT_FORMAL
                    set(lh2, 'Visible', 'off');
                    set(lh5, 'Visible', 'off');
                    set(lh8, 'Visible', 'off');
                    set(lh9, 'Visible', 'off');

                    kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                else
                    kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                end
                
                set(kh, 'Location', 'BestOutside');
                
                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('Loss Rate', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                
                print(fh, '-dpng', [output_dir file '.' num2str(elem_frac*100) 'ElemRandLoss.mse.png']);
            end
        end
    end   %% end of plot


    %% --------------------
    %% xxElemSyncLoss
    %% --------------------
    if(PLOT_ELEM_SYNC)
        fprintf('\nElemSyncLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% ElemSyncLoss
            drop_ele_mode = 'elem';
            drop_mode     = 'syn';
            elem_fracs    = [0.1 0.3];
            loss_rates    = [0.05 0.1 0.2 0.4 0.6 0.8];
            burst_size    = 1;


            for elem_frac = elem_fracs
                %% pca1
                r = 10;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts1   = zeros(size(loss_rates));
                pca_mses1   = zeros(size(loss_rates));
                pca_maes1   = zeros(size(loss_rates));
                pca_ccs1    = zeros(size(loss_rates));
                pca_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts1   = cnts;
                pca_mses1   = mses;
                pca_maes1   = maes;
                pca_ccs1    = ccs;
                pca_ratios1 = ratios;


                %% pca2
                r = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts2   = zeros(size(loss_rates));
                pca_mses2   = zeros(size(loss_rates));
                pca_maes2   = zeros(size(loss_rates));
                pca_ccs2    = zeros(size(loss_rates));
                pca_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts2   = cnts;
                pca_mses2   = mses;
                pca_maes2   = maes;
                pca_ccs2    = ccs;
                pca_ratios2 = ratios;


                %% DCT, quan = 50
                scheme = 'dct_based_pred';
                opt_type = 'single';
                gop = 4;
                quan = 50;
                opt_swap_mat = 'org';
                
                dct_cnts1   = zeros(size(loss_rates));
                dct_mses1   = zeros(size(loss_rates));
                dct_maes1   = zeros(size(loss_rates));
                dct_ccs1    = zeros(size(loss_rates));
                dct_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s not exist\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts1   = cnts;
                dct_mses1   = mses;
                dct_maes1   = maes;
                dct_ccs1    = ccs;
                dct_ratios1 = ratios;

                
                %% DCT, # chunks = 200
                scheme = 'dct_based_pred';
                opt_type = 'chunk';
                sel_chunks = 200;
                gop = 4;
                opt_swap_mat = 'org';
                
                dct_cnts2   = zeros(size(loss_rates));
                dct_mses2   = zeros(size(loss_rates));
                dct_maes2   = zeros(size(loss_rates));
                dct_ccs2    = zeros(size(loss_rates));
                dct_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            fprintf(' %s%s\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts2   = cnts;
                dct_mses2   = mses;
                dct_maes2   = maes;
                dct_ccs2    = ccs;
                dct_ratios2 = ratios;


                %% srmf - r24
                scheme = 'srmf_based_pred';
                opt_type = 'srmf';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts1   = zeros(size(loss_rates));
                srmf_mses1   = zeros(size(loss_rates));
                srmf_maes1   = zeros(size(loss_rates));
                srmf_ccs1    = zeros(size(loss_rates));
                srmf_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            % fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts1   = cnts;
                srmf_mses1   = mses;
                srmf_maes1   = maes;
                srmf_ccs1    = ccs;
                srmf_ratios1 = ratios;


                %% srmf+knn - r24
                opt_type = 'srmf_knn';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts2   = zeros(size(loss_rates));
                srmf_mses2   = zeros(size(loss_rates));
                srmf_maes2   = zeros(size(loss_rates));
                srmf_ccs2    = zeros(size(loss_rates));
                srmf_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts2   = cnts;
                srmf_mses2   = mses;
                srmf_maes2   = maes;
                srmf_ccs2    = ccs;
                srmf_ratios2 = ratios;


                %% svd - r1
                opt_type = 'svd';
                r = 1;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts3   = zeros(size(loss_rates));
                srmf_mses3   = zeros(size(loss_rates));
                srmf_maes3   = zeros(size(loss_rates));
                srmf_ccs3    = zeros(size(loss_rates));
                srmf_ratios3 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts3   = cnts;
                srmf_mses3   = mses;
                srmf_maes3   = maes;
                srmf_ccs3    = ccs;
                srmf_ratios3 = ratios;


                %% nearby - fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts1   = zeros(size(loss_rates));
                mpeg_mses1   = zeros(size(loss_rates));
                mpeg_maes1   = zeros(size(loss_rates));
                mpeg_ccs1    = zeros(size(loss_rates));
                mpeg_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts1   = cnts;
                mpeg_mses1   = mses;
                mpeg_maes1   = maes;
                mpeg_ccs1    = ccs;
                mpeg_ratios1 = ratios;


                %% nearby - no fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'no_fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts2   = zeros(size(loss_rates));
                mpeg_mses2   = zeros(size(loss_rates));
                mpeg_maes2   = zeros(size(loss_rates));
                mpeg_ccs2    = zeros(size(loss_rates));
                mpeg_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts2   = cnts;
                mpeg_mses2   = mses;
                mpeg_maes2   = maes;
                mpeg_ccs2    = ccs;
                mpeg_ratios2 = ratios;


                %% lc - local, #blocks=64
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'local';
                opt_fill_in    = 'fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 64;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts1   = zeros(1, length(loss_rates));
                lc_mses1   = zeros(1, length(loss_rates));
                lc_maes1   = zeros(1, length(loss_rates));
                lc_ccs1    = zeros(1, length(loss_rates));
                lc_ratios1 = zeros(1, length(loss_rates));

                cnts   = zeros(1, length(loss_rates));
                mses   = zeros(1, length(loss_rates));
                maes   = zeros(1, length(loss_rates));
                ccs    = zeros(1, length(loss_rates));
                ratios = zeros(1, length(loss_rates));

                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts1   = cnts;
                lc_mses1   = mses;
                lc_maes1   = maes;
                lc_ccs1    = ccs;
                lc_ratios1 = ratios;


                %% lc - global, #blocks=128
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'global';
                opt_fill_in    = 'no_fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 128;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts2   = zeros(1, length(loss_rates));
                lc_mses2   = zeros(1, length(loss_rates));
                lc_maes2   = zeros(1, length(loss_rates));
                lc_ccs2    = zeros(1, length(loss_rates));
                lc_ratios2 = zeros(1, length(loss_rates));

                cnts   = zeros(1, length(loss_rates));
                mses   = zeros(1, length(loss_rates));
                maes   = zeros(1, length(loss_rates));
                ccs    = zeros(1, length(loss_rates));
                ratios = zeros(1, length(loss_rates));

                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts2   = cnts;
                lc_mses2   = mses;
                lc_maes2   = maes;
                lc_ccs2    = ccs;
                lc_ratios2 = ratios;


                %% LENS - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts1   = zeros(size(loss_rates));
                lens_mses1   = zeros(size(loss_rates));
                lens_maes1   = zeros(size(loss_rates));
                lens_ccs1    = zeros(size(loss_rates));
                lens_ratios1 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts1   = cnts;
                lens_mses1   = mses;
                lens_maes1   = maes;
                lens_ccs1    = ccs;
                lens_ratios1 = ratios;


                %% lens+knn - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens_knn';
                r = 10;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts2   = zeros(size(loss_rates));
                lens_mses2   = zeros(size(loss_rates));
                lens_maes2   = zeros(size(loss_rates));
                lens_ccs2    = zeros(size(loss_rates));
                lens_ratios2 = zeros(size(loss_rates));

                cnts   = zeros(size(loss_rates));
                mses   = zeros(size(loss_rates));
                maes   = zeros(size(loss_rates));
                ccs    = zeros(size(loss_rates));
                ratios = zeros(size(loss_rates));
                for i = [1:length(loss_rates)]
                    loss_rate = loss_rates(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts2   = cnts;
                lens_mses2   = mses;
                lens_maes2   = maes;
                lens_ccs2    = ccs;
                lens_ratios2 = ratios;


                %% plot mse
                clf;
                fh = figure;
                font_size = 28;

                lh1 = plot(loss_rates, pca_mses1);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(loss_rates, pca_mses2);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(loss_rates, dct_mses1);
                set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);
                hold on;

                lh4 = plot(loss_rates, dct_mses2);
                set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh4, 'LineWidth', 4);
                set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh4, 'MarkerEdgeColor', 'auto');
                set(lh4, 'MarkerFaceColor', 'auto');
                set(lh4, 'MarkerSize', 12);
                hold on;

                lh5 = plot(loss_rates, srmf_mses1);
                set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh5, 'LineWidth', 4);
                set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh5, 'MarkerEdgeColor', 'auto');
                set(lh5, 'MarkerFaceColor', 'auto');
                set(lh5, 'MarkerSize', 12);
                hold on;

                lh6 = plot(loss_rates, srmf_mses2);
                set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh6, 'LineWidth', 4);
                set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh6, 'MarkerEdgeColor', 'auto');
                set(lh6, 'MarkerFaceColor', 'auto');
                set(lh6, 'MarkerSize', 12);
                hold on;

                lh7 = plot(loss_rates, mpeg_mses1);
                set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh7, 'LineWidth', 4);
                set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh7, 'MarkerEdgeColor', 'auto');
                set(lh7, 'MarkerFaceColor', 'auto');
                set(lh7, 'MarkerSize', 12);
                hold on;

                lh8 = plot(loss_rates, mpeg_mses2);
                set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh8, 'LineWidth', 4);
                set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh8, 'MarkerEdgeColor', 'auto');
                set(lh8, 'MarkerFaceColor', 'auto');
                set(lh8, 'MarkerSize', 12);
                hold on;

                lh9 = plot(loss_rates, srmf_mses3);
                set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh9, 'LineWidth', 4);
                set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh9, 'MarkerEdgeColor', 'auto');
                set(lh9, 'MarkerFaceColor', 'auto');
                set(lh9, 'MarkerSize', 12);
                hold on;

                lh10 = plot(loss_rates, lc_mses1);
                set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh10, 'LineWidth', 4);
                set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh10, 'MarkerEdgeColor', 'auto');
                set(lh10, 'MarkerFaceColor', 'auto');
                set(lh10, 'MarkerSize', 12);
                hold on;

                lh11 = plot(loss_rates, lc_mses2);
                set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh11, 'LineWidth', 4);
                set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh11, 'MarkerEdgeColor', 'auto');
                set(lh11, 'MarkerFaceColor', 'auto');
                set(lh11, 'MarkerSize', 12);
                hold on;

                lh12 = plot(loss_rates, lens_mses1);
                set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh12, 'LineWidth', 4);
                set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh12, 'MarkerEdgeColor', 'auto');
                set(lh12, 'MarkerFaceColor', 'auto');
                set(lh12, 'MarkerSize', 12);
                hold on;

                lh13 = plot(loss_rates, lens_mses2);
                set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh13, 'LineWidth', 4);
                set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh13, 'MarkerEdgeColor', 'auto');
                set(lh13, 'MarkerFaceColor', 'auto');
                set(lh13, 'MarkerSize', 12);
                hold on;


                if PLOT_FORMAL
                    set(lh2, 'Visible', 'off');
                    set(lh5, 'Visible', 'off');
                    set(lh8, 'Visible', 'off');
                    set(lh9, 'Visible', 'off');

                    kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                else
                    kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                end
                
                set(kh, 'Location', 'BestOutside');
                
                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('Loss Rate', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                
                print(fh, '-dpng', [output_dir file '.' num2str(elem_frac*100) 'ElemSyncLoss.mse.png']);
            end
        end
    end   %% end of plot


    %% --------------------
    %% RowRandLoss
    %% --------------------
    if(PLOT_ROW_RAND)
        fprintf('\nRowRandLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% RowRandLoss
            drop_ele_mode = 'row';
            drop_mode     = 'ind';
            elem_fracs    = [0.05 0.1 0.2 0.4 0.6 0.8];
            loss_rates    = [0.05 0.1 0.5];
            burst_size    = 1;


            for loss_rate = loss_rates
                %% pca1
                r = 10;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts1   = zeros(size(elem_fracs));
                pca_mses1   = zeros(size(elem_fracs));
                pca_maes1   = zeros(size(elem_fracs));
                pca_ccs1    = zeros(size(elem_fracs));
                pca_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts1   = cnts;
                pca_mses1   = mses;
                pca_maes1   = maes;
                pca_ccs1    = ccs;
                pca_ratios1 = ratios;


                %% pca2
                r = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts2   = zeros(size(elem_fracs));
                pca_mses2   = zeros(size(elem_fracs));
                pca_maes2   = zeros(size(elem_fracs));
                pca_ccs2    = zeros(size(elem_fracs));
                pca_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts2   = cnts;
                pca_mses2   = mses;
                pca_maes2   = maes;
                pca_ccs2    = ccs;
                pca_ratios2 = ratios;


                %% DCT, quan = 50
                scheme = 'dct_based_pred';
                opt_type = 'single';
                gop = 4;
                quan = 50;
                opt_swap_mat = 'org';
                
                dct_cnts1   = zeros(size(elem_fracs));
                dct_mses1   = zeros(size(elem_fracs));
                dct_maes1   = zeros(size(elem_fracs));
                dct_ccs1    = zeros(size(elem_fracs));
                dct_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s not exist\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts1   = cnts;
                dct_mses1   = mses;
                dct_maes1   = maes;
                dct_ccs1    = ccs;
                dct_ratios1 = ratios;

                
                %% DCT, # chunks = 200
                scheme = 'dct_based_pred';
                opt_type = 'chunk';
                sel_chunks = 200;
                gop = 4;
                opt_swap_mat = 'org';
                
                dct_cnts2   = zeros(size(elem_fracs));
                dct_mses2   = zeros(size(elem_fracs));
                dct_maes2   = zeros(size(elem_fracs));
                dct_ccs2    = zeros(size(elem_fracs));
                dct_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            fprintf(' %s%s\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts2   = cnts;
                dct_mses2   = mses;
                dct_maes2   = maes;
                dct_ccs2    = ccs;
                dct_ratios2 = ratios;


                %% srmf - r24
                scheme = 'srmf_based_pred';
                opt_type = 'srmf';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts1   = zeros(size(elem_fracs));
                srmf_mses1   = zeros(size(elem_fracs));
                srmf_maes1   = zeros(size(elem_fracs));
                srmf_ccs1    = zeros(size(elem_fracs));
                srmf_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            % fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts1   = cnts;
                srmf_mses1   = mses;
                srmf_maes1   = maes;
                srmf_ccs1    = ccs;
                srmf_ratios1 = ratios;


                %% srmf+knn - r24
                opt_type = 'srmf_knn';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts2   = zeros(size(elem_fracs));
                srmf_mses2   = zeros(size(elem_fracs));
                srmf_maes2   = zeros(size(elem_fracs));
                srmf_ccs2    = zeros(size(elem_fracs));
                srmf_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts2   = cnts;
                srmf_mses2   = mses;
                srmf_maes2   = maes;
                srmf_ccs2    = ccs;
                srmf_ratios2 = ratios;


                %% svd - r1
                opt_type = 'svd';
                r = 1;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts3   = zeros(size(elem_fracs));
                srmf_mses3   = zeros(size(elem_fracs));
                srmf_maes3   = zeros(size(elem_fracs));
                srmf_ccs3    = zeros(size(elem_fracs));
                srmf_ratios3 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts3   = cnts;
                srmf_mses3   = mses;
                srmf_maes3   = maes;
                srmf_ccs    = ccs;
                srmf_ratios3 = ratios;


                %% nearby - fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts1   = zeros(size(elem_fracs));
                mpeg_mses1   = zeros(size(elem_fracs));
                mpeg_maes1   = zeros(size(elem_fracs));
                mpeg_ccs1    = zeros(size(elem_fracs));
                mpeg_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts1   = cnts;
                mpeg_mses1   = mses;
                mpeg_maes1   = maes;
                mpeg_ccs1    = ccs;
                mpeg_ratios1 = ratios;


                %% nearby - no fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'no_fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts2   = zeros(size(elem_fracs));
                mpeg_mses2   = zeros(size(elem_fracs));
                mpeg_maes2   = zeros(size(elem_fracs));
                mpeg_ccs2    = zeros(size(elem_fracs));
                mpeg_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts2   = cnts;
                mpeg_mses2   = mses;
                mpeg_maes2   = maes;
                mpeg_ccs2    = ccs;
                mpeg_ratios2 = ratios;


                %% lc - local, #blocks=64
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'local';
                opt_fill_in    = 'fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 64;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts1   = zeros(1, length(elem_fracs));
                lc_mses1   = zeros(1, length(elem_fracs));
                lc_maes1   = zeros(1, length(elem_fracs));
                lc_ccs1    = zeros(1, length(elem_fracs));
                lc_ratios1 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts1   = cnts;
                lc_mses1   = mses;
                lc_maes1   = maes;
                lc_ccs1    = ccs;
                lc_ratios1 = ratios;


                %% lc - global, #blocks=128
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'global';
                opt_fill_in    = 'no_fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 128;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts2   = zeros(1, length(elem_fracs));
                lc_mses2   = zeros(1, length(elem_fracs));
                lc_maes2   = zeros(1, length(elem_fracs));
                lc_ccs2    = zeros(1, length(elem_fracs));
                lc_ratios2 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts2   = cnts;
                lc_mses2   = mses;
                lc_maes2   = maes;
                lc_ccs2    = ccs;
                lc_ratios2 = ratios;


                %% LENS - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts1   = zeros(size(elem_fracs));
                lens_mses1   = zeros(size(elem_fracs));
                lens_maes1   = zeros(size(elem_fracs));
                lens_ccs1    = zeros(size(elem_fracs));
                lens_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts1   = cnts;
                lens_mses1   = mses;
                lens_maes1   = maes;
                lens_ccs1    = ccs;
                lens_ratios1 = ratios;


                %% LENS+KNN - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens_knn';
                r = 10;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts2   = zeros(size(elem_fracs));
                lens_mses2   = zeros(size(elem_fracs));
                lens_maes2   = zeros(size(elem_fracs));
                lens_ccs2    = zeros(size(elem_fracs));
                lens_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts2   = cnts;
                lens_mses2   = mses;
                lens_maes2   = maes;
                lens_ccs2    = ccs;
                lens_ratios2 = ratios;


                %% plot mse
                clf;
                fh = figure;
                font_size = 28;

                lh1 = plot(elem_fracs, pca_mses1);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(elem_fracs, pca_mses2);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(elem_fracs, dct_mses1);
                set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);
                hold on;

                lh4 = plot(elem_fracs, dct_mses2);
                set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh4, 'LineWidth', 4);
                set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh4, 'MarkerEdgeColor', 'auto');
                set(lh4, 'MarkerFaceColor', 'auto');
                set(lh4, 'MarkerSize', 12);
                hold on;

                lh5 = plot(elem_fracs, srmf_mses1);
                set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh5, 'LineWidth', 4);
                set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh5, 'MarkerEdgeColor', 'auto');
                set(lh5, 'MarkerFaceColor', 'auto');
                set(lh5, 'MarkerSize', 12);
                hold on;

                lh6 = plot(elem_fracs, srmf_mses2);
                set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh6, 'LineWidth', 4);
                set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh6, 'MarkerEdgeColor', 'auto');
                set(lh6, 'MarkerFaceColor', 'auto');
                set(lh6, 'MarkerSize', 12);
                hold on;

                lh7 = plot(elem_fracs, mpeg_mses1);
                set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh7, 'LineWidth', 4);
                set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh7, 'MarkerEdgeColor', 'auto');
                set(lh7, 'MarkerFaceColor', 'auto');
                set(lh7, 'MarkerSize', 12);
                hold on;

                lh8 = plot(elem_fracs, mpeg_mses2);
                set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh8, 'LineWidth', 4);
                set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh8, 'MarkerEdgeColor', 'auto');
                set(lh8, 'MarkerFaceColor', 'auto');
                set(lh8, 'MarkerSize', 12);
                hold on;

                lh9 = plot(elem_fracs, srmf_mses3);
                set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh9, 'LineWidth', 4);
                set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh9, 'MarkerEdgeColor', 'auto');
                set(lh9, 'MarkerFaceColor', 'auto');
                set(lh9, 'MarkerSize', 12);
                hold on;

                lh10 = plot(elem_fracs, lc_mses1);
                set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh10, 'LineWidth', 4);
                set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh10, 'MarkerEdgeColor', 'auto');
                set(lh10, 'MarkerFaceColor', 'auto');
                set(lh10, 'MarkerSize', 12);
                hold on;

                lh11 = plot(elem_fracs, lc_mses2);
                set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh11, 'LineWidth', 4);
                set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh11, 'MarkerEdgeColor', 'auto');
                set(lh11, 'MarkerFaceColor', 'auto');
                set(lh11, 'MarkerSize', 12);
                hold on;

                lh12 = plot(elem_fracs, lens_mses1);
                set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh12, 'LineWidth', 4);
                set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh12, 'MarkerEdgeColor', 'auto');
                set(lh12, 'MarkerFaceColor', 'auto');
                set(lh12, 'MarkerSize', 12);
                hold on;

                lh13 = plot(elem_fracs, lens_mses2);
                set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh13, 'LineWidth', 4);
                set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh13, 'MarkerEdgeColor', 'auto');
                set(lh13, 'MarkerFaceColor', 'auto');
                set(lh13, 'MarkerSize', 12);
                hold on;


                if PLOT_FORMAL
                    set(lh2, 'Visible', 'off');
                    set(lh5, 'Visible', 'off');
                    set(lh8, 'Visible', 'off');
                    set(lh9, 'Visible', 'off');

                    kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                else
                    kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                end
                
                set(kh, 'Location', 'BestOutside');
                
                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('Loss Rate', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                
                print(fh, '-dpng', [output_dir file '.' num2str(loss_rate*100) 'RowRandLoss.mse.png']);
            end
        end
    end   %% end of plot


    %% --------------------
    %% ColRandLoss
    %% --------------------
    if(PLOT_COL_RAND)
        fprintf('\nColRandLoss\n');

        
        files = {'tm_3g_region_all.res0.002.bin60.sub.', 'tm_3g_region_all.res0.004.bin60.sub.', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 'tm_totem.'};

        for file = files
            file = char(file);
            fprintf('  %s\n', file);
            
            if strcmpi(file, 'tm_3g_region_all.res0.002.bin60.sub.')
                num_frames = 24;
                width      = 120;
                height     = 100;

                %% pca
                block_w    = 120;
                block_h    = 100;

                %% dct
                chunk_w    = 12;
                chunk_h    = 10;

            elseif strcmpi(file, 'tm_3g_region_all.res0.004.bin60.sub.')
                num_frames = 24;
                width      = 60;
                height     = 60;

                %% pca
                block_w    = 60;
                block_h    = 60;

                %% dct
                chunk_w    = 6;
                chunk_h    = 6;

            elseif strcmpi(file, 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.')
                num_frames = 19;
                width      = 217;
                height     = 400;

                %% pca
                block_w    = 217;
                block_h    = 400;

                %% dct
                chunk_w    = 22;
                chunk_h    = 40;

            elseif strcmpi(file, 'tm_totem.')
                num_frames = 100;
                width      = 23;
                height     = 23;

                %% pca
                block_w    = 23;
                block_h    = 23;

                %% dct
                chunk_w    = 4;
                chunk_h    = 4;

            end
            

            %% ColRandLoss
            drop_ele_mode = 'col';
            drop_mode     = 'ind';
            elem_fracs    = [0.05 0.1 0.2 0.4 0.6 0.8];
            loss_rates    = [0.05 0.1 0.5];
            burst_size    = 1;


            for loss_rate = loss_rates
                %% pca1
                r = 10;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts1   = zeros(size(elem_fracs));
                pca_mses1   = zeros(size(elem_fracs));
                pca_maes1   = zeros(size(elem_fracs));
                pca_ccs1    = zeros(size(elem_fracs));
                pca_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            % fprintf('  !! %s%s not exist\n', pca_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts1   = cnts;
                pca_mses1   = mses;
                pca_maes1   = maes;
                pca_ccs1    = ccs;
                pca_ratios1 = ratios;


                %% pca2
                r = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                pca_cnts2   = zeros(size(elem_fracs));
                pca_mses2   = zeros(size(elem_fracs));
                pca_maes2   = zeros(size(elem_fracs));
                pca_ccs2    = zeros(size(elem_fracs));
                pca_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds

                        filename = ['pca_based_pred.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(block_w) '.' int2str(block_h) '.r' int2str(r) '.' opt_swap_mat '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([pca_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [pca_dir filename]);
                        data = load([pca_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                pca_cnts2   = cnts;
                pca_mses2   = mses;
                pca_maes2   = maes;
                pca_ccs2    = ccs;
                pca_ratios2 = ratios;


                %% DCT, quan = 50
                scheme = 'dct_based_pred';
                opt_type = 'single';
                gop = 4;
                quan = 50;
                opt_swap_mat = 'org';
                
                dct_cnts1   = zeros(size(elem_fracs));
                dct_mses1   = zeros(size(elem_fracs));
                dct_maes1   = zeros(size(elem_fracs));
                dct_ccs1    = zeros(size(elem_fracs));
                dct_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw0.ch0.nc0.quan' num2str(quan) '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s not exist\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts1   = cnts;
                dct_mses1   = mses;
                dct_maes1   = maes;
                dct_ccs1    = ccs;
                dct_ratios1 = ratios;

                
                %% DCT, # chunks = 200
                scheme = 'dct_based_pred';
                opt_type = 'chunk';
                sel_chunks = 200;
                gop = 4;
                opt_swap_mat = 'org';
                
                dct_cnts2   = zeros(size(elem_fracs));
                dct_mses2   = zeros(size(elem_fracs));
                dct_maes2   = zeros(size(elem_fracs));
                dct_ccs2    = zeros(size(elem_fracs));
                dct_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.' opt_swap_mat '.' opt_type '.cw' int2str(chunk_w) '.ch' int2str(chunk_h) '.nc' int2str(sel_chunks) '.quan0.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([dct_dir filename]))
                            % fprintf(' %s%s\n', dct_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [dct_dir filename]);
                        data = load([dct_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                dct_cnts2   = cnts;
                dct_mses2   = mses;
                dct_maes2   = maes;
                dct_ccs2    = ccs;
                dct_ratios2 = ratios;


                %% srmf - r24
                scheme = 'srmf_based_pred';
                opt_type = 'srmf';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts1   = zeros(size(elem_fracs));
                srmf_mses1   = zeros(size(elem_fracs));
                srmf_maes1   = zeros(size(elem_fracs));
                srmf_ccs1    = zeros(size(elem_fracs));
                srmf_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            % fprintf('  %s%s\n', srmf_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts1   = cnts;
                srmf_mses1   = mses;
                srmf_maes1   = maes;
                srmf_ccs1    = ccs;
                srmf_ratios1 = ratios;


                %% srmf+knn - r24
                opt_type = 'srmf_knn';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts2   = zeros(size(elem_fracs));
                srmf_mses2   = zeros(size(elem_fracs));
                srmf_maes2   = zeros(size(elem_fracs));
                srmf_ccs2    = zeros(size(elem_fracs));
                srmf_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts2   = cnts;
                srmf_mses2   = mses;
                srmf_maes2   = maes;
                srmf_ccs2    = ccs;
                srmf_ratios2 = ratios;


                %% svd - r1
                opt_type = 'srmf_knn';
                r = 1;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                srmf_cnts3   = zeros(size(elem_fracs));
                srmf_mses3   = zeros(size(elem_fracs));
                srmf_maes3   = zeros(size(elem_fracs));
                srmf_ccs3    = zeros(size(elem_fracs));
                srmf_ratios3 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                srmf_cnts3   = cnts;
                srmf_mses3   = mses;
                srmf_maes3   = maes;
                srmf_ccs3    = ccs;
                srmf_ratios3 = ratios;


                %% nearby - fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts1   = zeros(size(elem_fracs));
                mpeg_mses1   = zeros(size(elem_fracs));
                mpeg_maes1   = zeros(size(elem_fracs));
                mpeg_ccs1    = zeros(size(elem_fracs));
                mpeg_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts1   = cnts;
                mpeg_mses1   = mses;
                mpeg_maes1   = maes;
                mpeg_ccs1    = ccs;
                mpeg_ratios1 = ratios;


                %% nearby - no fill in
                scheme = 'mpeg_based_pred';
                opt_delta = 'diff';
                opt_f_b = 18;
                opt_fill_in = 'no_fill';
                opt_swap_mat = 'org';
                
                mpeg_cnts2   = zeros(size(elem_fracs));
                mpeg_mses2   = zeros(size(elem_fracs));
                mpeg_maes2   = zeros(size(elem_fracs));
                mpeg_ccs2    = zeros(size(elem_fracs));
                mpeg_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.bw' int2str(chunk_w) '.bh' int2str(chunk_h) '.' opt_delta '.' int2str(opt_f_b) '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_dir filename]))
                            % fprintf('  %s%s\n', mpeg_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_dir filename]);
                        data = load([mpeg_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                mpeg_cnts2   = cnts;
                mpeg_mses2   = mses;
                mpeg_maes2   = maes;
                mpeg_ccs2    = ccs;
                mpeg_ratios2 = ratios;


                %% lc - local, #blocks=64
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'local';
                opt_fill_in    = 'fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 64;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts1   = zeros(1, length(elem_fracs));
                lc_mses1   = zeros(1, length(elem_fracs));
                lc_maes1   = zeros(1, length(elem_fracs));
                lc_ccs1    = zeros(1, length(elem_fracs));
                lc_ratios1 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts1   = cnts;
                lc_mses1   = mses;
                lc_maes1   = maes;
                lc_ccs1    = ccs;
                lc_ratios1 = ratios;


                %% lc - global, #blocks=128
                scheme = 'mpeg_lc_based_pred';
                opt_scope      = 'global';
                opt_fill_in    = 'no_fill';
                opt_sel_method = 'mae';
                num_sel_blocks = 128;
                opt_swap_mat   = 'org';
                opt_delta      = 'diff';
                
                lc_cnts2   = zeros(1, length(elem_fracs));
                lc_mses2   = zeros(1, length(elem_fracs));
                lc_maes2   = zeros(1, length(elem_fracs));
                lc_ccs2    = zeros(1, length(elem_fracs));
                lc_ratios2 = zeros(1, length(elem_fracs));

                cnts   = zeros(1, length(elem_fracs));
                mses   = zeros(1, length(elem_fracs));
                maes   = zeros(1, length(elem_fracs));
                ccs    = zeros(1, length(elem_fracs));
                ratios = zeros(1, length(elem_fracs));

                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);

                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(chunk_w) '.' int2str(chunk_h) '.' int2str(num_sel_blocks) '.' opt_delta '.' opt_scope '.' opt_sel_method '.' opt_swap_mat '.' opt_fill_in '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([mpeg_lc_dir filename]))
                            % fprintf(' %s%s not exist\n', mpeg_lc_dir, filename);
                            continue;
                        end

                        % fprintf(' %s\n', [mpeg_lc_dir filename]);
                        data = load([mpeg_lc_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  index %d > %f, %f, %f, %f\n', i, mses(i), maes(i), ccs(i), ratios(i));

                end
                lc_cnts2   = cnts;
                lc_mses2   = mses;
                lc_maes2   = maes;
                lc_ccs2    = ccs;
                lc_ratios2 = ratios;


                %% LENS - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens';
                r = num_frames;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts1   = zeros(size(elem_fracs));
                lens_mses1   = zeros(size(elem_fracs));
                lens_maes1   = zeros(size(elem_fracs));
                lens_ccs1    = zeros(size(elem_fracs));
                lens_ratios1 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts1   = cnts;
                lens_mses1   = mses;
                lens_maes1   = maes;
                lens_ccs1    = ccs;
                lens_ratios1 = ratios;


                %% LENS+KNN - r20
                scheme = 'srmf_based_pred';
                opt_type = 'lens_knn';
                r = 10;
                gop = num_frames;
                opt_swap_mat = 'org';
                opt_dim = '2d';
                
                lens_cnts2   = zeros(size(elem_fracs));
                lens_mses2   = zeros(size(elem_fracs));
                lens_maes2   = zeros(size(elem_fracs));
                lens_ccs2    = zeros(size(elem_fracs));
                lens_ratios2 = zeros(size(elem_fracs));

                cnts   = zeros(size(elem_fracs));
                mses   = zeros(size(elem_fracs));
                maes   = zeros(size(elem_fracs));
                ccs    = zeros(size(elem_fracs));
                ratios = zeros(size(elem_fracs));
                for i = [1:length(elem_fracs)]
                    elem_frac = elem_fracs(i);
                    
                    for seed = seeds
                        filename = [scheme '.' file '.' int2str(num_frames) '.' int2str(width) '.' int2str(height) '.' int2str(gop) '.r' int2str(r) '.' opt_swap_mat '.' opt_type '.' opt_dim '.' drop_ele_mode '.' drop_mode '.elem' num2str(elem_frac) '.loss' num2str(loss_rate) '.burst' int2str(burst_size) '.seed' int2str(seed) '.txt'];

                        if ~(exist([srmf_dir filename]))
                            continue;
                        end

                        % fprintf(' %s\n', [srmf_dir filename]);
                        data = load([srmf_dir filename]);
                        mses(i)   = mses(i) + data(1);
                        maes(i)   = maes(i) + data(2);
                        ccs(i)    = ccs(i) + data(3);
                        ratios(i) = ratios(i) + data(4);
                        cnts(i) = cnts(i) + 1;
                        % fprintf('  %f, %f, %f, %f\n', mse, mae, cc, ratio);
                    end

                    if(cnts(i) > 1)
                        mses(i)   = mses(i) / cnts(i);
                        maes(i)   = maes(i) / cnts(i);
                        ccs(i)    = ccs(i) / cnts(i);
                        ratios(i) = ratios(i) / cnts(i);
                    end
                    fprintf('  rank %d > %f, %f, %f, %f\n', r, mses(i), maes(i), ccs(i), ratios(i));
                end
                lens_cnts2   = cnts;
                lens_mses2   = mses;
                lens_maes2   = maes;
                lens_ccs2    = ccs;
                lens_ratios2 = ratios;


                %% plot mse
                clf;
                fh = figure;
                font_size = 28;

                lh1 = plot(elem_fracs, pca_mses1);
                set(lh1, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh1, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh1, 'LineWidth', 4);
                set(lh1, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh1, 'MarkerEdgeColor', 'auto');
                set(lh1, 'MarkerFaceColor', 'auto');
                set(lh1, 'MarkerSize', 10);
                hold on;

                lh2 = plot(elem_fracs, pca_mses2);
                set(lh2, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh2, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh2, 'LineWidth', 4);
                set(lh2, 'marker', '*');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh2, 'MarkerEdgeColor', 'auto');
                set(lh2, 'MarkerFaceColor', 'auto');
                set(lh2, 'MarkerSize', 12);
                hold on;

                lh3 = plot(elem_fracs, dct_mses1);
                set(lh3, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh3, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh3, 'LineWidth', 4);
                set(lh3, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh3, 'MarkerEdgeColor', 'auto');
                set(lh3, 'MarkerFaceColor', 'auto');
                set(lh3, 'MarkerSize', 12);
                hold on;

                lh4 = plot(elem_fracs, dct_mses2);
                set(lh4, 'Color', 'c');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh4, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh4, 'LineWidth', 4);
                set(lh4, 'marker', 's');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh4, 'MarkerEdgeColor', 'auto');
                set(lh4, 'MarkerFaceColor', 'auto');
                set(lh4, 'MarkerSize', 12);
                hold on;

                lh5 = plot(elem_fracs, srmf_mses1);
                set(lh5, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh5, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh5, 'LineWidth', 4);
                set(lh5, 'marker', 'd');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh5, 'MarkerEdgeColor', 'auto');
                set(lh5, 'MarkerFaceColor', 'auto');
                set(lh5, 'MarkerSize', 12);
                hold on;

                lh6 = plot(elem_fracs, srmf_mses2);
                set(lh6, 'Color', 'y');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh6, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh6, 'LineWidth', 4);
                set(lh6, 'marker', '^');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh6, 'MarkerEdgeColor', 'auto');
                set(lh6, 'MarkerFaceColor', 'auto');
                set(lh6, 'MarkerSize', 12);
                hold on;

                lh7 = plot(elem_fracs, mpeg_mses1);
                set(lh7, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh7, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh7, 'LineWidth', 4);
                set(lh7, 'marker', '>');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh7, 'MarkerEdgeColor', 'auto');
                set(lh7, 'MarkerFaceColor', 'auto');
                set(lh7, 'MarkerSize', 12);
                hold on;

                lh8 = plot(elem_fracs, mpeg_mses2);
                set(lh8, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh8, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh8, 'LineWidth', 4);
                set(lh8, 'marker', '<');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh8, 'MarkerEdgeColor', 'auto');
                set(lh8, 'MarkerFaceColor', 'auto');
                set(lh8, 'MarkerSize', 12);
                hold on;

                lh9 = plot(elem_fracs, srmf_mses3);
                set(lh9, 'Color', 'g');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh9, 'LineStyle', '-');  %% line  : -|--|:|-.
                set(lh9, 'LineWidth', 4);
                set(lh9, 'marker', 'p');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh9, 'MarkerEdgeColor', 'auto');
                set(lh9, 'MarkerFaceColor', 'auto');
                set(lh9, 'MarkerSize', 12);
                hold on;

                lh10 = plot(elem_fracs, lc_mses1);
                set(lh10, 'Color', 'b');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh10, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh10, 'LineWidth', 4);
                set(lh10, 'marker', 'h');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh10, 'MarkerEdgeColor', 'auto');
                set(lh10, 'MarkerFaceColor', 'auto');
                set(lh10, 'MarkerSize', 12);
                hold on;

                lh11 = plot(elem_fracs, lc_mses2);
                set(lh11, 'Color', 'm');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh11, 'LineStyle', ':');  %% line  : -|--|:|-.
                set(lh11, 'LineWidth', 4);
                set(lh11, 'marker', '+');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh11, 'MarkerEdgeColor', 'auto');
                set(lh11, 'MarkerFaceColor', 'auto');
                set(lh11, 'MarkerSize', 12);
                hold on;

                lh12 = plot(elem_fracs, lens_mses1);
                set(lh12, 'Color', 'k');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh12, 'LineStyle', '-.');  %% line  : -|--|:|-.
                set(lh12, 'LineWidth', 4);
                set(lh12, 'marker', 'o');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh12, 'MarkerEdgeColor', 'auto');
                set(lh12, 'MarkerFaceColor', 'auto');
                set(lh12, 'MarkerSize', 12);
                hold on;

                lh13 = plot(elem_fracs, lens_mses2);
                set(lh13, 'Color', 'r');      %% color : r|g|b|c|m|y|k|w|[.49 1 .63]
                set(lh13, 'LineStyle', '--');  %% line  : -|--|:|-.
                set(lh13, 'LineWidth', 4);
                set(lh13, 'marker', 'x');     %% marker: +|o|*|.|x|s|d|^|>|<|p|h
                set(lh13, 'MarkerEdgeColor', 'auto');
                set(lh13, 'MarkerFaceColor', 'auto');
                set(lh13, 'MarkerSize', 12);
                hold on;


                if PLOT_FORMAL
                    set(lh2, 'Visible', 'off');
                    set(lh5, 'Visible', 'off');
                    set(lh8, 'Visible', 'off');
                    set(lh9, 'Visible', 'off');

                    kh = legend([lh1, lh3, lh4, lh6, lh7, lh10, lh11, lh12, lh13], 'PCA', 'DCT-quan', 'DCT-chunk', 'SRMF+KNN', 'Nearby-fill in', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                else
                    kh = legend([lh1, lh2, lh3, lh4, lh5, lh6, lh9, lh7, lh8, lh10, lh11, lh12, lh13], 'PCA-r1', 'PCA-rmax', 'DCT-quan', 'DCT-chunk', 'SRMF', 'SRMF+KNN', 'svd', 'Nearby-fill in', 'Nearby-no', 'LC-local', 'LC-global', 'LENS', 'LENS+KNN');
                end
                
                set(kh, 'Location', 'BestOutside');
                
                set(fh, 'PaperUnits', 'points');
                set(fh, 'PaperPosition', [0 0 1024 768]);

                set(gca, 'XLim', [0 Inf]);
                set(gca, 'YLim', [0 1]);

                xlabel('Loss Rate', 'FontSize', font_size);
                ylabel('MSE', 'FontSize', font_size);

                set(gca, 'FontSize', font_size);
                
                print(fh, '-dpng', [output_dir file '.' num2str(loss_rate*100) 'ColRandLoss.mse.png']);
            end
        end
    end   %% end of plot
end




