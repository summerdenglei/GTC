function wrapperdaily
	%inputFile = '/v/filer4b/v24q005/gene/socialTM/GWL_DailyTMs/GWL_3day';
	%inputFile = '/v/filer4b/v24q005/gene/socialTM/GWL_DailyTMs/ORIGINAL/GWL_Inter_Daily_ORIGINAL';
  inputFile = '/v/filer4b/v24q005/gene/socialTM/GWL_IntraTM/Austin/dailyTM_CLUSTERED/GWL_Intra_Daily_Austin_CLUSTERED';
	rank = 5; % Rank
  XY = load(inputFile);
	[row col] = size(XY);
	%XY(row+1:169,:) = 0;
	XY = XY(1:2500,:);
	%i = 0.3
	%j = 1
	for i=0.1:0.1:1
		for j=1:5
			do_one_expr(XY,50,j,2,rank,i,0.1,'/v/filer4b/v24q005/swati/mobility_prediction_srmf/Zero','Zero');
		end
	end
end
