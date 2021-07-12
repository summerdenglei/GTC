function wrapperSRMFSocialTM(inputFile)
  r = 5; % Rank
%	aggregationValue = 1;
  XY = load(inputFile);
	[row col] = size(XY);
%	temp = reshape(XY, aggregationValue, col * row / aggregationValue);
%	temp = sum(temp);
%	XY = reshape(temp,row, col/aggregationValue);
%	[row col] = size(XY);
	XY(row+1:900,:) = 0;
	
	for i=0.1:0.1:1
		for j=1:5
			do_one_expr(XY,30,j,2,r,i,0.1,'/v/filer4b/v24q005/swati/mobility_prediction_srmf/Weekly','Weekly');
		end
	end
end
