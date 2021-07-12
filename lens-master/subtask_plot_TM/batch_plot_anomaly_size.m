

%% ----------------------------
%% WiFi
%% ----------------------------
%% SJTU: AP, Internet: BGP
plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 19, 250, 400, 60);
%% AP
plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 114, 50, 1, 10);
plot_anomaly_size('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi2.ap_load.all.bin600.top100.txt', 287, 100, 1, 10);


%% ----------------------------
%% 3G
%% ----------------------------
%% lat, lng
plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.006.bin10.sub.', 144, 21, 26, 10)
%% BS type
plot_anomaly_size('../condor_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs0.all.bin10.txt', 144, 1074, 1, 10);
plot_anomaly_size('../condor_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs1.all.bin10.txt', 144, 458, 1, 10);
plot_anomaly_size('../condor_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1, 10);
plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin60.txt', 25, 472, 1, 60);
plot_anomaly_size('../condor_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs6.all.bin10.txt', 144, 240, 1, 10);
%% all
plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.all.all.bin10.txt', 144, 2469, 1, 10);
plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.load.top200.all.bin10.txt', 144, 200, 1, 10);
%% RNC
plot_anomaly_size('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.rnc.all.bin10.txt', 144, 13, 1, 10);



%% ----------------------------
%% Abilene
%% ----------------------------
plot_anomaly_size('../condor_data/abilene/', 'X', 1008, 121, 1, 10);


%% ----------------------------
%% GEANT
%% ----------------------------
plot_anomaly_size('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 1008, 23, 23, 15);



%% ----------------------------
%% 4SQ
%% ----------------------------
plot_anomaly_size('../processed_data/subtask_process_4sq/TM/', 'TM_Airport_period5_', 12, 500, 500, 5*24*60);


%% ----------------------------
%% GEANT
%% ----------------------------
plot_anomaly_size('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12, 5);

