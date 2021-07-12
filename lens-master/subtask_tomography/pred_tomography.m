%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Yi-Chao Chen
%% 2013.10.08 @ UT Austin
%%
%% - Input:
%%
%%
%% - Output:
%%
%%
%% e.g.
%%
%%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mad_lens3, mad_base, mad_srmf, mad_gvt, mad_tg, mad_tg_lens3, mad_tg_srmf, mad_tg_base] = pred_tomography(num_anom, sigma_mag, trace_name)
% function pred_tomography()
    % addpath('/u/yichao/anomaly_compression/utils/lens');
    % addpath('/u/yichao/anomaly_compression/utils/mirt_dctn');
    % addpath('/u/yichao/anomaly_compression/utils/compressive_sensing');
    % addpath('/u/yichao/anomaly_compression/utils');
    addpath('/u/yzhang/MRA/Matlab');
    addpath('/u/yzhang/MRA/TrafficMatrix')

    %% --------------------
    %% DEBUG
    %% --------------------
    DEBUG0 = 0;
    DEBUG1 = 1;
    DEBUG2 = 1;
    DEBUG3 = 1;
    DEBUG4 = 1;  %% results

    if strcmp(trace_name, 'abilene')
        ABILENE = 1;
        GEANT = 0;
    elseif strcmp(trace_name, 'geant')
        ABILENE = 0;
        GEANT = 1;
    else 
        %% use abilene in default
        ABILENE = 1;
        GEANT = 0;
    end


    %% --------------------
    %% Variable
    %% --------------------
    % input_dir  = '/u/yichao/anomaly_compression/condor_data/abilene/';
    input_dir  = '/u/yzhang/MRA/data/';

    
    r0 = 8;
    lambda = 1e-4;

    % sigma_mag = 1;  %% anomaly size
    % num_anom = 0.05;     %% ratio of anomalies
    sigma_noise = 0; %% noise size

    loss_rate = 1;
    


    %% --------------------
    %% Check input
    %% --------------------
    % if nargin < 1, arg = 1; end
    % if nargin < 1, arg = 1; end


    %% --------------------
    %% Main starts
    %% --------------------


    %% --------------------
    %% load data
    %% --------------------
    if ABILENE
        X = load([input_dir 'AbileneAnukool/raw/X']); %% 1008x121
        A = load([input_dir 'AbileneAnukool/raw/A']); %% 41x121
        % X = X/max(X(:));
        X = X';
        N = sqrt(size(X,1));
    elseif GEANT
        link_file = [input_dir 'GeantTotemAnon/TM/2005/04/topology-anonymised.links'];
        files = dir([input_dir 'GeantTotemAnon/TM/2005/04/IntraTM-2005-04-*.xml']);
        
        t0 = 0;
        tmax = 7*24*4;
        X = [];
        for i = 1:tmax
            file = files(t0+i).name;
            tm_file = [input_dir 'GeantTotemAnon/TM/2005/04/' file '.tm'];
            tm_data = textread(tm_file, '', 'commentstyle', 'shell', 'delimiter', ' ');
            X = [X reshape(tm_data,[],1)];
        end
        % X = X/max(X(:));
        N = sqrt(size(X,1));

        L = load([input_dir 'GeantTotemAnon/topo/links.txt']);
        A = RoutingMatrix(sparse(L(:,1),L(:,2),1,N,N));
    end
    fprintf('size X: %dx%d\n', size(X));
    fprintf('size A: %dx%d\n', size(A));
    % return
    



    %% --------------------
    %% add anomalies
    %% --------------------
    if DEBUG2, fprintf('add anomalies\n'); end

    [m,n] = size(X);
    ny = floor(m*n*num_anom);
    % fprintf('  # anomalies = %d\n', ny);
    Y = sparse(m,n);
    % fprintf('size Y: %dx%d\n', size(Y));

    ewma_alpha = 0.9;
    ewma_pred = X;
    for ti = 2:size(X,2)
        ewma_pred(:, ti) = (1-ewma_alpha) * ewma_pred(:, ti-1) + ewma_alpha * X(:, ti-1);
    end
    dif = abs(X - ewma_pred);
    dif = sort(dif(:), 'descend');
    % anomaly_base = mean(mean(dif(1:2)));
    anomaly_base = dif(1);
    % fprintf('  anomaly base = %f\n', anomaly_base/max(D(:)));

    Y(randsample(m*n, ny)) = anomaly_base * sign(randn(ny, 1)) .* (sigma_mag);
    % fprintf('size Y: %dx%d\n', size(Y));
    

    %% --------------------
    %% add noise
    %% --------------------
    if DEBUG2, fprintf('add noise\n'); end

    Z = randn(m,n) * max(X(:)) * sigma_noise;
    X = max(0, X + Y + Z);


    X = X/max(X(:));
    N = sqrt(size(X,1));



    %% --------------------
    % add the additional constraints on row/col sums
    %% --------------------
    if DEBUG2, fprintf('add the additional constraints on row/col sums\n'); end

    if ABILENE
        Ind = reshape(1:N*N,N,N);
        for i = 1:N
            row = zeros(1,N*N);
            row(Ind(i,:)) = 1;
            A = [A; row];
            row = zeros(1,N*N);
            row(Ind(:,i)) = 1;
            A = [A; row];
        end
    end

    % D = load([input_dir 'Y']); %% 1008x41
    D = A*X;
    fprintf('size A: %dx%d\n', size(A));
    fprintf('size D: %dx%d\n', size(D));



    %% --------------------
    %% Drop TM elements
    %% --------------------
    if DEBUG2, fprintf('Drop TM elements\n'); end

    sx = size(X);
    nx = prod(sx);
    n  = length(sx);

    M = DropValues(N,N,sx(n),1,loss_rate,'elem','ind');
    M = reshape(M,sx);
    E = ~M;
    if DEBUG3, 
        fprintf('  loss rate = %f\n', nnz(E) / prod(size(E))); 
        fprintf('  size of E: %dx%d\n', size(E));
    end

    meanX2 = mean(X(:).^2);
    meanX = mean(X(:));


    %% ====================================
    %% LENS_ST
    if DEBUG2, fprintf('- LENS\n'); end

    mad_lens3 = 0;
    [m,n] = size(D);
    E = zeros(m,n);
    % B = speye(m);
    B = A;
    C = speye(m);
    
    soft = 1;
    sigma0 = [];
    this_r = r0 * 4;
    rho = 1.01;

    [m,n] = size(X);
    CC = zeros(1, n-1); CC(1,1) = 1;
    RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1; % P: mxm, x: mxn, Q: nxn
    P = speye(m,m);
    Q = toeplitz(CC,RR);
    K = P*zeros(m,n)*Q';
    if DEBUG3, fprintf('  num non-zero of K: %d\n', nnz(K)); end
    
    [x,y,z,w,enable_B,sig,gamma] = lens3(D,this_r,A,B,C,E,P,Q,K,[],soft,rho);
    
    if (enable_B)
        est1 = x+y;
        est2 = A*x+B*y;
    else
        est1 = x;
        est2 = A*x;
    end  
    Z = est1;
    err_lens3 = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_lens3 = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_lens3 = corrcoef(X(~M),max(0,Z(~M)));
    Z_lens3 = Z;
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_lens3, mad_lens3, cc_lens3(1,2)); end
    

    %% ====================================
    %% Base
    if DEBUG2, fprintf('- Base\n'); end

    [C1,d1] = AB2Cd(A,D);
    [C2,d2] = XM2Ab(X,M);
    C = [C1;C2];
    d = [d1;d2];
    BaseX = EstimateBaseline(C,d,sx);
    BaseX(M==1) = X(M==1);
    BaseX = max(0,BaseX);
    err_base = mean((X(~M)-max(0,BaseX(~M))).^2)/meanX2;
    mad_base = mean(abs((X(~M)-max(0,BaseX(~M)))))/meanX;
    cc_base = corrcoef(X(~M),max(0,BaseX(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_base, mad_base, cc_base(1,2)); end


    %% ====================================
    %% SRMF
    if DEBUG2, fprintf('- SRMF\n'); end
    r = r0;

    sx = size(X);
    nx = prod(sx);
    n  = length(sx);

    [u,v] = SRMF2(A,D,X,r,M,cell(1,n),1,lambda,50);
    Z = tensorprod(u,v);
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    Z_srmf = Z;

    err_srmf = mean((X(~M)-max(0,Z_srmf(~M))).^2)/meanX2;
    mad_srmf = mean(abs((X(~M)-max(0,Z_srmf(~M)))))/meanX;
    cc_srmf = corrcoef(X(~M),max(0,Z_srmf(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_srmf, mad_srmf, cc_srmf(1,2)); end


    %% ====================================
    %% gravity solutions
    if DEBUG2, fprintf('gravity solutions\n'); end

    sx = size(X);
    nx = prod(sx);
    n  = length(sx);

    Z = zeros(N*N,sx(n));
    for i = 1:sx(n)
      xi = reshape(X(:,i),N,N);
      Z(:,i) = reshape(sum(xi,2)*sum(xi,1)/sum(sum(xi)),[],1);
    end
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    err_gvt = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_gvt = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_gvt = corrcoef(X(~M),max(0,Z(~M)));
    Z_gvt = Z;
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_gvt, mad_gvt, cc_gvt(1,2)); end


    %% ====================================
    % tomogravity solutions
    if DEBUG2, fprintf('tomogravity solutions\n'); end

    Z = zeros(N*N,sx(n));
    for i = 1:sx(n)
      idx = find(M(:,i));
      Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
      Ai = [A;Mi];
      Bi = [D(:,i); X(idx,i)];
      Z(:,i) = entsolve(Ai,Z_gvt(:,i),Bi,lambda);
    end
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    Z_tg = Z;
    err_tg = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_tg = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_tg = corrcoef(X(~M),max(0,Z(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_tg, mad_tg, cc_tg(1,2)); end


    %% ====================================
    % SRMF + tomogravity
    if DEBUG2, fprintf('SRMF + tomogravity\n'); end
    
    Z = zeros(N*N,sx(n));
    for i = 1:sx(n)
      idx = find(M(:,i));
      Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
      Ai = [A;Mi];
      Bi = [D(:,i); X(idx,i)];
      Z(:,i) = entsolve(Ai,Z_srmf(:,i),Bi,lambda);
    end
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    err_tg_srmf = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_tg_srmf = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_tg_srmf = corrcoef(X(~M),max(0,Z(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_tg_srmf, mad_tg_srmf, cc_tg_srmf(1,2)); end


    %% ====================================
    % LENS3 + tomogravity
    if DEBUG2, fprintf('LENS3 + tomogravity\n'); end
    
    Z = zeros(N*N,sx(n));
    for i = 1:sx(n)
      idx = find(M(:,i));
      Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
      Ai = [A;Mi];
      Bi = [D(:,i); X(idx,i)];
      Z(:,i) = entsolve(Ai,Z_lens3(:,i),Bi,lambda);
    end
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    err_tg_lens3 = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_tg_lens3 = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_tg_lens3 = corrcoef(X(~M),max(0,Z(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_tg_lens3, mad_tg_lens3, cc_tg_lens3(1,2)); end


    %% ====================================
    % tomogravity + base
    if DEBUG2, fprintf('SRMF + base\n'); end

    Z = zeros(N*N,sx(n));
    for i = 1:sx(n)
      idx = find(M(:,i));
      Mi = sparse(1:length(idx),idx,1,length(idx),N*N);
      Ai = [A;Mi];
      Bi = [D(:,i); X(idx,i)];
      Z(:,i) = entsolve(Ai,BaseX(:,i),Bi,lambda);
    end
    Z(M==1) = X(M==1);
    Z = max(0,Z);
    err_tg_base = mean((X(~M)-max(0,Z(~M))).^2)/meanX2;
    mad_tg_base = mean(abs((X(~M)-max(0,Z(~M)))))/meanX;
    cc_tg_base = corrcoef(X(~M),max(0,Z(~M)));
    if DEBUG4, fprintf('  mse=%f, mae=%f, cc=%f\n', err_tg_base, mad_tg_base, cc_tg_base(1,2)); end

end