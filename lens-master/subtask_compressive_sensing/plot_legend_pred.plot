reset
set terminal postscript eps enhanced 28

# set size 2.3,0.18
set size 1.5,0.08

set pointsize 0
set border 0
set noxtics;
set noytics;
set key Left above center reverse nobox horizontal spacing 1 samplen 3.5 width 1.5

set output "legend_pred.eps"

set style line 1 lc rgb "#e41a1c"  lt 1 lw 5 pt 1 ps 3 pi -1  ## +
set style line 2 lc rgb "#ff7f00"  lt 2 lw 5 pt 2 ps 3 pi -1  ## x
set style line 3 lc rgb "black"    lt 8 lw 5 pt 8 ps 3 pi -1  ## triangle
set style line 4 lc rgb "#732C7B"  lt 7 lw 5 pt 12 ps 3 pi -1 ## dimond  
set style line 5 lc rgb "blue"     lt 6 lw 5 pt 6 ps 3 pi -1  ## circle
set style line 6 lc rgb "#000078"  lt 5 lw 5 pt 3 ps 3 pi -1  ## 
set style line 7 lc rgb "#00CC00"  lt 4 lw 5 pt 4 ps 3 pi -1  ## box
set style line 8 lc rgb "#FFD800"  lt 3 lw 5 pt 5 ps 3 pi -1  ## solid box
set style line 9 lc rgb "red"      lt 9 lw 5 pt 9 ps 3 pi -1
set style line 10 lc rgb "blue"    lt 10 lw 5 pt 10 ps 1.0 pi -1
set style line 11 lc rgb "#00CC00" lt 11 lw 5 pt 11 ps 1.0 pi -1
set style line 12 lc rgb "#7F171F" lt 12 lw 5 pt 12 ps 1.0 pi -1
set pointintervalbox 3  ## interval to a point


plot [:0.001][0:0.001] \
     x+100 with linespoints ls 1 title '{/Helvetica=28 Base}', \
     x+100 with linespoints ls 3 title '{/Helvetica=28 SRMF}', \
     x+100 with linespoints ls 5 title '{/Helvetica=28 LENS}'
     
