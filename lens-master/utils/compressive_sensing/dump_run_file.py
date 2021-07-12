fp = open('run_checkins.m','w');
for i in range(1,11):
	for j in range(1,11):
		fileN = 'data/chk_50_' + (str)(i) + '_xy'
		cmd = 'wrapperSRMF(\'' + fileN + '\',' + (str)(j) + ')';
		fp.write(cmd + "\n");

fp.close();
