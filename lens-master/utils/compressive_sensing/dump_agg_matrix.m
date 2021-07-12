function dump_agg_matrix(inputFile)
	aggregationValue = 6;
  XY = load(inputFile);
	XY=XY(:,1:84);
	[row col] = size(XY);
	aggXY = zeros(row, col/aggregationValue);
	for i = 1:row
		pos = 1;
		for j = 1:aggregationValue:col
			aggXY(i,pos) = XY(i,j) + XY(i,j+1) + XY(i,j+2) +  XY(i,j+3) +  XY(i,j+4) +  XY(i,j+5) ;
			pos = pos + 1;
		end
	end
	dlmwrite('../../gene/socialTM/GWL_DailyTMs/GWL_6day',aggXY, ' ');
	return;
end
