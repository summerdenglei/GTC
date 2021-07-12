#!/bin/bash

matlab -r "out_file = ['/u/yichao/anomaly_compression/processed_data/subtask_channel_selection/results/MOBILITY_traceTRACE.antANT.rRANK.SAMPLE_MODE.chNUM_KNOWN_CH.PRED_METHOD.accuracy.txt']; if(exist(out_file)), exit; end; lens_channel_sel('MOBILITY_traceTRACE.antANT', RANK, 'SAMPLE_MODE', NUM_KNOWN_CH, 'PRED_METHOD', 'SCHEMES'); exit;"
