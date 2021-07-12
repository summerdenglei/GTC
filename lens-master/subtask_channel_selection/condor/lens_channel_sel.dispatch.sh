#!/bin/bash

func="lens_channel_sel"

num_jobs=205
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag

mobilities=("static")
trs=(1 2 4 5 6 7 8 9)
ants=(1 2 3)
rank=16
sample_modes=("know_all" "rand_fix" "equal_fix")
num_known_chs=(1 2 3 4 5 6 7 8)
# pred_methods=("srmf_knn")
pred_methods=("lens3_knn")
# pred_methods=("srmf_lens_st_v2_knn")
# pred_methods=("lens_st_v2_knn" "lens_st_knn")
schemes="our+cspy"

# mobilities=("static")
# trs=(8 9)
# ants=(1 2 3)
# rank=16
# sample_modes=("know_all" "rand_fix" "equal_fix")
# num_known_chs=(1 2 3 4 5 6 7 8)
# pred_methods=("srmf_knn")
# schemes="our+cspy"


for mobility in ${mobilities[@]}; do
    for tr in ${trs[@]}; do
        for ant in ${ants[@]}; do
            trace_name="${mobility}_trace${tr}.ant${ant}"
            echo ${trace_name}

            for sample_mode in ${sample_modes[@]}; do
                for num_known_ch in ${num_known_chs[@]}; do

                    if [[ ${sample_mode} == "know_all" ]] && [[ ${num_known_ch} -eq 1 ]]; then
                        num_known_ch=0
                        schemes="our+cspy"
                    elif [[ ${sample_mode} == "know_all" ]]; then
                        continue
                    else
                        schemes="our"
                    fi

                    for pred_method in ${pred_methods[@]}; do

                        name="${func}.${mobility}.tr${tr}.ant${ant}.r${rank}.${sample_mode}.ch${num_known_ch}.${pred_method}"
                        sed "s/MOBILITY/${mobility}/g; s/TRACE/${tr}/g; s/ANT/${ant}/g; s/RANK/${rank}/g; s/SAMPLE_MODE/${sample_mode}/g; s/NUM_KNOWN_CH/${num_known_ch}/g; s/PRED_METHOD/${pred_method}/g; s/SCHEMES/${schemes}/g" ${func}.mother.sh > tmp.${name}.sh
                        sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
                        echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
                        cnt=$((${cnt} + 1))
                    done
                done
            done

        done
    done
done

echo $cnt / $num_jobs

condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag



