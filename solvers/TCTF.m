function [ TC,psnr ] = TCTF( X,Omega )

%% produce data
data=X(Omega);
known=Omega;
[n1,n2,n3]=size(X);

%% our method 
opts = [];
opts.maxIter=150;
opts.tol = -1e-5; % run to maxit by using negative tolerance
opts.Mtr = X; % pass the true tensor to calculate the fitting
opts.alpha_adj = 0;
opts.rank_adj = -1*ones(1,n3);
opts.rank_inc = 1*ones(1,n3);
opts.rank_min = [25,5,5];
opts.rank_max = [50,20,20];

EstCoreNway = round(30*ones(1,n3));
Nway=[n1,n2,n3];
[~,~,TC,~,~] = TCTF_solver(data,known,Nway,EstCoreNway,opts);

%% compute PSNR
maxP=max(X(:));
TC = max(TC,0);
TC = min(TC,maxP);

psnr= PSNR(X,TC,maxP);

end

