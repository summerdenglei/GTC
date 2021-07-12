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
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = load_dist(time_bin)
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
    PLOT_TRAFFIC_TS    = 1;
    PLOT_LOAD_DIST     = 0;
    PLOT_CELL_CORR     = 0;
    PLOT_TOP_CELL_CORR = 0;
    PLOT_MORAN_I       = 0;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '../processed_data/subtask_parse_huawei_3g/ip_traffic/';
    output_dir = '../processed_data/subtask_analyze_3g/stat/';

    all_traffic_file = ['3g_cell_traffic_ts.all.bin' int2str(time_bin) '.txt'];
    dl_traffic_file  = ['3g_cell_traffic_ts.dl.bin' int2str(time_bin) '.txt'];
    ul_traffic_file  = ['3g_cell_traffic_ts.ul.bin' int2str(time_bin) '.txt'];


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% load traffic
    %% --------------------    
    if DEBUG2
        fprintf('load traffic\n');
    end

    all_traffic_info = load([input_dir all_traffic_file])';
    dl_traffic_info = load([input_dir dl_traffic_file])';
    ul_traffic_info = load([input_dir ul_traffic_file])';

    all_traffic = all_traffic_info(4:end, :);
    dl_traffic  = dl_traffic_info(4:end, :);
    ul_traffic  = ul_traffic_info(4:end, :);
    
    all_sx = size(all_traffic);
    dl_sx  = size(dl_traffic);
    ul_sx  = size(ul_traffic);

    cell_ids = all_traffic(1, :);
    bs_ids = floor(cell_ids / 10);
    num_bs = length(unique(bs_ids(:)));

    if DEBUG3
        fprintf('# bs: %d\n', num_bs);
        fprintf('all traffic: #time bin=%d, #cells=%d\n', all_sx);
        fprintf('dl traffic : #time bin=%d, #cells=%d\n', dl_sx);
        fprintf('ul traffic : #time bin=%d, #cells=%d\n', ul_sx);
    end


    %% --------------------
    %% plot traffic timeseries
    %% --------------------    
    if PLOT_TRAFFIC_TS
        if DEBUG2
            fprintf('plot traffic timeseries\n');
        end

        unit = 1000000; %% MBytes
        %% all
        file_name_all = [output_dir 'ts_cells.all.bin' int2str(time_bin) '.txt'];
        [sorted, ix] = sort(sum(all_traffic), 'descend');
        mat_all = [sum(all_traffic, 2), all_traffic(:, ix)] / unit;
        dlmwrite(file_name_all, mat_all, 'delimiter', '\t');

        %% downlink
        file_name_dl = [output_dir 'ts_cells.dl.bin' int2str(time_bin) '.txt'];
        % [sorted, ix] = sort(sum(dl_traffic), 'descend');
        mat_dl = [sum(dl_traffic, 2), dl_traffic(:, ix)] / unit;
        dlmwrite(file_name_dl, mat_dl, 'delimiter', '\t');

        %% uplink
        file_name_ul = [output_dir 'ts_cells.ul.bin' int2str(time_bin) '.txt'];
        % [sorted, ix] = sort(sum(ul_traffic), 'descend');
        mat_ul = [sum(ul_traffic, 2), ul_traffic(:, ix)] / unit;
        dlmwrite(file_name_ul, mat_ul, 'delimiter', '\t');
    end


    %% --------------------
    %% plot load distribution
    %% --------------------    
    if PLOT_TRAFFIC_TS
        if DEBUG2
            fprintf('plot load distribution\n');
        end

        %% all
        file_name_all = [output_dir 'load_cdf.all.txt'];
        [f, x] = ecdf(sum(all_traffic));
        dlmwrite(file_name_all, [f, x], 'delimiter', '\t');
        
        file_name_all = [output_dir 'load_cdf.all.day.txt'];
        [f, x] = ecdf(sum(all_traffic(9:18,:) ));
        dlmwrite(file_name_all, [f, x], 'delimiter', '\t');
        
        file_name_all = [output_dir 'load_cdf.all.night.txt'];
        [f, x] = ecdf(sum(all_traffic([1:8, 19:end],:) ));
        dlmwrite(file_name_all, [f, x], 'delimiter', '\t');

        %% dl
        file_name_dl = [output_dir 'load_cdf.dl.txt'];
        [f, x] = ecdf(sum(dl_traffic));
        dlmwrite(file_name_dl, [f, x], 'delimiter', '\t');
        
        file_name_dl = [output_dir 'load_cdf.dl.day.txt'];
        [f, x] = ecdf(sum(dl_traffic(9:18,:) ));
        dlmwrite(file_name_dl, [f, x], 'delimiter', '\t');
        
        file_name_dl = [output_dir 'load_cdf.dl.night.txt'];
        [f, x] = ecdf(sum(dl_traffic([1:8, 19:end],:) ));
        dlmwrite(file_name_dl, [f, x], 'delimiter', '\t');

        %% ul
        file_name_ul = [output_dir 'load_cdf.ul.txt'];
        [f, x] = ecdf(sum(ul_traffic));
        dlmwrite(file_name_ul, [f, x], 'delimiter', '\t');
        
        file_name_ul = [output_dir 'load_cdf.ul.day.txt'];
        [f, x] = ecdf(sum(ul_traffic(9:18,:) ));
        dlmwrite(file_name_ul, [f, x], 'delimiter', '\t');
        
        file_name_ul = [output_dir 'load_cdf.ul.night.txt'];
        [f, x] = ecdf(sum(ul_traffic([1:8, 19:end],:) ));
        dlmwrite(file_name_ul, [f, x], 'delimiter', '\t');
        
    end
   

    %% --------------------
    %% plot correlation coefficient between cells
    %% --------------------    
    threshold = 500000;  % 0;  %% only consider cells with load > threshold (bytes)
    dist_levels = [1:4, 5:5:100];

    if PLOT_CELL_CORR
        if DEBUG2
            fprintf('plot correlation coefficient between cells\n');
        end

    
        %% all
        file_name_all = [output_dir 'corrcoef_dist.all.bin' int2str(time_bin) '.txt'];
        fh = fopen(file_name_all, 'w');
        
        sel_cell_ix = find(sum(all_traffic) > threshold);
        sel_traffic = all_traffic(:, sel_cell_ix);
        sel_traffic_info = all_traffic_info(1:3, sel_cell_ix);
        
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
        file_name = [output_dir 'corrcoef_dist_rank.all.bin' int2str(time_bin) '.txt'];
        dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');


        %% downlink
        file_name_dl = [output_dir 'corrcoef_dist.dl.bin' int2str(time_bin) '.txt'];
        fh = fopen(file_name_dl, 'w');
        
        % sel_cell_ix = find(sum(dl_traffic) > threshold);
        sel_traffic = dl_traffic(:, sel_cell_ix);
        sel_traffic_info = dl_traffic_info(1:3, sel_cell_ix);
        
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
        file_name = [output_dir 'corrcoef_dist_rank.dl.bin' int2str(time_bin) '.txt'];
        dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');


        %% uplink
        file_name_ul = [output_dir 'corrcoef_dist.ul.bin' int2str(time_bin) '.txt'];
        fh = fopen(file_name_ul, 'w');
        
        % sel_cell_ix = find(sum(ul_traffic) > threshold);
        sel_traffic = ul_traffic(:, sel_cell_ix);
        sel_traffic_info = ul_traffic_info(1:3, sel_cell_ix);
        
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
        file_name = [output_dir 'corrcoef_dist_rank.ul.bin' int2str(time_bin) '.txt'];
        dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');
    end


    %% --------------------
    %% plot correlation coefficient of of top cells
    %% --------------------    
    if PLOT_TOP_CELL_CORR
        if DEBUG2
            fprintf('plot correlation coefficient of of top cells\n');
        end

        %% all
        for top_ix = [1:4]
            file_name_all = [output_dir 'corrcoef_dist.top' int2str(top_ix) '.all.bin' int2str(time_bin) '.txt'];
            fh = fopen(file_name_all, 'w');
            
            % sel_cell_ix = find(sum(all_traffic) > threshold);
            [sorted, ix] = sort(sum(all_traffic), 'descend');
            sel_cell_ix = ix(1:100);
            sel_traffic = all_traffic(:, sel_cell_ix);
            sel_traffic_info = all_traffic_info(1:3, sel_cell_ix);
            

            [sorted, ix] = sort(sum(sel_traffic), 'descend');
            this_top = ix(top_ix);
            top_cell_id  = sel_traffic_info(1, this_top);
            top_cell_lat = sel_traffic_info(2, this_top);
            top_cell_lng = sel_traffic_info(3, this_top);
            top_bs_id    = floor(top_cell_id / 10);


            R = corrcoef(sel_traffic);
            num_sel = size(R, 1);

            num_dist_rank = length(dist_levels) + 1;
            coef_avg = zeros(num_dist_rank, 1);
            coef_cnt = zeros(num_dist_rank, 1);
            
            for i = [1:num_sel]
                if i == this_top
                    continue;
                end

                cell_id_i = sel_traffic_info(1, i);
                lat_i     = sel_traffic_info(2, i);
                lng_i     = sel_traffic_info(3, i);
                bs_id_i   = floor(cell_id_i / 10);

                if cell_id_i == top_cell_id
                    error('same cell id');
                end

                if DEBUG1
                    fprintf('  %d: (%d, %d, %f, %f)\n', i, cell_id_i, bs_id_i, lat_i, lng_i);
                end


                dist = pos2dist(lat_i, lng_i, top_cell_lat, top_cell_lng, 2);
                corr = R(i, this_top);
                fprintf(fh, '%f\t%f\n', corr, dist);


                if bs_id_i == top_bs_id
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
            fclose(fh);

            coef_avg(coef_cnt == 0) = NaN;
            coef_avg(coef_cnt > 0) = coef_avg(coef_cnt > 0) ./ coef_cnt(coef_cnt > 0);
            file_name = [output_dir 'corrcoef_dist_rank.top' int2str(top_ix) '.all.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');
        end

        %% downlink
        for top_ix = [1:4]
            file_name_dl = [output_dir 'corrcoef_dist.top' int2str(top_ix) '.dl.bin' int2str(time_bin) '.txt'];
            fh = fopen(file_name_dl, 'w');
            
            % sel_cell_ix = find(sum(dl_traffic) > threshold);
            % [sorted, ix] = sort(sum(dl_traffic), 'descend');
            % sel_cell_ix = ix(1:100);
            sel_traffic = dl_traffic(:, sel_cell_ix);
            sel_traffic_info = dl_traffic_info(1:3, sel_cell_ix);

            [sorted, ix] = sort(sum(sel_traffic), 'descend');
            this_top = ix(top_ix);
            top_cell_id  = sel_traffic_info(1, this_top);
            top_cell_lat = sel_traffic_info(2, this_top);
            top_cell_lng = sel_traffic_info(3, this_top);
            top_bs_id    = floor(top_cell_id / 10);


            R = corrcoef(sel_traffic);
            num_sel = size(R, 1);

            num_dist_rank = length(dist_levels) + 1;
            coef_avg = zeros(num_dist_rank, 1);
            coef_cnt = zeros(num_dist_rank, 1);
            
            for i = [1:num_sel]
                if i == this_top
                    continue;
                end

                cell_id_i = sel_traffic_info(1, i);
                lat_i     = sel_traffic_info(2, i);
                lng_i     = sel_traffic_info(3, i);
                bs_id_i   = floor(cell_id_i / 10);

                if cell_id_i == top_cell_id
                    error('same cell id');
                end

                if DEBUG1
                    fprintf('  %d: (%d, %d, %f, %f)\n', i, cell_id_i, bs_id_i, lat_i, lng_i);
                end


                dist = pos2dist(lat_i, lng_i, top_cell_lat, top_cell_lng, 2);
                corr = R(i, this_top);
                fprintf(fh, '%f\t%f\n', corr, dist);


                if bs_id_i == top_bs_id
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
            fclose(fh);

            coef_avg(coef_cnt == 0) = NaN;
            coef_avg(coef_cnt > 0) = coef_avg(coef_cnt > 0) ./ coef_cnt(coef_cnt > 0);
            file_name = [output_dir 'corrcoef_dist_rank.top' int2str(top_ix) '.dl.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');
        end

        %% uplink
        for top_ix = [1:4]
            file_name_ul = [output_dir 'corrcoef_dist.top' int2str(top_ix) '.ul.bin' int2str(time_bin) '.txt'];
            fh = fopen(file_name_ul, 'w');
            
            % sel_cell_ix = find(sum(ul_traffic) > threshold);
            % [sorted, ix] = sort(sum(ul_traffic), 'descend');
            % sel_cell_ix = ix(1:100);
            sel_traffic = ul_traffic(:, sel_cell_ix);
            sel_traffic_info = ul_traffic_info(1:3, sel_cell_ix);

            [sorted, ix] = sort(sum(sel_traffic), 'descend');
            this_top = ix(top_ix);
            top_cell_id  = sel_traffic_info(1, this_top);
            top_cell_lat = sel_traffic_info(2, this_top);
            top_cell_lng = sel_traffic_info(3, this_top);
            top_bs_id    = floor(top_cell_id / 10);


            R = corrcoef(sel_traffic);
            num_sel = size(R, 1);

            num_dist_rank = length(dist_levels) + 1;
            coef_avg = zeros(num_dist_rank, 1);
            coef_cnt = zeros(num_dist_rank, 1);
            
            for i = [1:num_sel]
                if i == this_top
                    continue;
                end

                cell_id_i = sel_traffic_info(1, i);
                lat_i     = sel_traffic_info(2, i);
                lng_i     = sel_traffic_info(3, i);
                bs_id_i   = floor(cell_id_i / 10);

                if cell_id_i == top_cell_id
                    error('same cell id');
                end

                if DEBUG1
                    fprintf('  %d: (%d, %d, %f, %f)\n', i, cell_id_i, bs_id_i, lat_i, lng_i);
                end


                dist = pos2dist(lat_i, lng_i, top_cell_lat, top_cell_lng, 2);
                corr = R(i, this_top);
                fprintf(fh, '%f\t%f\n', corr, dist);


                if bs_id_i == top_bs_id
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
            fclose(fh);

            coef_avg(coef_cnt == 0) = NaN;
            coef_avg(coef_cnt > 0) = coef_avg(coef_cnt > 0) ./ coef_cnt(coef_cnt > 0);
            file_name = [output_dir 'corrcoef_dist_rank.top' int2str(top_ix) '.ul.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [[0, dist_levels]', coef_avg], 'delimiter', '\t');
        end
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
            % sel_cell_ix = find(sum(all_traffic) > threshold);
            [sorted, ix] = sort(sum(all_traffic), 'descend');
            sel_cell_ix = ix(1:100);
            sel_traffic = all_traffic(:, sel_cell_ix);
            sel_traffic_info = all_traffic_info(1:3, sel_cell_ix);

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

            file_name = [output_dir 'moranI.thresh' int2str(dist_threshold) '.all.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [moranI_ts, moranI_avg_ts], 'delimiter', '\t');


            %% downlink
            % sel_cell_ix = find(sum(dl_traffic) > threshold);
            [sorted, ix] = sort(sum(dl_traffic), 'descend');
            sel_cell_ix = ix(1:100);
            sel_traffic = dl_traffic(:, sel_cell_ix);
            sel_traffic_info = dl_traffic_info(1:3, sel_cell_ix);

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

            file_name = [output_dir 'moranI.thresh' int2str(dist_threshold) '.dl.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [moranI_ts, moranI_avg_ts], 'delimiter', '\t');


            %% uplink
            % sel_cell_ix = find(sum(ul_traffic) > threshold);
            [sorted, ix] = sort(sum(ul_traffic), 'descend');
            sel_cell_ix = ix(1:100);
            sel_traffic = ul_traffic(:, sel_cell_ix);
            sel_traffic_info = ul_traffic_info(1:3, sel_cell_ix);

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

            file_name = [output_dir 'moranI.thresh' int2str(dist_threshold) '.ul.bin' int2str(time_bin) '.txt'];
            dlmwrite(file_name, [moranI_ts, moranI_avg_ts], 'delimiter', '\t');
        end
    end

end