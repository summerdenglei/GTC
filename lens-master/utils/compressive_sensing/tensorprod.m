function P = tensorprod(U,V,W)
%
% P = TENSORPROD(U,V,W) computes the tensor product of U, V, W
% That is: P(i,j,k) = sum(U(i,:).*V(j,:).*W(k,:))
%
% file:        tensorprod.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Dec 24 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if (nargin < 3)
    if (nargin == 2)
      P = U*V';
    elseif (nargin == 1)
      P = U;
    else
      P = [];
    end
    return
  end

  [nu,ru] = size(U);
  [nv,rv] = size(V);
  [nw,rw] = size(W);

  % if (range([ru rv rw]) > 0)
  %   error('U, V, W have incompatible sizes');
  % end

  VW = zeros(nv*nw,ru);
  for i = 1:ru
    VW(:,i) = reshape(V(:,i)*W(:,i)',nv*nw,1);
  end

  P = reshape(U*VW',[nu nv nw]);
