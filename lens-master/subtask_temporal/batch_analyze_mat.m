%% GEANT
scheme = 'GEANT';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 672, 23, 23);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% Abilene
scheme = 'Abilene';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% 3G
scheme = '3G';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% WiFi
scheme = 'WiFi';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 110, 50, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% CSI
scheme = 'CSI';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../condor_data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% RON
scheme = 'RON';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% Cister RSSI
scheme = 'Cister RSSI';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 10000, 16, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% CU RSSI
scheme = 'CU RSSI';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% Channel CSI
scheme = 'Channel CSI';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_csi_channel/csi/', 'static_trace13.ant1.mag.txt', 1000, 270, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% UCSB Meshnet
scheme = 'UCSB Meshnet';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_ucsb_meshnet/tm/', 'tm_ucsb_meshnet.connected.txt', 1527, 425, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);

%% UMich RSS
scheme = 'UMich RSS';
[mean_err, max_err, num_std, num_3std, num_5std] = analyze_mat('../processed_data/subtask_parse_umich_rss/tm/', 'tm_umich_rss.txt', 1000, 182, 1);
fprintf('%s: mean=%f, max=%f, #std=%f, #3std=%f, #5std=%f\n', scheme, mean_err, max_err, num_std, num_3std, num_5std);
