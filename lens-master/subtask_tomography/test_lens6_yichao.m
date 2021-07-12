addpath('/u/yichao/anomaly_compression/utils/lens');
addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
% addpath('../Matlab');
% addpath('../LENS');

D = load('../../data/abilene/X')';
% size(D)
% D = randn(121);
% D = D(:, 1:200);
D = D/mean(mean(D));
[n, m] = size(D);
r0 = 64;

%% add anomalies
sigma_magnitude = 0;  %% anomaly size
% ny = 2*min(m,n);
ny = ceil(m*n*0.05);
Y = sparse(n,m);
Y = zeros(n, m);
Y(randsample(n*m, ny)) = sign(randn(ny, 1)) * max(D(:)) * sigma_magnitude;

%% add noise
sigma_noise = 0; %% noise size
Z = randn(n, m) * max(D(:)) * sigma_noise;
D = max(0, D + Y + Z);

%% drop elements
loss_rate = 0.25;
[d_r, d_c] = size(D);
E = zeros(size(D));
% E(:,ceil(d_c/2)+1:d_c) = ones(d_r, d_c-ceil(d_c/2));
E = rand(size(D)) < loss_rate;
M = ~E;

if 0
%% ====================================
%% LENS
fprintf('=======================\nLENS\n');
r = r0;
A = speye(n,n);
B = speye(n,n);
C = speye(n,n);
F = ones(n,m);
soft = 1;
[x,y,z,w,sig] = lens(D,r,A,B,C,E,F,[],soft);
est = x+y;
mae = sum(abs(est(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f\n', mae);
end

if 0
%% ====================================
%% LENS_ST
fprintf('=======================\nLENS_ST\n');
r = r0;
A = speye(n,n);
B = speye(n,n);
C = speye(n,n);
F = ones(n,m);
soft = 1;
[x,y,z,w,u,v,s,t,sigma] = lens_st(D,r,A,B,C,E,F,[],soft);
est = x+y+s+t;
fprintf('norm(y)=%f norm(t)=%f\n',norm(y),norm(t));
mae = sum(abs(est(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f\n', mae);
end

if 0
%% ====================================
%% LENS_NO_ST
fprintf('=======================\nLENS_NO_ST\n');
r = r0;
A = speye(n,n);
B = speye(n,n)*0;
C = speye(n,n);
F = ones(n,m);
soft = 1;
[x,y,z,w,u,v,s,t,sigma] = lens_no_st(D,r,A,B,C,E,F,[],soft);
est = x; %x+y+s+t;
mae = sum(abs(est(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f\n', mae);
end

if 0
%% ======================================
%% LENS3
fprintf('=======================\nLENS3\n');
r = r0*2;
A = speye(n,n);
B = speye(n,n);
C = speye(n,n);
F = ones(n,m);
soft = 1;
rho = 1;
CC = zeros(1, m-1); CC(1,1) = 1;
RR = zeros(1, m); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
P = speye(n,n);
Q = toeplitz(CC,RR);
K = P*zeros(n,m)*Q';
[x,y,z,w,enable_B,sig,gamma] = lens3(D,r,A,B,C,E,P,Q,K,[],soft,rho);
if (enable_B)
  est1 = x+y;
  est2 = A*x+B*y;
else
  est1 = x;
  est2 = A*x;
end  
fprintf('norm(y)=%f\n',norm(y));
mae1 = sum(abs(est1(~M)-D(~M))) / sum(abs(D(~M)));
mae2 = sum(abs(est2(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f %f\n', mae1, mae2);
end

%% ====================================
%% SRMF
fprintf('=======================\nSRMF\n');
r = r0;
epsilon = 0.01;
alpha = 10;
lambda = 1e-4;
sx = size(D);
% M = (y > 0 | ~E);
[A, b] = XM2Ab(D, M);
config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
[u4, v4] = SRMF(D, r, M, config, alpha, lambda, 50);
est = u4 * v4';
mae = sum(abs(est(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f\n', mae);

if 0
%% ====================================
%% SRMF
fprintf('=======================\nSRMF\n'); 
r = r0;
epsilon = 0.01;
alpha = 10;
lambda = 1e-4;
sx = size(D); 
M = (y > 0 | ~E); 
[A, b] = XM2Ab(D, M); 
config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
[u4, v4] = SRMF(D, r, M, config, alpha, lambda, 50);
est = u4 * v4';
mae = sum(abs(est(~M)-D(~M))) / sum(abs(D(~M)));
fprintf('=> mae=%f\n', mae);
end
