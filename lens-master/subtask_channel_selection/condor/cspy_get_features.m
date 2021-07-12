%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2014.02.27 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%  cspy_get_features('../processed_data/subtask_parse_csi_channel/csi/', 'static_trace1.ant1')
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cspy_get_features(input_dir, trace_name)
    addpath('/u/yichao/anomaly_compression/utils');
    addpath('/u/yichao/anomaly_compression/utils/wireless');
    addpath('/u/yichao/anomaly_compression/utils/linux-80211n-csitool-supplementary');

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;


    %% --------------------
    %% Constant
    %% --------------------
    num_sc = 30;
    num_channels = 9;
    FRAME_LEN = 1000 * 8;

    %% --------------------
    %% Variable
    %% --------------------
    input_dir  = '/u/yichao/anomaly_compression/processed_data/subtask_parse_csi_channel/csi/';
    output_dir = '/u/yichao/anomaly_compression/processed_data/subtask_channel_selection/features/';


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------

    %% --------------------
    %% read CSI trace
    %% --------------------
    if(DEBUG2); fprintf('read CSI trace\n'); end;

    tmp_phase = load([input_dir trace_name '.phase.txt']);
    tmp_mag = load([input_dir trace_name '.mag.txt']);
    csi = tmp_mag .* exp(i*tmp_phase);
    sx = size(csi);
    if(DEBUG1); fprintf('  size: %d, %d\n', sx); end


    %% --------------------
    %% calculate features
    %% --------------------
    if(DEBUG2); fprintf('calculate features\n'); end;

    sci = zeros(sx(1), 1);
    features = zeros(sx);
    for pkti = 1:sx(1)

        best_sci = 1;
        best_tput = -1;
        for ch = 1:num_channels
            ch_std = (ch-1) * num_sc + 1;
            ch_end = ch * num_sc;

            cfr = csi(pkti, ch_std:ch_end);
            cir = ifft(cfr);

            %% we divide the discrete CIR vector by its amplitude and 
            %% we subtract the phase of the first tap from the phases of all taps. 
            norm_cir = cir ./ abs(cir);
            features(pkti, ch_std:ch_end) = phase(norm_cir) - phase(norm_cir(1));

            %% tput
            [tput, mcs_index] = calculate_tput(cfr, FRAME_LEN);
            if tput > best_tput
                best_tput = tput;
                best_sci = ch;
            end
        end

        sci(pkti) = best_sci;

        fprintf('.');
    end
    fprintf('\n');
    

    %% --------------------
    %% write features
    %% --------------------
    if(DEBUG2); fprintf('write features\n'); end;

    for ch = 1:num_channels
        ch_std = (ch-1) * num_sc + 1;
        ch_end = ch * num_sc;

        fh = fopen([output_dir trace_name '.ch' num2str(ch) '.txt'], 'w'); 

        for pkti = 1:sx(1)

            fprintf(fh, '%d ', sci(pkti));
            for sc = 1:num_sc
                fprintf(fh, '%d:%f ', sc, features(pkti, (ch-1) * num_sc + sc));
            end
            fprintf(fh, '\n');
        end
        
        fclose(fh);

        fprintf('.');
    end
    fprintf('\n');


 end