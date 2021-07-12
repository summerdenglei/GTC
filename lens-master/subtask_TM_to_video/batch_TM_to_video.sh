output_dir="/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/"

# matlab -r "TM_to_video('../processed_data/subtask_process_4sq/TM/TM_Airport_period5_', 300, 300, 12); exit;"
# matlab -r "TM_to_video('../processed_data/subtask_process_4sq/TM/TM_Austin_period5_', 300, 300, 12); exit;"
# matlab -r "TM_to_video('../processed_data/subtask_process_4sq/TM/TM_Manhattan_period5_', 500, 500, 12); exit;"
# matlab -r "TM_to_video('../processed_data/subtask_process_4sq/TM/TM_San_Francisco_period5_', 300, 300, 12); exit;"


matlab -r "TM_to_video('../processed_data/subtask_inject_error/TM_err/TM_Airport_period5_.exp0.', 300, 300, 12); exit;"
matlab -r "TM_to_video('../processed_data/subtask_inject_error/TM_err/TM_Airport_period5_.exp1.', 300, 300, 12); exit;"
matlab -r "TM_to_video('../processed_data/subtask_inject_error/TM_err/TM_Airport_period5_.exp2.', 300, 300, 12); exit;"

# scp /u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/*yuv keywest.csres.utexas.edu:/home/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/