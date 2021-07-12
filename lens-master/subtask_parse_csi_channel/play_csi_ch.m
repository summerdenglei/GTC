%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.22 @ UT Austin
%%
%% - Input:
%%    num_pkts: # packets per round per channel
%%
%% - Output:
%%
%%
%% e.g.
%%    play_csi_ch('static_trace1', 100, 5)
%%    play_csi_ch('static_trace2', 1000, 5)
%%    play_csi_ch('static_trace4', 1000, 10)
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function play_csi_ch(trace_name, num_rounds, num_pkts)
    addpath('../utils');
    addpath('../utils/wireless');
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
    channels = [36, 40, 44, 48, 149, 153, 157, 161, 165];
    num_channels = length(channels);
    num_sc = 30;        %% # subcarriers per channel

    frame_len = 1000 * 8;


    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '../processed_data/subtask_parse_csi_channel/csi/';
    output_dir = '../processed_data/subtask_parse_csi_channel/';
    
    % csi_ant{1} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 1
    % csi_ant{2} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 2
    % csi_ant{3} = zeros(num_rounds * num_pkts, num_sc * num_channels);   %% CSI for antenna 3


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

    tmp_phase = load([input_dir trace_name '.ant1.phase.txt']);
    tmp_mag = load([input_dir trace_name '.ant1.mag.txt']);
    csi_ant{1} = tmp_mag .* exp(i*tmp_phase);
    tmp_phase = load([input_dir trace_name '.ant2.phase.txt']);
    tmp_mag = load([input_dir trace_name '.ant2.mag.txt']);
    csi_ant{2} = tmp_mag .* exp(i*tmp_phase);
    tmp_phase = load([input_dir trace_name '.ant3.phase.txt']);
    tmp_mag = load([input_dir trace_name '.ant3.mag.txt']);
    csi_ant{3} = tmp_mag .* exp(i*tmp_phase);
    
    
    

    %% --------------------
    %% calculate throughput for each packet
    %% --------------------
    fprintf('calculate throughput for each packet\n');

    for ant = [1:3]
        sx = size(csi_ant{ant});
        fprintf('  ant %d: size = %d, %d\n', ant, sx);


        tputs = zeros(sx(1), num_channels);
        eff_snr_qpsk = zeros(sx(1), num_channels);
        
        for pkti = [1:sx(1)]

            for ci = [1:num_channels]
                col_std = (ci - 1) * num_sc + 1;
                col_end = ci * num_sc;

                csi = csi_ant{ant}(pkti, col_std:col_end);
                [tput, mcs_index] = calculate_tput(csi, frame_len);

                tputs(pkti, ci) = tput;

                
                %% QPSK effective snr
                eff_snr = db(get_eff_SNRs(reshape(csi, 1, 1, [])), 'pow');
                eff_snr_qpsk(pkti, ci) = get_effsnr_modu(eff_snr, 'qpsk');
            end
        end

        fprintf('    write to files:\n');
        dlmwrite([output_dir 'tput/' trace_name '.ant' num2str(ant) '.txt'], tputs);
        dlmwrite([output_dir 'effsnr/' trace_name '.ant' num2str(ant) '.txt'], eff_snr_qpsk);


        %% --------------------
        %% optimal scheme
        %% --------------------
        fprintf('    optimal scheme:');
        best_tputs = max(tputs, [], 2);
        optimal_ett = sum(sum(frame_len ./ best_tputs));
        optimal_tput = frame_len * sx(1) / optimal_ett;
        fprintf(' %fMbps\n', optimal_tput);


        %% --------------------
        %% random scheme
        %% --------------------
        fprintf('    random scheme:');
        rand_tputs = zeros(sx(1), 1);
        for pkti = 1:sx(1)
            sel = round(rand(1)*(num_channels-1))+1;
            rand_tputs(pkti, 1) = tputs(pkti, sel);
        end
        rand_ett = sum(sum(frame_len ./ rand_tputs));
        rand_tput = frame_len * sx(1) / rand_ett;
        fprintf(' %fMbps\n', rand_tput);


    end

end


