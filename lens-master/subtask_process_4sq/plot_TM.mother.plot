reset
set terminal postscript eps enhanced color 28
#set terminal jpeg enhanced font helvetica 20
filename="XXX"
axis_range=ZZZ

set output "../figures/subtask_process_4sq/TM/" . filename . ".eps"
#set output "../figures/subtask_process_4sq/TM/jpeg/" . filename . ".jpeg"

set tic scale 0
# Color runs from white to green
#set palette rgbformula -7,2,-7
set cbrange [0:YYY]
#set cblabel "Score"
#unset cbtics

set xrange [0:axis_range]
set yrange [0:axis_range]

#set view map
plot '../processed_data/subtask_process_4sq/TM/tmp.' . filename . '.txt' matrix w image notitle
