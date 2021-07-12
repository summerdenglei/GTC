function [] = test_geant(odir,Seed,Dim,Rank,LossRate,lambda)

data_dir = '../data/GeantTotemAnon/TM/2005/04';
dist_file = [data_dir '/../../../geant-topology-distances.dat'];
link_file = [data_dir '/topology-anonymised.links'];
files = dir([data_dir '/IntraTM-2005-04-*.xml']);
dataset = 'geant';

t0 = 0;
tmax = 7*24*4;
X = [];
for i = 1:tmax
  file = files(t0+i).name;
  tm_file = [data_dir '/' file '.tm'];
  tm_data = textread(tm_file, '', 'commentstyle', 'shell', 'delimiter', ' ');
  X = [X reshape(tm_data,[],1)];
end
X = X/max(X(:));
N = sqrt(size(X,1));


L = load('../data/GeantTotemAnon/topo/links.txt');
addpath ../Matlab
A = RoutingMatrix(sparse(L(:,1),L(:,2),1,N,N));
B = A*X;

do_one_expr(A,B,X,N,Seed,Dim,Rank,LossRate,lambda,odir,dataset);
