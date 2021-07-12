function [U,V,obj,iter] = FactMatrixACLS(X,k,M,NonNeg,lambda,MaxIter,Tol,MaxIterNMF)  
%
% [U,V,obj,iter] = FACTMATRIXACLS(X,k,M,NonNeg,lambda,MaxIter,Tol,MaxIterNMF)
% performs alternating constrained least squares to factorize matrix X
%
%  minimize obj(U,V,X) = lambda*(|U|_2^2 + |V|_2^2) + |(U*V'-X).*M|_2^2
%
% Input:
%
%    X:        input matrix
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
%    lambda:   regularization parameter for U, V (default: 0)
%
%    MaxIter:  max number of iterations (default: 50)
%
%    Tol:      tolerance for convergence (stop when improvement in obj
%              is less than Tol*norm(X.*M,'fro')^2) (default: 1e-10)
%
%    MaxIterNMF: max number of iterations for NMF (default: 1000)
%
% Output:
%
%    U,V:      the factor matrices
%
%    obj:      the objective value
%
%    iter:     the number of iterations
%
% file:        FactMatrixACLS.m
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
  if nargin < 8, MaxIterNMF = 1000; end
  
  M(find(M)) = 1;
  X  = X.*M;
  xn = sum(X(:).^2);

  % get size information
  sx = size(X);
  if (length(sx) ~= 2)
    error('Can only factorize 2-d matrices');
  end
  nu = sx(1);
  nv = sx(2);

  if (~NonNeg) && (all(M(:)==1))
    % Directly Use SVD
    k0 = k;
    k  = min(k,min(sx));
    [u,s,v] = svds(X,k);
    U = u*sparse(s.^0.5);
    V = v*sparse(s.^0.5);
    if (k < k0)
      U = [U zeros(nu,k0-k)];
      V = [V zeros(nu,k0-k)];
    end
    obj  = objfcn(X,M,U,V,lambda);
    iter = 0;
    return 
  end
  
  Mv = M;
  Xv = X;
  Mu = M';
  Xu = X';
  
  Ik = eye(k,k);
  zu = zeros(k,nu);
  zv = zeros(k,nv);
  ou = ones(k,nu);
  ov = ones(k,nv);

  % initialize U
  if (~NonNeg)
    U = randn(nu,k);
    V = randn(nv,k);
  else
    [U,V] = nmf(X,k,M,'l2',MaxIterNMF,lambda);
  end

  U_opt = U;
  V_opt = V;
  obj = objfcn(X,M,U,V,lambda);

  for iter = 1:MaxIter

    if (lambda)
      % find V that minimizes lambda*|V|_2^2 + |U*V'-X|_2^2
      V = myInverse([U;Ik*sqrt(lambda)],[Xv;zv],[Mv;ov],NonNeg)';
      % find U that minimizes lambda*|U|_2^2 + |U*V'-X|_2^2
      U = myInverse([V;Ik*sqrt(lambda)],[Xu;zu],[Mu;ou],NonNeg)';
    else
      % find V that minimizes |U*V'-X|_2^2
      V = myInverse(U,Xv,Mv,NonNeg)';
      % find U that minimizes |U*V'-X|_2^2
      U = myInverse(V,Xu,Mu,NonNeg)';
    end

    % normalize U, V
    [U,V] = normalize(U,V);
    
    % update the objective
    ob = objfcn(X,M,U,V,lambda);
    if (ob <= obj)
      U_opt = U;
      V_opt = V;
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

%  
% make sure U(:,i) and V(:,i) have the same norm, which minimizes
% |U|_2^2 + |V|_2^2 without affecting U*V'
%
function [U,V] = normalize(U,V)

  r  = size(U,2);
  u2 = sqrt(sum(U.^2,1));
  v2 = sqrt(sum(V.^2,1));
  s  = sqrt(u2.*v2);
  for i = 1:r
    if (s(i) == 0)
      U(:,i) = 0;
      V(:,i) = 0;
    else
      U(:,i) = U(:,i)*(s(i)/u2(i));
      V(:,i) = V(:,i)*(s(i)/v2(i));
    end
  end

  [s,idx] = sort(s,'descend');
  U = U(:,idx);
  V = V(:,idx);
  
function obj = objfcn(X,M,U,V,lambda)

  E  = (U*V'-X).*M;
  en = sum(E(:).^2);
  if (lambda)
    un = sum(U(:).^2);
    vn = sum(V(:).^2);
    obj = lambda*(un + vn) + en;
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
                                                                                            
