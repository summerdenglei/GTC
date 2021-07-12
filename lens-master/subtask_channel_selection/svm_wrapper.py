#!/usr/bin/env python

import sys
import os
from subprocess import *
import numpy as np


#########
## Commands: svm, grid, and gnuplot executable files
#########
svmscale_exe = "/u/yichao/bin/libsvm-3.17/svm-scale"
svmtrain_exe = "/u/yichao/bin/libsvm-3.17/svm-train"
svmpredict_exe = "/u/yichao/bin/libsvm-3.17/svm-predict"
grid_py = "/u/yichao/bin/libsvm-3.17/tools/grid.py"
# gnuplot_exe = "/usr/bin/gnuplot"

assert os.path.exists(svmscale_exe),"svm-scale executable not found"
assert os.path.exists(svmtrain_exe),"svm-train executable not found"
assert os.path.exists(svmpredict_exe),"svm-predict executable not found"
# assert os.path.exists(gnuplot_exe),"gnuplot executable not found"
assert os.path.exists(grid_py),"grid.py not found"


#########
## Constant
#########
TRAIN_MODEL = 1


#########
## Variables
#########
input_dir  = "../processed_data/subtask_channel_selection/features/"
output_dir = "../processed_data/subtask_channel_selection/svm_results/"

num_channels = 9
mobilities = ['static']
traces = np.r_[1,2, 4:10]
ants = np.r_[1:4]


#########
## Check Input
#########
if len(sys.argv) < 1:
	print "Not enough input: " + str(sys.argv)
	print('Usage: {0} num_training_pkts'.format(sys.argv[0]))
	raise SystemExit

num_train_per_file = int(sys.argv[1])
train_file = "train" + str(num_train_per_file)


#########
## Main Start 
#########


for ch in np.r_[1:num_channels+1]:
	this_train_file = train_file + ".ch" + str(ch) + ".txt"
	cmd = 'truncate --size=0 {0}{1}'.format(output_dir, this_train_file)
	Popen(cmd, shell = True).communicate()


	scaled_file = this_train_file + ".scale"
	model_file  = this_train_file + ".model"
	range_file  = this_train_file + ".range"


	print "-------------------------"
	print "channel " + str(ch)
	print "-------------------------"


	if TRAIN_MODEL == 1:
		
		#########
		## get training data
		#########
		print("get training data:")

		for mobility in mobilities:
			for tr in traces:
				for ant in ants:			
					trace_name = mobility + "_trace" + str(tr) + ".ant" + str(ant) + ".ch" + str(ch) + ".txt"
					print trace_name
					cmd = 'head -{0} {1}{2} >> {3}{4}'.format(num_train_per_file, input_dir, trace_name, output_dir, this_train_file)
					Popen(cmd, shell = True).communicate()


		#########
		## statistics of the training file
		#########
		print "static of the training file:"

		cmd = "cat " + output_dir + this_train_file + " | awk '{print $1}' | sort | uniq -c"
		# print cmd
		f = Popen(cmd, shell = True, stdout = PIPE).stdout
		while True:
			line = f.readline()
			print line,
			if not line: break
					

		#########
		## training start
		#########
		print "\ntraining start:"

		#########
		## a) scaling training data
		#########
		print "  scaling training data:"
		cmd = '{0} -s "{1}{2}" "{1}{3}" > "{1}{4}"'.format(svmscale_exe, output_dir, range_file, this_train_file, scaled_file)
		Popen(cmd, shell = True, stdout = PIPE).communicate()

		#########
		## b) cross validation
		#########
		print "  cross validation:"
		# cmd = '{0} -svmtrain "{1}" -gnuplot "{2}" "{3}{4}"'.format(grid_py, svmtrain_exe, gnuplot_exe, output_dir, scaled_file)
		cmd = '{0} -svmtrain "{1}" "{2}{3}"'.format(grid_py, svmtrain_exe, output_dir, scaled_file)
		f = Popen(cmd, shell = True, stdout = PIPE).stdout
		while True:
			last_line = line
			line = f.readline()
			if not line: break
		c,g,rate = map(float,last_line.split())
		print('    best c={0}, g={1} CV rate={2}'.format(c,g,rate))

		#########
		## c) train the model
		#########
		print "  train the model"
		cmd = '{0} -c {1} -g {2} "{3}{4}" "{3}{5}"'.format(svmtrain_exe, c, g, output_dir, scaled_file, model_file)
		Popen(cmd, shell = True, stdout = PIPE).communicate()

	## end if need to train the model
	#######


	#########
	## testing start
	#########
	print "testing start:"

	for mobility in mobilities:
		for tr in traces:
			for ant in ants:
				trace_name = mobility + "_trace" + str(tr) + ".ant" + str(ant) + ".ch" + str(ch) + ".txt"
				print "  > " + trace_name

				scaled_test_file = trace_name + ".scale"
				predict_test_file = trace_name + ".predict"


				#########
				## a) scaling testing data
				#########
				print "  scaling testing data:"
				cmd = '{0} -r "{1}{2}" "{3}{4}" > "{1}{5}"'.format(svmscale_exe, output_dir, range_file, input_dir, trace_name, scaled_test_file)
				# print cmd
				Popen(cmd, shell = True, stdout = PIPE).communicate()

				#########
				## b) testing
				#########
				print "  testing:"
				cmd = '{0} "{1}{2}" "{1}{3}" "{1}{4}"'.format(svmpredict_exe, output_dir, scaled_test_file, model_file, predict_test_file)
				# print cmd
				Popen(cmd, shell = True).communicate()
