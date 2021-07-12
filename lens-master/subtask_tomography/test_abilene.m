function [] = test_abilene(odir,Seed,Dim,Rank,LossRate,lambda)

A = load('../data/AbileneAnukool/raw/A');

X = load('../data/AbileneAnukool/raw/X');
X = X/max(X(:));
X = X';
N = sqrt(size(X,1));
dataset = 'abilene';

% add the additional constraints on row/col sums
Ind = reshape(1:N*N,N,N);
for i = 1:N
  row = zeros(1,N*N);
  row(Ind(i,:)) = 1;
  A = [A; row];
  row = zeros(1,N*N);
  row(Ind(:,i)) = 1;
  A = [A; row];
end

% get the link loads
B = A*X;

% perform an experiment
do_one_expr(A,B,X,N,Seed,Dim,Rank,LossRate,lambda,odir,dataset);
