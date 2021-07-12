function wrapperAnomaly
	inputFile = '/v/filer4b/v24q005/gene/socialTM/GWL_DailyTMs/GWL_Daily_Austin';
  rank = 5; % Rank
	n = 1; % Period
	history = 30;
  I = load(inputFile);
	%I = I(:,1:10);
	[row col] = size(I)

	ratio = zeros(col,1);
	difference = zeros(col,1);
	anomaly_indicator = zeros(col,1);
	for ii=1:col-history
		XY = I(1:row,ii:ii+history);
		size(XY);
		%return
		M = ones(size(XY));
		[r c] = size(M);
		M(:,c) = 0;

		T = zeros(c-n,c);
		for i=1:(c-n)
			T(i,i) = 1;
			T(i,i+n) = -1;
		end
		Cons{2} = T;
		T;
		% Main call to SRMF
		[U,V,obj,iter] = SRMF(XY,rank,M,Cons);

		approximatedXY = U*V';
		approximatedXY = max(0,approximatedXY);
		%nmae_snap = sum(sum(abs(approximatedXY - XY).*(1-M)))/sum(sum(approximatedXY.*(1-M))) 
		ratio_snap = sum(sum(XY.*(1-M)))/sum(sum(approximatedXY.*(1-M)));
		difference_snap = abs(sum(sum(XY.*(1-M))) - sum(sum(approximatedXY.*(1-M))));
		if ratio_snap > 3 && difference_snap > 50 || ratio_snap < 0.33 && difference_snap > 50
			ii
			anomaly_indicator(ii+history) = 1;
			I(:,ii+history) = I(:,ii+history-1);
		end
		ratio(ii+history) = ratio_snap;
		difference(ii+history) = difference_snap;
	end
dlmwrite('Ratio',ratio', ' ');
dlmwrite('Difference',difference',' ')
anomaly_indicator'

end
