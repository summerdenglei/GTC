#!/bin/bash

input_dir="../processed_data/subtask_TM_to_video/video"
output_dir="../processed_data/subtask_TM_to_video/comp_video"

files=`ls `

#for b in 10 100 200 300 400 500 600 700 ; do
for b in 1 3 5 7 9 10 15 20 30 40 50 100 200 300 400 500 600 700 ; do
    # file="TM_Airport_period5_"
    # frame=12
    # width=300
    # height=300
    # echo $file", frame="$frame", "${width}"x"${height}", br="$b
    # ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    # ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    # file="TM_Austin_period5_"
    # frame=12
    # width=300
    # height=300
    # echo $file", frame="$frame", "${width}"x"${height}", br="$b
    # ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    # ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    # file="TM_Manhattan_period5_"
    # frame=12
    # width=500
    # height=500
    # echo $file", frame="$frame", "${width}"x"${height}", br="$b
    # ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    # ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    # file="TM_San_Francisco_period5_"
    # frame=12
    # width=300
    # height=300
    # echo $file", frame="$frame", "${width}"x"${height}", br="$b
    # ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    # ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    ##############################################

    file="TM_Airport_period5_.exp0."
    frame=12
    width=300
    height=300
    echo $file", frame="$frame", "${width}"x"${height}", br="$b
    ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b:v ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="TM_Airport_period5_.exp1."
    frame=12
    width=300
    height=300
    echo $file", frame="$frame", "${width}"x"${height}", br="$b
    ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b:v ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="TM_Airport_period5_.exp2."
    frame=12
    width=300
    height=300
    echo $file", frame="$frame", "${width}"x"${height}", br="$b
    ffmpeg -s ${width}x${height} -i ${input_dir}/${file}.yuv -b:v ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s ${width}x${height} ${output_dir}/${file}.b${b}.mpeg_dec.yuv
done

# echo "yuv"
# ls -al ../processed_data/subtask_TM_to_video/comp_video/*yuv | gawk '{ match($0, /yichao +([0-9]+).*subtask_TM_to_video\/comp_video\/(.*)\.b([0-9]+)/, arr); print arr[2]", "arr[3]", "arr[1]}'

# echo "mpeg"
# ls -al ../processed_data/subtask_TM_to_video/comp_video/*mpeg | gawk '{ match($0, /yichao +([0-9]+).+\/comp_video\/(.*)\.b([0-9]+)/, arr); print arr[2]", "arr[3]", "arr[1]}'

# scp ../processed_data/subtask_TM_to_video/comp_video/* valleyview.cs.utexas.edu:/u/yichao/anomaly_compression/processed_data/subtask_TM_to_video/comp_video/
