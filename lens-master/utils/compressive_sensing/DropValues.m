function M = DropValues(nr,nc,nt,ElemFrac,LossRate,ElemMode,LossMode,BurstSize)
%
% place help info about DROPVALUES here
%
%
% file:        DropValues.m
% directory:   /u/yzhang/MRA/Matlab/
% created:     Thu Jan  8 2009 
% author:      Yin Zhang 
% email:       yzhang@cs.utexas.edu
%

  if nargin < 8, BurstSize = 1; end

  % first select the elements
  numElem = nr*nc;
  Ind = reshape(1:numElem,nr,nc);
  switch(lower(ElemMode))
  case {'elem'}
    idx = randperm(numElem);
    elem_list = idx(1:ceil(numElem*ElemFrac));
  case {'row'}
    idx = randperm(nr);
    row_list = idx(1:ceil(nr*ElemFrac));
    elem_list = reshape(Ind(row_list,:),1,[]);
  case {'col'}
    idx = randperm(nc);
    col_list = idx(1:ceil(nc*ElemFrac));
    elem_list = reshape(Ind(:,col_list),1,[]);
  case {'time'}
    elem_list = 1:numElem;
  end

  % then drop the selected elements
  M = ones(numElem,nt);
  switch(lower(LossMode))
  case {'ind'}
    % rand loss independent across elem_list
    switch(lower(ElemMode))
    case {'elem','time'}
      for e = elem_list
        idx = randperm(nt);
        M(e,idx(1:ceil(nt*LossRate))) = 0;
      end
    case {'row'}
      for r = row_list
        idx = randperm(nt);
        M(Ind(r,:),idx(1:ceil(nt*LossRate))) = 0;
      end
    case {'col'}
      for c = col_list
        idx = randperm(nt);
        M(Ind(:,c),idx(1:ceil(nt*LossRate))) = 0;
      end
    end
    
  case {'syn'}
    % rand loss synchronized among elem_list
    idx = randperm(nt);
    M(elem_list,idx(1:ceil(nt*LossRate))) = 0;
    
  case {'half'}
    % deterministic loss in which entire second half is lost
    M(elem_list,max(1,ceil(nt*(1-LossRate))):end) = 0;
    
  end

  % add back the selected time points (if applicable)
  if (strcmpi(ElemMode,'time'))
    idx = randperm(nt);
    time_list = idx(1:ceil(nt*(1-ElemFrac)));
    M(:,time_list) = 1;
  end

  if (BurstSize > 1)
    N = zeros(size(M));
    for i = 1:BurstSize:nt
      imax = min(i+BurstSize-1,nt);
      N(:,i:imax) = repmat(M(:,ceil(i/BurstSize)),1,imax-i+1);
    end
    M = N;
  end
  
  % reshape
  M = reshape(M,nr,nc,nt);
  
  % size(M)
  % nnz(M)/prod(size(M))
