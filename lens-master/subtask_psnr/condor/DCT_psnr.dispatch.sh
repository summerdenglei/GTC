#!/bin/bash

for grp_size in 4; do
    for num_chunks in 1 3 5 10 15 30 50 70 100 150 200 250; do
        num_frames=12

        video_name="TM_Airport_period5_.exp0."
        width=300
        height=300
        sed "s/NUM_CHUNKS/${num_chunks}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" DCT_psnr.mother.sh > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}/g" DCT_psnr.mother.condor > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor


        video_name="TM_Airport_period5_.exp1."
        width=300
        height=300
        sed "s/NUM_CHUNKS/${num_chunks}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" DCT_psnr.mother.sh > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}/g" DCT_psnr.mother.condor > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor


        video_name="TM_Airport_period5_.exp2."
        width=300
        height=300
        sed "s/NUM_CHUNKS/${num_chunks}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" DCT_psnr.mother.sh > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}/g" DCT_psnr.mother.condor > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor

        ################################################

        
        # video_name="TM_Airport_period5_"
        # width=300
        # height=300
        # sed "s/NUM_CHUNKS/${num_chunks}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" DCT_psnr.mother.sh > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}/g" DCT_psnr.mother.condor > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor


        # video_name="TM_Manhattan_period5_"
        # width=500
        # height=500
        # sed "s/NUM_CHUNKS/${num_chunks}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" DCT_psnr.mother.sh > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}/g" DCT_psnr.mother.condor > tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.DCT_psnr.${video_name}.${grp_size}.${num_chunks}.${num_frames}.${width}.${height}.condor


    done
done




