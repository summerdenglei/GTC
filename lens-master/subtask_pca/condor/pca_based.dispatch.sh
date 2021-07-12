#!/bin/bash

func="pca_based"

for expnum in 0 1 2; do
    input_dir='\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/'
    filename="TM_Airport_period5_.exp"
    num_frames=12
    width=300
    height=300
    # input_dir='\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/'
    # filename="tm.sort_ips.ap.country.txt.3600."
    # num_frames=8
    # width=346
    # height=346

    for opt_swap_mat in 0 1 2 3; do
        for opt_dect in 1 2; do
            for block_size in 30 100 300; do
                for rank in 1 2 3 5 10 20 30; do
                    for thresh in 5 10 15 20 30 50 70 100 150 200 250; do
                        echo ${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${thresh}.${opt_dect}.${opt_swap_mat}
                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}${expnum}./g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_size}/g;s/BLOCK_WIDTH/${block_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/THRESH/${thresh}/g;s/OPT_DECT/${opt_dect}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g" ${func}.mother.sh > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${thresh}.${opt_dect}.${opt_swap_mat}.sh
                        sed "s/XXX/${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${thresh}.${opt_dect}.${opt_swap_mat}/g" ${func}.mother.condor > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${thresh}.${opt_dect}.${opt_swap_mat}.condor
                        condor_submit tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${rank}.${thresh}.${opt_dect}.${opt_swap_mat}.condor
                    done
                done
            done
        done
    done
done




