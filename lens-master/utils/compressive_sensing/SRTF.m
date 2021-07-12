function [P,U,V,W,obj,iter] = SRTF(X,r,M,Cons,alpha,lambda,MaxIter)
%
% [U,V,W,obj,iter] = SRTF(X,r,M,Cons,alpha,lambda,MaxIter)
% Sparsity Regularized Tensor Factorization (SRTF) performs alternating constrained least
% squares to factorize tensor X subject to sparse constraints in wavelet coefficients /
% forecast errors 
%
%  minimize obj(U,V,X) = 
%
%     |(tensorprod(U,V,W)-X).*M|^2  + 
%       alpha*(|tensorprod(FU,V,W)|^2 + |tensorprod(U,GV,W)|^2 + |tensorprod(U,V,HW)|^2)
%       lambda*(|U|^2 + |V|^2 + |W|^2)
%
% Input:
%
%    X:            input matrix
%
%    r:            number of columns in U and V
%
%    M:            specifies whether any data in X is missing
%                  Specifically, if M(i,j) = 0, it means X(i,j) is missing.
%                  if X(i,j) is 1, it means X(i,j) is available.
%                  (default: ones(size(X)))
%
%    Cons:         the set of constraints: Cons{1} = F, Cons{2} = G, Cons{3} = H
%
%    alpha:        weight for sparsity constraint F*U*V'*G' = 0 (default: 10)
%
%    lambda:       regularization parameter for U, V (default: 1e-3)
%
%    MaxIter:      max number of iterations (default: 20)
%
% Output:
%
%    U,V,W:    the factor matrices
%
%    obj:      the objective value
%
%    iter:     the number of iterations
%
% file:        SRTF.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Dec 24 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 3, M = ones(size(X));   end
  if nargin < 4, Cons = cell(1,3);    end
  if nargin < 5, alpha = 10;          end
  if nargin < 6, lambda = 1e-3;       end
  if nargin < 7, MaxIter = 20;        end
  
  M(find(M)) = 1;
  X  = X.*M;

  % get size information
  sx = size(X);
  if (length(sx) > 3)
    error('Can only factorize 3-d tensors');
  elseif (length(sx) < 3)
    [U,V,obj,iter] = SRMF(X,r,M,Cons,alpha,lambda,MaxIter);
    W = ones(1,r);
    return
  end
  nu = sx(1);
  nv = sx(2);
  nw = sx(3);

  F = sparse(Cons{1});
  G = sparse(Cons{2});
  H = sparse(Cons{3});
  if (isempty(F)), F = sparse(0,nu); end
  if (isempty(G)), G = sparse(0,nv); end
  if (isempty(H)), H = sparse(0,nw); end

  % get rid of empty rows in F and G
  nz = find(any(F,2));
  F = F(nz,:);
  nz = find(any(G,2));
  G = G(nz,:);
  nz = find(any(H,2));
  H = sparse(H(nz,:));
  
  Xw = reshape(X,nu*nv,nw);
  Mw = reshape(M,nu*nv,nw);
  Xu = reshape(shiftdim(X,1),nv*nw,nu);
  Mu = reshape(shiftdim(M,1),nv*nw,nu);
  Xv = reshape(shiftdim(X,2),nw*nu,nv);
  Mv = reshape(shiftdim(M,2),nw*nu,nv);

  % initialize U and V
  U = rand(nu,r);
  V = rand(nv,r);
  W = rand(nw,r);
  U_opt = U;
  V_opt = V;
  W_opt = W;
  obj   = objfcn(X,M,U,V,W,F,G,H,alpha,lambda);

  for iter = 1:MaxIter

    fprintf('     itr %d\n', iter);

    % alternating update of V and U
    W = myInverse(Xw,Mw,prodfcn(U,V),[prodfcn(F*U,V);prodfcn(U,G*V)],H,W,alpha,lambda);
    U = myInverse(Xu,Mu,prodfcn(V,W),[prodfcn(G*V,W);prodfcn(V,H*W)],F,U,alpha,lambda);
    V = myInverse(Xv,Mv,prodfcn(W,U),[prodfcn(H*W,U);prodfcn(W,F*U)],G,V,alpha,lambda);

    % minimize |U|^2 + |V|^2 + |W|^2 without affecting tensorprod(U,V,W)
    [U,V,W] = normalize(U,V,W);
    
    % update the objective
    ob = objfcn(X,M,U,V,W,F,G,H,alpha,lambda);
    if (ob <= obj)
      obj   = ob;
      U_opt = U;
      V_opt = V;
      W_opt = W;
    end
  end

  U = U_opt;
  V = V_opt;
  W = W_opt;
  P=tensorprod(U,V,W);
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

function obj = objfcn(X,M,U,V,W,F,G,H,alpha,lambda)

  E  = (tensorprod(U,V,W)-X).*M;
  en = sum(E(:).^2);
  obj = en;

  fprintf('    obj: en=%f, ', en);

  if (alpha)
    FUVW = tensorprod(F*U,V,W);
    UGVW = tensorprod(U,G*V,W);
    UVHW = tensorprod(U,V,H*W);

    
    fprintf('alpha=%f, ', (sum(FUVW(:).^2) + sum(UGVW(:).^2) + sum(UVHW(:).^2)));

    obj = obj + alpha*(sum(FUVW(:).^2) + sum(UGVW(:).^2) + sum(UVHW(:).^2));
  end
  if (lambda)
    un = sum(U(:).^2);
    vn = sum(V(:).^2);
    wn = sum(W(:).^2);
    
    
    fprintf('beta=%f\n', (un + vn + wn));
    

    obj = obj + lambda*(un + vn + wn);
  end
  
  
% min |(U*V' - X).*M|_2^2 + alpha*|FU*V'|_2^2 + lambda*|V|_2^2
function V = myInverseNoG(X,M,U,FU,alpha,lambda)

  sx = size(X);
  nu = sx(1);
  nv = sx(2);
  nf = size(FU,1);
  r  = size(U,2);
   
  % this is much more efficient than unique(M','rows') and
  % almost never fails
  [Mu,I,J] = unique(rand(1,nu)*M);

  % initialize to 0
  V = zeros(nv,r);
  
  % since there is no G, we can decompose original optimization problem
  % into separable problems for each row of V, i.e. V(i,:)
  FUtFU = FU'*FU;
  for i = 1:length(I)
    ind = find(M(:,I(i)));
    Ui = U(ind,:);
    cols = find(J == i);
    vi = (Ui'*Ui + alpha*FUtFU + lambda*speye(r))\(Ui'*X(ind,cols));
    V(cols,:) = vi';
  end


% min |(U*V' - X).*M|_2^2 + alpha*|FU*V'|_2^2 + alpha*|U*V'*G'|_2^2 + lambda*|V|_2^2
function V = myInverse(X,M,U,FU,G,V0,alpha,lambda)
  
  sx = size(X);
  nu = sx(1);
  nv = sx(2);
  nf = size(FU,1);
  ng = size(G,1);
  r  = size(U,2);

  EPS = 1e-10;
  if ((ng == nv) && (norm(G'*G-speye(nv),inf) < EPS))
    %
    % special case: |FU*V'*G'|_2^2 = |FU*V'|_2^2
    %
    V = myInverseNoG(X,M,U,[FU;U],alpha,lambda);
    return
  elseif (nnz(alpha*G) == 0)
    V = myInverseNoG(X,M,U,FU,alpha,lambda);
    return
  end
  
  %
  % It is rather expensive to convert U*V'*G' into a linear function of V
  % So we do a change of variable here.  Let [Uu,Us,Uv] = svd(U,0).  Let Y = Uv'*V'
  % (which is of size r-by-nv)
  %
  % We then have:
  %
  %   (U*V'-X).*M = (U*Uv)*Y
  %   FU*V'      =  (FU*Uv)*Y
  %   |U*V'*G'|_2 = (Us*Y*G')
  %   |V|_2       = |Y|_2
  %
  [Uu,Us,Uv] = svd(U,0);
  Us    = sparse(Us);
  UUv   = U*Uv;
  FUUv  = FU*Uv;
  
  %
  % Convert:
  %
  %         (UUv*Y).*M = X.*M
  %
  % into:
  %
  %         P*y = p
  %
  %
  % For better memory efficiency, we directly compute
  %
  %   PtP = P'*P and Ptp = P'*p
  %
  cPtP = zeros(r*r*nv,1);
  Ptp  = zeros(r*nv,1);
  for k = 1:nv
    Mnz     = find(M(:,k));
    p_k     = X(Mnz,k);
    P_k     = UUv(Mnz,:);

    I       = ((k-1)*r*r+1):(k*r*r);
    cPtP(I) = reshape(P_k'*P_k,r*r,1);
    
    I       = ((k-1)*r+1):(k*r);
    Ptp(I)  = P_k'*p_k;
  end
  
  % the following is more efficient than PtP = blkdiag(P_1'*P_1,P_2'*P_2,...)
  [I,J] = ind2sub([r r],(1:(r*r))');
  I = repmat(I,nv,1);
  J = repmat(J,nv,1);
  K = reshape(repmat(r*(0:(nv-1)),r*r,1),[],1);
  PtP = sparse(I+K,J+K,cPtP,nv*r,nv*r);
  
  %
  % Convert
  %
  %           FUUv*Y = 0
  %
  % into 
  % 
  %           R*y = 0
  %
  % For better memory efficiency, we directly compute
  %
  %   RtR = R'*R
  %
  % We have:
  %
  %   cRtR      = cell(1,nv);
  %   [cRtR{:}] = deal(sparse(FUUv'*FUUv));
  %   RtR       = blkdiag(cRtR{:});
  %
  %
  if (alpha)
    % the following is more efficient that RtR = blkdiag(FUUv'*FUUv,...)
    [I,J] = ind2sub([r r],(1:(r*r))');
    I = repmat(I,nv,1);
    J = repmat(J,nv,1);
    K = reshape(repmat(r*(0:(nv-1)),r*r,1),[],1);
    RtR = sparse(I+K,J+K,repmat(reshape(FUUv'*FUUv,[],1),nv,1),nv*r,nv*r);
  else
    RtR = 0;
  end

  %
  % Handle 
  %
  %        Us*Y*G' = 0
  %
  % into:
  %
  %         Q*y = 0
  %
  % For better memory efficiency, we directly compute
  %
  %   QtQ = Q'*Q
  %
  % Note that Us*Y*G' = 0 is equivalent to:
  %
  %   blkdiag(Us(1,1)*G,Us(2,2)*G,...) * reshape(Y',[],1) = 0
  %
  % Let S = blkdiag(Us(1,1)*G,Us(2,2)*G,...), perm = reshape(reshape(1:nv*r,nv,r)',1,[])
  %
  % Let StS = S'*S
  %
  % We have:
  %
  %    StS(perm,perm) = QtQ
  %
  if (alpha)
    cStS = cell(1,r);
    GtG = sparse(G'*G);
    for k = 1:r
      cStS{k} = Us(k,k)^2*GtG;
    end
    StS = blkdiag(cStS{:});
    perm = reshape(reshape(1:nv*r,nv,r)',1,[]);
    QtQ = StS(:,perm);
    QtQ = QtQ(perm,:);
  else
    QtQ = 0;
  end
  
  % 
  % solve y
  %
  A  = PtP + alpha*RtR + alpha*QtQ + lambda*speye(nv*r);
  b  = Ptp;
  y0 = reshape(Uv'*V0',[],1);
  y  = invMinL2(A,b,0,y0,false);  
  Y  = reshape(y,r,nv);
  
  % convert Y back to V
  V  = Y'*Uv';
