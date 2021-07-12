#!/bin/bash

input_dir="../processed_data/subtask_parse_sjtu_wifi/text/"

cnt=1
ls ${input_dir} | while read f ; do
    echo "${cnt}: \"${input_dir}$f\""
    let cnt=${cnt}+1

    perl gen_trace_summary.pl "${input_dir}$f" 1
done