#!/bin/bash

matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.', 19, 217, 400, 0, 0.05, 1); exit;"


matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../condor_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.004.bin60.', 24, 324, 475, 0, 0.05, 1); exit;"

matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../condor_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.004.bin60.sub.', 24, 60, 60, 0, 0.05, 1); exit;"

matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../condor_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.002.bin60.', 24, 647, 949, 0, 0.05, 1); exit;"

matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../condor_data/subtask_parse_huawei_3g/region_tm/', 'tm_3g_region_all.res0.002.bin60.sub.', 24, 120, 100, 0, 0.05, 1); exit;"


matlab -r "[mse, mae, cc, ratio] = feature_match_based_pred('../processed_data/subtask_process_4sq/TM/', 'TM_Airport_period5_', 12, 300, 300, 0, 0.05, 1); exit;"
