function [X,Y] = nmf(A,r,M,metric,MaxIter,lambda)
%
% [X,Y] = NMF(A,r,M,metric,MaxIter,lambda) performs nonnegative matrix 
% factorization. Specifically, it factors nonnegative matrix A into X*Y' 
% to minimize distance(X*Y'-A) subject to the constraint that X and Y 
% are nonnegative, where X and Y both have r columns.  
% The optional parameter M specifies whether any data in A is missing.
% Specifically, if M(i,j) = 0, it means A(i,j) is missing.  if M(i,j) is
% 1, it means A(i,j) is available.  The distance metric is either 
% L2-norm or KL-divergence 
%
% Input:
%
%    A:        input matrix
%
%    r:        number of columns in X and Y
%
%    M:        specifies whether any data in A is missing
%              Specifically, if M(i,j) = 0, it means A(i,j) is missing.  
%              if M(i,j) is 1, it means A(i,j) is available.
%
%    metric:   'L2' => L2-norm is used; 'KL' => KL-divergence is used
%              (default: 'L2')
%
%    MaxIter:  max number of iterations (default: 500, which seems more
%              than enough.
%
%    lambda:   regularization parameter.  we will minimize
%
%                | (X*Y'-A).*M |_2^2 + lambda * (|U|_2^2 + |V|_2^2)
%
%              or
%                 
%                KL((X*Y').*M, A.*M) + KL(lambda*U,0) + KL(lambda*V,0)
%
% Output:
%
%   [X,Y]:     X*Y' is the desired rank-r approximation
%
% Reference:
%
%    Daniel D. Lee and H. Sebastian Seung
%    Algorithms for non-negative matrix factorization
%    Proc. Neural Information Processing Systems (NIPS), pp. 556-562, 2000.
%
%    Yun Mao, Lawrence K. Saul
%    Modeling Distances in Large-Scale Networks by Matrix Factorization
%    Proc. Internet Measurement Conference (IMC), pp. 278-287, 2004.
%
% file:      	nmf.m
% directory:   /export/home/yzhang/SpatTemp/src/SpatTemp/
% created: 	Fri Dec 10 2004 
% author:  	Yin Zhang 
% email:   	yzhang@research.att.com
%

  if nargin < 3, M = ones(size(A)); end
  if nargin < 4, metric = 'L2';     end
  if nargin < 5, MaxIter = 4000;    end
  if nargin < 6, lambda = 0;        end
  
  EPS = 1e-10;
  
  % initalization (shall we do it deterministically to get repeatable results?)
  [m,n] = size(A);
  X     = abs(randn(m,r));
  Y     = abs(randn(n,r));
  
  % Just in case user doesn't pass in a 0/1 matrix
  M(M~=0) = 1;
  A(M==0) = 0;
  AM      = A.*M;

  % updates
  for iter = 1:MaxIter

    % this improves speed as Matlab becomes very slow
    % when too many elements become too small
    X = max(EPS,X);
    Y = max(EPS,Y);
    
    switch(lower(metric))
     case {'l2'}
      X = X .* (AM*Y) ./ (EPS+((X*Y').*M)*Y+lambda*X);
      Y = Y .* (AM'*X) ./ (EPS+((Y*X').*M')*X+lambda*Y);
     case {'kl'}
      X = X .* (AM./(EPS+X*Y')*Y) ./ repmat(EPS+lambda+sum(Y,1),m,1);
      Y = Y .* (AM'./(EPS+Y*X')*X) ./ repmat(EPS+lambda+sum(X,1),n,1);
    end
    [X,Y] = normalize(X,Y);

  end

function [X,Y] = normalize(X,Y)

  r  = size(X,2);
  x2 = sqrt(sum(X.^2,1));
  y2 = sqrt(sum(Y.^2,1));
  s  = sqrt(x2.*y2);

  for i = 1:r
    if (s(i) == 0)
      X(:,i) = 0;
      Y(:,i) = 0;
    else
      X(:,i) = X(:,i)*(s(i)/x2(i));
      Y(:,i) = Y(:,i)*(s(i)/y2(i));
    end
  end

  % ensure diag(S) is in descending order
  [s,idx] = sort(s,'descend');
  X       = X(:,idx);
  Y       = Y(:,idx);  
