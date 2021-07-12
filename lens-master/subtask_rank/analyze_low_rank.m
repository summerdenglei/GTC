%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.10 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%   [sigma] = analyze_lowrank('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 8, 217, 400, 0.01)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sigma] = analyze_low_rank(input_TM_dir, filename, num_frames, width, height, thresh)
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
    output_dir = '../processed_data/subtask_rank/rank/';


    %% --------------------
    %% Main starts
    %% --------------------
    % rand('seed', seed);
    

    %% --------------------
    %% Read data matrix
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    data = zeros(height, width, num_frames);
    for frame = [0:num_frames-1]
        if DEBUG0, fprintf('  frame %d\n', frame); end

        %% load data matrix
        this_matrix_file = [input_TM_dir filename int2str(frame) '.txt'];
        if DEBUG0, fprintf('    file = %s\n', this_matrix_file); end
        
        tmp = load(this_matrix_file);
        data(:,:,frame+1) = tmp(1:height, 1:width);
    end
    sx = size(data(:,:,1));
    nx = prod(sx);
    

    %% --------------------
    %% calculate the rank for each frame
    %% --------------------
    if DEBUG2, fprintf('read data matrix\n'); end

    ranks = []; 
    for f = [1:num_frames]
        m = data(:,:,f);
        m = m - mean(m(:));
        sigma = svd(m);

        total_sum = sum(sigma);
        total_sum_sofar = cumsum(sigma);
        cdf = total_sum_sofar ./ total_sum;

        %% change point
        inv_singular = [1; 1 - cdf];
        ix = find(inv_singular < thresh);
        if length(ix) > 0
            ranks = [ranks; ix(1)];
        else
            ranks = [ranks; length(sigma)];
        end


        output_file = [output_dir filename 'rank.' int2str(f) '.txt'];
        dlmwrite(output_file, inv_singular, 'delimiter', '\t');

        output_file = [output_dir filename 'sigma.' int2str(f) '.txt'];
        dlmwrite(output_file, sigma, 'delimiter', '\t');
    end

    output_file = [output_dir filename 'rank.txt'];
    dlmwrite(output_file, ranks, 'delimiter', '\t');


    %% --------------------
    %% remove the top-rank nodes
    %% --------------------
    if DEBUG2, fprintf('remove the top-loaded nodes\n'); end

    light_ranks = []; 
    for f = [1:num_frames]
        m = data(:,:,f);
        
        row_sum = sum(m);
        [sorted, ix] = sort(row_sum, 'descend');
        row_ix = ix(ranks(f)+1:end);

        col_sum = sum(m, 2);
        [sorted, ix] = sort(col_sum, 'descend');
        col_ix = ix(ranks(f)+1:end);

        m = m(col_ix, row_ix);


        m = m - mean(m(:));
        sigma = svd(m);

        total_sum = sum(sigma);
        total_sum_sofar = cumsum(sigma);
        cdf = total_sum_sofar ./ total_sum;

        %% change point
        inv_singular = [1; 1 - cdf];
        ix = find(inv_singular < thresh);
        if length(ix) > 0
            light_ranks = [light_ranks; ix(1)];
        else
            light_ranks = [light_ranks; length(sigma)];
        end

    end

    output_file = [output_dir filename 'light_rank.txt'];
    dlmwrite(output_file, light_ranks, 'delimiter', '\t');
    
end






