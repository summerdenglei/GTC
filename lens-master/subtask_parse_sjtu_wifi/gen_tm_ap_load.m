%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.01.05 @ UT Austin
%%
%% - Input:
%%   top
%%
%% - Output:
%%
%%
%% e.g.
%%   gen_tm_ap_load(50)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gen_tm_ap_load(sel_ap)
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
    input_dir  = '../processed_data/subtask_parse_sjtu_wifi/tm/';
    output_dir = '../processed_data/subtask_parse_sjtu_wifi/tm/';

    filename_ul = 'tm_upload.sort_ips.ap.country.txt.600.';
    filename_dl = 'tm_download.sort_ips.ap.country.txt.600.';
    nf     = 114;
    num_ap = 250;


    %% --------------------
    %% Check input
    %% --------------------
    if nargin < 1, sel_ap = 250; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% Read 3D TM
    %% --------------------
    fprintf('Read 3G TM\n');

    data_ul = zeros(num_ap, nf);
    data_dl = zeros(num_ap, nf);
    for f = 1:nf
        fprintf('frame %d\n', f);

        %% uplink
        tmp = load([input_dir filename_ul int2str(f-1) '.txt']);
        tmp = sum(tmp, 2);
        fprintf('  UL: %d, %d\n', size(tmp));
        data_ul(:, f) = tmp;

        %% downlink
        tmp = load([input_dir filename_dl int2str(f-1) '.txt']);
        tmp = sum(tmp, 1)';
        fprintf('  DL: %d, %d\n', size(tmp));
        data_dl(:, f) = tmp;
    end


    %% --------------------
    %% sort 
    %% --------------------
    fprintf('Sort\n');

    data_all = data_ul + data_dl;
    sum_data = sum(data_all, 2);
    [sorted, ix] = sort(sum_data, 'descend');

    sel_data_all = data_all(ix(1:sel_ap), :);
    sel_data_ul  = data_ul(ix(1:sel_ap), :);
    sel_data_dl  = data_dl(ix(1:sel_ap), :);

    
    dlmwrite([output_dir 'tm_sjtu_wifi.ap_load.all.bin600.top' int2str(sel_ap) '.txt'], sel_data_all', 'delimiter', '\t');
    dlmwrite([output_dir 'tm_sjtu_wifi.ap_load.ul.bin600.top' int2str(sel_ap) '.txt'], sel_data_ul', 'delimiter', '\t');
    dlmwrite([output_dir 'tm_sjtu_wifi.ap_load.dl.bin600.top' int2str(sel_ap) '.txt'], sel_data_dl', 'delimiter', '\t');

end