%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.11.27 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%   load_dist('all', 60)
%%   load_dist('1125', 60)
%%   load_dist('1126', 60)
%%   load_dist('1128', 60)
%%   load_dist('1129', 60)
%%   load_dist('1130', 60)
%%   load_dist('1201', 60)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = load_dist(goal, time_bin)
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;  %% load traffic info


    %% --------------------
    %% Constant
    %% --------------------
    PLOT_TRAFFIC_TS    = 0;
    PLOT_EWMA_PREDICT  = 0;
    PLOT_PERIODIC_PRED = 1;
    PLOT_LOAD_DIST     = 0;
    PLOT_CELL_CORR     = 0;
    % PLOT_TOP_CELL_CORR = 0;
    PLOT_MORAN_I       = 0;
    PLOT_AUTO_CORR     = 0;
    PLOT_FFT           = 0;
    PLOT_STABILITY     = 0;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '../processed_data/plot_sigmetrics14/tm/';
    output_dir = '../processed_data/plot_sigmetrics14/tm/';

    timebin_per_day = 24 * 60 / time_bin;
    

    %% --------------------
    %% Check input
    %% --------------------


    %% --------------------
    %% Main starts
    %% --------------------
    fprintf('goal: %s\n', goal);
    fprintf('time bin: %d\n', time_bin);


    %% --------------------
    %% load traffic
    %% --------------------    
    if DEBUG2
        fprintf('load traffic\n');
    end

    traffic_info_1125 = load([input_dir '1125_tm_1min.all.bin' int2str(time_bin) '.txt'])';
    traffic_info_1126 = load([input_dir '1126_tm_1min.all.bin' int2str(time_bin) '.txt'])';
    traffic_info_1128 = load([input_dir '1128_tm_1min.all.bin' int2str(time_bin) '.txt'])';
    traffic_info_1129 = load([input_dir '1129_tm_1min.all.bin' int2str(time_bin) '.txt'])';
    traffic_info_1130 = load([input_dir '1130_tm_1min.all.bin' int2str(time_bin) '.txt'])';
    traffic_info_1201 = load([input_dir '1201_tm_1min.all.bin' int2str(time_bin) '.txt'])';


    if strcmp(goal, 'all') == 1
        common_cell_id = intersect(traffic_info_1125(1,:), traffic_info_1126(1,:));
        common_cell_id = intersect(common_cell_id, traffic_info_1128(1,:));
        common_cell_id = intersect(common_cell_id, traffic_info_1129(1,:));
        common_cell_id = intersect(common_cell_id, traffic_info_1130(1,:));
        common_cell_id = intersect(common_cell_id, traffic_info_1201(1,:));
        
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1125(1,:));
        traffic_geo_1125 = traffic_info_1125(1:3, ib);
        traffic_1125     = traffic_info_1125(4:4+timebin_per_day-1, ib);
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1126(1,:));
        traffic_geo_1126 = traffic_info_1126(1:3, ib);
        traffic_1126     = traffic_info_1126(4:4+timebin_per_day-1, ib);
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1128(1,:));
        traffic_geo_1128 = traffic_info_1128(1:3, ib);
        traffic_1128     = traffic_info_1128(4:4+timebin_per_day-1, ib);
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1129(1,:));
        traffic_geo_1129 = traffic_info_1129(1:3, ib);
        traffic_1129     = traffic_info_1129(4:4+timebin_per_day-1, ib);
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1130(1,:));
        traffic_geo_1130 = traffic_info_1130(1:3, ib);
        traffic_1130     = traffic_info_1130(4:4+timebin_per_day-1, ib);
        [C,ia,ib] = intersect(common_cell_id, traffic_info_1201(1,:));
        traffic_geo_1201 = traffic_info_1201(1:3, ib);
        traffic_1201     = traffic_info_1201(4:4+timebin_per_day-1, ib);

        target_traffic = [traffic_1125; traffic_1126; traffic_1128; traffic_1129; traffic_1130; traffic_1201];
        target_geo     = traffic_geo_1125;
        cell_ids       = common_cell_id;
    elseif strcmp(goal, '1125') == 1
        target_traffic = traffic_info_1125(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1125(1:3, :);
        cell_ids       = traffic_info_1125(1,:);
    elseif strcmp(goal, '1126') == 1
        target_traffic = traffic_info_1126(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1126(1:3, :);
        cell_ids       = traffic_info_1126(1,:);
    elseif strcmp(goal, '1128') == 1
        target_traffic = traffic_info_1128(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1128(1:3, :);
        cell_ids       = traffic_info_1128(1,:);
    elseif strcmp(goal, '1129') == 1
        target_traffic = traffic_info_1129(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1129(1:3, :);
        cell_ids       = traffic_info_1129(1,:);
    elseif strcmp(goal, '1130') == 1
        target_traffic = traffic_info_1130(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1130(1:3, :);
        cell_ids       = traffic_info_1130(1,:);
    elseif strcmp(goal, '1201') == 1
        target_traffic = traffic_info_1201(4:4+timebin_per_day-1, :);
        target_geo     = traffic_info_1201(1:3, :);
        cell_ids       = traffic_info_1201(1,:);
    else
        error('goad is wrong: %s', goal);
    end

    
    bs_ids = floor(cell_ids / 10);
    num_bs = length(unique(bs_ids(:)));

    if DEBUG3
        fprintf('# bs: %d\n', num_bs);
        % fprintf('1125 traffic: #time bin=%d, #cells=%d\n', size(traffic_1125));
        % fprintf('1126 traffic: #time bin=%d, #cells=%d\n', size(traffic_1126));
        % fprintf('1128 traffic: #time bin=%d, #cells=%d\n', size(traffic_1128));
        % fprintf('1129 traffic: #time bin=%d, #cells=%d\n', size(traffic_1129));
        % fprintf('1130 traffic: #time bin=%d, #cells=%d\n', size(traffic_1130));
        % fprintf('1201 traffic: #time bin=%d, #cells=%d\n', size(traffic_1201));
        fprintf('target traffic: #time bin=%d, #cells=%d\n', size(target_traffic));
    end





    %% --------------------
    %% plot traffic timeseries
    %% --------------------    
    unit = 1000000; %% MBytes

    if PLOT_TRAFFIC_TS
        if DEBUG2
            fprintf('plot traffic timeseries\n');
        end
    
        file_name = [output_dir goal '.bin' int2str(time_bin) '.ts.txt'];
        [sorted, ix] = sort(sum(target_traffic), 'descend');
        mat = [sum(target_traffic, 2), target_traffic(:, ix)] / unit;
        dlmwrite(file_name, mat, 'delimiter', '\t');
    end


    %% --------------------
    %% plot EWMA prediction
    %% --------------------    
    if PLOT_EWMA_PREDICT
        if DEBUG2
            fprintf('plot EWMA prediction\n');
        end

        alphas   = [0:0.1:1]';
        pred_err = zeros(length(alphas), 2);
        ts = sum(target_traffic, 2);
        mat = [];
        for a = 1:length(alphas)
            alpha = alphas(a);
            prev  = 0;
            pred_ts = zeros(length(ts), 1);
            for i = 1:length(ts)
                pred_ts(i) = prev;

                if i == 1
                    prev = ts(i);
                else
                    prev = alpha * ts(i) + (1-alpha) * prev;
                end
            end

            abs_err   = abs(ts-pred_ts);
            ratio_err = abs(ts-pred_ts) ./ ts;
            mat = [mat, pred_ts / unit, abs_err, ratio_err];

            pred_err(a, 1) = mean(abs_err(5:end));
            pred_err(a, 2) = mean(ratio_err(5:end));
        end
        
        file_name = [output_dir goal '.bin' int2str(time_bin) '.ewma.txt'];
        dlmwrite(file_name, mat, 'delimiter', '\t'); 

        file_name = [output_dir goal '.bin' int2str(time_bin) '.ewma.err.txt'];
        dlmwrite(file_name, [alphas, pred_err], 'delimiter', '\t'); 

    end


    %% --------------------
    %% plot week pattern prediction
    %% --------------------    
    if PLOT_PERIODIC_PRED
        if DEBUG2
            fprintf('plot week pattern prediction\n');
        end

        ts = sum(target_traffic, 2) / unit;
        pred_ts = zeros(length(ts), 1);
        pred_ts(25:end) = ts(1:end-24);

        abs_err   = abs(ts - pred_ts);
        ratio_err = abs(ts - pred_ts) ./ ts;
        mat = [pred_ts, abs_err, ratio_err];

        file_name = [output_dir goal '.bin' int2str(time_bin) '.period_pred.txt'];
        dlmwrite(file_name, [[24:length(abs_err)-1]', mat(25:end, :)], 'delimiter', '\t'); 

        file_name = [output_dir goal '.bin' int2str(time_bin) '.period_pred.err.txt'];
        dlmwrite(file_name, [mean(abs_err(25:end)), mean(ratio_err(25:end))], 'delimiter', '\t'); 

    end


    %% --------------------
    %% plot load distribution
    %% --------------------    
    if PLOT_LOAD_DIST
        if DEBUG2
            fprintf('plot load distribution\n');
        end

        %% all
        file_name = [output_dir goal '.load.cdf.txt'];
        [f, x] = ecdf(sum(target_traffic));
        dlmwrite(file_name, [f, x], 'delimiter', '\t');
        
        %% day & night
        if strcmp(goal, 'all') == 1
            tmp = [9:20];
            day_hour = [[tmp], [tmp+24], [tmp+48], [tmp+72], [tmp+96], [tmp+120]];
                        
            tmp = [1:9, 21:24];
            night_hour = [[tmp], [tmp+24], [tmp+48], [tmp+72], [tmp+96], [tmp+120]];

        else
            day_hour = [9:20];
                        
            night_hour = [1:9, 21:24];
        end

        file_name = [output_dir goal '.load.cdf.day.txt'];
        [f, x] = ecdf(sum(target_traffic([day_hour],:) ));
        dlmwrite(file_name, [f, x], 'delimiter', '\t');

        file_name = [output_dir goal '.load.cdf.night.txt'];
        [f, x] = ecdf(sum(target_traffic([night_hour],:) ));
        dlmwrite(file_name, [f, x], 'delimiter', '\t');


        %% --------------------
        %% zipf
        %% --------------------
        ts = sum(target_traffic) / sum(target_traffic(:));
        [sorted, ix] = sort(ts', 'descend');
        
        out_mat  = [];
        out_perf = [];

        sel_rank = [1:100]';
        fit_ts = sorted(sel_rank);
        [slope, intercept] = logfit(sel_rank, fit_ts, 'loglog'); 
        yApprox = (10^intercept) * (sel_rank.^(slope));
        
        meanX2 = mean(fit_ts .^ 2);
        mse    = mean( (fit_ts - yApprox) .^ 2 ) / meanX2;
        
        out_mat  = [out_mat, fit_ts, yApprox];
        out_perf = [out_perf, 10^intercept, slope, mse];

        % tails = 11:100;
        % fit_tail = fit_ts(tails);
        % [slope_tail, intercept_tail] = logfit(tails, fit_tail, 'loglog'); 
        % yApprox_tail = (10^intercept_tail)*x.^(slope_tail);
        % abs_err_tail = abs(fit_tail - yApprox_tail(tails));
        % abs_err_ratio_tail = abs_err_tail ./ fit_tail;


        file_name = [output_dir goal '.load.zipf.txt'];
        dlmwrite(file_name, out_mat, 'delimiter', '\t');

        file_name = [output_dir goal '.load.zipf.alpha.txt'];
        dlmwrite(file_name, out_perf, 'delimiter', '\t');

    end
   

    %% --------------------
    %% plot correlation coefficient between cells
    %% --------------------    
    threshold = 500000;  % 0;  %% only consider cells with load > threshold (bytes)
    dist_levels = [1:4, 5:5:100, 999999];

    if PLOT_CELL_CORR
        if DEBUG2
            fprintf('plot correlation coefficient between cells\n');
        end

    
        %% all
        file_name = [output_dir goal '.bin' int2str(time_bin) '.corrcoef_dist.txt'];
        fh = fopen(file_name, 'w');
        
        % sel_cell_ix = find(sum(target_traffic) > threshold);
        [sorted, ix] = sort(sum(target_traffic), 'descend');
        sel_cell_ix = ix(1:min(length(ix), 600));
        sel_traffic = target_traffic(:, sel_cell_ix);
        sel_traffic_info = target_geo(:, sel_cell_ix);
        
        R = corrcoef(sel_traffic);
        num_sel = size(R, 1);

        num_dist_rank = length(dist_levels) + 1;
        coef_avg = zeros(num_dist_rank, 1);
        coef_cnt = zeros(num_dist_rank, 1);
        
        for i = [1:num_sel-1]
            cell_id_i = sel_traffic_info(1, i);
            lat_i     = sel_traffic_info(2, i);
            lng_i     = sel_traffic_info(3, i);
            bs_id_i   = floor(cell_id_i / 10);

            if DEBUG1
                fprintf('  %d: (%d, %d, %f, %f)\n', i, cell_id_i, bs_id_i, lat_i, lng_i);
            end


            for j = [i+1:num_sel]
                cell_id_j = sel_traffic_info(1, j);
                lat_j     = sel_traffic_info(2, j);
                lng_j     = sel_traffic_info(3, j);
                bs_id_j   = floor(cell_id_j / 10);

                dist = pos2dist(lat_i, lng_i, lat_j, lng_j, 2);
                corr = R(i, j);
                fprintf(fh, '%f\t%f\n', corr, dist);

                if DEBUG0
                    fprintf('    %d: (%d, %d, %f, %f) - %f\n', j, cell_id_j, bs_id_j, lat_j, lng_j, dist);
                end


                if bs_id_i == bs_id_j
                    ix = 1;
                    coef_avg(ix) = coef_avg(ix) + corr;
                    coef_cnt(ix) = coef_cnt(ix) + 1;
                else

                    find_it = 0;
                    for ix = [1:length(dist_levels)] + 1
                        if dist < dist_levels(ix-1)
                            coef_avg(ix) = coef_avg(ix) + corr;
                            coef_cnt(ix) = coef_cnt(ix) + 1;
                            find_it = find_it + 1;
                            break;
                        end
                    end

                    if find_it == 0
                        error('too far... i: [%d, %f, %f] - [%d, %f, %f]', cell_id_i, lat_i, lng_i, cell_id_j, lat_j, lng_j);
                    elseif find_it > 1
                        error('find_it > 1: %d', find_it);
                    end
                end
            end
        end
        fclose(fh);

        coef_avg(coef_cnt == 0) = NaN;
        coef_avg(coef_cnt > 0) = coef_avg(coef_cnt > 0) ./ coef_cnt(coef_cnt > 0);
        file_name = [output_dir goal '.bin' int2str(time_bin) '.corrcoef_dist_rank.txt'];
        dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');

    end



    %% -------------------
    %% plot Moran I
    %% -------------------
    dist_thresholds = [0, 2, 5, 10];
    if PLOT_MORAN_I
        if DEBUG2
            fprintf('plot Moran I\n');
        end

        for dist_threshold = dist_thresholds
            %% all
            % sel_cell_ix = find(sum(target_traffic) > threshold);
            [sorted, ix] = sort(sum(target_traffic), 'descend');
            sel_cell_ix = ix(1:300);
            sel_traffic = target_traffic(:, sel_cell_ix);
            sel_traffic_info = target_geo(:, sel_cell_ix);

            num_frames = size(sel_traffic, 1);
            num_cells  = size(sel_traffic, 2);

            %% calculate W
            W = zeros(num_cells);
            for cell_i = [1:num_cells]
                lat_i = sel_traffic_info(2, cell_i);
                lng_i = sel_traffic_info(3, cell_i);

                for cell_j = [1:num_cells]
                    if cell_i == cell_j
                        continue;
                    end

                    lat_j = sel_traffic_info(2, cell_j);
                    lng_j = sel_traffic_info(3, cell_j);

                    dist = pos2dist(lat_i, lng_i, lat_j, lng_j, 2);


                    if dist <= dist_threshold
                        W(cell_i, cell_j) = 1;
                    else
                        W(cell_i, cell_j) = 0;
                    end

                end
            end

            W_sum = sum(W(:));

            %% Moran's I
            moranI_ts = zeros(num_frames, 1);
            for f = [1:num_frames]
                fprintf('  f=%d\n', f);
                
                X = sel_traffic(f, :);
                X_mean = mean(X(:));

                moran_up = 0;
                moran_down = 0;
                for cell_i = [1:num_cells]
                    moran_down = moran_down + power((X(cell_i) - X_mean), 2);

                    for cell_j = [1:num_cells]
                        moran_up = moran_up + W(cell_i, cell_j) * (X(cell_i) - X_mean) * (X(cell_j) - X_mean);
                    end
                end

                moranI_ts(f) = num_cells * moran_up / W_sum / moran_down;
            end

            %% moving avg
            if time_bin <= 10
                win_size = 8;
            elseif time_bin <= 100
                win_size = 2;
            else 
                win_size = 1;
            end
            moranI_avg_ts = zeros(num_frames, 1);
            for f = [1:num_frames]
                f_s = max(1, f-win_size);
                f_e = min(num_frames, f+win_size);

                moranI_avg_ts(f) = mean(moranI_ts(f_s:f_e));
            end

            file_name = [output_dir goal '.bin' int2str(time_bin) '.moranI.thresh' int2str(dist_threshold) '.txt'];
            dlmwrite(file_name, [moranI_ts, moranI_avg_ts], 'delimiter', '\t');

        end
    end


    %% -------------------
    %% plot autocorrelation
    %% -------------------
    if PLOT_AUTO_CORR
        if DEBUG2
            fprintf('plot autocorrelation\n');
        end

        file_name = [output_dir goal '.bin' int2str(time_bin) '.autocorr.txt'];
        mat = [];
        sum_traffic = sum(target_traffic, 2);
        % acf = my_autocorr(sum_traffic);
        % acf = xcorr(sum_traffic, 'coeff');
        acf = my_autocorr2(sum_traffic);
        mat = [mat, reshape(acf, [], 1)];
        % dlmwrite(file_name, reshape(acf, [], 1), 'delimiter', '\t');

        [sorted, ix] = sort(sum(target_traffic), 'descend');
        for top_n = 1:5
            acf = my_autocorr2(target_traffic(:,ix(top_n)));
            mat = [mat, reshape(acf, [], 1)];
        end
        dlmwrite(file_name, mat, 'delimiter', '\t');
        
    end


    %% -------------------
    %% plot FFT
    %% -------------------
    if PLOT_FFT
        if DEBUG2
            fprintf('plot FFT\n');
        end

        file_name = [output_dir goal '.bin' int2str(time_bin) '.fft.txt'];
        sum_traffic = sum(target_traffic, 2);
        mat = my_fft(sum_traffic, time_bin);
        dlmwrite(file_name, mat, 'delimiter', '\t');

        [sorted, ix] = sort(sum(target_traffic), 'descend');
        for top_n = 1:5
            file_name = [output_dir goal '.bin' int2str(time_bin) '.fft.top' int2str(top_n) '.txt'];
            mat = my_fft(target_traffic(:,ix(top_n)), time_bin);
            dlmwrite(file_name, mat, 'delimiter', '\t');
        end
    end



    %% -------------------
    %% plot stability
    %%    x: time, y: overlaps of top_n
    %% -------------------
    if PLOT_STABILITY
        if DEBUG2
            fprintf('plot STABILITY\n');
        end


        tbs = [1 2 3 4 5 6 12 18 24];
        tops = [5, 10, 25, 50, 100, 200];

        % for this_tb = tbs
        %     for top_n = tops
            
        %         file_name = [output_dir goal '.overlap.tb' int2str(this_tb) '.top' int2str(top_n) '.txt'];
        %         fh = fopen(file_name, 'w');

        %         num_tb = ceil(size(target_traffic, 1) / this_tb);
        %         new_tm = [];
        %         top_sectors = [];
        %         for i = [1:num_tb]
        %             s = (i-1) * this_tb + 1;
        %             e = i * this_tb;
        %             this_tm = target_traffic(s:e, :);
        %             % new_tm = [new_tm; this_tm];
        %             this_sum = sum(this_tm, 1);
        %             [sorted, ix] = sort(this_sum, 'descend');

        %             num_overlap = length(intersect(top_sectors, ix(1:top_n)));
        %             top_sectors = ix(1:top_n);

        %             fprintf(fh, '%d, %d, %f\n', s, num_overlap, num_overlap/top_n);
        %         end
        %         fprintf(fh, '\n');

        %         fclose(fh);

        %     end
        % end

        file_name = [output_dir goal '.overlap.txt'];
        fh = fopen(file_name, 'w');
        
        for top_i = 1:length(tops)
            top_n   = tops(top_i);
            fprintf(fh, '"top%d"', top_n);

            for tb_i = 1:length(tbs)
                this_tb = tbs(tb_i);

                num_tb = ceil(size(target_traffic, 1) / this_tb);
                top_sectors = [];
                all_num_overlap = [];
                for i = [1:num_tb]
                    s = (i-1) * this_tb + 1;
                    e = min(i * this_tb, size(target_traffic, 1));
                    this_tm = target_traffic(s:e, :);
                    this_sum = sum(this_tm, 1);
                    [sorted, ix] = sort(this_sum, 'descend');

                    num_overlap = length(intersect(top_sectors, ix(1:top_n)));
                    top_sectors = ix(1:top_n);

                    if i > 1
                        all_num_overlap = [all_num_overlap, num_overlap];
                    end

                end
                
                avg_num_overlap = mean(all_num_overlap);
                avg_ratio = avg_num_overlap / top_n;
                fprintf(fh, ', %f', avg_ratio);

            end
            fprintf(fh, '\n');
        end

        fclose(fh);


        % %% ---------------

        file_name = [output_dir goal '.overlap.across_days.txt'];
        fh = fopen(file_name, 'w');
        
        for top_i = 1:length(tops)
            top_n   = tops(top_i);
            fprintf(fh, '"top%d"', top_n);

            this_tb = 24;
            num_tb = ceil(size(target_traffic, 1) / this_tb);
            top_sectors = [];
            all_num_overlap = [];
            for i = [1:num_tb]
                s = (i-1) * this_tb + 1;
                e = min(i * this_tb, size(target_traffic, 1));
                this_tm = target_traffic(s:e, :);
                this_sum = sum(this_tm, 1);
                [sorted, ix] = sort(this_sum, 'descend');


                if i == 1
                    top_sectors = ix(1:top_n);
                else
                    num_overlap = length(intersect(top_sectors, ix(1:top_n)));
                    fprintf(fh, ', %f', num_overlap / top_n);

                    top_sectors = ix(1:top_n);
                end
            end
            
            fprintf(fh, '\n');
        end

        fclose(fh);

        %% ---------------


        % file_name = [output_dir goal '.overlap.across_days.txt'];
        % fh = fopen(file_name, 'w');

        % this_tb = 24;
        % for top_n = tops

        %     num_tb = ceil(size(target_traffic, 1) / this_tb);
        %     new_tm = [];
        %     top_sectors = [];
        %     for i = [1:num_tb]
        %         s = (i-1) * this_tb + 1;
        %         e = i * this_tb;
        %         this_tm = target_traffic(s:e, :);
        %         % new_tm = [new_tm; this_tm];
        %         this_sum = sum(this_tm, 1);
        %         [sorted, ix] = sort(this_sum, 'descend');

        %         num_overlap = length(intersect(top_sectors, ix(1:top_n)));
        %         top_sectors = ix(1:top_n);

        %         fprintf(fh, '%d, %d, %f\n', s, num_overlap, num_overlap/top_n);
        %     end
        %     fprintf(fh, '\n');

        %     fclose(fh);

        % end
        

    end

end





%% my_autocorr
function [m] = my_autocorr(ts)
    x = ts;
    N = length(ts);
    y = x;
    z = x;
    for i = 1:N-1
        for i = N-1:-1:1
            x(i+1) = x(i);
        end
        x(1) = 0;
        z = [z; x];
    end;
    m = [z]*[y'];
    m = m/N;
end

function [m] = my_autocorr2(ts)
    N = length(ts);
    m = [];
    for i = 5:N
        ts1 = ts(N-i+1:N);
        ts2 = ts(1:i);
        % i
        % size(ts1)
        % size(ts2)
        R = corrcoef(ts1, ts2);
        % size(R)
        m = [m, R(1,2)];
    end
    for j = 1:N-4
        ts1 = ts(1:N-j);
        ts2 = ts(j+1:N);
        % j
        % size(ts1)
        % size(ts2)
        R = corrcoef(ts1, ts2);
        m = [m, R(1,2)];
    end
end


%% my_fft: function description
function [mat] = my_fft(ts, time_bin)
    Fs = 1 / (time_bin*60);                    % Sampling frequency
    T = time_bin*60;                     % Sample time
    L = length(ts);                     % Length of signal
    t = (0:L-1)*T;                % Time vector
    
    NFFT = 2^nextpow2(L); % Next power of 2 from length of y
    Y = fft(ts, NFFT) / L;
    f = Fs/2 * linspace(0, 1, NFFT/2+1);

    mat = [f', 2*abs(Y(1:NFFT/2+1))];
end


% y = a x^b 
function [a, b] = my_powerLawFit(x, y)
    logx=log10(x); 
    logy=log10(y); 
    p=polyfit(logx,logy,1); 
    b=p(1); 
    loga=p(2); 
    a=power(10, loga); 
end
