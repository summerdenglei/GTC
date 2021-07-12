#!/bin/bash

func="srmf_based"

for expnum in 0 1 2; do
    input_dir='\/u\/yichao\/anomaly_compression\/condor_data\/subtask_inject_error\/TM_err\/'
    filename="TM_Airport_period5_.exp"
    num_frames=12
    width=300
    height=300

    for opt_swap_mat in 0 1 2 3; do
        for group_size in 4; do
            for rank in 1 2 3 5 7 10 20 30 50; do
                for opt_type in 0 1; do
                    for thresh in 5 10 15 20 30 50 70 100 150 200 250; do
                        echo ${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}
                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}${expnum}./g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/THRESH/${thresh}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;" ${func}.mother.sh > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.sh
                        sed "s/XXX/${filename}${expnum}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}/g" ${func}.mother.condor > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.condor
                        condor_submit tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${group_size}.${rank}.${thresh}.${opt_swap_mat}.${opt_type}.condor
                    done
                done
            done
        done
    done
done




