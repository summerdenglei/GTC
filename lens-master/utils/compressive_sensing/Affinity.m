function A = Affinity(X,Option,k,zdiag)
%
% A = AFFINITY(X,Option,k) generates a m-by-m affinity matrix from an
% n-by-m input matrix X using given Option.   Each column of X is viewed
% as a n-dimensional data point.
%
% file:        Affinity.m
% directory:   /u/yzhang/MRA/Wavelet/
% created:     Sun Nov 30 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  m = size(X,2);
  k = min(m-1,k);

  Symmetric = true;
  NonNeg    = true;  
  switch(lower(Option))
   case {lower('Gaussian')}
    A = GaussianAffinity(X,k);
   case {lower('GlobalGaussian')} 
    A = GlobalGaussianAffinity(X,k);
   case {lower('AdaptiveGaussian')}
    A = AdaptiveGaussianAffinity(X,k);
   case {lower('KNN')}
    A = KNNAffinity(X,k);
   case {lower('DirectedKNN')}
    Symmetric = false;
    A = DirectedKNNAffinity(X,k);
   case {lower('MutualKNN')}
    A = MutualKNNAffinity(X,k);
   case {lower('Epsilon')}
    A = EpsilonAffinity(X,k);
   case {lower('LLE')}
    NonNeg    = false;
    Symmetric = false;
    A = LocalLinearEmbedAffinity(X,k);
   case {lower('Regression')}
    NonNeg    = false;
    Symmetric = false;
    A = RegressionAffinity(X,k);
   case {lower('Cosine')}
    A = CosineAffinity(X,k);
   case {lower('InnerProduct')}
    A = InnerProductAffinity(X,k);
   case {lower('Jaccard')}
    A = JaccardAffinity(X,k);
   case {lower('Correlation')}
    A = CorrelationAffinity(X,k);
   case {lower('Harmonic')}
    A = HarmonicAffinity(X,k);
  end

  % reset the diagonal
  %if (zdiag)
    A(1:m+1:end) = 0;
  %end
  
  % reset small elements to 0
  if (NonNeg)
    A(A<eps) = 0;
  end
  
  % make A symmetric
  if (Symmetric)
    A = (A+A')/2;
  end
  
%-------------------------------------------------------
% utility functions
%-------------------------------------------------------
function D = GetPairwiseDistance(X)

  [n,m] = size(X);
  if (~any(isnan(X(:))))
    X2 = repmat(sum(X.^2,1),m,1);
    D  = sqrt(max(0,X2+X2'-2*X'*X));
    return
  end
  
  % D(i,j) = |X(:,i)-X(:,j)|_2^2
  D = zeros(m,m);
  for i = 2:m
    % the following code automatically copes with missing values
    J = 1:(i-1);
    dX = X(:,J) - repmat(X(:,i),1,(i-1));
    nn = isnan(dX);
    nnn = sum(nn,1);
    dX(nn) = 0;
    DiJ = sqrt(sum(dX.^2,1)./(1-nnn/n));
    D(i,J) = DiJ;
    D(J,i) = DiJ;
  end

  D(isnan(D)) = inf;
  
function A = GaussianAffinity(X,k)

  [n,m] = size(X);
  D = GetPairwiseDistance(X);

  % automatically search for sigma such that average degree is k (excluding self)
  Dvec = D((D>0) & (D<inf));
  k = min(length(Dvec))/m/2;
  sfun = @(sigma) sum(exp(-Dvec.^2/(sigma^2))) - m*k;
  % smax and smin ensures that sfun(smax) > 0, sfun(smin) < 0
  smax = 1;
  while (sfun(smax) < 0)
    smax = smax*2;
  end
  smin = eps;
  sigma = fzero(sfun,[smin smax]);

  A = exp(-D.^2./(sigma^2));

function A = AdaptiveGaussianAffinity(X,k)

  D = GetPairwiseDistance(X);  
  Ds = D;
  Ds(Ds==0) = inf;
  Ds = sort(Ds);
  sigma = Ds(k,:);
  
  % A(i,j) = exp(-D(i,j)^2/(sigma(i)*sigma(j)))
  A = exp(-D.^2./(sigma'*sigma));

%  
% reference:
%     A unifying theorem for spectral embedding and clustering
%     by Matthev Br, Kun Huang
%     http://research.microsoft.com/conferences/AIStats2003/proceedings/189.ps 
%
function A = GlobalGaussianAffinity(X,k)

  D = GetPairwiseDistance(X);  
  Ds = D;
  Ds(Ds==0) = inf;
  Ds = sort(Ds);
  sigma = mean(Ds(2,:));
  
  % A(i,j) = exp(-D(i,j)^2/(2*sigma^2))
  A = exp(-D.^2/(2*sigma^2));
  
function A = KNNAffinity(X,k)
  
  [n,m] = size(X);
  D = GetPairwiseDistance(X);

  A = zeros(m,m);
  for i = 1:m
    % find k nearest neighbors (excluding i itself)
    D(i,i) = inf;
    [di,idx] = sort(D(i,:));
    A(i,idx(1:k)) = 1;
  end
  % retain edge (i,j) when either A(i,j) = 1 or A(j,i) = 1
  A = max(A,A');
  
function A = DirectedKNNAffinity(X,k)
  
  [n,m] = size(X);
  D = GetPairwiseDistance(X);

  A = zeros(m,m);
  for i = 1:m
    % find k nearest neighbors (excluding i itself)
    D(i,i) = inf;
    [di,idx] = sort(D(i,:));
    A(i,idx(1:k)) = 1;
  end
  
  A(isinf(D)) = 0;
  
function A = MutualKNNAffinity(X,k)
  
  [n,m] = size(X);
  D = GetPairwiseDistance(X);

  A = zeros(m,m);
  for i = 1:m
    % find k nearest neighbors (excluding i itself)
    D(i,i) = inf;
    [di,idx] = sort(D(i,:));
    A(i,idx(1:k)) = 1;
  end
  % retain edge (i,j) when both A(i,j) = 1 and A(j,i) = 1
  A = min(A,A');
  
function A = EpsilonAffinity(X,k)

  [n,m] = size(X);
  D = GetPairwiseDistance(X);
  
  % automatically search for epsilon such that average degree is k (excluding self)
  Dvec = sort(D(D>0));
  epsilon = Dvec(k*m);
  A = zeros(m,m);
  A(D<epsilon) = 1;
  
% Harmonic potential
function A = HarmonicAffinity(X,k)

  [n,m] = size(X);
  D = GetPairwiseDistance(X);

  % automatically search for a such that average degree is k
  Dvec = D(D>0);
  afun = @(a) sum(1./(1+a*Dvec)) - m*k;
  amin = 0;
  amax = 1;
  while(afun(amax) > 0)
    amax = amax*2;
  end
  a = fzero(afun,[amin amax]);

  A = 1./(1 + a*D);
  
% only works for nonnegative X  
function A = CosineAffinity(X,k)

  [n,m] = size(X);

  if (~any(isnan(X(:))))
    X2 = repmat(sum(X.^2,1),m,1);
    XX = X'*X;
    A  = XX./sqrt(X2.*X2');
    A(isnan(A)) = 0;
    return
  end
  
  A = zeros(m,m);
  for i = 2:m
    % the following code automatically copes with missing values
    J = 1:(i-1);
    xi = repmat(X(:,i),1,(i-1));
    xJ = X(:,J);
    nn = (isnan(xi) | isnan(xJ));
    xi(nn) = 0;
    xJ(nn) = 0;
    A(i,J) = sum(xi.*xJ,1)./sqrt(sum(xi.^2,1).*sum(xJ.^2,1));
    A(J,i) = A(i,J);
  end
  
  A(isnan(A)) = 0;
  
% only works for nonnegative X  
function A = InnerProductAffinity(X,k)

  A = X'*X;
  
% only works for nonnegative X  
function A = JaccardAffinity(X,k)

  [n,m] = size(X);

  if (~any(isnan(X(:))))
    X2 = repmat(sum(X.^2,1),m,1);
    XX = X'*X;
    A  = XX./max(0,X2+X2'-XX);
    A(isnan(A)) = 0;
    return
  end
  
  A = zeros(m,m);
  for i = 2:m
    % the following code automatically copes with missing values
    J = 1:(i-1);
    xi = repmat(X(:,i),1,(i-1));
    xJ = X(:,J);
    nn = (isnan(xi) | isnan(xJ));
    xi(nn) = 0;
    xJ(nn) = 0;
    A(i,J) = sum(xi.*xJ,1)./max(0,sum(xi.^2+xJ.^2-xi.*xJ,1));
    A(J,i) = A(i,J);
  end
  
  A(isnan(A)) = 0;
  
% Pearson's correlation coefficient normalized to [0,1]  
function A = CorrelationAffinity(X,k)

  [n,m] = size(X);

  if (~any(isnan(X(:))))
    Xavg = repmat(mean(X,1),n,1);
  else
    Y = X;
    Y(isnan(Y)) = 0;
    Xavg = repmat(sum(Y,1)./sum(~isnan(X),1),n,1);
    Xavg(isnan(Xavg)) = 0;
  end
  
  A = Affinity(X-Xavg,'Cosine',k);

%  
% Reconstruction weights in Local Linear Embedding (LLE)
% Reference: http://www.cs.toronto.edu/~roweis/lle/algorithm.html
%
function A = LocalLinearEmbedAffinity(X,k)

  [n,m] = size(X);

  % first get the k-nearest neighbors w.r.t. Cosine similarity
  S  = Affinity(X,'Cosine',k);
  for j = 1:m
    [sj,ij] = sort(S(j,:),'descend');
    S(j,ij(k+1:end)) = 0;
  end
  N  = spones(S);
  Nt = N';
  
  % solve for reconstruction weights A
  A = sparse(m,m);
  EPS = 1e-3;
  for i = 1:m
    Xi = X(:,i);
    nbrs = find(Nt(:,i));
    nn   = length(nbrs);
    Z = X(:,nbrs);
    Z = Z - repmat(Xi,1,nn);
    C = Z'*Z;
    C = C + max(eps,EPS*trace(C)/nn)*speye(nn);
    w = C\ones(nn,1);
    A(i,nbrs) = w/sum(w);
  end



function A = RegressionAffinity(X,k)

  [n,m] = size(X);

  % first get the k-nearest neighbors w.r.t. Cosine similarity
  S  = Affinity(X,'Cosine',k);
  for j = 1:m
    [sj,ij] = sort(S(j,:),'descend');
    S(j,ij(k+1:end)) = 0;
  end
  N  = spones(S);
  Nt = N';
  
  % solve for reconstruction weights A
  A = sparse(m,m);
  EPS = 1e-3;
  for i = 1:m
    Xi = X(:,i);
    nbrs = find(Nt(:,i));
    nn   = length(nbrs);
    Z    = X(:,nbrs);
    C    = Z'*Z;
    d    = Z'*Xi;
    C    = C + max(eps,EPS*trace(C)/nn)*speye(nn);
    w    = C\d;
    A(i,nbrs) = w;
  end



