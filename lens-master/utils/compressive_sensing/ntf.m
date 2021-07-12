function [X,Y,Z] = ntf(A,r,M,metric,MaxIter,lambda)
%
% [X,Y,Z] = NTF(A,r,M,metric,MaxIter,lambda) performs nonnegative tensor
% factorization. Specifically, it factors nonnegative tensor A into tensorprod(X,Y,Z)
% to minimize distance(tensorprod(X,Y,Z)-A) subject to the constraint that X, Y, Z
% are nonnegative, where X, Y, Z all have columns.  
% The optional parameter M specifies whether any data in A is missing.
% Specifically, if M(i,j,k) = 0, it means A(i,j,k) is missing.  if M(i,j,k) is
% 1, it means A(i,j,k) is available.  The distance metric is either 
% L2-norm or KL-divergence 
%
% Input:
%
%    A:        input matrix
%
%    r:        number of columns in X, Y, Z
%
%    M:        specifies whether any data in A is missing
%              Specifically, if M(i,j) = 0, it means A(i,j) is missing.  
%              if M(i,j) is 1, it means A(i,j) is available.
%
%    metric:   'L2' => L2-norm is used; 'KL' => KL-divergence is used
%              (default: 'L2')
%
%    MaxIter:  max number of iterations (default: 4000, which seems more
%              than enough.
%              
%    lambda:   regularization parameter.  Let J = lambda^(1/2)*I, then
%              we try to minimize either 
%
%                | (tensorprod(X,Y,Z)-A).*M |_2^2 + lambda * (|U|_2^2 + |V|_2^2)
%
%              or
%
%                KL(tensorprod(X,Y,Z).*M, A.*M) + KL(lambda*U,0) + KL(lambda*V,0)
%
% Output:
%
%   [X,Y,Z]:   tensorprod(X,Y,Z) is the desired rank-r approximation
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
% file:      	ntf.m
% directory:   /export/home/yzhang/SpatTemp/src/SpatTemp/
% created: 	Fri Dec 10 2004 
% author:  	Yin Zhang 
% email:   	yzhang@research.att.com
%

  if nargin < 3, M = ones(size(A)); end
  if nargin < 4, metric = 'L2';     end
  if nargin < 5, MaxIter = 4000;    end
  if nargin < 6, lambda = 0;        end
  
  sa = size(A);
  if (length(sa) < 3)
    [X,Y] = nmf(A,r,M,metric,MaxIter);
    Z = ones(1,r);
    return
  end

  EPS = 1e-10;
  
  na = prod(sa);
  nx = sa(1);
  ny = sa(2);
  nz = sa(3);
  
  X  = abs(randn(nx,r));
  Y  = abs(randn(ny,r));
  Z  = abs(randn(nz,r));
  
  % Just in case user doesn't pass in a 0/1 matrix
  M(M~=0) = 1;
  A(M==0) = 0;
  AM      = A.*M;
  
  % create reshaped version of AM and M
  AMz = reshape(AM,na/nz,nz);
  AMx = reshape(shiftdim(AM,1),na/nx,nx);
  AMy = reshape(shiftdim(AM,2),na/ny,ny);
  Mz = reshape(M,na/nz,nz);
  Mx = reshape(shiftdim(M,1),na/nx,nx);
  My = reshape(shiftdim(M,2),na/ny,ny);
  
  % updates
  for iter = 1:MaxIter

    % this improves speed as Matlab becomes very slow
    % when too many elements become too small
    X = max(EPS,X);
    Y = max(EPS,Y);
    Z = max(EPS,Z);
    
    switch(lower(metric))
     case {'l2'}
      P = prodfcn(Y,Z);
      X = X .* (AMx'*P)./(EPS+((X*P').*Mx')*P+lambda*X);
      P = prodfcn(Z,X);
      Y = Y .* (AMy'*P)./(EPS+((Y*P').*My')*P+lambda*Y);
      P = prodfcn(X,Y);
      Z = Z .* (AMz'*P)./(EPS+((Z*P').*Mz')*P+lambda*Z);
     case {'kl'}
      P = prodfcn(Y,Z);
      X = X .* (AMx'./(EPS+X*P')*P) ./ repmat(EPS+sum(P,1)+lambda,nx,1);
      P = prodfcn(Z,X);
      Y = Y .* (AMy'./(EPS+Y*P')*P) ./ repmat(EPS+sum(P,1)+lambda,ny,1);
      P = prodfcn(X,Y);
      Z = Z .* (AMz'./(EPS+Z*P')*P) ./ repmat(EPS+sum(P,1)+lambda,nz,1);
    end
    [X,Y,Z] = normalize(X,Y,Z);
  end

function [X,Y,Z] = normalize(X,Y,Z)

  r  = size(X,2);
  x2 = sqrt(sum(X.^2,1));
  y2 = sqrt(sum(Y.^2,1));
  z2 = sqrt(sum(Z.^2,1));
  s  = (x2.*y2.*z2).^(1/3);

  for i = 1:r
    if (s(i) == 0)
      X(:,i) = 0;
      Y(:,i) = 0;
      Z(:,i) = 0;
    else
      X(:,i) = X(:,i)*(s(i)/x2(i));
      Y(:,i) = Y(:,i)*(s(i)/y2(i));
      Z(:,i) = Z(:,i)*(s(i)/z2(i));
    end
  end

  % ensure diag(S) is in descending order
  [s,idx] = sort(s,'descend');
  X       = X(:,idx);
  Y       = Y(:,idx);
  Z       = Z(:,idx);
  

