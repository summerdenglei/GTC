reset
set terminal postscript eps enhanced color 28
# set terminal postscript eps enhanced monochrome 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "../processed_data/subtask_time/run_time/"
fig_dir  = "../processed_data/subtask_time/run_time/figures/"
file_name = "time_mn"
fig_name  = "time_mn"
set output fig_dir.fig_name.".eps"

set xlabel '{/Helvetica=28 Matrix Size}'
set ylabel '{/Helvetica=28 Time (seconds)}'

set xtics nomirror rotate by -30
set ytics nomirror
set tics font "Helvetica,28"

# set xrange [X_RANGE_S:X_RANGE_E]
# set yrange [Y_RANGE_S:Y_RANGE_E]

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9

set style fill pattern 2
# set style fill solid 0.8
set palette color
# set palette gray

set key left top
# set key Left under reverse horizontal spacing 0.9 samplen 1.5 width -1
# set nokey


set style line 1 lc rgb "red"     lt 1 lw 1 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 1 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 1 lw 1 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 1 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 3 lw 1 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 1 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 1 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 1 pt 8 ps 1.5 pi -1  ## triangle

set xtics ("50x50" 0, "100x100" 1, "200x100" 2, "400x100" 3, "500x200" 4)

plot data_dir.file_name.".txt" \
    using 3 t '{/Helvetica=28 SRMF}' fs pattern 2 ls 1, \
    '' using 4 t '{/Helvetica=28 LENS}' fs pattern 3 ls 2


## data example
# Region        Austria        Hungary        Belgium        Czechoslovakia
# 1891-1900        234081        181288        18167                 50231
# 1901-1910        668209        808511        41635                 65285
