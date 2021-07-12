function wrapperSRMFSocialTM(inputFile,n)
  r = 5; % Rank
  XY = load(inputFile);
	XY = XY(1:30,:);
	M = ones(size(XY));
	[r c] = size(M);
%	T = sparse(c-2,c);
%	for i=1:(c-2)
%		T(i,i) = 1;
%		T(i,i+1) = -2;
%		T(i,i+2) = 1;
%	end
	T = sparse(c-n,c);
	for i=1:(c-n)
		T(i,i) = 1;
		T(i,i+n) = -1;
	end
	Cons{2} = T;

	%M(:,c) = 0;

	M = rand(size(M))<0.8;
	% Main call to SRMF
  [U,V,obj,iter] = SRMF(XY,r,M,Cons);

	approximatedXY = U*V';


%	output_err_file = strcat(inputFile,'_',num2str(n),'_err');
%	dlmwrite(output_err_file,E, ' ');

%	actual_loc_file = strcat(inputFile,'_',num2str(n),'_actual_traffic');
%	dlmwrite(actual_loc_file,XY.*(1-M), ' ');
	
%	approx_loc_file = strcat(inputFile,'_',num2str(n),'_approx_traffic');
%	dlmwrite(approx_loc_file,approximatedXY.*(1-M), ' ');
	
	abs(approximatedXY - XY).*(1-M)
	approximatedXY.*(1-M)
	XY

	NAME = sum(sum(abs(approximatedXY - XY).*(1-M)))/sum(sum(XY.*(1-M))) 
end
