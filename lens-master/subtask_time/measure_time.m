addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
% addpath('../Matlab');
% addpath('../LENS');

output_dir = '../processed_data/subtask_time/run_time/';
EXP_TIMES = 1; 


rho = 1.2;
max_itr = 30;

%% ==========================================================
%% fix rank = 10, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix rank = 10, loss rate = 0.5:\n');

r0 = 10;
loss_rate = 0.5;

ms = [50, 100, 200, 400, 500];
ns = [50, 100, 100, 100, 200];
times_srmf = zeros(1, length(ms));
times_lens = zeros(1, length(ms));

for si = 1:length(ms)
    m = ms(si);
    n = ns(si);


    D = rand(m, n) * 5;
    D = D/mean(mean(D));
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(si) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: size=%dx%d: %f\n', size(D), times_lens(si));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(si) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(si));

end

dlmwrite([output_dir 'time_mn.txt'], [ms', ns', times_srmf', times_lens'], 'delimiter', '\t');





%% ==========================================================
%% fix m = 100, n = 100, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix m = 100, n = 100, loss rate = 0.5: \n');

m = 100;
n = 100
loss_rate = 0.5;

rs = [2, 4, 8, 16, 32, 64];
times_srmf = zeros(1, length(rs));
times_lens = zeros(1, length(rs));


for ri = 1:length(rs)
    r0 = rs(ri);

    D = rand(m, n) * 5;
    D = D/mean(mean(D));
    
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(ri) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: r=%d: %f\n', r0, times_lens(ri));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(ri) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(ri));

    % est = u4 * v4';
    
    

end

dlmwrite([output_dir 'time_r.txt'], [rs', times_srmf', times_lens'], 'delimiter', '\t');




%% ==========================================================
%% fix rank = 10, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix rank = 10, loss rate = 0.5:\n');

r0 = 10;
loss_rate = 0.5;

ss = [50, 100, 250, 500, 750];
times_srmf = zeros(1, length(ss));
times_lens = zeros(1, length(ss));


for si = 1:length(ss)
    s = ss(si);

    D = rand(s, s) * 5;
    D = D/mean(mean(D));
    [m, n] = size(D);
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(si) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: size=%dx%d: %f\n', size(D), times_lens(si));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(si) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(si));

end

dlmwrite([output_dir 'time_s.txt'], [ss', times_srmf', times_lens'], 'delimiter', '\t');



%% ==========================================================
%% fix rank ratio = 0.2, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix rank = 10, loss rate = 0.5:\n');


loss_rate = 0.5;
rank_rate = 0.2;

ss = [50, 100, 250, 500, 750];
times_srmf = zeros(1, length(ss));
times_lens = zeros(1, length(ss));


for si = 1:length(ss)
    s = ss(si);
    r0 = ceil(s * rank_rate);

    D = rand(s, s) * 5;
    D = D/mean(mean(D));
    [m, n] = size(D);
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(si) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: size=%dx%d: %f\n', size(D), times_lens(si));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(si) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(si));

end

dlmwrite([output_dir 'time_s.txt'], [ss', times_srmf', times_lens'], 'delimiter', '\t');




%% ==========================================================
%% fix m = 100, rank = 10, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix m = 100, rank = 10, loss rate = 0.5:\n');

m = 100;
r0 = 10;
loss_rate = 0.7;

ns = [50, 100, 250, 500, 750, 1000];
times_srmf = zeros(1, length(ns));
times_lens = zeros(1, length(ns));


for ni = 1:length(ns)
    n = ns(ni);

    D = rand(m, n) * 5;
    % fprintf('rank of D=%d\n', rank(D));
    D = D/mean(mean(D));
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(ni) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: size=%dx%d: %f\n', size(D), times_lens(ni));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(ni) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(ni));

end

dlmwrite([output_dir 'time_n.txt'], [ns', times_srmf', times_lens'], 'delimiter', '\t');




%% ==========================================================
%% fix n = 100, rank = 10, loss rate = 50%: 
%% ==========================================================
fprintf('=======================\nfix n = 100, rank = 10, loss rate = 0.5:\n');

n = 100;
r0 = 10;
loss_rate = 0.5;

ms = [50, 100, 250, 500, 750, 1000];
times_srmf = zeros(1, length(ms));
times_lens = zeros(1, length(ms));


for mi = 1:length(ms)
    m = ms(mi);

    D = rand(m, n) * 5;
    D = D/mean(mean(D));
    
    
    E = zeros(size(D));
    E = rand(size(D)) < loss_rate;
    M = ~E;

    %% ======================================
    %% LENS3
    
    r = r0;
    A = speye(m,m);
    B = speye(m,m);
    C = speye(m,m);
    F = ones(m,n);
    soft = 1;
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';

    exp_time_lens = 0;
    for expi = 1:EXP_TIMES
        [x,y,z,w,enable_B,sig,gamma, time_lens] = lens3(D,r,A,B,C,E,P,Q,K,[],soft, rho);
        exp_time_lens = exp_time_lens + time_lens;
    end
    
    times_lens(mi) = exp_time_lens / EXP_TIMES;
    fprintf('LENS: size=%dx%d: %f\n', size(D), times_lens(mi));
    

    %% ====================================
    %% SRMF
    r = r0;
    epsilon = 0.01;
    alpha = 10;
    lambda = 1e-4;
    sx = size(D);

    exp_time_srmf = 0;
    for expi = 1:EXP_TIMES
        tic;

        [A, b] = XM2Ab(D, M);
        config = ConfigSRTF(A, b, D, M, sx, r, r, epsilon, true);
        [u4, v4] = SRMF(D, r, M, config, alpha, lambda, max_itr);
        
        exp_time_srmf = exp_time_srmf + toc;
    end
    
    times_srmf(mi) = exp_time_srmf / EXP_TIMES;
    fprintf('SRMF: size=%dx%d: %f\n\n', size(D), times_srmf(mi));

end

dlmwrite([output_dir 'time_m.txt'], [ms', times_srmf', times_lens'], 'delimiter', '\t');




