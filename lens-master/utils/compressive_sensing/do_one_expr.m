function [] = do_one_expr(X,N,Seed,Dim,Rank,LossRate,lambda,odir,dataset)

addpath /u/yzhang/MRA/Matlab;

rand('state',Seed);
randn('state',Seed);

if (Dim == 2)
  X = reshape(X,N*N,[]);
elseif (Dim == 3)
  X = reshape(X,N,N,[]);
end

meanX2 = mean(X(:).^2);
meanX = mean(X(:));

sx = size(X);
nx = prod(sx);
n  = length(sx);

%M = DropValues(N,N,sx(n),0.5,LossRate,'elem','half');
M = DropValues(N,N,sx(n),1,LossRate,'elem','ind');
M = reshape(M,sx);
%M = ones(size(X));
%M = rand(size(M))<0.9;
%M
[A,b] = XM2Ab(X,M);
BaseX = EstimateBaseline(A,b,sx);
err_base = mean((X(~M)-max(0,BaseX(~M))).^2)/meanX2
mad_base = mean(abs((X(~M)-max(0,BaseX(~M)))))/meanX
cc_base = corrcoef(X(~M),max(0,BaseX(~M)))

K = Rank;
Cons = ConfigSRTF(A,b,X,M,sx,Rank,K,lambda,true);
[u4,v4,w4] = SRTF(X,Rank,M,Cons,10,1e-1,50);
Z = tensorprod(u4,v4,w4);
Z(M==1) = X(M==1);
Z = max(0,Z);
Z_srmf = Z;
err_srmf = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_srmf = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_srmf = corrcoef(X(~M),max(0,Z(~M)))

%
% SRMF + KNN
%
Z = Z_srmf;
maxDist = 3;
EPS = 1e-3;
for i = 1:sx(1)
  for j = find(M(i,:) == 0);
    ind = find((M(i,:)==1) & (abs((1:sx(n)) - j) <= maxDist));
    if (~isempty(ind))
      Y  = Z_srmf(:,ind);
      C  = Y'*Y;
      nc = size(C,1);
      C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
      w  = C\(Y'*Z_srmf(:,j));
      w  = reshape(w,1,nc);
      Z(i,j) = sum(X(i,ind).*w);
    end
  end
end
X
Z
M
err_srmf_knn = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_srmf_knn = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_srmf_knn = corrcoef(X(~M),max(0,Z(~M)))

Z = InterpKNN(X,M,n:-1:1,Rank);
Z(M==1) = X(M==1);
Z = max(0,Z);
err_knn = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_knn = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_knn = corrcoef(X(~M),max(0,Z(~M)))

[u,v,w] = ntf(X,Rank,M,'L2',200,lambda);
Z = tensorprod(u,v,w);
Z(M==1) = X(M==1);
Z = max(0,Z);
Z_nmf = Z;
err_nmf = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_nmf = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_nmf = corrcoef(X(~M),max(0,Z(~M)))

[u,v,w] = FactTensorACLS(X,Rank,M,false,lambda,50,1e-8,0);
Z = tensorprod(u,v,w);
Z(M==1) = X(M==1);
Z = max(0,Z);
err_svd = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_svd = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_svd = corrcoef(X(~M),max(0,Z(~M)))

[u,v,w] = FactTensorACLS(X-BaseX,Rank,M,false,lambda,50,1e-8,0);
Z = tensorprod(u,v,w) + BaseX;
Z(M==1) = X(M==1);
Z = max(0,Z);
err_svd_base = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_svd_base = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_svd_base = corrcoef(X(~M),max(0,Z(~M)))
Z_svd_base = Z;

%
% SVD-base + KNN (has to immediately follow SVD-base
%
Z = Z_svd_base;
maxDist = 3;
EPS = 1e-3;
for i = 1:sx(1)
  for j = find(M(i,:) == 0);
    ind = find((M(i,:)==1) & (abs((1:sx(n)) - j) <= maxDist));
    if (~isempty(ind))
      Y  = Z_svd_base(:,ind);
      C  = Y'*Y;
      nc = size(C,1);
      C  = C + max(eps,EPS*trace(C)/nc)*speye(nc);
      w  = C\(Y'*Z_svd_base(:,j));
      w  = reshape(w,1,nc);
      Z(i,j) = sum(X(i,ind).*w);
    end
  end
end
err_svd_base_knn = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_svd_base_knn = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_svd_base_knn = corrcoef(X(~M),max(0,Z(~M)))

NormalizedMSE = zeros(8,1);
NormalizedMSE(1) = err_srmf;
NormalizedMSE(2) = err_srmf_knn;
NormalizedMSE(3) = err_nmf;
NormalizedMSE(4) = err_base;
NormalizedMSE(5) = err_svd;
NormalizedMSE(6) = err_svd_base;
NormalizedMSE(7) = err_knn;
NormalizedMSE(8) = err_svd_base_knn;

NormalizedMAD = zeros(8,1);
NormalizedMAD(1) = mad_srmf;
NormalizedMAD(2) = mad_srmf_knn;
NormalizedMAD(3) = mad_nmf;
NormalizedMAD(4) = mad_base;
NormalizedMAD(5) = mad_svd;
NormalizedMAD(6) = mad_svd_base;
NormalizedMAD(7) = mad_knn;
NormalizedMAD(8) = mad_svd_base_knn;

CorrCoef = zeros(8,1);
CorrCoef(1) = cc_srmf(1,2);
CorrCoef(2) = cc_srmf_knn(1,2);
CorrCoef(3) = cc_nmf(1,2);
CorrCoef(4) = cc_base(1,2);
CorrCoef(5) = cc_svd(1,2);
CorrCoef(6) = cc_svd_base(1,2);
CorrCoef(7) = cc_knn(1,2);
CorrCoef(8) = cc_svd_base_knn(1,2);

Algo = {'SRMF', 'SRMF_KNN_3', 'NMF', 'Base', 'SVD', 'SVD_base', 'KNN', 'SVD_base_KNN_3'};

NormalizedRMSE = sqrt(NormalizedMSE*meanX2)/meanX;

ofile = sprintf('%s/%s-dim%d-rank%d-loss%.2g-seed%d-lambda%.4g.csv', ...
                odir, dataset, Dim, Rank, LossRate, Seed, lambda);
fd = fopen(ofile,'w');
fprintf(fd,'# Format: Algorithm,Dim,Rank,LossRate,Seed,lambda,NormalizedMSE,NormalizedMAD,NormalizedRMSE,CorrCoef\n');
for i = 1:length(Algo)
  fprintf(fd,'%s,%d,%d,%.3g,%d,%.4g,%.6f,%.6f,%.6f,%.6f\n', ...
          Algo{i}, Dim, Rank, LossRate, Seed, lambda, ...
          NormalizedMSE(i), NormalizedMAD(i), NormalizedRMSE(i), CorrCoef(i));
end
fclose(fd);


