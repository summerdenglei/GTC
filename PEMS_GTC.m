%%
clear;

addpath(genpath('solvers'));
addpath(genpath('lens-master'));
mean_num=1;
% load('pems04_288_59_307.mat')
load('pems08_288_62_170.mat')


%%
X=T;
% i=0.5;
lamda=50;
alpha=0.001;
st_or_not=0;     %0:no st 1:st
RSE=zeros(1,9);

%% load data
for rate=2
    opq=0.1*rate; % sampling rate
    i=5;
    for j=1:mean_num
        %             for lamda=100
        opqrst=fix(opq*10);
        %    for i=0.7
        p = opq;
        
        % X = A/max(abs(A(:)));
        [n1,n2,n3] = size(X);
        maxP = max(X(:));
        %  Omega = find(rand(n1*n2*n3,1)<p);
        
        %% 随机缺失
        rand('seed',10);
        Omega=randperm(n1*n2*n3,round(p*n1*n2*n3))     ;
        O= zeros(size(X))               ;
        O(Omega)=1;
        data=X(Omega);
        known=Omega;
        
        %% tensor completion
        % t0=tic;
        rank_strategy=-1;
        iSS=fix(i/2);
        jj=fix(lamda/10);
        
        Ts=X.*O;
        maxiter=1;
        T0=rand(n1,n2,n3);
        for iter=1:maxiter
            [ TC,para,iterRSE] = TCTF_video(Ts,Omega,rank_strategy,p,lamda,alpha,i,2,T0);%i是秩
            di=X-TC;
            di=di.*(1-O);
            %
            error1=norm(di(:))/norm(X(:))
        end
    end
    

end



function [ TC,para ,RSE] =TCTF_video( X,Omega,rank_strategy,p,lamda,alpha,rank,st_or_not,T0)

%% produce data

data=X(Omega);
known=Omega;

[n1,n2,n3]=size(X);
B=zeros(size(X));
B(Omega)=1;
%% our method
opts = [];
opts.maxIter=100;
opts.tol = 1e-4;
opts.Mtr = X;

opts.alpha_adj = 0;
opts.rank_adj = -1*ones(1,n3);
opts.rank_inc = 1*ones(1,n3);
opts.rank_min = 1*ones(1,n3);

opts.lamda=lamda;
opts.alpha=alpha;
opts.rank_strategy=rank_strategy;%1:increase rank,-1:decrease rank
%initialize rank
sampling_rate=p;

EstCoreNway = round(rank*ones(1,n3));
% opts.rank_max = 3*ones(1,n3);
opts.rank_max =round(10*EstCoreNway);
Nway=[n1,n2,n3];
[~,~,TC,~,~,truerel,RSE] = TCTF_tensorGFT_solver(X,B,data,known,Nway,EstCoreNway,opts,T0);

%% compute PSNR
maxP=max(X(:));
TC = max(TC,0);
TC = min(TC,maxP);

diff=X-TC;
rse(rank)=norm(diff(:))/norm(X(:));
diff_w=B.*diff;
X_w=B.*X;
wre=norm(diff_w(:))/norm(X_w(:));
psnr= PSNR(X,TC,maxP);

para.rse=rse;
para.wre=wre;
para.psnr=psnr;
para.truerel=truerel;
% end
end


function [X,Y,TC,TotalRes,TrueRel,truerel,RSE] = TCTF_tensorGFT_solver(Oridata,B,data,known,Nway,coreNway,opts,T0)
%% Data preprocessing and initialization 2020.1.10

load('L_PeMS08.mat') % corresponding Laplacian matrix
load('pems08_288_62_170.mat');


Cons = cell(1,2);
S=L;

F = sparse(Cons{1});
G = sparse(Cons{2});
% get rid of empty rows in F and G
nz = find(any(F,2));
F = F(nz,:);
nz = find(any(G,2));
G = G(nz,:);


n1=Nway(1);
n2=Nway(2);
n3=Nway(3);
rank_adj = opts.rank_adj;
rank_min = opts.rank_min;
rank_max = opts.rank_max;
rank_str=opts.rank_strategy;
tol=opts.tol;
maxit=opts.maxIter;

lamda=opts.lamda;
alpha=opts.alpha;
% diff=1e-05;

[known,id] = sort(known);
data = data(id);
normdata=norm(data(:));
normM=norm(opts.Mtr(:));

%rank inc
rank_inc = ones(1,n3);
rank_inc_num = sum(rank_adj==1);
%% initialization X and Y
TC=T0;
TC(known)=data;
TC=tensor_gft(TC,S);
% TC(:,:,1)=TC(:,:,1)+(TC(:,:,2)-real(TC(:,:,2)));
for i = 1:n3
    %     [Uk,Sigmak,Vk]=svds(TC(:,:,i),coreNway(i));
    [Uk,Sigmak,Vk]=svds(TC(:,:,i));
    X{i} = Uk*sqrt(Sigmak);
    Y{i} = sqrt(Sigmak)*Vk';
end
for i=1:n3
    E{i}=B(:,:,i).*(TC(:,:,i)-Oridata(:,:,i));
    EE(:,:,i)=B(:,:,i).*Oridata(:,:,i);
end
E_FFT=fft(Oridata,[],3);
EE_FFT=fft(EE,[],3);
res0=0;
% res0 = zeros(1,n3);
TotalRes = 0;
res = res0;
for idxx=1:n3
    res0(idxx) = norm(E{idxx}(:));
end
% res0 = norm(TC(known)-data);
%% compute the initialization residual
TotalRes = [];
TrueRel = [];
C=zeros(n1,n2,n3);
for n = 1:n3
    C(:,:,n)=X{n}*Y{n};
end
% V=C;
TC=tensor_igft(C,S);
TotalRes = [TotalRes,norm(TC(known)-data)];
TrueRel = [TrueRel, norm(TC(:)-opts.Mtr(:))/norm(opts.Mtr(:))];

TC(known) = data;
TC=real(TC);
C=tensor_gft(TC,S);
% V1=C;
rho=0.95;
mu=1.01;
k=1;
reschg=1;
% reschg = ones(1,n3);
reschg_tol = 1e-2;

%%
order=14;
a=ones(1,order+1);
a(order/2+1)=-1*order;
c=zeros(1,n1-order-1);
b=[a,c];
TM1=triu(toeplitz(b));
%%

%%
Tlength=n2;
z = ones(Tlength,1);
delta_T = spdiags([-z z], [0 1], Tlength, Tlength);
delta_T(Tlength,1) = 1;
TM=full(delta_T);
%%


while (k<=maxit)
    
    if k==1
        lastv=0;
    else
        lastv=v;
    end
    %% update (X,Y)
    for n = 1:n3
        
        
        Cons{1}=TM1;
        Cons{2}=(TM);
        
        [U,V] = TCTF_SRMF(X{n},Y{n}',C(:,:,n),coreNway(n),ones(n1,n2),Cons,alpha,lamda);
        X{n}=U;
        Y{n}=V';
        Xsq{n} = X{n}'*X{n};
        C(:,:,n)=X{n}*Y{n};
        
        F = sparse(Cons{1});
        G = sparse(Cons{2});
        
    end
    
    
    TC=tensor_igft(C,S);
    
    for ix=1:n3
        res(ix) = norm(B(:,:,ix).*(TC(:,:,ix)-Oridata(:,:,ix)));
    end
    
    ratio = res./res0;
    reschg = abs(1-ratio);
    
    %% adjust the rank of (X,Y)
    if rank_adj(n) == -1 && rho<1 && rank_str==-1
        max_k=max(coreNway);
        sum_k=sum(coreNway);
        sigmas=zeros(max_k*n3,1);
        for i=1:n3
            s = svd(Xsq{i});
            sigmas((i-1)*max_k+1:(i-1)*max_k+length(s))=s;
            
        end
        [dR,id]=sort(sigmas,'descend');
        drops = dR(1:sum_k-1)./dR(2:sum_k);
        [dmx,imx] = max(drops);
        rel_drp = (sum_k-1)*dmx/(sum(drops)-dmx);
        if rel_drp>10
            thold=rho*sum(dR);
            iidx=0;ss=0;
            len=length(dR);
            for i=1:len
                ss=ss+dR(i);
                if(ss>thold)
                    iidx=i;
                    break;
                end
            end
            if(iidx>sum(rank_min(n)))
                idx=floor((id(iidx+1:sum_k)-1)/max_k);
                for n=1:n3
                    num=length(find(idx==n-1));
                    if(num>0)
                        if coreNway(n)-num>rank_min(n)
                            coreNway(n) = coreNway(n)-num;
                        else
                            coreNway(n) = rank_min(n);
                        end
                        [Qx,Rx] = qr(X{n},0);
                        [Qy,Ry] = qr(Y{n}',0);
                        [U,S1,V] = svd(Rx*Ry');
                        sigv = diag(S1);
                        X{n} = full(Qx*U(:,1:coreNway(n))*spdiags(sigv(1:coreNway(n)),0,coreNway(n),coreNway(n)));
                        
                        Y{n} = (Qy*V(:,1:coreNway(n)))';
                        C(:,:,n)=X{n}*Y{n};
                    end
                end
            end
            rho=rho*mu;
        end
    end
    
    %% increase the estimated rank
    
    for n=1:n3
        if coreNway(n) < rank_max(n) && reschg(n)< reschg_tol && rank_str==1
            % if coreNway(n) < rank_max(n)  && rank_str==1
            
            [Q,R] = qr(Y{n}',0);
            for ii = 1:rank_inc(n)
                rdnx = randn(n2,1);
                rdnx = rdnx-Q*(Q'*rdnx);
                rdnx = rdnx/norm(rdnx);
                Q = [Q,rdnx];
                zerox=zeros(n1,1);
            end
            Y{n} = Q';
            %          X{n}=[X{n},zerox];
            coreNway(n) = coreNway(n)+rank_inc(n);
            if coreNway(n) >= rank_max(n)
                rank_inc_num = rank_inc_num - 1;
            end
            X{n} = C(:,:,n)*Y{n}';
            
        end
    end
    
    %% judge whether converges
    
    TC=tensor_igft(C,S);
    
    
    res1=norm(TC(:)-opts.Mtr(:))/normM;
    
    %% CONSTRAINT MATRIX
    TCC=real(TC);
    % E=TC(known)-Oridata(known);
    for i=1:n3
        E{i}=B(:,:,i).*(TCC(:,:,i)-Oridata(:,:,i));
    end
    for i=1:n3
        W{i}=Cons{1}*TCC(:,:,i);
        TT{i}=TCC(:,:,i)*Cons{2}';
        
    end
    %     f1=norm(E(:),'fro');
    for i=1:n3
        f1(i)=norm(E{i},'fro');
        f2(i)=norm(X{i},'fro');
        f3(i)=norm(Y{i},'fro');
        f4(i)=norm(W{i},'fro');
        f5(i)=norm(TT{i},'fro');
        a(i)=f1(i)^2;
        b(i)=f2(i)^2+f3(i)^2;
        c(i)=f4(i)^2+f5(i)^2;
        v(i)=(a(i)+lamda*b(i)+alpha*c(i));
        %     v(i)=a(i)+0.5*b(i);
    end
    
    v=sum(v(:));
    diff=abs(v-lastv);
    if mod( k, 1) == 0
        disp(['k ' num2str(k) '   v  ' num2str(v)   '   diff  ' num2str(diff)]  );
    end
    
    if k<maxit+1
        TC(known) = data;
        TC=real(TC);%结果 只取实数
    else
        TC=real(TC);
    end
    %%
    
    truerel(k) = norm(TC(:)-Oridata(:))/norm(Oridata(:));
    if diff<tol
        break;
    else
        k=k+1;
    end
    res0 = res;
    %       TC(known) = data;
    
    %% update C
    C=tensor_gft(TC,S);
    
    di=T-TC;
    RSE(k)=norm(di(:))/norm(T(:));
end
end
