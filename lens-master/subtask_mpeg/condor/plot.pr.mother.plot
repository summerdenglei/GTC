reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28
# set terminal jpeg enhanced font Helvetica 28
set size ratio 0.7

data_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg/output/"
fig_dir   = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg/figures/"
file_name = "FILENAME"
fig_name  = "FIGNAME"
set output fig_dir.fig_name.".eps"
# set output fig_dir.fig_name.".png"
# set output fig_dir.fig_name.".jpg"

set xlabel '{/Helvetica=28 X_LABEL}'
set ylabel '{/Helvetica=28 Y_LABEL}'

set xtics nomirror
set ytics nomirror
set xtics rotate by DEGREE

set xrange [X_RANGE_S:X_RANGE_E]
set yrange [Y_RANGE_S:Y_RANGE_E]

# set key right top
set key Left above reverse nobox spacing 1
# set nokey

set style line 1 lc rgb "red"     lt 1 lw 5 pt 1 ps 1.5 pi -1
set style line 2 lc rgb "blue"    lt 2 lw 5 pt 2 ps 1.5 pi -1
set style line 3 lc rgb "#00CC00" lt 3 lw 5 pt 3 ps 1.5 pi -1
set style line 4 lc rgb "#7F171F" lt 4 lw 5 pt 4 ps 1.5 pi -1
set style line 5 lc rgb "#FFD800" lt 5 lw 5 pt 5 ps 1.5 pi -1
set style line 6 lc rgb "#000078" lt 6 lw 5 pt 6 ps 1.5 pi -1
set style line 7 lc rgb "#732C7B" lt 7 lw 5 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 5 pt 8 ps 1.5 pi -1
set pointintervalbox 2  ## interval to a point

# plot data_dir."FIGURE_NAME.txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir."FIGURE_NAME.txt" using 1:2 with lines ls 1 title '{/Helvetica=28 TITLE_2}'

# plot data_dir.file_name.".txt" using 1:2 with linespoints ls 1 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:3 with linespoints ls 2 title '{/Helvetica=28 TITLE_2}'

plot