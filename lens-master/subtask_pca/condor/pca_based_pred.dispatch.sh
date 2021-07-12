#!/bin/bash

func="pca_based_pred"

num_jobs=100
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


# for filename in "TM_Airport_period5_" "tm.sort_ips.ap.gps.5.txt.3600." "tm.select_matrix_for_id-Assignment.txt.60." "tm.sort_ips.ap.country.txt.3600." "tm.sort_ips.ap.bgp.8.txt.3600." "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600." ; do
# for filename in "tm.sort_ips.ap.gps.1.sub_CN.txt.3600."; do
# for filename in "tm.sort_ips.ap.country.txt.3600."  "tm.sort_ips.ap.bgp.8.txt.3600." "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600."; do

# for filename in "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400." "tm_upload.sort_ips.ap.bgp.sub_CN.txt.3600.top400." "tm_download.sort_ips.ap.country.txt.3600.top400." "tm_upload.sort_ips.ap.country.txt.3600.top400." "tm_download.sort_ips.ap.gps.1.sub_CN.txt.3600.top400." "tm_upload.sort_ips.ap.gps.1.sub_CN.txt.3600.top400." "tm_download.sort_ips.ap.gps.5.txt.3600.top400." "tm_upload.sort_ips.ap.gps.5.txt.3600.top400."; do
# files=("tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.")

# files=("tm_3g_region_all.res0.004.bin60." "tm_3g_region_all.res0.004.bin60.sub." "tm_3g_region_all.res0.002.bin60.sub.")
# files=("tm_3g_region_all.res0.002.bin60.sub.")

# files=("tm_3g_region_all.res0.002.bin60.sub." "tm_3g_region_all.res0.004.bin60.sub." "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.")

files=("tm_totem.")


for filename in ${files[@]}; do

    # #############
    # if [[ ${filename} == "TM_Airport_period5_" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
    #     num_frames=12
    #     width=300
    #     height=300

    #     block_sizes=(30 100 200 400)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # #############
    # if [[ ${filename} == "tm.select_matrix_for_id-Assignment.txt.60." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/signaling_tm\/"
    #     num_frames=12
    #     width=28
    #     height=28

    #     block_sizes=(10 14 28)
    #     ranks=(1 2 3 4 5 10)
    # fi
    # #############
    # if [[ ${filename} == "tm.sort_ips.ap.country.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=400
    #     height=400

    #     block_sizes=(40 100 200)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.gps.5.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=738
    #     height=738

    #     block_sizes=(70 125 247)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.gps.1.sub_CN.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=410
    #     height=410

    #     block_sizes=(41 103 205)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.bgp.8.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=421
    #     height=421

    #     block_sizes=(43 106 211)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=403
    #     height=403

    #     block_sizes=(41 101 202)
    #     ranks=(1 2 3 5 10 20 30)
    # fi
    # #############
    if [[ ${filename} == "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=19
        width=217
        height=400

        block_sizes=(0)
        block_ws=(217)
        block_hs=(400)
        ranks=(1 3 10 20)
    fi
    #############
    if [[ ${filename} == "tm_3g_region_all.res0.004.bin60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=324
        height=475

        block_sizes=(0)
        block_ws=(324)
        block_hs=(475)
        ranks=(1 2 3 5 10 20 30 100)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.004.bin60.sub." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=60
        height=60

        block_sizes=(0)
        block_ws=(60)
        block_hs=(60)
        ranks=(1 3 5 10 20 24)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.002.bin60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=647
        height=949

        block_sizes=(0)
        block_ws=(647)
        block_hs=(949)
        ranks=(1 2 3 5 10 20 30 100)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.002.bin60.sub." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=120
        height=100

        block_sizes=(0)
        block_ws=(120)
        block_hs=(100)
        ranks=(1 3 5 10 20 24)
    fi
    #############
    if [[ ${filename} == "tm_totem." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_totem\/tm\/"
        num_frames=100
        width=23
        height=23

        block_sizes=(0)
        block_ws=(23)
        block_hs=(23)
        ranks=(1 3 5 10 30 50 100)
    fi
    


    seeds=(1 2 3 4 5)
    opt_swap_mats=("org")
    opt_dims=("2d")


    for seed in ${seeds[@]}; do
        for block_size in ${block_sizes[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for rank in ${ranks[@]}; do
                    for opt_dim in ${opt_dims[@]}; do
                
                        ## PureRandLoss: elem_frac = 1
                        ## xxElemRandLoss: xx = elem_frac
                        ## xxTimeRandLoss: xx = loss_rate
                        drop_ele_mode="elem"
                        drop_mode="ind"
                        elem_fracs=(0.1 0.3 0.5 0.7 1)
                        loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8)
                        burst_size=1
                        for elem_frac in ${elem_fracs[@]}; do
                            for loss_rate in ${loss_rates[@]}; do
                                name=${func}.${filename}.${num_frames}.${width}.${height}.${block_ws[$block_size]}.${block_hs[$block_size]}.r${rank}.${opt_swap_mat}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                echo ${name}
                                sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_hs[$block_size]}/g;s/BLOCK_WIDTH/${block_ws[$block_size]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g" ${func}.mother.sh > tmp.${name}.sh
                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                # condor_submit tmp.${name}.condor
                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                cnt=$((${cnt} + 1))
                            done
                        done

                        ## xxElemSyncLoss: xx = elem_frac
                        drop_ele_mode="elem"
                        drop_mode="syn"
                        elem_fracs=(0.1 0.3)
                        loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8)
                        burst_size=1
                        for elem_frac in ${elem_fracs[@]}; do
                            for loss_rate in ${loss_rates[@]}; do
                                name=${func}.${filename}.${num_frames}.${width}.${height}.${block_ws[$block_size]}.${block_hs[$block_size]}.r${rank}.${opt_swap_mat}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                echo ${name}
                                sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_hs[$block_size]}/g;s/BLOCK_WIDTH/${block_ws[$block_size]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g" ${func}.mother.sh > tmp.${name}.sh
                                sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                # condor_submit tmp.${name}.condor
                                echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                cnt=$((${cnt} + 1))
                            done
                        done

                        ## RowRandLoss:
                        ## ColRandLoss:
                        drop_ele_modes=("row" "col")
                        drop_mode="ind"
                        elem_fracs=(0.05 0.1 0.2 0.4 0.6 0.8)
                        loss_rates=(0.05 0.1 0.5)
                        burst_size=1
                        for drop_ele_mode in ${drop_ele_modes[@]}; do
                            for elem_frac in ${elem_fracs[@]}; do
                                for loss_rate in ${loss_rates[@]}; do
                                    name=${func}.${filename}.${num_frames}.${width}.${height}.${block_ws[$block_size]}.${block_hs[$block_size]}.r${rank}.${opt_swap_mat}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                    echo ${name}
                                    sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/BLOCK_HEIGHT/${block_hs[$block_size]}/g;s/BLOCK_WIDTH/${block_ws[$block_size]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/RANK/${rank}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g" ${func}.mother.sh > tmp.${name}.sh
                                    sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                    # condor_submit tmp.${name}.condor
                                    echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                    cnt=$((${cnt} + 1))
                                done
                            done
                        done

                    done
                done
            done
        done
    done
done

echo $cnt / $num_jobs

condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag

