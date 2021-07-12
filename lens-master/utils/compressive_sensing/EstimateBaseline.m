function [BaseX,MeanX,Offsets] = EstimateBaseline(A,b,sx,lambda)
%
% [BaseX,MeanX,Offsets] = EstimateBaseline(A,b,sx,lambda) computes
% the least squares baseline estimate for input matrix/tensor X
% under constraint A*X(:) = b
%
% Input:
%
%    A:        constraint on X: A*X(:) = b
%
%    b:        constraint on X: A*X(:) = b
%
%    sx:       sx = size(X)
%
%    lambda:   regularization parameter to avoid overfitting
%
% Output:
%
%    BaseX:    the estiamted baseline (with same size as X)
%              BaseX(i1,i2,...) = MeanX + Offsets{1}(i1) + Offsets{2}(i2) + ...
%
%    MeanX:    estimated mean(X(:))
%
%    Offsets:  a cell where Offsets{i} gives the offset for dimension
%              i (i = 1, 2, ... n=length(sx))
%
% file:        EstimateBaseline.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Wed Dec 31 2008 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if (nargin < 4), lambda = 1e-8; end

  % get size information
  n  = length(sx);
  nx = prod(sx);
  ny = sum(sx);
  
  % convert indices to subscripts
  subs = cell(1,n);
  [subs{:}] = ind2sub(sx,(1:nx)');

  %
  % first estimate the global mean
  %
  Aone = A*ones(nx,1);
  if (lambda ~= 0)
    MeanX = (Aone'*b)/(Aone'*Aone + lambda);
  else
    MeanX = pinv(Aone'*Aone)*(Aone'*b);
  end
  b = b - Aone*MeanX;
  
  CumSumSizeX = [0 cumsum(sx)];
  CombinedSubscripts = zeros(nx*n,1);
  for i = 1:n
    bas = (i-1)*nx;
    CombinedSubscripts(bas+1:bas+nx) = subs{i} + CumSumSizeX(i);
  end
  
  A = sparse(A);
  B = sparse(repmat((1:nx)',n,1),CombinedSubscripts,1,nx,ny);
  
  AB = A*B;
  if (lambda ~= 0)
    offsets = (AB'*AB + lambda*speye(ny,ny))\(AB'*b);
  else
    offsets = pinv(AB'*AB)*(AB'*b);
  end
  Offsets = cell(1,n);
  for i = 1:n
    Offsets{i} = offsets(CumSumSizeX(i)+1:CumSumSizeX(i+1));
  end
  
  BaseX = MeanX + reshape(B*offsets,sx);
