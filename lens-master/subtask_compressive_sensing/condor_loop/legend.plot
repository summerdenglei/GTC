reset
set terminal postscript eps enhanced color 28
# set terminal png enhanced 28 size 800,600
# set terminal jpeg enhanced font helvetica 28
set size 0.4,0.75

set output "legend_iter.eps"

set xrange [0:0]
set yrange [0:0]

set pointsize 0
set border 0
set noxtics;
set noytics;

set key Left above left reverse nobox vertical spacing 1 samplen 1.5 width -6


set style line 1 lc rgb "red"     lt 1 lw 5 pt 1 ps 1.5 pi -1  ## +
set style line 2 lc rgb "blue"    lt 2 lw 5 pt 2 ps 1.5 pi -1  ## x
set style line 3 lc rgb "#00CC00" lt 5 lw 5 pt 3 ps 1.5 pi -1  ## *
set style line 4 lc rgb "#7F171F" lt 4 lw 5 pt 4 ps 1.5 pi -1  ## box
set style line 5 lc rgb "#FFD800" lt 3 lw 5 pt 5 ps 1.5 pi -1  ## solid box
set style line 6 lc rgb "#000078" lt 6 lw 5 pt 6 ps 1.5 pi -1  ## circle
set style line 7 lc rgb "#732C7B" lt 7 lw 5 pt 7 ps 1.5 pi -1
set style line 8 lc rgb "black"   lt 8 lw 5 pt 8 ps 1.5 pi -1  ## triangle
set style line 9 lc rgb "red"     lt 9 lw 5 pt 9 ps 1.5 pi -1  ## triangle
set style line 10 lc rgb "blue"    lt 10 lw 5 pt 10 ps 1.5 pi -1
set style line 11 lc rgb "#00CC00" lt 11 lw 5 pt 11 ps 1.5 pi -1
# set pointintervalbox 2  ## interval to a point

plot [0:0.0001][0:0.0001] \
     x+100 with linespoints ls 3 title '{/Helvetica=20 3G}', \
     x+100 with linespoints ls 4 title '{/Helvetica=20 WiFi}', \
     x+100 with linespoints ls 1 title '{/Helvetica=20 Abilene}', \
     x+100 with linespoints ls 2 title '{/Helvetica=20 GEANT}', \
     x+100 with linespoints ls 5 title '{/Helvetica=20 CSI (1 channel)}', \
     x+100 with linespoints ls 9 title '{/Helvetica=20 CSI (multi-channel)}', \
     x+100 with linespoints ls 6 title '{/Helvetica=20 Cister RSSI}', \
     x+100 with linespoints ls 7 title '{/Helvetica=20 CU RSSI}', \
     x+100 with linespoints ls 11 title '{/Helvetica=20 UMich RSS}', \
     x+100 with linespoints ls 10 title '{/Helvetica=20 UCSB Meshnet}'

