reset
set terminal postscript eps enhanced color 32
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output/"
fig_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/figures/"
file_name = "FILE_NAME"
fig_name  = "FIG_NAME"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=32 X_LABEL}' offset character 0, 0, 0
set ylabel '{/Helvetica=32 Y_LABEL}' offset character 2.5, 0, 0

set tics font "Helvetica,24"
set xtics nomirror rotate by 0
set ytics nomirror
# set format x "10^{%L}"

set xrange [X_RANGE_S:X_RANGE_E]
set yrange [0:Y_RANGE_E]

# set logscale x
# set logscale y

# set lmargin 4.5
# set rmargin 5.5
# set bmargin 3.7
# set tmargin 4.4

# set key left top
# set key Left above reverse nobox horizontal spacing 0.9 samplen 1.5 width 0
set nokey

set style line 1 lc rgb "#e41a1c"  lt 1 lw 5 pt 1 ps 3 pi -1  ## +
set style line 2 lc rgb "#ff7f00"  lt 2 lw 5 pt 2 ps 3 pi -1  ## x
set style line 3 lc rgb "black"    lt 8 lw 5 pt 8 ps 3 pi -1  ## triangle
set style line 4 lc rgb "#732C7B"  lt 7 lw 5 pt 12 ps 3 pi -1 ## dimond  
set style line 5 lc rgb "#000078"  lt 6 lw 5 pt 6 ps 3 pi -1  ## circle
set style line 6 lc rgb "#00CC00"  lt 5 lw 5 pt 3 ps 3 pi -1  ## 
set style line 7 lc rgb "blue"     lt 4 lw 5 pt 4 ps 3 pi -1  ## box
set style line 8 lc rgb "#FFD800"  lt 3 lw 5 pt 5 ps 3 pi -1  ## solid box
set style line 9 lc rgb "red"      lt 9 lw 5 pt 9 ps 3 pi -1
set style line 10 lc rgb "blue"    lt 10 lw 5 pt 10 ps 1.0 pi -1
set style line 11 lc rgb "#00CC00" lt 11 lw 5 pt 11 ps 1.0 pi -1
set style line 12 lc rgb "#7F171F" lt 12 lw 5 pt 12 ps 1.0 pi -1
# set pointintervalbox 2  ## interval to a point

# plot data_dir.file_name.".txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:2 with lines ls 1 notitle

#plot data_dir.file_name.".txt" using 1:5 with linespoints ls 1 title '{/Helvetica=28 SRMF+KNN}', \
#     data_dir.file_name.".txt" using 1:6 with linespoints ls 2 title '{/Helvetica=28 LENS+KNN}', \
#     data_dir.file_name.".txt" using 1:7 with linespoints ls 3 title '{/Helvetica=28 Combined}'

plot data_dir.file_name.".txt" \
