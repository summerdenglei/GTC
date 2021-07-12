#!/bin/bash

for grp_size in 4; do
    for rank in 1 3 5 10 15 20 30 50 70 100 150; do
        num_frames=12

        
        video_name="TM_Airport_period5_.exp0."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr.mother.sh > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr.mother.condor > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor

        video_name="TM_Airport_period5_.exp1."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr.mother.sh > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr.mother.condor > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor

        video_name="TM_Airport_period5_.exp2."
        width=300
        height=300
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr.mother.sh > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr.mother.condor > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor

        ################################################################

        # video_name="TM_Airport_period5_"
        # width=300
        # height=300
        # sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr.mother.sh > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr.mother.condor > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


        # video_name="TM_Manhattan_period5_"
        # width=500
        # height=500
        # sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr.mother.sh > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        # sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr.mother.condor > tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        # condor_submit tmp.compressive_sensing_psnr.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


    done
done




