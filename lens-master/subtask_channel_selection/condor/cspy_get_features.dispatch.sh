#!/bin/bash

func="cspy_get_features"

num_jobs=220
cnt=0

## DAG 
rm tmp.$func.dag*
echo "" > tmp.$func.dag

input_dir="\/u\/yichao\/anomaly_compression\/processed_data\/subtask_parse_csi_channel\/csi\/"
mobilities=("static")
# trs=(1 2 4 5 6 7 8 9)
trs=(10 11 12 13)
ants=(1 2 3)


for mobility in ${mobilities[@]}; do
    for tr in ${trs[@]}; do
        for ant in ${ants[@]}; do
            trace_name="${mobility}_trace${tr}.ant${ant}"
            echo ${trace_name}

            name="${func}.${mobility}.tr${tr}.ant${ant}"
            sed "s/INPUT_DIR/${input_dir}/g; s/MOBILITY/${mobility}/g; s/TRACE/${tr}/g; s/ANT/${ant}/g;" ${func}.mother.sh > tmp.${name}.sh
            sed "s/XXX/${name}/g" ${func}.mother.condor > tmp.${name}.condor
            echo JOB J${cnt} tmp.${name}.condor >> tmp.$func.dag
            cnt=$((${cnt} + 1))

        done
    done
done

echo $cnt / $num_jobs

condor_submit_dag -maxjobs ${num_jobs} tmp.${func}.dag


