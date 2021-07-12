function [XI] = InterpKNN(X,M,TrialOrder,KList)
%
% place [XI] = INTERPKNN(X,M,k,dim) performs K-NN interpolation
%
% Input:
%
%     X:             the input array
%
%     M:             X(M==0) are missing, X(M==1) are available
%
%     TrialOrder:    the order of dimensions to try (default: 1:n)
%
%     KList:         KList(d) is the K to use for dimension d (default: ones(1,n)
%
% Output:
%
%     XI:            the interpolated results
%
% file:        InterpKNN.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Tue Jan  6 2009 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  n = ndims(X);
  if nargin < 3, TrialOrder = 1:n;    end
  if nargin < 4, KList = ones(1,n);   end

  if (length(KList) == 1)
    KList = KList*ones(1,n);
  end
  
  % make sure we don't cheat
  M(find(M)) = 1;
  X = X.*M;
  
  % Estimate the baseline
  sx = size(X);
  nx = prod(sx);
  [A,b] = XM2Ab(X,M);  
  BaseX = EstimateBaseline(A,b,sx);
  
  Y = (X-BaseX).*M;
  Y(M==0) = nan;
  YI = Y;
  
  for d = TrialOrder

    K     = KList(d);
    
    % compute the pairwise similarity
    Yd    = shiftdim(Y,d-1);
    Ymat  = reshape(Yd,sx(d),[]);    
    Sim   = Affinity(Ymat','Cosine',0);

    % try to interpolate along dimension d
    YId   = shiftdim(YI,d-1);
    YImat = reshape(YId,sx(d),[]);
    cidx = find(any(isnan(YImat),1));
    for c = cidx
      ridx0 = find(isnan(YImat(:,c)))';
      ridx1 = find(~isnan(Ymat(:,c)))';
      if (isempty(ridx1))
        continue;
      end
      for r = ridx0
        [sd_sorted,sd_idx] = sort(Sim(r,ridx1),'descend');
        if (any(sd_sorted > 0))
          rows       = ridx1(sd_idx(1:min(K,end)));
          YImat(r,c) = sum(Ymat(rows,c).*Sim(rows,r))/sum(Sim(rows,r));
        end
      end
    end
    
    YId = reshape(YImat,size(YId));
    YI  = shiftdim(YId,n-(d-1));
  end
  
  % the rest simply set them to 0
  YI(isnan(YI)) = 0;
  
  % add back the baseline
  XI = YI + BaseX;
