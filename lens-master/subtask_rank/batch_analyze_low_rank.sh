#!/bin/bash

thresh=0.01

###################################
## SJTU WiFi

## 1. dl
dir="../processed_data/subtask_parse_sjtu_wifi/tm/"
filename="tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top400."
width=250
height=400
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 1. ul
filename="tm_upload.sort_ips.ap.bgp.sub_CN.txt.3600.top400."
width=400
height=250
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 2. dl
filename="tm_download.sort_ips.ap.country.txt.3600.top400."
width=250
height=193
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 2. ul
filename="tm_upload.sort_ips.ap.country.txt.3600.top400."
width=193
height=250
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot

## 3. dl
filename="tm_download.sort_ips.ap.gps.1.sub_CN.txt.3600.top400."
width=250
height=223
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 3. ul
filename="tm_upload.sort_ips.ap.gps.1.sub_CN.txt.3600.top400."
width=223
height=250
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 4. dl
filename="tm_download.sort_ips.ap.gps.5.txt.3600.top400."
width=250
height=400
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 4. ul
filename="tm_upload.sort_ips.ap.gps.5.txt.3600.top400."
width=400
height=250
num_frame=19

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


###################################
## Huawei 3G

## 1. 0.004
dir="../processed_data/subtask_parse_huawei_3g/region_tm/"
filename="tm_3g_region_all.res0.004.bin60."
width=324
height=475
num_frame=24

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 1. 0.004, sub-region
filename="tm_3g_region_all.res0.004.bin60.sub."
width=61
height=61

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot

## 2. 0.002
dir="../processed_data/subtask_parse_huawei_3g/region_tm/"
filename="tm_3g_region_all.res0.002.bin60."
width=647
height=949
num_frame=24

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


## 2. 0.002, sub-region
filename="tm_3g_region_all.res0.002.bin60.sub."
width=121
height=101

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot


###################################
## 4SQ 
thresh=0.05

## 1. airport
dir="../processed_data/subtask_process_4sq/TM/"
filename="TM_Airport_period5_"
width=300
height=300
num_frame=12

matlab -r "[sigma] = analyze_low_rank('${dir}', '${filename}', ${num_frame}, ${width}, ${height}, ${thresh}); exit;"

sed "s/FILE_NAME/${filename}/g; s/FIG_NAME/${filename}rank/g;" plot.rank.plot > tmp.plot.rank.plot
gnuplot tmp.plot.rank.plot
rm tmp.plot.rank.plot

sed "s/FILE_NAME/${filename}rank.10/g; s/FIG_NAME/${filename}rank.10/g;" plot.sigma.plot > tmp.plot.sigma.plot
gnuplot tmp.plot.sigma.plot
rm tmp.plot.sigma.plot

