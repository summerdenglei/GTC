#####################################################
## ALL

reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "../processed_data/subtask_analyze_3g/stat/"
fig_dir  = "../processed_data/subtask_analyze_3g/stat/figures/"
file_name = "ts_cells.all.bin60"
fig_name  = "ts_cells.all.bin60"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=28 Time (hour)}'
set ylabel '{/Helvetica=28 Total Network Load (MBytes)}'
set y2label '{/Helvetica=28 BS Network Load (MBytes)}'

set xtics nomirror
set ytics nomirror
set y2tics nomirror
set xtics rotate by -45
set tics font "Helvetica,24"

set xrange [:]
set yrange [:]
set y2range [0:2000]

# set key right top
set key Left above reverse nobox spacing 1
# set nokey

set style line 1 lc rgb "red"     lt 1 lw 5 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 5 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 3 lw 5 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 5 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 5 lw 5 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 5 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 5 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 5 pt 8 ps 1.5 pi -1  ## triangle
set pointintervalbox 2  ## interval to a point

# plot data_dir.file_name.".txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:2 with lines ls 1 notitle

plot data_dir.file_name.".txt" using 1 with linespoints ls 1 title '{/Helvetica=28 Total}' axes x1y1, \
     data_dir.file_name.".txt" using 2 with linespoints ls 2 title '{/Helvetica=28 Cell #1}' axes x1y2, \
     data_dir.file_name.".txt" using 3 with linespoints ls 3 title '{/Helvetica=28 Cell #2}' axes x1y2, \
     data_dir.file_name.".txt" using 4 with linespoints ls 4 title '{/Helvetica=28 Cell #3}' axes x1y2


#####################################################
## Downlink

reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "../processed_data/subtask_analyze_3g/stat/"
fig_dir  = "../processed_data/subtask_analyze_3g/stat/figures/"
file_name = "ts_cells.dl.bin60"
fig_name  = "ts_cells.dl.bin60"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=28 Time (hour)}'
set ylabel '{/Helvetica=28 Total Network Load (MBytes)}'
set y2label '{/Helvetica=28 BS Network Load (MBytes)}'

set xtics nomirror
set ytics nomirror
set y2tics nomirror
set xtics rotate by -45
set tics font "Helvetica,24"

set xrange [:]
set yrange [:]
set y2range [0:2000]

# set key right top
set key Left above reverse nobox spacing 1
# set nokey

set style line 1 lc rgb "red"     lt 1 lw 5 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 5 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 3 lw 5 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 5 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 5 lw 5 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 5 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 5 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 5 pt 8 ps 1.5 pi -1  ## triangle
set pointintervalbox 2  ## interval to a point

# plot data_dir.file_name.".txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:2 with lines ls 1 notitle

plot data_dir.file_name.".txt" using 1 with linespoints ls 1 title '{/Helvetica=28 Total}' axes x1y1, \
     data_dir.file_name.".txt" using 2 with linespoints ls 2 title '{/Helvetica=28 Cell #1}' axes x1y2, \
     data_dir.file_name.".txt" using 3 with linespoints ls 3 title '{/Helvetica=28 Cell #2}' axes x1y2, \
     data_dir.file_name.".txt" using 4 with linespoints ls 4 title '{/Helvetica=28 Cell #3}' axes x1y2


#####################################################
## Uplink

reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "../processed_data/subtask_analyze_3g/stat/"
fig_dir  = "../processed_data/subtask_analyze_3g/stat/figures/"
file_name = "ts_cells.ul.bin60"
fig_name  = "ts_cells.ul.bin60"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=28 Time (hour)}'
set ylabel '{/Helvetica=28 Total Network Load (MBytes)}'
set y2label '{/Helvetica=28 BS Network Load (MBytes)}'

set xtics nomirror
set ytics nomirror
set y2tics nomirror
set xtics rotate by -45
set tics font "Helvetica,24"

set xrange [:]
set yrange [:]
set y2range [0:500]

# set key right top
set key Left above reverse nobox spacing 1
# set nokey

set style line 1 lc rgb "red"     lt 1 lw 5 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 5 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 3 lw 5 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 5 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 5 lw 5 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 5 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 5 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 5 pt 8 ps 1.5 pi -1  ## triangle
set pointintervalbox 2  ## interval to a point

# plot data_dir.file_name.".txt" using 1:3 with lines ls 2 title '{/Helvetica=28 TITLE_1}', \
#      data_dir.file_name.".txt" using 1:2 with lines ls 1 notitle

plot data_dir.file_name.".txt" using 1 with linespoints ls 1 title '{/Helvetica=28 Total}' axes x1y1, \
     data_dir.file_name.".txt" using 2 with linespoints ls 2 title '{/Helvetica=28 Cell #1}' axes x1y2, \
     data_dir.file_name.".txt" using 3 with linespoints ls 3 title '{/Helvetica=28 Cell #2}' axes x1y2, \
     data_dir.file_name.".txt" using 4 with linespoints ls 4 title '{/Helvetica=28 Cell #3}' axes x1y2

