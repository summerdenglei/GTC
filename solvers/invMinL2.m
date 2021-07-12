function [x] = invMinL2(A,B,lambda,x0,nonneg)
%
% [x] = INVMINL2(A,B,lambda) solves Ax=B by minimizing 
%
%    minimize    lambda*|x|_2^2 + |A*x-B|_2^2
%
% lambda should typically be <= 1 (e.g. 1e-2, 1e-3)
%

  if nargin < 3, lambda  = 1e-3; end
  if nargin < 4, x0 = [];        end
  if nargin < 5, nonneg = false; end

  % make A sparse
  sparse_thresh = 0.2;
  if ~issparse(A) && (nnz(A)/prod(size(A)) < sparse_thresh)
    A = sparse(A);
  end
  
  % use appropriate solvers depending on nnz(A)
  [m,n] = size(A);
  t = size(B,2);
  if (lambda > 0)
    A = [A; speye(n)*sqrt(lambda)];
    B = [B; zeros(n,t)];
    m = m + n;
  end
  if (isempty(x0))
    x0 = zeros(n,t);
  end
  
  nnz_thresh = 1.5e6;
  if (nonneg)
    % nonnegative least squares
    x = fcnnls(A,B);
    return
  else
    done = false;
    if (m > n)
      AtA = A'*A;
      if (nnz(AtA) < nnz_thresh)
        AtB = A'*B;
        x   = AtA\AtB;
        done = true;
      end
    elseif (nnz(A) < nnz_thresh)
      x    = A\B;
      done = true;
    end

    if (~done)
      x = zeros(n,t);
      for i = 1:t
        [xi,flag] = lsqr(A,B(:,i),[],[],[],[],x0(:,t));
        x(:,i) = xi;
      end
    end
  end
  
