%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.12.18 @ UT Austin
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

function batch_srmf_based_pred(sel_gamma)
    addpath('../utils');

    %% Abilene
    % tm_dir  = '../condor_data/subtask_parse_abilene/tm/';
    % tm_name = 'tm_abilene.od.';
    % nf      = 1008;
    % nw      = 11;
    % nh      = 11;
    % gop     = nf;
    % r       = 8;
    %% GEANT
    % tm_dir  = '../processed_data/subtask_parse_totem/tm/';
    % tm_name = 'tm_totem.';
    % nf      = 672;
    % nw      = 23;
    % nh      = 23;
    % gop     = nf;
    % r       = 8;
    %% 3G
    % tm_dir  = '../condor_data/subtask_parse_huawei_3g/bs_tm/';
    % tm_name = 'tm_3g.cell.bs.bs3.all.bin10.txt';
    % nf      = 144;
    % nw      = 472;
    % nh      = 26;
    % gop     = nf;
    % r       = 64;
    %% WiFi
    % tm_dir  = '../processed_data/subtask_parse_sjtu_wifi/tm/';
    % tm_name = 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt';
    % nf      = 100;
    % nw      = 50;
    % nh      = 1;
    % gop     = 100;
    % r       = 8;
    %% RON
    % tm_dir  = '../condor_data/subtask_parse_ron/tm/';
    % tm_name = 'tm_ron1.latency.';
    % nf      = 494;
    % nw      = 12;
    % nh      = 12;
    % gop     = nf;
    % r       = 16;
    %% CSI
    % tm_dir  = '../data/csi/mobile/';
    % tm_name = 'Mob-Recv1run1.dat0_matrix.mat_dB.txt';
    % nf      = 1000;
    % nw      = 90;
    % nh      = 1;
    % gop     = 1000;
    % r       = 16;



    thresh = -1;
    period = 1;
    order  = 'org';

    loss_rate   = 0.5;
    num_anomaly = 0.04;
    sigma_mag   = 1;
    sigma_noise = 0;
    

    %% ====================================================================
    %% Channel CSI
    fprintf('\n=================\nChannel CSI:\n');

    tm_dir  = '../condor_data/subtask_parse_csi_channel/csi/';
    tm_name = 'static_trace13.ant1.mag.txt';
    nf      = 500;
    nw      = 270;
    nh      = 1;
    gop     = 500;
    r       = 16;

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('  gamma = %f: mas = %f\n', gamma, mae);


    

    %% ====================================================================
    %% 3G
    fprintf('\n=================\n3G:\n');
    
    tm_dir  = '../condor_data/subtask_parse_huawei_3g/bs_tm/';
    tm_name = 'tm_3g.cell.bs.bs3.all.bin10.txt';
    nf      = 144;
    nw      = 472;
    nh      = 1;
    gop     = nf;
    r       = 16;
    
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('gamma = %f: mae = %f\n', gamma, mae);




    %% ====================================================================
    %% GEANT
    fprintf('\n=================\nGEANT:\n');
    
    tm_dir  = '../processed_data/subtask_parse_totem/tm/';
    tm_name = 'tm_totem.';
    nf      = 672;
    nw      = 23;
    nh      = 23;
    gop     = nf;
    r       = 8;
    
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('gamma = %f: mae = %f\n', gamma, mae);


    %% ====================================================================
    %% UMich RSS
    fprintf('\n=================\nUMich RSS:\n');
    
    tm_dir  = '../processed_data/subtask_parse_umich_rss/tm/';
    tm_name = 'tm_umich_rss.txt';
    nf      = 100;
    nw      = 182;
    nh      = 1;
    gop     = nf;
    r       = 32;
    
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('gamma = %f: mae = %f\n', gamma, mae);


    %% ====================================================================
    %% UCSB Meshnet
    fprintf('\n=================\nUCSB Meshnet:\n');
    
    tm_dir  = '../processed_data/subtask_parse_ucsb_meshnet/tm/';
    tm_name = 'tm_ucsb_meshnet.connected.txt';
    nf      = 1000;
    nw      = 425;
    nh      = 1;
    gop     = nf;
    r       = 16;
    
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('gamma = %f: mae = %f\n', gamma, mae);


    %% ====================================================================
    %% 1-channel CSI
    fprintf('\n=================\n1-channel CSI:\n');
    
    tm_dir  = '/u/yichao/anomaly_compression/condor_data/csi/mobile/';
    tm_name = 'Mob-Recv1run1.dat0_matrix.mat_dB.txt';
    nf      = 1000;
    nw      = 90;
    nh      = 1;
    gop     = nf;
    r       = 16;
    
    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh, gamma] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, sel_gamma, thresh, 1);
    fprintf('gamma = %f: mae = %f\n', gamma, mae);

    
    
end

