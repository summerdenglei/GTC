function [A,b] = XM2Ab(X,M)
%
% [A,b] = XM2AB(X,M) converts a missing value inference problem instance
% into a set of linear constraint on X(:)
%
% Input:
%
%    X:        input matrix/tensor
%
%    M:        specifies whether any data in X is missing
%              Specifically, if M(i) = 0, it means X(i) is missing.
%              if X(i) is 1, it means X(i) is available.
%
% Output:
%
%    A,b:      A*Y(:)=b is equivalent to Y.*M = X.*M
%
% file:        XM2Ab.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Sun Jan  4 2009 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  ind  = find(M);
  nnzM = length(ind);
  nx   = prod(size(X));
  A    = sparse((1:nnzM)',ind,1,nnzM,nx);
  b    = X(ind);
  
