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

function batch_srmf_based_pred()
    addpath('../utils');

    % loss_rates   = [0.1 0.2 0.4 0.6 0.8 0.9 0.95];
    loss_rates   = [0.1];
    % sigma_mags   = [0 0.2 0.4 0.6 0.8 1];
    % sigma_noises = [0 0   0   0   0   0];
    sigma_mags   = [0];
    sigma_noises = [0];
    schemes      = {'srmf_knn', 'lens3', 'lens3_knn'};
    
    output1 = zeros(length(loss_rates) * length(sigma_mags), 8);
    output2 = zeros(length(loss_rates) * length(sigma_mags), 9*length(schemes));


    %% Abilene
    tm_dir  = '../condor_data/subtask_parse_abilene/tm/';
    tm_name = 'tm_abilene.od.';
    nf      = 1008;
    nw      = 11;
    nh      = 11;
    gop     = nf;
    r       = 8;
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
    num_anomaly = 0.05;

    for sigma = 1:length(sigma_mags)
        sigma_mag   = sigma_mags(sigma);
        sigma_noise = sigma_noises(sigma);
        fprintf('sigma=%d: anomaly=%f, noise=%f\n', sigma, sigma_mag, sigma_noise);

        for lri = 1:length(loss_rates)
            loss_rate = loss_rates(lri);

            ind = (sigma-1) * length(loss_rates) + lri;
            fprintf('  lri=%d, loss=%f\n', lri, loss_rate);
            fprintf('  ind=%d\n', ind);


            % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'srmf_knn', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, thresh, 1);
            % output1(ind, [1,4]) = [mse, mae];
            % output2(ind, [1,4,7,10,13,16,19,22,25]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

            [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, thresh, 1);
            output1(ind, [2,5,7,8]) = [mse, mae, normalized_y, y_val];
            output2(ind, [2,5,8,11,14,17,20,23,26]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

            % [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, normalized_y, y_val, best_thresh] = srmf_based_pred(tm_dir, tm_name, nf, nw, nh, gop, r, period, order, 'lens3_knn', '2d', 'elem', 'ind', 1, loss_rate, 1, num_anomaly, sigma_mag, sigma_noise, thresh, 1); 
            % output1(ind, [3,6]) = [mse, mae];
            % output2(ind, [3,6,9,12,15,18,21,24,27]) = [precision, recall, f1score, jaccard, tp, tn, fp, fn, best_thresh];

        end
    end

    % dlmwrite(['tmp_output/' tm_name '.pred.txt'], output1, 'delimiter', '\t');
    % dlmwrite(['tmp_output/' tm_name '.dect.txt'], output2, 'delimiter', '\t');
    output1
    output2

end

