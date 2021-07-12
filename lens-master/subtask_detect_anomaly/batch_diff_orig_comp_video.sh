#!/bin/bash


for exp in 0 1 2; do
    method=MPEG
    for vb in 1 3 5 7 9 10 15 20 30 40 50 100 200 300 400 500 600 700; do
        echo "exp${exp}, video bit rate = ${vb}"
        matlab -r "diff_orig_comp_video('/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/TM_Airport_period5_.exp${exp}..yuv', '/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/comp_video/TM_Airport_period5_.exp${exp}..b${vb}.mpeg_dec.yuv', 12, 300, 300); exit;"
    done


    # method=3DDCT
    # for grp_size in 4; do
    #     for num_chunks in 1 3 5 10 15 30 50 70 100 150 200 250; do
        
    #         num_frames=12
    #         width=300
    #         height=300

    #         echo "method=${method}: exp=${exp}, GoP=${grp_size}, # chunks=${num_chunks}"
    #         echo "diff_orig_comp_video('/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/TM_Airport_period5_.exp${exp}..yuv', '/u/yichao/anomaly_compression/processed_data/subtask_psnr/comp_video/TM_Airport_period5_.exp${exp}..yuv.${method}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.yuv', ${num_frames}, ${width}, ${height}); exit;"
    #         matlab -r "diff_orig_comp_video('/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/TM_Airport_period5_.exp${exp}..yuv', '/u/yichao/anomaly_compression/processed_data/subtask_psnr/comp_video/TM_Airport_period5_.exp${exp}..yuv.${method}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.yuv', ${num_frames}, ${width}, ${height}); exit;"
    #     done
    # done


    # method=PCA
    # for grp_size in 4; do
    #     for rank in 1 3 5 10 15 20 30 40 50 60 70 80 90 100 150 200 250; do
        
    #         dct_thresh=0
    #         num_frames=12
    #         width=300
    #         height=300

    #         echo "method=${method}: exp=${exp}, GoP=${grp_size}, rank=${rank}, dct_thresh=${dct_thresh}"
    #         matlab -r "diff_orig_comp_video('/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/TM_Airport_period5_.exp${exp}..yuv', '/u/yichao/anomaly_compression/processed_data/subtask_psnr/comp_video/TM_Airport_period5_.exp${exp}..yuv.${method}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.yuv', ${num_frames}, ${width}, ${height}); exit;"
    #     done
    # done


    # method=comp_sen
    # for grp_size in 4; do
    #     for rank in 1 3 5 10 15 20 30 50 70 100 150; do
        
    #         num_frames=12
    #         width=300
    #         height=300

    #         echo "method=${method}: exp=${exp}, GoP=${grp_size}, rank=${rank}"
    #         matlab -r "diff_orig_comp_video('/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/video/TM_Airport_period5_.exp${exp}..yuv', '/u/yichao/anomaly_compression/processed_data/subtask_psnr/comp_video/TM_Airport_period5_.exp${exp}..yuv.${method}.${grp_size}.${rank}.${num_frames}.${width}.${height}.yuv', ${num_frames}, ${width}, ${height}); exit;"
    #     done
    # done
done