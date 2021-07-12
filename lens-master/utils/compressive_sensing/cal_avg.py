runs = 5;
i = 0.1;
while i <= 1:
	resultHash = {};
	resultFile = '3Day/Loss' + (str)(i); 
	fpO = open(resultFile, 'w');
	loss = (str)(i);
	if i > 0.95:
		loss = (str)((int)(1));
		print loss;
	for j in range(1,6):
		fileName = '3Day/3Day-dim2-rank5-loss' + loss + '-seed' + (str)(j) + '-lambda0.1.csv';
		fp = open(fileName,'r');
		fp.readline();
		while fp:
			record = fp.readline();
			if record == '':
				break;
			recordP = record.split(',');
			algo = recordP[0];
			nmae = recordP[7];
			if algo in resultHash:
				resultHash[algo] = resultHash[algo] + (float)(nmae);
			else:
				resultHash[algo] = (float)(nmae);
		fp.close();

	for algo in resultHash:
		fpO.write((str)(algo) + ' ' + (str)(resultHash[algo]/runs) + "\n");
	
	fpO.close();
	i = i + 0.1;



