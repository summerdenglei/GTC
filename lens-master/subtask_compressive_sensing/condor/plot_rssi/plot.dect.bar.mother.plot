reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output/"
fig_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/figures/"
file_name = "FILE_NAME"
fig_name  = "FIG_NAME"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=28 X_LABEL}' offset character 0, 0, 0
set ylabel '{/Helvetica=28 Y_LABEL}' offset character 2.5, 0, 0

set tics font "Helvetica,24"
set xtics nomirror rotate by -35
set ytics nomirror
# set format x "10^{%L}"

set xrange [X_RANGE_S:X_RANGE_E]
set yrange [Y_RANGE_S:Y_RANGE_E]

# set logscale x
# set logscale y

set lmargin 3
set rmargin 3
# set bmargin 3.7
set tmargin 2

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9

set style fill pattern 2
# set style fill solid 0.8
set palette color
# set palette gray

# set key right top
set key Left above reverse horizontal spacing 0.9 samplen 1.5 width 2
# set nokey


set style line 1 lc rgb "red"     lt 1 lw 1 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 1 pt 2 ps 1.5 pi -1  ## x

# plot data_dir.file_name.".txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:2 with lines ls 1 notitle

#plot data_dir.file_name.".txt" using 1:5 with linespoints ls 1 title '{/Helvetica=28 SRMF+KNN}', \
#     data_dir.file_name.".txt" using 1:6 with linespoints ls 2 title '{/Helvetica=28 LENS+KNN}', \
#     data_dir.file_name.".txt" using 1:7 with linespoints ls 3 title '{/Helvetica=28 Combined}'

plot data_dir.file_name.".txt" \
