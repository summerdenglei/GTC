function [U,V,W,obj,iter] = FactTensorACLS(X,k,M,NonNeg,lambda,MaxIter,Tol,MaxIterNTF)
%
% [U,V,W,obj,iter] = FACTTENSORACLS(X,k,M,NonNeg,lambda,MaxIter,Tol,MaxIterNTF) performs
% alternating constrained least squares to factorize 3-d tensor X
%
%  minimize obj(U,V,W,X) = lambda * (|U|_2^2 + |V|_2^2 + |W|_2^2)
%                          +|(tensorprod(U,V,W)-X).*M|_2^2
%
% Input:
%
%    X:        input tensor
%
%    k:        number of columns in U and V
%
%    M:        specifies whether any data in X is missing
%              Specifically, if M(i,j) = 0, it means X(i,j) is missing.
%              if X(i,j) is 1, it means X(i,j) is available.
%              (default: ones(size(X)))
%
%    NonNeg:   whether enforce nonnegativity constraints: U, V >= 0
%              (default: false)
%
%    lambda:   regularization parameter for U, V, W (default: 0)
%
%    MaxIter:  max number of iterations (default: 1000)
%
%    Tol:      tolerance for convergence (stop when improvement in obj
%              is less than Tol*norm(X.*M,'fro')^2) (default: 1e-10)
%
%    MaxIterNTF: max number of iterations for NTF (default: 1000)
%
% Output:
%
%    U,V,W:    the factor matrices
%
%    obj:      the objective value
%
%    iter:     the number of iterations
%
% file:        FactTensorACLS.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Dec 24 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 3, M = ones(size(X)); end
  if nargin < 4, NonNeg = false;    end
  if nargin < 5, lambda = 1e-3;     end
  if nargin < 6, MaxIter = 50;      end
  if nargin < 7, Tol = 1e-10;       end
  if nargin < 8, MaxIterNTF = 1000; end
  
  M(find(M)) = 1;
  X  = X.*M;
  xn = sum(X(:).^2);

  % get size information
  sx = size(X);
  if (length(sx) > 3)
    error('Can only factorize 3-d tensors');
  elseif (length(sx) < 3)
    [U,V,obj,iter] = FactMatrixACLS(X,k,M,NonNeg,lambda,MaxIter,Tol,MaxIterNTF);
    W = ones(1,k);
    [U,V,W] = normalize(U,V,W);
    return
  end
  nu = sx(1);
  nv = sx(2);
  nw = sx(3);
  
  % initialize U
  if (~NonNeg)
    U = randn(nu,k);
    V = randn(nv,k);
    W = randn(nw,k);
  else
    [U,V,W] = ntf(X,k,M,'l2',MaxIterNTF,lambda);
  end

  Xw = reshape(X,nu*nv,nw);
  Mw = reshape(M,nu*nv,nw);
  Xu = reshape(shiftdim(X,1),nv*nw,nu);
  Mu = reshape(shiftdim(M,1),nv*nw,nu);
  Xv = reshape(shiftdim(X,2),nw*nu,nv);
  Mv = reshape(shiftdim(M,2),nw*nu,nv);
  
  Ik = eye(k,k);
  zu = zeros(k,nu);
  zv = zeros(k,nv);
  zw = zeros(k,nw);
  ou = ones(k,nu);
  ov = ones(k,nv);
  ow = ones(k,nw);

  U_opt = U;
  V_opt = V;
  W_opt = W;
  obj = objfcn(X,M,U,V,W,lambda);
  for iter = 1:MaxIter

    if (lambda)
      % find W that minimizes lambda*|W|_2^2 + |(UV*W'-Xw).*Mw|_2^2
      W = myInverse([prodfcn(U,V);Ik*sqrt(lambda)],[Xw;zw],[Mw;ow],NonNeg)';
      % find U that minimizes lambda*|U|_2^2 + |(VW*U'-Xu).*Mu|_2^2
      U = myInverse([prodfcn(V,W);Ik*sqrt(lambda)],[Xu;zu],[Mu;ou],NonNeg)';
      % find V that minimizes lambda*|V|_2^2 + |(WU*V'-Xv).*Mv|_2^2
      V = myInverse([prodfcn(W,U);Ik*sqrt(lambda)],[Xv;zv],[Mv;ov],NonNeg)';
    else
      % find W that minimizes |(UV*W'-Xw).*Mw|_2^2
      W = myInverse(prodfcn(U,V),Xw,Mw,NonNeg)';
      % find U that minimizes |(VW*U'-Xu).*Mu|_2^2
      U = myInverse(prodfcn(V,W),Xu,Mu,NonNeg)';
      % find V that minimizes |(WU*V'-Xv).*Mv|_2^2
      V = myInverse(prodfcn(W,U),Xv,Mv,NonNeg)';
    end
    
    % normalize U, V, W
    [U,V,W] = normalize(U,V,W);
    
    % update the objective
    ob = objfcn(X,M,U,V,W,lambda);
    if (ob <= obj)
      U_opt = U;
      V_opt = V;
      W_opt = W;
    end
    delta = abs(obj - ob);
    obj = min(obj,ob);
    % convergence reached
    if (delta <= Tol*xn)
      break
    end
  end
  
  U = U_opt;
  V = V_opt;
  W = W_opt;

%  
% make sure U(:,i), V(:,i), W(:,i) have the same norm, which minimizes
% |U|_2^2 + |V|_2^2 + |W|_2^2 without affecting tensorprod(U,V,W)
%
function [U,V,W] = normalize(U,V,W)

  r  = size(U,2);
  u2 = sqrt(sum(U.^2,1));
  v2 = sqrt(sum(V.^2,1));
  w2 = sqrt(sum(W.^2,1));
  s  = (u2.*v2.*w2).^(1/3);
  for i = 1:r
    if (s(i) == 0)
      U(:,i) = 0;
      V(:,i) = 0;
      W(:,i) = 0;
    else
      U(:,i) = U(:,i)*(s(i)/u2(i));
      V(:,i) = V(:,i)*(s(i)/v2(i));
      W(:,i) = W(:,i)*(s(i)/w2(i));
    end
  end

  [s,idx] = sort(s,'descend');
  U = U(:,idx);
  V = V(:,idx);
  W = W(:,idx);
  
function obj = objfcn(X,M,U,V,W,lambda)

  E  = (tensorprod(U,V,W)-X).*M;
  en = sum(E(:).^2);
  if (lambda)
    un = sum(U(:).^2);
    vn = sum(V(:).^2);
    wn = sum(W(:).^2);
    obj = lambda*(un + vn + wn) + en;
  else
    obj = en;
  end
  
function Y = myInverse(A,B,M,NonNeg)

  [m,n] = size(B);
  k = size(A,2);

  % this is much more efficient than unique(M','rows') and
  % almost never fails
  [Mu,I,J] = unique(rand(1,m)*M);
  
  % initialize to 0
  Y = zeros(k,n);
  for i = 1:length(I)
    ind = find(M(:,I(i)));
    if (~isempty(ind))
      Ai = A(ind,:);
      cols = find(J == i);
      Bi = B(ind,cols);
      if (NonNeg)
        Y(:,cols) = fcnnls(Ai,Bi);
      else
        Y(:,cols) = (Ai'*Ai)\(Ai'*Bi);
      end
    end
  end
  
  % ensure numerical stability
  EPS = 1e-10;
  Y(abs(Y)<EPS) = 0;
