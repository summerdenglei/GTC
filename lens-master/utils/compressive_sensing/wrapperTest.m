function wrapperSRMFSocialTM(inputFile)
  rank = 5; % Rank
%	aggregationValue = 1;
  XY = load(inputFile);
	[row col] = size(XY);
%	temp = reshape(XY, aggregationValue, col * row / aggregationValue);
%	temp = sum(temp);
%	XY = reshape(temp,row, col/aggregationValue);
%	[row col] = size(XY);
XY = XY(1:324,:);
%	XY(row+1:900,:) = 0;
%	XY = XY(1:121,:);
	i = 0.5;
	j = 1;
%	for i=0.1:0.1:1
%		for j=1:10
			do_one_expr(XY,18,j,2,rank,i,0.1,'/v/filer4b/v24q005/swati/mobility_prediction_srmf/Test','daily');
%		end
%	end
end
