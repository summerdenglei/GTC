#!/bin/bash

func="dct_based_pred"

num_jobs=75
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


# for filename in "TM_Airport_period5_" "tm.sort_ips.ap.gps.5.txt.3600." "tm.select_matrix_for_id-Assignment.txt.60." "tm.sort_ips.ap.country.txt.3600."  "tm.sort_ips.ap.bgp.8.txt.3600." "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600."; do
# for filename in "tm.sort_ips.ap.gps.1.sub_CN.txt.3600."; do
# for filename in "tm.sort_ips.ap.country.txt.3600."  "tm.sort_ips.ap.bgp.8.txt.3600." "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600."; do

# for filename in "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400." "tm_upload.sort_ips.ap.bgp.sub_CN.txt.3600.top400." "tm_download.sort_ips.ap.country.txt.3600.top400." "tm_upload.sort_ips.ap.country.txt.3600.top400." "tm_download.sort_ips.ap.gps.1.sub_CN.txt.3600.top400." "tm_upload.sort_ips.ap.gps.1.sub_CN.txt.3600.top400." "tm_download.sort_ips.ap.gps.5.txt.3600.top400." "tm_upload.sort_ips.ap.gps.5.txt.3600.top400."; do
# files=("tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.")

# files=("tm_3g_region_all.res0.004.bin60." "tm_3g_region_all.res0.002.bin60.sub.")
# files=("tm_3g_region_all.res0.004.bin60.sub.")

# files=("tm_3g_region_all.res0.002.bin60.sub." "tm_3g_region_all.res0.004.bin60.sub." "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400.")

files=("tm_totem.")


for filename in ${files[@]}; do

    # #############
    # if [[ ${filename} == "TM_Airport_period5_" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_process_4sq\/TM\/"
    #     num_frames=12
    #     width=300
    #     height=300

    #     chunk_sizes=(30 50 100)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # #############
    # if [[ ${filename} == "tm.select_matrix_for_id-Assignment.txt.60." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/signaling_tm\/"
    #     num_frames=12
    #     width=28
    #     height=28

    #     chunk_sizes=(10 14)
    #     sel_chunkss=(1 2 3 5 10)
    # fi
    # #############
    # if [[ ${filename} == "tm.sort_ips.ap.country.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=400
    #     height=400

    #     chunk_sizes=(40 100 200)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.gps.5.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=738
    #     height=738

    #     chunk_sizes=(70 125 247)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.gps.1.sub_CN.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=410
    #     height=410

    #     chunk_sizes=(41 103 205)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.bgp.8.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=421
    #     height=421

    #     chunk_sizes=(43 106 211)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # if [[ ${filename} == "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
    #     num_frames=7
    #     width=403
    #     height=403

    #     chunk_sizes=(41 101 202)
    #     sel_chunkss=(1 5 10 20 30)
    # fi
    # #############
    if [[ ${filename} == "tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=19
        width=217
        height=400

        group_sizes=(4 19)
        chunk_sizes=(0)
        chunk_ws=(22 40)
        chunk_hs=(40 40)
        
    fi
    #############
    if [[ ${filename} == "tm_3g_region_all.res0.004.bin60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=324
        height=475

        group_sizes=(4 24)
        chunk_sizes=(0)
        chunk_ws=(33 66)
        chunk_hs=(48 96)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.004.bin60.sub." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=60
        height=60

        group_sizes=(4 24)
        chunk_sizes=(0)
        chunk_ws=(6 10)
        chunk_hs=(6 10)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.002.bin60." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=647
        height=949

        group_sizes=(4 24)
        chunk_sizes=(0)
        chunk_ws=(65 130)
        chunk_hs=(95 190)
    fi
    if [[ ${filename} == "tm_3g_region_all.res0.002.bin60.sub." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
        num_frames=24
        width=120
        height=100

        group_sizes=(4 24)
        chunk_sizes=(0)
        chunk_ws=(12 24)
        chunk_hs=(10 20)
    fi
    #############
    if [[ ${filename} == "tm_totem." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_totem\/tm\/"
        num_frames=100
        width=23
        height=23

        group_sizes=(4 100)
        chunk_sizes=(0)
        chunk_ws=(4)
        chunk_hs=(4)
    fi



    seeds=(1 2 3 4 5)
    opt_swap_mats=("org")
    
    opt_types=("single" "chunk")
    sel_chunkss=(1 50 200)
    quantizations=(1 50 100)


    for seed in ${seeds[@]}; do
        for group_size in ${group_sizes[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for opt_type in ${opt_types[@]}; do

                    if [[ ${opt_type} == "single" ]]; then
                        chunk_size=0
                        sel_chunks=0

                        for quantization in ${quantizations[@]}; do

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
                                    name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_size}.ch${chunk_size}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                    echo ${name}

                                    sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
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
                                    name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_size}.ch${chunk_size}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                    echo ${name}

                                    sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
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
                                        name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_size}.ch${chunk_size}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                        echo ${name}

                                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_size}/g;s/CHUNK_HEIGHT/${chunk_size}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                        sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                        # condor_submit tmp.${name}.condor
                                        echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                        cnt=$((${cnt} + 1))
                                    done
                                done
                            done

                            
                        done
                    
                    elif [[ ${opt_type} == "chunk" ]]; then
                        quantization=0

                        for chunk_size in ${chunk_sizes[@]}; do
                            for sel_chunks in ${sel_chunkss[@]}; do
                                
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
                                        name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_ws[${chunk_size}]}.ch${chunk_hs[${chunk_size}]}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                        echo ${name}

                                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_ws[${chunk_size}]}/g;s/CHUNK_HEIGHT/${chunk_hs[${chunk_size}]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
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
                                        name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_ws[${chunk_size}]}.ch${chunk_hs[${chunk_size}]}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                        echo ${name}

                                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_ws[${chunk_size}]}/g;s/CHUNK_HEIGHT/${chunk_hs[${chunk_size}]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
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
                                            name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.${opt_swap_mat}.${opt_type}.cw${chunk_ws[${chunk_size}]}.ch${chunk_hs[${chunk_size}]}.nc${sel_chunks}.quan${quantization}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.seed${seed}
                                            echo ${name}

                                            sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/CHUNK_WIDTH/${chunk_ws[${chunk_size}]}/g;s/CHUNK_HEIGHT/${chunk_hs[${chunk_size}]}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/SEL_CHUNKS/${sel_chunks}/g;s/QUANTIZATION/${quantization}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                            sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                            # condor_submit tmp.${name}.condor
                                            echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                            cnt=$((${cnt} + 1))
                                        done
                                    done
                                done

                            done
                        done
                    fi
                done
            done
        done
    done
done

echo $cnt / $num_jobs

condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag
