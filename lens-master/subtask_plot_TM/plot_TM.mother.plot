reset
# set terminal postscript eps enhanced color 28
set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28 size 800,600
set size ratio 0.7

data_dir = "DATA_DIR"
fig_dir  = "FIG_DIR"
file_name = "FILE_NAME"
fig_name  = "FIG_NAME"
set output fig_dir.fig_name.".png"

set xlabel '{/Helvetica=28 X_LABEL}'
set ylabel '{/Helvetica=28 Y_LABEL}'

set xtics nomirror
set ytics nomirror
set xtics rotate by DEGREE
set tics font "Helvetica,24"

set xrange [X_RANGE_S:X_RANGE_E]
set yrange [Y_RANGE_S:Y_RANGE_E]

set tic scale 0

# Color runs from white to green
# set palette rgbformula -7,2,-7
set cbrange [CBRANGE_S:CBRANGE_E]
set cblabel "CBLABEL"
# unset cbtics

plot data_dir.file_name matrix w image notitle
