#!/bin/bash

for grp_size in 4 8 16; do
    for rank in 5 10 15 20 25 30 35 40 50 60 70; do
        
        video_name="stefan_cif"
        num_frames=90
        width=352
        height=288
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr2.mother.sh > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr2.mother.condor > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


        video_name="bus_cif"
        num_frames=150
        width=352
        height=288
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr2.mother.sh > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr2.mother.condor > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


        video_name="foreman_cif"
        num_frames=300
        width=352
        height=288
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr2.mother.sh > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr2.mother.condor > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


        video_name="coastguard_cif"
        num_frames=300
        width=352
        height=288
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr2.mother.sh > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr2.mother.condor > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor


        video_name="highway_cif"
        num_frames=300
        width=352
        height=288
        sed "s/RANK/${rank}/g;s/GRP_SIZE/${grp_size}/g;s/VIDEO_NAME/${video_name}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;" compressive_sensing_psnr2.mother.sh > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.sh
        sed "s/XXX/${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}/g" compressive_sensing_psnr2.mother.condor > tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
        condor_submit tmp.compressive_sensing_psnr2.${video_name}.${grp_size}.${rank}.${num_frames}.${width}.${height}.condor
    done
done
