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
%%    tm_top('../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.bgp.0.sub_CN.txt.3600', 8, 300)
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = tm_top(full_path, num_frames, num_sel)
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
    input_dir  = '';
    output_dir = '';


    %% --------------------
    %% Check input
    %% --------------------
    if nargin ~= 3, error(['wrong # inputs: ' int2str(nargin)]); end
    if isa(num_sel, 'char')
        fprintf('is deployed\n');
        num_sel = str2num(num_sel);
        num_frames = str2num(num_frames);
    end
    % num_sel = str2num(num_sel);
    % num_frames = str2num(num_frames);


    [file_name, input_dir] = basename(full_path);
    if DEBUG2
        fprintf('input dir: %s\n', input_dir);
        fprintf('files: %s\n', file_name);
    end


    %% --------------------
    %% Main starts
    %% --------------------
    
    %% --------------------
    %% Read TM
    %% --------------------
    if DEBUG2, fprintf('\nread tm\n'); end;

    for f = [0:(num_frames-1)]
        this_file = [full_path '.' int2str(f) '.txt'];
        if DEBUG2, fprintf('  file: %s\n', this_file); end;

        tm = load(this_file);

        if f == 0
            rows = sum(tm, 2);
            cols = sum(tm, 1);
        else
            rows = rows + sum(tm, 2);
            cols = cols + sum(tm, 1);
        end
    end

    %% --------------------
    %% Sort rows and cols
    %% --------------------
    if DEBUG2, fprintf('\nSort rows and cols\n'); end;

    [sorted_rows, ind_rows] = sort(rows, 'descend');
    [sorted_cols, ind_cols] = sort(cols, 'descend');

    selected_rows = ind_rows(1:min(num_sel, length(ind_rows)));
    selected_cols = ind_cols(1:min(num_sel, length(ind_cols)));

    selected_rows = sort(selected_rows);
    selected_cols = sort(selected_cols);


    %% --------------------
    %% write top rows / cols
    %% --------------------
    if DEBUG2, fprintf('\nwrite top rows / cols\n'); end;

    for f = [0:(num_frames-1)]
        this_file = [full_path '.' int2str(f) '.txt'];
        tm = load(this_file);
        new_tm = tm(selected_rows, selected_cols);


        output_file = [input_dir '/' file_name '.top' int2str(num_sel) '.' int2str(f) '.txt'];
        if DEBUG2, fprintf('  file: %s\n', output_file); end;

        dlmwrite(output_file, new_tm, 'delimiter', ',');
    end
end