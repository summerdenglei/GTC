function wrapperSRMFWeekly(inputFile)
  r = 5; % Rank
  XY = load(inputFile);
	M = ones(size(XY));
	[r c] = size(M);
	M(:,c) = 0;
%	T = sparse(c-2,c);
%	for i=1:(c-2)
%		T(i,i) = 1;
%		T(i,i+1) = -2;
%		T(i,i+2) = 1;
%	end
	T = sparse(c-24*7,c);
	for i=1:(c-24*7)
		T(i,i) = 1;
		T(i,i+24*7) = -1;
	end
	Cons{2} = T;

	% Main call to SRMF
  [U,V,obj,iter] = SRMF(XY,r,M,Cons);

	approximatedXY = U*V';

	X = XY(1:r/2,:);
	Y = XY(r/2+1:r,:);
	approximatedX = approximatedXY(1:r/2,:);
	approximatedY = approximatedXY(r/2+1:r,:);

	E = ((X(:,c) - approximatedX(:,c)).^2 + (Y(:,c) - approximatedY(:,c)).^2).^0.5;

	output_err_file = strcat(inputFile,'_err');
	dlmwrite(output_err_file,E, ' ');

	actual_loc_file = strcat(inputFile,'_actual_locs');
	dlmwrite(actual_loc_file,XY(:,c), ' ');
	
	approx_loc_file = strcat(inputFile,'_approx_locs');
	dlmwrite(approx_loc_file,approximatedXY(:,c), ' ');
	
	abs(approximatedXY - XY)

end
