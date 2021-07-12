function [U,S,V] = GraphTSVD(A,L)
  D = tensor_gft(A,L);
  %D = A;
  n3 = size(A,3);
  
  for i = 1:n3 %nframes
    [Ux,Sx,Vx] = svd(D(:,:,i));
    Uy(:,:,i) = Ux;
    Sy(:,:,i) = Sx;
    Vy(:,:,i) = Vx;
  end
  
  U = tensor_igft(Uy,L);
  S = tensor_igft(Sy,L);
  V = tensor_igft(Vy,L);
  %U = Uy;
  %S = Sy;
  %V = Vy;
end


