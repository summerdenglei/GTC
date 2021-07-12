function P = prodfcn(X,Y)

  [nx,k] = size(X);
  [ny,k] = size(Y);

  P = zeros(nx*ny,k);
  for i = 1:k
    P(:,i) = reshape(X(:,i)*Y(:,i)',nx*ny,1);
  end
                
