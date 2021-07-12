
% file_path = '../processed_data/subtask_parse_huawei_3g/bs_tm/';
% filename = 'tm_3g.cell.load.top200.all.bin10.txt';
% nw = 200;
% nh = 1;
% nf = 100;
% r = 64;
% file_path = '../processed_data/subtask_parse_huawei_3g/bs_tm/';
% filename = 'tm_3g.cell.bs.bs3.all.bin10.txt';
% nw = 472;
% nh = 1;
% nf = 144;
% r = 64;
% file_path = '../processed_data/subtask_parse_huawei_3g/bs_tm/';
% filename = 'tm_3g.cell.rnc.all.bin10.txt';
% nw = 13;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '../processed_data/subtask_parse_abilene/tm/';
% filename = 'tm_abilene.od.';
% nw = 11;
% nh = 11;
% nf = 1008;
% r = 8;
% file_path = '../processed_data/subtask_parse_totem/tm/';
% filename = 'tm_totem.';
% nw = 23;
% nh = 23;
% nf = 672;
% r = 8;
% file_path = '../processed_data/subtask_parse_sjtu_wifi/tm/';
% filename = 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt';
% nw = 50;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '/v/filer4b/v27q002/ut-wireless/swati/processed_traces/MonitorExp1/';
% filename = '128.83.158.127_file.dat0_matrix.mat.txt';
% nw = 90;
% nh = 1;
% nf = 1000;
% r = 32;
% file_path = '../data/csi/mobile/';
% filename = 'Mob-Recv1run1.dat0_matrix.mat_dB.txt';
% nw = 90;
% nh = 1;
% nf = 1000;
% r = 32;
% file_path = '../processed_data/subtask_parse_sensor/tm/';
% filename = 'tm_sensor.temp.bin600.txt';
% nw = 54;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '../processed_data/subtask_parse_sensor/tm/';
% filename = 'tm_sensor.humidity.bin600.txt';
% nw = 54;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '../processed_data/subtask_parse_sensor/tm/';
% filename = 'tm_sensor.light.bin600.txt';
% nw = 54;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '../processed_data/subtask_parse_sensor/tm/';
% filename = 'tm_sensor.voltage.bin600.txt';
% nw = 54;
% nh = 1;
% nf = 100;
% r = 8;
% file_path = '../processed_data/subtask_parse_ron/tm/';
% filename = 'tm_ron1.latency.';
% nw = 12;
% nh = 12;
% nf = 494;
% r = 12;
% file_path = '../processed_data/subtask_parse_telos_rssi/tm/';
% filename = 'tm_telos_rssi.txt';
% nw = 16;
% nh = 1;
% nf = 1000;
% r = 8;
% file_path = '../processed_data/subtask_parse_multi_loc_rssi/tm/';
% filename = 'tm_multi_loc_rssi.txt';
% nw = 895;
% nh = 1;
% nf = 500;
% r = 16;
% file_path = '../processed_data/subtask_parse_ucsb_meshnet/tm/';
% filename = 'tm_ucsb_meshnet.connected.txt';
% nw = 425;
% nh = 1;
% nf = 1000;
% r = 32;
file_path = '../processed_data/subtask_parse_ucsb_meshnet/tm/';
filename = 'tm_ucsb_meshnet.';
nw = 38;
nh = 38;
nf = 1000;
r = 16;
% file_path = '../processed_data/subtask_parse_umich_rss/tm/';
% filename = 'tm_umich_rss.txt';
% nw = 182;
% nh = 1;
% nf = 1000;
% r = 32;
% file_path = '../processed_data/subtask_parse_csi_channel/csi/';
% filename = 'static_trace13.ant1.mag.txt';
% nw = 270;
% nh = 1;
% nf = 500;
% r = 32;


filename

period = 1;
num_anomaly = 0.05;
anomaly_size = 0;
loss_rate = 0.4;


best_mae = 99999;
best_alpha = 0;


lambda = 0;
for alpha = [0 0.001 0.01 0.1 1 10 100 1000 10000]
% for alpha = [0 0.00000001 0.0000001 0.000001 0.00001]
% for alpha = [1000]
    
    fprintf('======================\n>>> alpha=%f, lambda=%f\n', alpha, lambda);

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred(file_path, filename, nf, nw, nh, nf, r, period, 'org', 'srmf', '2d','elem', 'ind', 1, loss_rate, 1, num_anomaly, anomaly_size, 0, 0.3, 1, alpha, lambda, 0);

    if(best_mae < 0 | mae < best_mae)
        best_alpha = alpha;
        best_mae = mae;
    end

end



alpha = best_alpha;
best_lambda = 0;

for lambda = [0.00001 0.0001 0.001 0.01 0.1 1 10 100 1000]
% for lambda = [0.00001 0.0001 0.001 0.01 0.1 1]
% for lambda = [10]
    
    fprintf('======================\n>>> alpha=%f, lambda=%f\n', alpha, lambda);

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred(file_path, filename, nf, nw, nh, nf, r, period, 'org', 'srmf', '2d','elem', 'ind', 1, loss_rate, 1, num_anomaly, anomaly_size, 0, 0.3, 1, alpha, lambda, 0);

    if(mae < best_mae)
        best_lambda = lambda;
        best_mae = mae;
    end
    
end


filename
best_alpha
best_lambda
best_mae



for r = [1 2 4 8 16 32 64 128]
    fprintf('======================\n>>> r=%d\n', r);

    [mse, mae, cc, ratio, tp, tn, fp, fn, precision, recall, f1score, jaccard, best_thresh] = srmf_based_pred(file_path, filename, nf, nw, nh, nf, r, period, 'org', 'srmf', '2d','elem', 'ind', 1, loss_rate, 1, num_anomaly, anomaly_size, 0, 0.3, 1, best_alpha, best_lambda, 0);

    if(mae < best_mae)
        best_r = r;
        best_mae = mae;
    end
end

filename
best_alpha
best_lambda
best_mae
r