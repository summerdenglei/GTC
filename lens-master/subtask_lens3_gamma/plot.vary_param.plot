reset
set terminal postscript eps enhanced color 28
# set terminal postscript eps enhanced monochrome 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size ratio 0.7

data_dir = "./"
fig_dir  = "./"
file_name = "results.vary_param"
fig_name  = "trace.lens3.gamma.vary_param"
set output fig_dir.fig_name.".eps"

# set xlabel '{/Helvetica=28 Trace}'
set ylabel '{/Helvetica=28 Gamma}'

set xtics nomirror rotate by 0
set ytics ("0" 1, "1" 2, "2" 3, "3" 4, "4" 5, "5" 6, "6" 7, "7" 8, "8" 9, "9" 10, "10" 11) nomirror
set tics font "Helvetica,28"

set xrange [-0.5:2.5]
set yrange [0:11]

set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9

set style fill pattern 2
# set style fill solid 0.8
set palette color
# set palette gray

# set key left top
set key Left above reverse horizontal spacing 0.9 samplen 1.5 width -1
# set nokey

# set lmargin 4.5
# set rmargin 5.5
# set bmargin 3.7
set tmargin 3

set style line 1 lc rgb "red"     lt 1 lw 1 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 1 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 1 lw 1 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 1 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 3 lw 1 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 1 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 1 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 1 pt 8 ps 1.5 pi -1  ## triangle


# plot data_dir.file_name.".txt" \
#     using ($2+1):xtic(1) t '{/Helvetica=28 Multi-ch CSI}' fs pattern 2 ls 1, \
#     '' using ($3+1):xtic(1) t '{/Helvetica=28 3G}' fs pattern 3 ls 2, \
#     '' using ($4+1):xtic(1) t '{/Helvetica=28 GEANT}' fs pattern 4 ls 3

plot data_dir.file_name.".txt" \
       using ($2+1):xtic(1) t '{/Helvetica=28 lr=10%}' fs pattern 2 ls 1, \
    '' using ($3+1):xtic(1) t '{/Helvetica=28 lr=40%}' fs pattern 3 ls 1, \
    '' using ($4+1):xtic(1) t '{/Helvetica=28 lr=90%}' fs pattern 4 ls 1, \
    '' using ($5+1):xtic(1) t '{/Helvetica=28 s=0.1}' fs pattern 2 ls 2, \
    '' using ($6+1):xtic(1) t '{/Helvetica=28 s=1}' fs pattern 3 ls 2, \
    '' using ($7+1):xtic(1) t '{/Helvetica=28 s=2}' fs pattern 4 ls 2, \
    '' using ($8+1):xtic(1) t '{/Helvetica=28 ratio=1%}' fs pattern 2 ls 3, \
    '' using ($9+1):xtic(1) t '{/Helvetica=28 ratio=4%}' fs pattern 3 ls 3, \
    '' using ($10+1):xtic(1) t '{/Helvetica=28 ratio=8%}' fs pattern 4 ls 3

