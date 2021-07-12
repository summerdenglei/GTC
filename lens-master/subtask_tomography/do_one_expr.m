function [] = do_one_expr(A,B,X,N,Seed,Dim,Rank,LossRate,lambda,odir,dataset)

addpath ../Matlab;

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

M = DropValues(N,N,sx(n),1,LossRate,'elem','ind');
M = reshape(M,sx);

% we already have a good spatial model A*X=B, so there
% is no need to infer it ourselves.
[C1,d1] = AB2Cd(A,B);
[C2,d2] = XM2Ab(X,M);
C = [C1;C2];
d = [d1;d2];
BaseX = EstimateBaseline(C,d,sx);
BaseX(M==1) = X(M==1);
BaseX = max(0,BaseX);
err_base = mean((X(~M)-max(0,BaseX(~M))).^2)/meanX2
mad_base = mean(abs((X(~M)-max(0,BaseX(~M)))))/meanX
cc_base = corrcoef(X(~M),max(0,BaseX(~M)))

[u,v] = SRMF2(A,B,X,Rank,M,cell(1,n),1,lambda,50);
Z = tensorprod(u,v);
Z(M==1) = X(M==1);
Z = max(0,Z);
Z_srmf = Z;
err_srmf = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_srmf = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_srmf = corrcoef(X(~M),max(0,Z(~M)))

% gravity solutions
Z = zeros(N*N,sx(n));
for i = 1:sx(n)
  xi = reshape(X(:,i),N,N);
  Z(:,i) = reshape(sum(xi,2)*sum(xi,1)/sum(sum(xi)),[],1);
end
Z(M==1) = X(M==1);
Z = max(0,Z);
err_gvt = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_gvt = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_gvt = corrcoef(X(~M),max(0,Z(~M)))
Z_gvt = Z;

% tomogravity solutions
addpath ../TrafficMatrix
Z = zeros(N*N,sx(n));
for i = 1:sx(n)
  idx = find(M(:,i));
  Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
  Ai = [A;Mi];
  Bi = [B(:,i); X(idx,i)];
  Z(:,i) = entsolve(Ai,Z_gvt(:,i),Bi,lambda);
end
Z(M==1) = X(M==1);
Z = max(0,Z);
Z_tg = Z;
err_tg = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_tg = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_tg = corrcoef(X(~M),max(0,Z(~M)))

%
% SRMF + tomogravity
%
Z = zeros(N*N,sx(n));
for i = 1:sx(n)
  idx = find(M(:,i));
  Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
  Ai = [A;Mi];
  Bi = [B(:,i); X(idx,i)];
  Z(:,i) = entsolve(Ai,Z_srmf(:,i),Bi,lambda);
end
Z(M==1) = X(M==1);
Z = max(0,Z);
err_tg_srmf = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_tg_srmf = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_tg_srmf = corrcoef(X(~M),max(0,Z(~M)))

%
% SRMF + base
%
Z = zeros(N*N,sx(n));
for i = 1:sx(n)
  idx = find(M(:,i));
  Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
  Ai = [A;Mi];
  Bi = [B(:,i); X(idx,i)];
  Z(:,i) = entsolve(Ai,BaseX(:,i),Bi,lambda);
end
Z(M==1) = X(M==1);
Z = max(0,Z);
err_tg_base = mean((X(~M)-max(0,Z(~M))).^2)/meanX2
mad_tg_base = mean(abs((X(~M)-max(0,Z(~M)))))/meanX
cc_tg_base = corrcoef(X(~M),max(0,Z(~M)))

NormalizedMSE = zeros(6,1);
NormalizedMSE(1) = err_srmf;
NormalizedMSE(2) = err_gvt;
NormalizedMSE(3) = err_base;
NormalizedMSE(4) = err_tg;
NormalizedMSE(5) = err_tg_srmf;
NormalizedMSE(6) = err_tg_base;

NormalizedMAD = zeros(6,1);
NormalizedMAD(1) = mad_srmf;
NormalizedMAD(2) = mad_gvt;
NormalizedMAD(3) = mad_base;
NormalizedMAD(4) = mad_tg;
NormalizedMAD(5) = mad_tg_srmf;
NormalizedMAD(6) = mad_tg_base;

CorrCoef = zeros(6,1);
CorrCoef(1) = cc_srmf(1,2);
CorrCoef(2) = cc_gvt(1,2);
CorrCoef(3) = cc_base(1,2);
CorrCoef(4) = cc_tg(1,2);
CorrCoef(5) = cc_tg_srmf(1,2);
CorrCoef(6) = cc_tg_base(1,2);
CorrCoef(isnan(CorrCoef)) = 0;

Algo = {'SRMF', 'Gravity', 'Base', 'Tomo-Gravity', 'Tomo-SRMF', 'Tomo-Base'};

NormalizedRMSE = sqrt(NormalizedMSE*meanX2)/meanX;

ofile = sprintf('%s/%s-dim%d-rank%d-loss%.4g-seed%d-lambda%.5g.csv', ...
                odir, dataset, Dim, Rank, LossRate, Seed, lambda);
fd = fopen(ofile,'w');
fprintf(fd,'# Format: Algorithm,Dim,Rank,LossRate,Seed,lambda,NormalizedMSE,NormalizedMAD,NormalizedRMSE,CorrCoef\n');
for i = 1:length(Algo)
  fprintf(fd,'%s,%d,%d,%.5g,%d,%.4g,%.6f,%.6f,%.6f,%.6f\n', ...
          Algo{i}, Dim, Rank, LossRate, Seed, lambda, ...
          NormalizedMSE(i), NormalizedMAD(i), NormalizedRMSE(i), CorrCoef(i));
end
fclose(fd);


