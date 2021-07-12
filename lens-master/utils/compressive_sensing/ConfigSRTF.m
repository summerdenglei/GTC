function [Cons] = ConfigSRTF(A,b,X,M,sx,Rank,K,epsilon,UseTempDiff,Period)
%
% [Cons] = CONFIGSRTF(A,b,X0,Rank,epsilon,UseTempDiff) generates constraint
% matrices (F, G, H, etc.) for SRTF/SRMF.
%
% Input:
%
%      A,b:       Constraints on X(:)
%
%       X0:       An initial estimation of X
%
%   epsilon:    tolerable size of norm(A*X(:)-b)^2/norm(b)^2
%                 (default: 0.01) 
%
%  SpatModelConf: our confidence in spatial models (i.e. anything
%                 except the last dimension).  it is used to
%                 scale down the corresponding F, G. (default: 0.1)
%
%   UseTempDiff:  wether or not use temporal differencing
%                 (default: true)
%
% Output:
%
%      Cons:      Cons{1:n} = {F,G,(H)}
%
% file:        ConfigSRTF.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Mon Jan 19 2009 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 7, K = 1;               end
  if nargin < 8, epsilon = 0.001;     end
  if nargin < 9, UseTempDiff = true;  end
  if nargin < 10, Period = 1;         end
  
  BaseX = EstimateBaseline(A,b,sx);
  BaseX = max(0,BaseX);
  BaseX=zeros(144,48);
  BaseX(M==1) = X(M==1);
  
  sx   = size(BaseX);
  n    = length(sx);
  Cons = cell(1,n);
  for i = 1:n
    try
      % k-NN for first n-1 dimensions
      Xi = reshape(shiftdim(BaseX,i-1),sx(i),[]);
      Si = Affinity(Xi','Regression',K);
      Ci = speye(sx(i)) - Si;
      Cons{i} = Ci;
    catch
      % don't do anything
    end
  end

  % temporal differencing for n-th dimension
  if (UseTempDiff)
    Cn  = sparse(0,sx(n));
    row = 0;
    for p = 1:length(Period)
      period = Period(p);
      for i = 1:(sx(n)-period)
        row = row+1;
        Cn(row,i) = 1;
        Cn(row,i+period) = -1;
      end
    end
    Cons{n} = Cn;
  end
  
%   scale matrices properly
%   for i = 1:n
%     if (nnz(Cons{i}) > 0)
%       Xi      = reshape(shiftdim(BaseX,i-1),sx(i),[]);
% 			% epsilon
%       scale   = sqrt(epsilon)*norm(b)/norm(Cons{i}*Xi,'fro');
%       scale   = min(scale,norm(b)/norm(Xi,'fro'));
%       if (i < n)
%         scale = scale*0.1;
%       end
%       Cons{i} = scale*Cons{i};
%     end
%   end


