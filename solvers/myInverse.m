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