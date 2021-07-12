function [U,V,obj,iter] = SRMF2(A,B,X,r,M,Cons,alpha,lambda,MaxIter)
%
% [U,V,obj,iter] = SRMF(X,r,M,Cons,alpha,lambda,MaxIter)
% performs alternating constrained least squares to factorize matrix X subject
% to sparse constraints in wavelet coefficients / forecast errors
%
%  minimize obj(U,V,X) = 
%
%     |A*U*V'-B|_2^2  + |(U*V'-X).*M|_2^2 + alpha*(|U*V'*G'|_2^2 + |F*U*V'|_2^2) + lambda*(|U|_2^2 + |V|_2^2)
%
% Input:
%
%    A:            constraint A*X = B
%
%    B:            constraint A*X = B
%
%    r:            number of columns in U and V
%
%    Cons:         the set of constraints: Cons{1} = F, Cons{2} = G
%
%    alpha:        weight for sparsity constraint F*U*V'*G' = 0 (default: 10)
%
%    lambda:       regularization parameter for U, V (default: 1e-3)
%
%    MaxIter:      max number of iterations (default: 20)
%
% Output:
%
%    U,V:      the factor matrices
%
%    obj:      the objective value
%
%    iter:     the number of iterations
%
% file:        SRMF.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Dec 24 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 3, M = ones(size(X));   end
  if nargin < 4, Cons = cell(1,2);    end
  if nargin < 5, alpha = 10;          end
  if nargin < 6, lambda = 1e-3;       end
  if nargin < 7, MaxIter = 20;        end
  
  M(find(M)) = 1;
  X  = X.*M;

  % get size information
  sx = size(X);
  if (length(sx) ~= 2)
    error('Can only factorize 2-d matrices');
  end
  nu = sx(1);
  nv = sx(2);

  F = sparse(Cons{1});
  G = sparse(Cons{2});
  if (isempty(F)), F = sparse(0,nu); end
  if (isempty(G)), G = sparse(0,nv); end

  % get rid of empty rows in F and G
  nz = find(any(F,2));
  F = F(nz,:);
  nz = find(any(G,2));
  G = G(nz,:);
  
  Mv = M;
  Xv = X;
  Mu = M';
  Xu = X';
  
  % initialize U and V
  U = rand(nu,r);
  V = rand(nv,r);
  U_opt = U;
  V_opt = V;
  obj   = objfcn(A,B,X,M,U,V,F,G,alpha,lambda);

  for iter = 1:MaxIter

    % alternating update of V and U
    V = myInverse(A,B,Xv,Mv,U,F*U,G,V,alpha,lambda);
    U = myInverse2(A,B,Xu,Mu,V,G*V,F,U,alpha,lambda);
    
    % minimize |U|^2 + |V|^2 without affecting U*V'
    [U,V] = normalize(U,V);
    
    % update the objective
    ob = objfcn(A,B,X,M,U,V,F,G,alpha,lambda);
    if (ob <= obj)
      obj   = ob;
      U_opt = U;
      V_opt = V;
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
  
function obj = objfcn(A,B,X,M,U,V,F,G,alpha,lambda)

  E  = A*U*V'-B;
  en = sum(E(:).^2);
  obj = en;
  E  = (U*V'-X).*M;
  en = sum(E(:).^2);
  obj = obj + en;
  if (alpha)
    FUV = (F*U)*V';
    UGV = U*(G*V)';
    obj = obj + alpha*(sum(FUV(:).^2) + sum(UGV(:).^2));
  end
  if (lambda)
    un = sum(U(:).^2);
    vn = sum(V(:).^2);
    obj = obj + lambda*(un + vn);
  end
  
% min |A*U*V'-B|_2^2 + |(U*V'-X).*M| + alpha*|FU*V'|_2^2 + lambda*|V'|_2^2
function V = myInverseNoG(A,B,X,M,U,FU,alpha,lambda)

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
  AU    = A*U;
  AUtAU = AU'*AU;
  AUtB  = AU'*B;
  for i = 1:length(I)
    ind = find(M(:,I(i)));
    Ui = U(ind,:);
    cols = find(J == i);
    vi = (AUtAU + Ui'*Ui + alpha*FUtFU + lambda*speye(r))\(Ui'*X(ind,cols) + AUtB(:,cols));
    V(cols,:) = vi';
  end

% min |A*U*V'-B|_2^2  + |(U*V'-X).*M| + alpha*|FU*V'|_2^2 + alpha*|U*V'*G'|_2^2 + lambda*|V|_2^2
function V = myInverse(A,B,X,M,U,FU,G,V0,alpha,lambda)
  
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
    V = myInverseNoG(A,B,X,M,U,[FU;U],alpha,lambda);
    return
  elseif (nnz(alpha*G) == 0)
    V = myInverseNoG(A,B,X,M,U,FU,alpha,lambda);
    return
  end
  
  %
  % It is rather expensive to convert U*V'*G' into a linear function of V
  % So we do a change of variable here.  Let [Uu,Us,Uv] = svd(U,0).  Let Y = Uv'*V'
  % (which is of size r-by-nv)
  %
  % We then have:
  %
  %   A*U*V'      = (A*U*Uv)*Y
  %   FU*V'       = (FU*Uv)*Y
  %   |U*V'*G'|_2 = (Us*Y*G')
  %   |V|_2       = |Y|_2
  %
  [Uu,Us,Uv] = svd(U,0);
  Us    = sparse(Us);
  AUUv  = A*U*Uv;
  UUv   = U*Uv;
  FUUv  = FU*Uv;
  
  %
  % Convert:
  %
  %         AUUv*Y = B
  %
  % into:
  %
  %            O*y = o
  %
  %
  % For better memory efficiency, we directly compute
  %
  %   OtO = O'*O and Oto = O'*o
  %
  
  % the following is more efficient than OtO = blkdiag(AUUv'*AUUv,AUUv'*AUUv,...)
  [I,J] = ind2sub([r r],(1:(r*r))');
  I = repmat(I,nv,1);
  J = repmat(J,nv,1);
  K = reshape(repmat(r*(0:(nv-1)),r*r,1),[],1);
  OtO = sparse(I+K,J+K,repmat(reshape(AUUv'*AUUv,[],1),nv,1),nv*r,nv*r);
  Oto = reshape(AUUv'*B,[],1);
  
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
  C  = OtO + PtP + alpha*RtR + alpha*QtQ + lambda*speye(nv*r);
  d  = Oto + Ptp;
  y0 = reshape(Uv'*V0',[],1);
  y  = invMinL2(C,d,0,y0,false);  
  Y  = reshape(y,r,nv);
  
  % convert Y back to V
  V  = Y'*Uv';

% min |U*V'*A'-B'|_2^2  + |(U*V'-X).*M| + alpha*|FU*V'|_2^2 + alpha*|U*V'*G'|_2^2 + lambda*|V|_2^2
function V = myInverse2(A,B,X,M,U,FU,G,V0,alpha,lambda)
  
  sx = size(X);
  nu = sx(1);
  nv = sx(2);
  nf = size(FU,1);
  ng = size(G,1);
  r  = size(U,2);

  %
  % It is rather expensive to convert U*V'*A'-B' and U*V'*G' into a linear function of V
  % So we do a change of variable here.  Let [Uu,Us,Uv] = svd(U,0).  Let Y = Uv'*V'
  % (which is of size r-by-nv)
  %
  % We then have:
  %
  %   |U*V'*A'-B'|_2^2 = |Uu*Us*Y*A'-B'|_2^2 = |Us*Y*A'-Uu'*B'|_2^2
  %   FU*V'      =  (FU*Uv)*Y
  %   |U*V'*G'|_2 = (Us*Y*G')
  %   |V|_2       = |Y|_2
  %
  [Uu,Us,Uv] = svd(U,0);
  BUu   = B*Uu;
  Us    = sparse(Us);
  UUv   = U*Uv;
  FUUv  = FU*Uv;
  
  %
  % Convert:
  %
  %         Us*Y*A' = BUu'
  %
  % into:
  %
  %         O*y = o
  %
  %
  % For better memory efficiency, we directly compute
  %
  %   OtO = O'*O and Oto = O'*o
  %
  % Note that Us*Y*A' = BUu' <==> A*Y'*Us = BUu <==>
  %
  %   blkdiag(Us(1,1)*A,Us(2,2)*A,...) * reshape(Y',[],1) = BUu
  %
  % Let T = blkdiag(Us(1,1)*A,Us(2,2)*A,...), perm = reshape(reshape(1:nv*r,nv,r)',1,[])
  %
  % Let TtT = T'*T
  %
  % We have:
  %
  %    TtT(perm,perm) = OtO
  %
  cTtT = cell(1,r);
  AtA = sparse(A'*A);
  for k = 1:r
    cTtT{k} = Us(k,k)^2*AtA;
  end
  TtT = blkdiag(cTtT{:});
  perm = reshape(reshape(1:nv*r,nv,r)',1,[]);
  OtO = TtT(:,perm);
  OtO = OtO(perm,:);
  Oto = reshape(A'*BUu*Us,[],1);
  Oto = Oto(perm,:);
  
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
  C  = OtO + PtP + alpha*RtR + alpha*QtQ + lambda*speye(nv*r);
  d  = Oto + Ptp;
  y0 = reshape(Uv'*V0',[],1);
  y  = invMinL2(C,d,0,y0,false);  
  Y  = reshape(y,r,nv);
  
  % convert Y back to V
  V  = Y'*Uv';

  
