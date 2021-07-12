#!/bin/bash

for grp_size in 4; do
    for rank in 1 3 5 10 15 20 30 40 50 60 70 80 90 100 150 200 250; do
        dct_thresh=0
        num_frames=12

        video_name="TM_Airport_period5_.exp0."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/DCT_THRESH/${dct_thresh}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" PCA_psnr_by_frame.mother.sh > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}/g" PCA_psnr_by_frame.mother.condor > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor


        video_name="TM_Airport_period5_.exp1."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/DCT_THRESH/${dct_thresh}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" PCA_psnr_by_frame.mother.sh > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}/g" PCA_psnr_by_frame.mother.condor > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor


        video_name="TM_Airport_period5_.exp2."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/DCT_THRESH/${dct_thresh}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" PCA_psnr_by_frame.mother.sh > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}/g" PCA_psnr_by_frame.mother.condor > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor

        ############################################

        
        # video_name="TM_Airport_period5_"
        # width=300
        # height=300
        # sed "s/RANK/${rank}/g;s/DCT_THRESH/${dct_thresh}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" PCA_psnr_by_frame.mother.sh > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}/g" PCA_psnr_by_frame.mother.condor > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor


        # video_name="TM_Manhattan_period5_"
        # width=500
        # height=500
        # sed "s/RANK/${rank}/g;s/DCT_THRESH/${dct_thresh}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" PCA_psnr_by_frame.mother.sh > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}/g" PCA_psnr_by_frame.mother.condor > tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.PCA_psnr_by_frame.${video_name}.${grp_size}.${rank}.${dct_thresh}.${num_frames}.${width}.${height}.condor


    done
done




