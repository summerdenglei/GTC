#!/bin/bash
func="gen_ip_info"
input_dir="/u/yichao/anomaly_compression/condor_data/subtask_parse_sjtu_wifi/text/"
cnt=1

ls ${input_dir} | while read f ; do
    echo "$cnt: ${input_dir}$f"

    sed "s/FILE_FULLPATH/$(echo ${input_dir}$f | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g;" ${func}.mother.sh > tmp.${func}.${cnt}.sh
    sed "s/IND/${cnt}/g" ${func}.mother.condor > tmp.${func}.${cnt}.condor
    condor_submit tmp.${func}.${cnt}.condor

    let cnt=${cnt}+1
done
