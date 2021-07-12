%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.22 @ UT Austin
%%
%% - Input:
%%    num_pkts: # packets per round per channel
%%
%%
%% - Output:
%%
%%
%% e.g.
%%    parse_csi_ch('static_trace1', 100, 5)
%%    parse_csi_ch('static_trace2', 1000, 5)
%%    parse_csi_ch('static_trace4', 1000, 10)
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function parse_csi_ch(trace_name, num_rounds, num_pkts)
    addpath('../utils');
    addpath('../utils/linux-80211n-csitool-supplementary');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------
    % num_pkts = 5;       %% # packets per round per channel
    channels = [36, 40, 44, 48, 149, 153, 157, 161, 165];
    num_channels = length(channels);
    num_sc = 30;        %% # subcarriers per channel


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = ['../data/csi_channel/' trace_name '/'];
    output_dir = '../processed_data/subtask_parse_csi_channel/';

    
    csi_ant{1} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 1
    csi_ant{2} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 2
    csi_ant{3} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 3


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% load file
    %% --------------------
    fprintf('load file\n');
            
    for rd = [0:num_rounds-1]
        for ci = [1:num_channels]
            channel = channels(ci);
            col_std = (ci-1) * num_sc + 1;
            col_end = ci * num_sc;
            if(DEBUG0); fprintf('  rd %d, ch %d (%d-%d)\n', rd, channel, col_std, col_end); end


            filename = ['csi.round' int2str(rd) '.' int2str(channel) '.dat'];
            csi_trace = read_bf_file([input_dir filename]);
            if length(csi_trace) ~= num_pkts; error(['num_pkts = ' num2str(num_pkts) ', but we have ' num2str(length(csi_trace)) 'here']); end
            
            for i = [1:num_pkts]
                this_row = rd * num_pkts + i;
                
                csi_entry = csi_trace{1};
                csi = get_scaled_csi(csi_entry);
                mapping = csi_entry.perm;

                csi_ant{mapping(1)}(this_row, col_std:col_end) = csi(1, 1, :);
                csi_ant{mapping(2)}(this_row, col_std:col_end) = csi(1, 2, :);
                csi_ant{mapping(3)}(this_row, col_std:col_end) = csi(1, 3, :);

                % eff_snr = db(get_eff_SNRs(csi(1,1,:)), 'pow');
                % fprintf('%f, ', eff_snr(1,:));
                % fprintf('\n');

                % eff_snr = db(get_eff_SNRs(csi(1,2,:)), 'pow');
                % fprintf('%f, ', eff_snr(1,:));
                % fprintf('\n');

                % eff_snr = db(get_eff_SNRs(csi(1,3,:)), 'pow');
                % fprintf('%f, ', eff_snr(1,:));
                % fprintf('\n');

            end

        end
    end


    %% --------------------
    %% output file
    %% --------------------
    fprintf('output csi\n');

    % dlmwrite([output_dir 'csi/' trace_name '.ant1.txt'], csi_ant{1});
    % dlmwrite([output_dir 'csi/' trace_name '.ant2.txt'], csi_ant{2});
    % dlmwrite([output_dir 'csi/' trace_name '.ant3.txt'], csi_ant{3});
    dlmwrite([output_dir 'csi/' trace_name '.ant1.phase.txt'], angle(csi_ant{1}));
    dlmwrite([output_dir 'csi/' trace_name '.ant1.mag.txt'], abs(csi_ant{1}));
    dlmwrite([output_dir 'csi/' trace_name '.ant2.phase.txt'], angle(csi_ant{2}));
    dlmwrite([output_dir 'csi/' trace_name '.ant2.mag.txt'], abs(csi_ant{2}));
    dlmwrite([output_dir 'csi/' trace_name '.ant3.phase.txt'], angle(csi_ant{3}));
    dlmwrite([output_dir 'csi/' trace_name '.ant3.mag.txt'], abs(csi_ant{3}));
    

end


