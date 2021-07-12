function detectAnomalyLastWeek
	inputFile = '/v/filer4b/v24q005/gene/socialTM/GWL_DailyTMs/GWL_Daily_Austin';
	history = 7;
  I = load(inputFile);
	[row col] = size(I)

	ratio = zeros(col,1);
	difference = zeros(col,1);
	anomaly_indicator = zeros(col,1);
	for ii=1+history:col

		XY = I(:,ii);
		approximatedXY = I(:,ii-history);
		ratio_snap = sum(sum(XY))/sum(sum(approximatedXY));
		difference_snap = abs(sum(sum(XY)) - sum(sum(approximatedXY)));
		if ratio_snap > 3 && difference_snap > 50 || ratio_snap < 0.33 && difference_snap > 50
			ii
			anomaly_indicator(ii) = 1;
			I(:,ii) = I(:,ii-history);
		end
		ratio(ii) = ratio_snap;
		difference(ii) = difference_snap;
	end
dlmwrite('Ratio_lastweek',ratio', ' ');
dlmwrite('Difference_lastweek',difference',' ')
anomaly_indicator'

end
