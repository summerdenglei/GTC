#!/bin/bash

matlab -r "out_file = ['/u/yichao/anomaly_compression/processed_data/subtask_channel_selection/features/MOBILITY_traceTRACE.antANT.ch1.txt']; if(exist(out_file)), exit; end; cspy_get_features('INPUT_DIR', 'MOBILITY_traceTRACE.antANT'); exit;"
