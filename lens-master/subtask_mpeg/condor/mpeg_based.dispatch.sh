#!/bin/bash

func="mpeg_based"

for expnum in 0 1 2; do
    input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
    filename="TM_Airport_period5_.exp"
    num_frames=12
    width=300
    height=300

    for opt_swap_mat in 0 1 2 3; do
        for opt_dect in 3; do
            for opt_delta in 1; do
                # for opt_f_b in `seq 18 26`; do
                for opt_f_b in 16 18 19 21; do
                    opt_frame="-1"
                    opt_block="-1"
                    if [[ $opt_f_b -eq 1 ]]; then
                        ## previous 1 frame, same blocks
                        opt_frame="-1"
                        opt_block="0"
                    fi
                    if [[ $opt_f_b -eq 2 ]]; then
                        ## previous 1 frame, nearby 5 blocks
                        opt_frame="-1"
                        opt_block="4"
                    fi
                    if [[ $opt_f_b -eq 3 ]]; then
                        ## previous 1 frame, nearby 9 blocks
                        opt_frame="-1"
                        opt_block="8"
                    fi
                    if [[ $opt_f_b -eq 4 ]]; then
                        ## previous 1 frame, all blocks
                        opt_frame="-1"
                        opt_block="-1"
                    fi
                    if [[ $opt_f_b -eq 5 ]]; then
                        ## current frame, nearby 4 blocks
                        opt_frame="0"
                        opt_block="4"
                    fi
                    if [[ $opt_f_b -eq 6 ]]; then
                        ## current frame, nearby 8 blocks
                        opt_frame="0"
                        opt_block="8"
                    fi
                    if [[ $opt_f_b -eq 7 ]]; then
                        ## current frame, all blocks
                        opt_frame="0"
                        opt_block="-1"
                    fi
                    if [[ $opt_f_b -eq 8 ]]; then
                        ## next frame, same block
                        opt_frame="1"
                        opt_block="0"
                    fi
                    if [[ $opt_f_b -eq 9 ]]; then
                        ## next frame, nearby 4 blocks
                        opt_frame="1"
                        opt_block="4"
                    fi
                    if [[ $opt_f_b -eq 10 ]]; then
                        ## next frame, nearby 8 block
                        opt_frame="1"
                        opt_block="8"
                    fi
                    if [[ $opt_f_b -eq 11 ]]; then
                        ## next frame, all blocks
                        opt_frame="1"
                        opt_block="-1"
                    fi
                    if [[ $opt_f_b -eq 12 ]]; then
                        ## previous and current frame
                        opt_frame="-1, 0"
                        opt_block=" 8, 8"
                    fi
                    if [[ $opt_f_b -eq 13 ]]; then
                        ## previous and current frame
                        opt_frame="-1, 0"
                        opt_block="-1, -1"
                    fi
                    if [[ $opt_f_b -eq 14 ]]; then
                        opt_frame="-2, -1, 0"
                        opt_block=" 0,  8, 8"
                    fi
                    if [[ $opt_f_b -eq 15 ]]; then
                        opt_frame="-2, -1,  0"
                        opt_block=" 4, -1, -1"
                    fi
                    if [[ $opt_f_b -eq 16 ]]; then
                        opt_frame="-2, -1, 0, 1, 2"
                        opt_block=" 0,  0, 0, 0, 0"
                    fi
                    if [[ $opt_f_b -eq 17 ]]; then
                        opt_frame="-2, -1, 0, 1, 2"
                        opt_block=" 0,  4, 8, 4, 0"
                    fi
                    if [[ $opt_f_b -eq 18 ]]; then
                        opt_frame="-2, -1, 0, 1, 2"
                        opt_block=" 0,  8, 8, 8, 0"
                    fi
                    if [[ $opt_f_b -eq 19 ]]; then
                        opt_frame="-2, -1, 0, 1, 2"
                        opt_block=" 4,  4, 4, 4, 4"
                    fi
                    if [[ $opt_f_b -eq 20 ]]; then
                        opt_frame="-2, -1, 0, 1, 2"
                        opt_block=" 8,  8, 8, 8, 8"
                    fi
                    if [[ $opt_f_b -eq 21 ]]; then
                        opt_frame="-2, -1,  0,  1,  2"
                        opt_block="-1, -1, -1, -1, -1"
                    fi
                    if [[ $opt_f_b -eq 22 ]]; then
                        opt_frame="-3, -2, -1, 0, 1, 2, 3"
                        opt_block=" 0,  0,  0, 0, 0, 0, 0"
                    fi
                    if [[ $opt_f_b -eq 23 ]]; then
                        opt_frame="-3, -2, -1, 0, 1, 2, 3"
                        opt_block=" 0,  4,  8, 8, 8, 4, 0"
                    fi
                    if [[ $opt_f_b -eq 24 ]]; then
                        opt_frame="-3, -2, -1, 0, 1, 2, 3"
                        opt_block=" 4,  4,  4, 4, 4, 4, 4"
                    fi
                    if [[ $opt_f_b -eq 25 ]]; then
                        opt_frame="-3, -2, -1, 0, 1, 2, 3"
                        opt_block=" 8,  8,  8, 8, 8, 8, 8"
                    fi
                    if [[ $opt_f_b -eq 26 ]]; then
                        opt_frame="-3, -2, -1,  0,  1,  2,  3"
                        opt_block="-1, -1, -1, -1, -1, -1, -1"
                    fi



                    for block_size in 30; do
                        for thresh in 5 10 15 20 30 50 70 100 150 200 250; do
                            echo ${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.${opt_f_b}.${opt_swap_mat}
                            sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}${expnum}./g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_size}/g;s/BLOCK_WIDTH/${block_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/THRESH/${thresh}/g;s/OPT_DECT/${opt_dect}/g;s/OPT_DELTA/${opt_delta}/g;s/OPT_FRAMES/${opt_frame}/g;s/OPT_BLOCKS/${opt_block}/g;s/OPT_FRAME_BLOCK/${opt_f_b}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g" ${func}.mother.sh > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.${opt_f_b}.${opt_swap_mat}.sh
                            sed "s/XXX/${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.${opt_f_b}.${opt_swap_mat}/g" ${func}.mother.condor > tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.${opt_f_b}.${opt_swap_mat}.condor
                            condor_submit tmp.${func}.${filename}${expnum}.${num_frames}.${width}.${height}.${block_size}.${block_size}.${thresh}.${opt_dect}.${opt_delta}.${opt_f_b}.${opt_swap_mat}.condor
                        done
                    done
                done
            done
        done
    done
done




