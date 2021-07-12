%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.22 @ UT Austin
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

function clean_unconnected_2d_mat()
    addpath('../utils');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '../processed_data/subtask_parse_ucsb_meshnet/tm/';
    output_dir = '../processed_data/subtask_parse_ucsb_meshnet/tm/';

    filename = 'tm_ucsb_meshnet.txt';
    outname  = 'tm_ucsb_meshnet.connected.txt';


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------
    data = load([input_dir filename]);
    fprintf('size of orig data = %dx%d\n', size(data));

    sum_data = sum(data, 1);
    connected = find(sum_data ~= 999 * size(data, 1));
    fprintf('  # of connected nodes: %d\n', length(connected));

    new_data = data(:, connected);
    fprintf('  size of connected data = %dx%d\n', size(new_data));

    dlmwrite([output_dir outname], new_data);
    


 end