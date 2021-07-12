#!/bin/bash

func="srmf_based_pred"

num_jobs=200
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag


# files=("tm_abilene.od.")
# files=("tm_totem.")
# files=("tm_3g.cell.bs.bs3.all.bin10.txt")
# files=("tm_3g.cell.bs.bs3.all.bin60.txt")
# files=("tm_3g.cell.rnc.all.bin10.txt")
# files=("tm_3g.cell.load.top200.all.bin10.txt")
# files=("tm_sjtu_wifi.ap_load.all.bin600.top50.txt")
# files=("128.83.158.127_file.dat0_matrix.mat.txt")
# files=("128.83.158.50_file.dat0_matrix.mat.txt")
# files=("Mob-Recv1run1.dat0_matrix.mat_dB.txt")
# files=("tm_sensor.temp.bin600.txt")
# files=("tm_sensor.humidity.bin600.txt")
# files=("tm_sensor.light.bin600.txt")
# files=("tm_sensor.voltage.bin600.txt")
# files=("tm_ron1.latency.")
# files=("tm_telos_rssi.txt")
# files=("tm_multi_loc_rssi.txt")
# files=("tm_ucsb_meshnet.connected.txt")
# files=("tm_ucsb_meshnet.")

files=("tm_abilene.od." "tm_totem." "tm_sjtu_wifi.ap_load.all.bin600.top50.txt" "tm_3g.cell.bs.bs3.all.bin10.txt" "Mob-Recv1run1.dat0_matrix.mat_dB.txt" "tm_ron1.latency." "tm_telos_rssi.txt" "tm_multi_loc_rssi.txt" "static_trace13.ant1.mag.txt" "tm_ucsb_meshnet.connected.txt" "tm_umich_rss.txt")
# files=("tm_abilene.od." "tm_totem." "tm_umich_rss.txt")
# files=("tm_3g.cell.bs.bs3.all.bin10.txt" "tm_multi_loc_rssi.txt")


# seeds=(1 2 3 4 5)
seeds=(1)
opt_swap_mats=("org")
opt_types=("srmf_knn" "srmf" "lens3" "svd_base" "svd_base_knn" "base")
# opt_types=("srmf" "lens3" "base")
opt_dims=("2d")
threshs=(-1)

######################
# sigma_mags=(0 0.1 0.5 1 1.5 2 2.5 3 5)  ## impact of anomaly size: N times stdev
sigma_mags=(0)                                 ## dropping mode; impact of number of anomalies
######################

######################
sigma_noises=(0 0.01 0.02 0.04 0.08 0.16 0.32 0.64)
######################

#################
# num_anomalies=(0 0.01 0.02 0.04 0.08 0.12 0.16 0.2)  # impact of number of anomalies
num_anomalies=(0)                               ## dropping mode; impact of anomaly size
#################

for filename in ${files[@]}; do

    #############
    ## WiFi
    if [[ ${filename} == "tm_sjtu_wifi.ap_load.all.bin600.top50.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sjtu_wifi\/tm\/"
        num_frames=100
        width=50
        height=1

        group_sizes=(100)
        # ranks=(32)
        ranks=(8)
        periods=(1)
    fi
    ###############
    ## 3G
    # if [[ ${filename} == "tm_3g_region_all.res0.006.bin10.sub." ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/region_tm\/"
    #     num_frames=100
    #     width=21
    #     height=26

    #     group_sizes=(100)
    #     ranks=(100)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_3g.cell.bs.bs0.all.bin10.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
    #     num_frames=100
    #     width=1074
    #     height=1

    #     group_sizes=(100)
    #     ranks=(64)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_3g.cell.bs.bs1.all.bin10.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
    #     num_frames=100
    #     width=458
    #     height=1

    #     group_sizes=(100)
    #     ranks=(64)
    #     periods=(1)
    # fi
    if [[ ${filename} == "tm_3g.cell.bs.bs3.all.bin10.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
        # num_frames=100
        num_frames=144
        width=472
        height=1

        # group_sizes=(100)
        group_sizes=(144)
        # ranks=(32)
        ranks=(32)
        periods=(1)
    fi
    # if [[ ${filename} == "tm_3g.cell.bs.bs3.all.bin60.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
    #     num_frames=24
    #     width=472
    #     height=1

    #     group_sizes=(24)
    #     ranks=(8)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_3g.cell.load.top200.all.bin10.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
    #     num_frames=100
    #     width=200
    #     height=1

    #     group_sizes=(100)
    #     ranks=(64)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_3g.cell.rnc.all.bin10.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_huawei_3g\/bs_tm\/"
    #     # num_frames=100
    #     num_frames=144
    #     width=13
    #     height=1

    #     # group_sizes=(100)
    #     group_sizes=(144)
    #     ranks=(8)
    #     periods=(1)
    # fi
    #############
    ## GEANT
    if [[ ${filename} == "tm_totem." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_totem\/tm\/"
        # num_frames=100
        num_frames=672
        width=23
        height=23

        # group_sizes=(100)
        group_sizes=(672)
        # ranks=(64)
        ranks=(25)
        periods=(1)
    fi
    #############
    ## Abilene
    # if [[ ${filename} == "X" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/abilene\/"
    #     num_frames=100
    #     width=121
    #     height=1

    #     group_sizes=(100)
    #     ranks=(8)
    #     periods=(1)
    # fi
    if [[ ${filename} == "tm_abilene.od." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_abilene\/tm\/"
        # num_frames=100
        num_frames=1008
        width=11
        height=11

        # group_sizes=(100)
        group_sizes=(1008)
        # ranks=(64)
        ranks=(20)
        periods=(1)
    fi
    #############
    ## CSI
    # if [[ ${filename} == "128.83.158.127_file.dat0_matrix.mat.txt" ]]; then
    #     input_dir="\/v\/filer4b\/v27q002\/ut-wireless\/swati\/processed_traces\/MonitorExp1\/"
    #     num_frames=1000
    #     width=90
    #     height=1

    #     group_sizes=(1000)
    #     ranks=(32)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "128.83.158.50_file.dat0_matrix.mat.txt" ]]; then
    #     input_dir="\/v\/filer4b\/v27q002\/ut-wireless\/swati\/processed_traces\/MonitorExp1\/"
    #     num_frames=1000
    #     width=90
    #     height=1

    #     group_sizes=(1000)
    #     ranks=(32)
    #     periods=(1)
    # fi
    if [[ ${filename} == "Mob-Recv1run1.dat0_matrix.mat_dB.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/csi\/mobile\/"
        num_frames=1000
        width=90
        height=1

        group_sizes=(1000)
        # ranks=(64)
        ranks=(16)
        periods=(1)
    fi
    # if [[ ${filename} == "Mob-Recv1run1.dat1_matrix.mat_dB.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/csi\/mobile\/"
    #     num_frames=1000
    #     width=90
    #     height=1

    #     group_sizes=(1000)
    #     ranks=(32)
    #     periods=(1)
    # fi
    #############
    ## sensor
    # if [[ ${filename} == "tm_sensor.temp.bin600.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sensor\/tm\/"
    #     # num_frames=100
    #     num_frames=144
    #     width=54
    #     height=1

    #     # group_sizes=(100)
    #     group_sizes=(144)
    #     ranks=(8)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_sensor.humidity.bin600.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sensor\/tm\/"
    #     # num_frames=100
    #     num_frames=144
    #     width=54
    #     height=1

    #     # group_sizes=(100)
    #     group_sizes=(144)
    #     ranks=(8)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_sensor.light.bin600.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sensor\/tm\/"
    #     # num_frames=100
    #     num_frames=144
    #     width=54
    #     height=1

    #     # group_sizes=(100)
    #     group_sizes=(144)
    #     ranks=(8)
    #     periods=(1)
    # fi
    # if [[ ${filename} == "tm_sensor.voltage.bin600.txt" ]]; then
    #     input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_sensor\/tm\/"
    #     # num_frames=100
    #     num_frames=144
    #     width=54
    #     height=1

    #     # group_sizes=(100)
    #     group_sizes=(144)
    #     ranks=(8)
    #     periods=(1)
    # fi
    #############
    ## RON
    if [[ ${filename} == "tm_ron1.latency." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_ron\/tm\/"
        num_frames=494
        width=12
        height=12

        group_sizes=(494)
        # ranks=(32)
        ranks=(16)
        periods=(1)
    fi
    #############
    ## RSSI - telos
    if [[ ${filename} == "tm_telos_rssi.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_telos_rssi\/tm\/"
        num_frames=500  ##100, 500, 1000, 2000
        width=16
        height=1

        group_sizes=(500)
        # ranks=(12)
        ranks=(8)
        periods=(1)
    fi
    #############
    ## RSSI - multi-location
    if [[ ${filename} == "tm_multi_loc_rssi.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_multi_loc_rssi\/tm\/"
        num_frames=500
        width=895
        height=1

        group_sizes=(500)
        # ranks=(32)
        ranks=(16)
        periods=(1)
    fi
    #############
    ## Channel CSI
    if [[ ${filename} == "static_trace13.ant1.mag.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_csi_channel\/csi\/"
        num_frames=500
        width=270
        height=1

        group_sizes=(500)
        # ranks=(64)
        ranks=(16)
        periods=(1)
    fi
    #############
    ## UCSB Meshnet
    if [[ ${filename} == "tm_ucsb_meshnet.connected.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_ucsb_meshnet\/tm\/"
        num_frames=1000
        width=425
        height=1

        group_sizes=(1000)
        # ranks=(64)
        ranks=(16)
        periods=(1)
    fi
    if [[ ${filename} == "tm_ucsb_meshnet." ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_ucsb_meshnet\/tm\/"
        num_frames=1000
        width=38
        height=38

        group_sizes=(1000)
        # ranks=(64)
        ranks=(16)
        periods=(1)
    fi
    #############
    ## UMich RSS
    if [[ ${filename} == "tm_umich_rss.txt" ]]; then
        input_dir="\/u\/yichao\/anomaly_compression\/condor_data\/subtask_parse_umich_rss\/tm\/"
        num_frames=1000
        width=182
        height=1

        group_sizes=(1000)
        # ranks=(64)
        ranks=(32)
        periods=(1)
    fi


    for seed in ${seeds[@]}; do
        for group_size in ${group_sizes[@]}; do
            for opt_swap_mat in ${opt_swap_mats[@]}; do
                for rank in ${ranks[@]}; do
                    for opt_type in ${opt_types[@]}; do
                        for opt_dim in ${opt_dims[@]}; do

                            for period in ${periods[@]}; do
                                for num_anomaly in ${num_anomalies[@]}; do

                                    for sigma_mag in ${sigma_mags[@]}; do
                                        for sigma_noise in ${sigma_noises[@]}; do
                                            for thresh in ${threshs[@]}; do

                                                #########################################
                                                # PureRandLoss: elem_frac = 1
                                                #########################################
                                                drop_ele_mode="elem"
                                                drop_mode="ind"
                                                elem_fracs=(1)
                                                ##############
                                                # loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                # loss_rates=(0.1 0.2 0.4 0.8 0.9 0.95)
                                                loss_rates=(0.5)
                                                ##############
                                                burst_size=1
                                                for elem_frac in ${elem_fracs[@]}; do
                                                    for loss_rate in ${loss_rates[@]}; do    
                                                        name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                        echo ${name}
                                                        sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                        sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                        # condor_submit tmp.${name}.condor
                                                        echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                        cnt=$((${cnt} + 1))
                                                    done
                                                done

                                                ##########################################
                                                ## xxElemRandLoss: xx = elem_frac
                                                ##########################################
                                                # drop_ele_mode="elem"
                                                # drop_mode="ind"
                                                # # elem_fracs=(0.25 0.5 0.75 0.9)
                                                # elem_fracs=(0.5)
                                                # # loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                # loss_rates=(0.1 0.2 0.4 0.8 0.9 0.95)
                                                # burst_size=1
                                                # for elem_frac in ${elem_fracs[@]}; do
                                                #     for loss_rate in ${loss_rates[@]}; do    
                                                #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                #         echo ${name}
                                                #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                #         # condor_submit tmp.${name}.condor
                                                #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                #         cnt=$((${cnt} + 1))
                                                #     done
                                                # done

                                                # # ##########################################
                                                # # ## xxElemSyncLoss: xx = elem_frac
                                                # # ##########################################
                                                # drop_ele_mode="elem"
                                                # drop_mode="syn"
                                                # # elem_fracs=(0.25 0.5 0.75 0.9 1)
                                                # elem_fracs=(0.5)
                                                # # loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                # loss_rates=(0.1 0.2 0.4 0.8 0.9 0.95)
                                                # burst_size=1
                                                # for elem_frac in ${elem_fracs[@]}; do
                                                #     for loss_rate in ${loss_rates[@]}; do    
                                                #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                #         echo ${name}
                                                #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                #         # condor_submit tmp.${name}.condor
                                                #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                #         cnt=$((${cnt} + 1))
                                                #     done
                                                # done

                                                # # ##########################################
                                                # # ## xxTimeRandLoss: xx = loss_rate
                                                # # ##########################################
                                                # drop_ele_mode="elem"
                                                # drop_mode="ind"
                                                # # elem_fracs=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                # elem_fracs=(0.1 0.2 0.4 0.8 0.9 0.95)
                                                # loss_rates=(0.5)
                                                # burst_size=1
                                                # for elem_frac in ${elem_fracs[@]}; do
                                                #     for loss_rate in ${loss_rates[@]}; do    
                                                #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                #         echo ${name}
                                                #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                #         # condor_submit tmp.${name}.condor
                                                #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                #         cnt=$((${cnt} + 1))
                                                #     done
                                                # done

                                                #########################################
                                                # Prediction: elem_frac = 1
                                                #########################################
                                                # drop_ele_mode="elem"
                                                # drop_mode="half"
                                                # elem_fracs=(1)
                                                # # loss_rates=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                # # loss_rates=(0.01 0.02 0.04 0.08 0.16 0.2)
                                                # loss_rates=(0.01)
                                                # burst_size=1
                                                # for elem_frac in ${elem_fracs[@]}; do
                                                #     for loss_rate in ${loss_rates[@]}; do    
                                                #         name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                #         echo ${name}
                                                #         sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                #         sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                #         # condor_submit tmp.${name}.condor
                                                #         echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                #         cnt=$((${cnt} + 1))
                                                #     done
                                                # done

                                                ##########################################
                                                ## only used by 3D matrices: RowRandLoss and ColRandLoss
                                                ##########################################
                                                # if [[ ${filename} == "tm_totem." ||
                                                #       ${filename} == "tm_abilene.od." ||
                                                #       ${filename} == "tm_ron1.latency." ||
                                                #       ${filename} == "tm_ucsb_meshnet." ||
                                                #       ${filename} == "tm_3g_region_all.res0.006.bin10.sub." ]]; then

                                                #     ## RowRandLoss:
                                                #     ## ColRandLoss:
                                                #     drop_ele_modes=("row" "col")
                                                #     drop_mode="ind"
                                                #     # elem_fracs=(0.05 0.1 0.2 0.4 0.6 0.8 0.9 0.93 0.95 0.97 0.98 0.99)
                                                #     elem_fracs=(0.1 0.2 0.4 0.8 0.9 0.95)
                                                #     # loss_rates=(1)
                                                #     loss_rates=(0.5)
                                                #     burst_size=1
                                                #     for drop_ele_mode in ${drop_ele_modes[@]}; do
                                                #         for elem_frac in ${elem_fracs[@]}; do
                                                #             for loss_rate in ${loss_rates[@]}; do
                                                #                 name=${func}.${filename}.${num_frames}.${width}.${height}.${group_size}.r${rank}.period${period}.${opt_swap_mat}.${opt_type}.${opt_dim}.${drop_ele_mode}.${drop_mode}.elem${elem_frac}.loss${loss_rate}.burst${burst_size}.na${num_anomaly}.anom${sigma_mag}.noise${sigma_noise}.thresh${thresh}.seed${seed}
                                                #                 echo ${name}
                                                #                 sed "s/INPUT_DIR/${input_dir}/g; s/FILENAME/${filename}/g;s/NUM_FRAMES/${num_frames}/g;s/WIDTH/${width}/g;s/HEIGHT/${height}/g;s/GROUP_SIZE/${group_size}/g;s/RANK/${rank}/g;s/PERIOD/${period}/g;s/OPT_SWAP_MAT/${opt_swap_mat}/g;s/OPT_TYPE/${opt_type}/g;s/OPT_DIM/${opt_dim}/g;s/DROP_ELE_MODE/${drop_ele_mode}/g;s/DROP_MODE/${drop_mode}/g;s/ELEM_FRAC/${elem_frac}/g;s/LOSS_RATE/${loss_rate}/g;s/BURST_SIZE/${burst_size}/g;s/NUM_ANOM/${num_anomaly}/g;s/SIGMA_MAG/${sigma_mag}/g;s/SIGMA_NOISE/${sigma_noise}/g;s/THRESH/${thresh}/g;s/SEED/${seed}/g;" ${func}.mother.sh > tmp.${name}.sh
                                                #                 sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                                                #                 # condor_submit tmp.${name}.condor
                                                #                 echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                                                #                 cnt=$((${cnt} + 1))
                                                #             done
                                                #         done
                                                #     done
                                                # fi
                                                


                                            done
                                        done
                                    done

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



