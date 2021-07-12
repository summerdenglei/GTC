#!/bin/bash

input_dir="../data/video"
output_dir="../processed_data/mpeg_video"


for b in 10 100 200 300 400 500 600 700 ; do
# for b in 10 ; do
    file="stefan_cif"
    frame=90
    echo $file", frame="$frame", br="$b
    ffmpeg -s 352x288 -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s 352x288 ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="bus_cif"
    frame=150
    echo $file", frame="$frame", br="$b
    ffmpeg -s 352x288 -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s 352x288 ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="foreman_cif"
    frame=300
    echo $file", frame="$frame", br="$b
    ffmpeg -s 352x288 -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s 352x288 ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="coastguard_cif"
    frame=300
    echo $file", frame="$frame", br="$b
    ffmpeg -s 352x288 -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s 352x288 ${output_dir}/${file}.b${b}.mpeg_dec.yuv

    file="highway_cif"
    frame=2000
    echo $file", frame="$frame", br="$b
    ffmpeg -s 352x288 -i ${input_dir}/${file}.yuv -b ${b}k ${output_dir}/${file}.b${b}.mpeg
    ffmpeg -i ${output_dir}/${file}.b${b}.mpeg -s 352x288 ${output_dir}/${file}.b${b}.mpeg_dec.yuv
done

echo "yuv"
ll ../processed_data/video/*yuv | gawk '{ match($0, /yichao +([0-9]+).+\/video\/(.*)\.b([0-9]+)/, arr); print arr[2]", "arr[3]", "arr[1]}'

echo "mpeg"
ll ../processed_data/video/*mpeg | gawk '{ match($0, /yichao +([0-9]+).+\/video\/(.*)\.b([0-9]+)/, arr); print arr[2]", "arr[3]", "arr[1]}'

