%% 用GFT的恢复结果作为初始化结果，再进行fft恢复，循环多次
clear;

% addpath(genpath('G:\lkt code&paper\TCTF_code _speed\TCTF-code'));
% addpath(genpath('test_video'));
addpath(genpath('solvers'));
addpath(genpath('lens-master'));
% rand('seed',2013); randn('seed',2013);


mean_num=1;
load('pems08_288_62_170.mat')
% X = permute(A,[2,3,1]);
% X = T(8*12:20*12,:,:);
X=T(:,:,1:20);
% i=0.5;
lamda=50;
alpha=0.001;
st_or_not=0;     %0:no st 1:st
RSE=zeros(1,9);

%% load data
for rate=1:9
    opq=0.1*rate;
    i=5; %rank
    for j=1:mean_num%平均次数
        %             for lamda=100
        opqrst=fix(opq*10);
        %    for i=0.7
        p = opq;
        
        % X = A/max(abs(A(:)));
        [n1,n2,n3] = size(X);
        maxP = max(X(:));
        %  Omega = find(rand(n1*n2*n3,1)<p);
        
        %% 随机缺失
        Omega=randperm(n1*n2*n3,round(p*n1*n2*n3))     ;
        O= zeros(size(X))               ;
        O(Omega)=1;
        data=X(Omega);
        known=Omega;

        %% 随机空间缺失
           id3=randperm(n3,round(p*n3));
           O= zeros(size(X))               ;
           for k3=1:length(id3)
               O(:,:,k3)=1;
           end
           Omega0=find(O);
           Omega=Omega0';
        %% 随机时间缺失
%         id=randperm(n2*n3,round(p*n2*n3));
%         O= zeros(size(X))               ;
%         Om=zeros(n2,n3);
%         Om(id)=1;
%         for k3=1:n1
%             O(k3,:,:)=Om;
%         end
%         Omega=find(O);

        %%                 Omega=find(O==1)';
        rank_strategy=-1;%1:increase rank,-1:decrease rank
        %                 r=5;
        %% tensor completion
        % t0=tic;
        iSS=fix(i/2);
        jj=fix(lamda/10);
        tic
        %%st
        %                 [ TC_st,para_st] = TCTF_video( X,Omega,rank_strategy,p,lamda,alpha,i,1);
        %                 toc
        %                 t1=toc;
        %                 tt1(iSS)=t1;
        % %                 diff=X(O==0)-TC_st(O==0);
        % %                 rse_REAL_tftc_st{opqrst}(iSS,jj)=norm(diff(:))/norm(X(O==0))
        %                 di=X-TC_st;
        %                 rse_tftc_20_st{opqrst}(iSS,jj)=norm(di(:))/norm(X(:))
        %                 NMAE_st=sum(abs(di(:)))/sum(abs(X(:)))
        %%no st
        Ts=X.*O;
        maxiter=1;
        T0=rand(n1,n2,n3);
        for iter=1:maxiter
            [ TC,para] = TCTF_video(Ts,Omega,rank_strategy,p,lamda,alpha,i,2,T0);%i是秩
            %
            %                 diff=X(O==0)-TC(O==0);
            %                 rse_REAL_tftc{opqrst}(iSS,jj)=norm(diff(:))/norm(X(O==0))
            di=X-TC;
            %
            error1(rate)=norm(di(:))/norm(X(:));
            continue
            TC2=permute(Ts,[3,1,2]) ;
            O2=permute(O,[3,1,2]) ;
            T1=permute(TC,[3,1,2]) ;
            Omega2=find(O2);
            Omega2=Omega2';
            [TC_st2,~] = TCTF_video(TC2,Omega2,rank_strategy,p,lamda,alpha,i,1,T1);
            e2=abs(TC_st2-A);
            error2(rate,iter)=norm(e2(:))/norm(A(:));
            T0=permute(TC_st2,[2,3,1]);
            
            
            
            
        end
    end
    
    %     real_tftc_mean{opqrst}=sum(rse_REAL_tftc{opqrst},2)/j;
    %     rse_tftc_mean{opqrst}=sum(rse_tftc_20{opqrst},2)/j;
    %         rse_tftc_st_mean{opqrst}=sum(rse_tftc_20_st{opqrst},2)/j;
    %         real_tftc_st_mean{opqrst}=sum(rse_REAL_tftc_st{opqrst},2)/j;
    %     end
    %     temp=rseTemp(rate,:);
%     RSE2(rate)=error2(rate,maxiter);
    RSE1(rate)=error1(rate);
end
figure
a=0.1:0.1:0.9;
plot(a,RSE1,'k--');
% legend('order=30')


function [ TC,para ] =TCTF_video( X,Omega,rank_strategy,p,lamda,alpha,rank,st_or_not,T0)

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
% switch sampling_rate
%     case {0.1}
%         rank=4;
%     case {0.2}
%         rank=2;
%     case {0.3}
%         rank=6;
%     case {0.4}
%         rank=14;
%     case {0.5}
%         rank=6;
%     case {0.6}
%         rank=29;
%     case {0.7}
%         rank=36;
%     case {0.8}
%         rank=41;
%     otherwise
%         rank=29;
% end
%  rank=4;
% for rank=1:10
EstCoreNway = round(rank*ones(1,n3));
% opts.rank_max = 3*ones(1,n3);
opts.rank_max =round(10*EstCoreNway);
Nway=[n1,n2,n3];
% end
switch st_or_not
    case 1
        [~,~,TC,~,~,truerel] = TCTF_ST_solver(X,B,data,known,Nway,EstCoreNway,opts,T0);
    case 2
        [~,~,TC,~,~,truerel] = TCTF_tensorGFT_solver(X,B,data,known,Nway,EstCoreNway,opts,T0);
end
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

function [X,Y,TC,TotalRes,TrueRel,truerel] = TCTF_ST_solver(Oridata,B,data,known,Nway,coreNway,opts,T0)
%% Data preprocessing and initialization
% load('spatial_matrix_half.mat')
% load('temporal_matrix_half.mat')
% % load('8road_spatial_matrix.mat')
% % load('spatial_144_175_9.mat')
% load('L_FZ.mat')

% load('spatial_bjr_48_144_7.mat')
% load('temporal_bjr_48_144_7.mat')
% SM=S;TM=T;
Cons = cell(1,2);

load L_FZ.mat
load temporal_matrix_half.mat
Cons{1}=S;
Cons{2}=T;
% Cons{1}=SM;
% Cons{2}=TM;
F = sparse(Cons{1});
G = sparse(Cons{2});
% get rid of empty rows in F and G
nz = find(any(F,2));
F = F(nz,:);%去掉没有值的行
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
TC=fft(TC,[],3);%频域C 第一slice为实数，其他为复数 为什么？
% TC(:,:,1)=TC(:,:,1)+(TC(:,:,2)-real(TC(:,:,2)));
for i = 1:n3
    [Uk,Sigmak,Vk]=svds(TC(:,:,i),coreNway(i));
    X{i} = Uk*sqrt(Sigmak);
    Y{i} = sqrt(Sigmak)*Vk';%频域XY
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
    C(:,:,n)=X{n}*Y{n};%频域C
end
% V=C;
TC=ifft(C,[],3);%时域TC,已经是实数
TotalRes = [TotalRes,norm(TC(known)-data)];
TrueRel = [TrueRel, norm(TC(:)-opts.Mtr(:))/norm(opts.Mtr(:))];

TC(known) = data;
TC=real(TC);%取实数
C=fft(TC,[],3);%频域C
% V1=C;
rho=0.95;
mu=1.01;
k=1;
reschg=1;
% reschg = ones(1,n3);
reschg_tol = 1e-2;

% for kk=1:n3
%         [A,b] = XM2Ab(Oridata(:,:,kk),B(:,:,kk));
%         Cons =ConfigSRTF(A,b,Oridata(:,:,kk),B(:,:,kk),[n1,n2],coreNway(kk));
%         ST(:,:,kk)=full(Cons{1});
%         TTT(:,:,kk)=full(Cons{2});
%
% %         ST(:,:,kk)=SM;
% %         TTT(:,:,kk)=TM;
% end
% ST_FFT=fft(ST,[],3);
% TT_FFT=fft(TTT,[],3);
% ST_FFT=ST;
% TT_FFT=TTT;
while (k<=maxit)
    if k==1
        lastv=0;
    else
        lastv=v;
    end
    %% update (X,Y)
    for n = 1:n3%除第一slice是实数，其他事复数
        
        %         Cons{1}=eye(n1);
        %         Cons{2}=eye(n2);
        
        [U,V] = TCTF_SRMF(X{n},Y{n}',C(:,:,n),coreNway(n),ones(n1,n2),Cons,alpha,lamda);
        X{n}=U;
        Y{n}=V';
        Xsq{n} = X{n}'*X{n};
        C(:,:,n)=X{n}*Y{n};
        
        F = sparse(Cons{1});
        G = sparse(Cons{2});
        %             V = myInverse(E{n},B(:,:,n),X{n},F*X{n},G,Y{n}',alpha,lamda);
        %             U = myInverse(E{n}',B(:,:,n)',Y{n}',G*Y{n}',F,X{n},alpha,lamda);
        %             X{n}=U;
        %             Y{n}=V';
        %             Xsq{n} = X{n}'*X{n};
        %             C(:,:,n)=X{n}*Y{n};
        
        %         X_A=alpha*(TM'*TM);
        %         X_B{n}=eye(coreNway(n))+Y{n}*(SM*SM')*Y{n}'*pinv(Y{n}*Y{n}')+lamda*pinv(Y{n}*Y{n}');
        %         X_C{n}=-C(:,:,n)*Y{n}'*pinv(Y{n}*Y{n}');
        %         X{n}=sylvester(X_A,X_B{n},X_C{n});
        %         Y_A{n}=(1/alpha*eye(coreNway(n))*pinv(X{n}'*X{n})*X{n}'*(TM'*TM)*X{n}+lamda/alpha*pinv(X{n}'*X{n}));
        %         Y_B=SM*SM';
        %         Y_C{n}=1/alpha*pinv(X{n}'*X{n})*X{n}'*C(:,:,n);
        %         Y{n}=sylvester(Y_A{n},Y_B,Y_C{n});
        %         Xsq{n} = X{n}'*X{n};
        %         C(:,:,n)=X{n}*Y{n};
        
        %         div_x=(B(:,:,n).*C(:,:,n)-EE{n})*Y{n}'+lamda*X{n}+alpha*S'*S*X{n};
        %         div_y=X{n}'*(B(:,:,n).*C(:,:,n)-EE{n})+lamda*Y{n}+alpha*Y{n}*T'*T;
        %                 X{n}=C(:,:,n)*Y{n}'*pinv(Y{n}*Y{n}');
        %                 Xsq{n} = X{n}'*X{n};
        %                 Y{n} = pinv(Xsq{n})*X{n}'*C(:,:,n);
        %                 X{n}=X{n}-alpha*div_x;
        %                 Y{n}=Y{n}-alpha*div_y;
        %                  C(:,:,n)=X{n}*Y{n};
        
        %         E{n}=B(:,:,n).*(TC(:,:,n)-Oridata(:,:,n));
        %
        %         diff_x=2*E{n}*Y{n}'+0.33*X{n}+0.33*TM'*TM*X{n};
        %         diff_y=2*X{n}'*E{n}+0.33*Y{n}+0.33*Y{n}*SM'*SM;
        %         X{n}=X{n}-(0.01/1+k)*diff_x;
        %         Y{n}=Y{n}-(0.01/1+k)*diff_y;
    end
    TC=ifft(C,[],3);
    for ix=1:n3
        res(ix) = norm(B(:,:,ix).*(TC(:,:,ix)-Oridata(:,:,ix)));
    end
    %          res=norm(TC(known)-data);
    ratio = res./res0;
    reschg = abs(1-ratio);
    %% adjust the rank of (X,Y)
    if rank_adj(n) == -1 && rho<1 && rank_str==-1
        max_k=max(coreNway);
        sum_k=sum(coreNway);
        sigmas=zeros(max_k*n3,1);
        for i=1:n3
            s = svd(Xsq{i});%返回X{n}'*X{n}奇异值
            sigmas((i-1)*max_k+1:(i-1)*max_k+length(s))=s;%用X{n}'*X{n}奇异值对sigma循环赋值1-coreNway(1)，coreNway(1)+1-coreNway(2)，...。。。
            %sigmas为所有切片的奇异值
        end
        [dR,id]=sort(sigmas,'descend');%所有切片奇异值降序排列
        drops = dR(1:sum_k-1)./dR(2:sum_k);
        [dmx,imx] = max(drops);
        rel_drp = (sum_k-1)*dmx/(sum(drops)-dmx);
        if rel_drp>10
            thold=rho*sum(dR);%rho*所有奇异值和
            iidx=0;ss=0;
            len=length(dR);
            for i=1:len
                ss=ss+dR(i);
                if(ss>thold)
                    iidx=i;%取前i个奇异值和,Sk,且<thold
                    break;
                end
            end
            if(iidx>sum(rank_min(n)))
                idx=floor((id(iidx+1:sum_k)-1)/max_k);
                for n=1:n3
                    num=length(find(idx==n-1));
                    if(num>0)%调整秩
                        if coreNway(n)-num>rank_min(n)
                            coreNway(n) = coreNway(n)-num;
                        else
                            coreNway(n) = rank_min(n);
                        end
                        [Qx,Rx] = qr(X{n},0);
                        [Qy,Ry] = qr(Y{n}',0);
                        [U,S,V] = svd(Rx*Ry');
                        sigv = diag(S);
                        X{n} = full(Qx*U(:,1:coreNway(n))*spdiags(sigv(1:coreNway(n)),0,coreNway(n),coreNway(n)));
                        %选取前coreNway(n)个奇异值
                        Y{n} = (Qy*V(:,1:coreNway(n)))';
                        C(:,:,n)=X{n}*Y{n};%频域 复数
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
            %         C(:,:,n)=X{n}*Y{n};
            %         if rank_inc_num == 0
            %             nstall = 0;
            %         end
            
            
        end
    end
    %% judge whether converges
    TC=ifft(C,[],3);
    %     res=norm(TC(known)-data)/normdata;
    %     res = norm(TC(known)-data);ratio = res./res0;   reschg = abs(1-ratio);
    res1=norm(TC(:)-opts.Mtr(:))/normM;
    %     if res<1e-8
    %         TC(known) = data;
    %         TC=real(TC);
    %         break;
    %     end
    
    %% CONSTRAINT MATRIX
    TCC=real(TC);
    % E=TC(known)-Oridata(known);
    for i=1:n3
        E{i}=B(:,:,i).*(TCC(:,:,i)-Oridata(:,:,i));
    end
    for i=1:n3
        W{i}=Cons{1}*TCC(:,:,i);
        TT{i}=TCC(:,:,i)*Cons{2}';
        
        %                 W{i}=zeros(10,10);
        %                 TT{i}=zeros(10,10);
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
    %     f2=sum(f2(:));f3=sum(f3(:));f4=sum(f4(:));f5=sum(f5(:));
    %     a=f1^2;
    %     b=f2^2+f3^2;
    %     c=f4^2+f5^2;
    %     v=a+0.01*b+0.001*c;
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
    %      if(k==maxit)&&diff<1e-4
    %     if(k==maxit)
    truerel(k) = norm(TC(:)-Oridata(:))/norm(Oridata(:));
    if diff<tol
        break;
    else
        k=k+1;
    end
    res0 = res;
    %       TC(known) = data;
    
    %% update C
    C=fft(TC,[],3);
end
end

function [X,Y,TC,TotalRes,TrueRel,truerel] = TCTF_tensorGFT_solver(Oridata,B,data,known,Nway,coreNway,opts,T0)
%% Data preprocessing and initialization 2020.1.10
% load('spatial_matrix_half.mat')
load('temporal_matrix_half.mat')
% load('8road_spatial_matrix.mat')
% load('spatial_144_175_9.mat')
load('L_PeMS08.mat')
%
% load('spatial_bjr_48_144_7.mat')
% load('temporal_bjr_48_144_7.mat')
% SM=S;TM=T;
Cons = cell(1,2);
S=L(1:20,1:20);
% Cons{1}=eye(Nway(1));
% Cons{2}=eye(Nway(2));
% Cons{1}=SM;
% Cons{2}=TM;
F = sparse(Cons{1});
G = sparse(Cons{2});
% get rid of empty rows in F and G
nz = find(any(F,2));
F = F(nz,:);%去掉没有值的行
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
TC=tensor_gft(TC,S);%频域C 第一slice为实数，其他为复数 为什么？
% TC(:,:,1)=TC(:,:,1)+(TC(:,:,2)-real(TC(:,:,2)));
for i = 1:n3
    %     [Uk,Sigmak,Vk]=svds(TC(:,:,i),coreNway(i));
    [Uk,Sigmak,Vk]=svds(TC(:,:,i));
    X{i} = Uk*sqrt(Sigmak);
    Y{i} = sqrt(Sigmak)*Vk';%频域XY
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
    C(:,:,n)=X{n}*Y{n};%频域C
end
% V=C;
TC=tensor_igft(C,S);%时域TC,已经是实数
TotalRes = [TotalRes,norm(TC(known)-data)];
TrueRel = [TrueRel, norm(TC(:)-opts.Mtr(:))/norm(opts.Mtr(:))];

TC(known) = data;
TC=real(TC);%取实数
C=tensor_gft(TC,S);%频域C
% V1=C;
rho=0.95;
mu=1.01;
k=1;
reschg=1;
% reschg = ones(1,n3);
reschg_tol = 1e-2;

%%
order=14;  %阶数必须是偶数
a=ones(1,order+1);
a(order/2+1)=-1*order;
c=zeros(1,n1-order-1);
b=[a,c];
TM1=triu(toeplitz(b));
%%
% Tlength=n1;
% z = ones(Tlength,1);
% delta_T = spdiags([-z z], [0 1], Tlength, Tlength);
% delta_T(Tlength,1) = 1;%fft对应，若是dct则(Tlength,Tlength-1) = 1;
% TM1=full(delta_T);
%%
Tlength=n2;
z = ones(Tlength,1);
delta_T = spdiags([-z z], [0 1], Tlength, Tlength);
delta_T(Tlength,1) = 1;%fft对应，若是dct则(Tlength,Tlength-1) = 1;
TM=full(delta_T);


while (k<=maxit)
    if k==1
        lastv=0;
    else
        lastv=v;
    end
    %% update (X,Y)
    for n = 1:n3%除第一slice是实数，其他事复数
%                 [A,b] = XM2Ab(Oridata(:,:,n),B(:,:,n));
%                 Cons =ConfigSRTF(A,b,Oridata(:,:,n),B(:,:,n),[n1,n2],coreNway(n));
%                 Cons{1}=eye(n1);
%                 Cons{2}=eye(n2);
                Cons{1}=TM1;
                Cons{2}=(TM);
%                 Cons{1}=ST(:,:,n);
%                 Cons{2}=TTT(:,:,n);
        %         EE_FFT
        [U,V] = TCTF_SRMF(X{n},Y{n}',C(:,:,n),coreNway(n),ones(n1,n2),Cons,alpha,lamda);
        X{n}=U;
        Y{n}=V';
        Xsq{n} = X{n}'*X{n};
        C(:,:,n)=X{n}*Y{n};
        
        F = sparse(Cons{1});
        G = sparse(Cons{2});
        %             V = myInverse(E{n},B(:,:,n),X{n},F*X{n},G,Y{n}',alpha,lamda);
        %             U = myInverse(E{n}',B(:,:,n)',Y{n}',G*Y{n}',F,X{n},alpha,lamda);
        %             X{n}=U;
        %             Y{n}=V';
        %             Xsq{n} = X{n}'*X{n};
        %             C(:,:,n)=X{n}*Y{n};
        
        %         X_A=alpha*(TM'*TM);
        %         X_B{n}=eye(coreNway(n))+Y{n}*(SM*SM')*Y{n}'*pinv(Y{n}*Y{n}')+lamda*pinv(Y{n}*Y{n}');
        %         X_C{n}=-C(:,:,n)*Y{n}'*pinv(Y{n}*Y{n}');
        %         X{n}=sylvester(X_A,X_B{n},X_C{n});
        %         Y_A{n}=(1/alpha*eye(coreNway(n))*pinv(X{n}'*X{n})*X{n}'*(TM'*TM)*X{n}+lamda/alpha*pinv(X{n}'*X{n}));
        %         Y_B=SM*SM';
        %         Y_C{n}=1/alpha*pinv(X{n}'*X{n})*X{n}'*C(:,:,n);
        %         Y{n}=sylvester(Y_A{n},Y_B,Y_C{n});
        %         Xsq{n} = X{n}'*X{n};
        %         C(:,:,n)=X{n}*Y{n};
        
        %         div_x=(B(:,:,n).*C(:,:,n)-EE{n})*Y{n}'+lamda*X{n}+alpha*S'*S*X{n};
        %         div_y=X{n}'*(B(:,:,n).*C(:,:,n)-EE{n})+lamda*Y{n}+alpha*Y{n}*T'*T;
        %                 X{n}=C(:,:,n)*Y{n}'*pinv(Y{n}*Y{n}');
        %                 Xsq{n} = X{n}'*X{n};
        %                 Y{n} = pinv(Xsq{n})*X{n}'*C(:,:,n);
        %                 X{n}=X{n}-alpha*div_x;
        %                 Y{n}=Y{n}-alpha*div_y;
        %                  C(:,:,n)=X{n}*Y{n};
        
        %         E{n}=B(:,:,n).*(TC(:,:,n)-Oridata(:,:,n));
        %
        %         diff_x=2*E{n}*Y{n}'+0.33*X{n}+0.33*TM'*TM*X{n};
        %         diff_y=2*X{n}'*E{n}+0.33*Y{n}+0.33*Y{n}*SM'*SM;
        %         X{n}=X{n}-(0.01/1+k)*diff_x;
        %         Y{n}=Y{n}-(0.01/1+k)*diff_y;
    end
    TC=tensor_igft(C,S);
    for ix=1:n3
        res(ix) = norm(B(:,:,ix).*(TC(:,:,ix)-Oridata(:,:,ix)));
    end
    %          res=norm(TC(known)-data);
    ratio = res./res0;
    reschg = abs(1-ratio);
    %% adjust the rank of (X,Y)
    if rank_adj(n) == -1 && rho<1 && rank_str==-1
        max_k=max(coreNway);
        sum_k=sum(coreNway);
        sigmas=zeros(max_k*n3,1);
        for i=1:n3
            s = svd(Xsq{i});%返回X{n}'*X{n}奇异值
            sigmas((i-1)*max_k+1:(i-1)*max_k+length(s))=s;%用X{n}'*X{n}奇异值对sigma循环赋值1-coreNway(1)，coreNway(1)+1-coreNway(2)，...。。。
            %sigmas为所有切片的奇异值
        end
        [dR,id]=sort(sigmas,'descend');%所有切片奇异值降序排列
        drops = dR(1:sum_k-1)./dR(2:sum_k);
        [dmx,imx] = max(drops);
        rel_drp = (sum_k-1)*dmx/(sum(drops)-dmx);
        if rel_drp>10
            thold=rho*sum(dR);%rho*所有奇异值和
            iidx=0;ss=0;
            len=length(dR);
            for i=1:len
                ss=ss+dR(i);
                if(ss>thold)
                    iidx=i;%取前i个奇异值和,Sk,且<thold
                    break;
                end
            end
            if(iidx>sum(rank_min(n)))
                idx=floor((id(iidx+1:sum_k)-1)/max_k);
                for n=1:n3
                    num=length(find(idx==n-1));
                    if(num>0)%调整秩
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
                        %选取前coreNway(n)个奇异值
                        Y{n} = (Qy*V(:,1:coreNway(n)))';
                        C(:,:,n)=X{n}*Y{n};%频域 复数
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
            %         C(:,:,n)=X{n}*Y{n};
            %         if rank_inc_num == 0
            %             nstall = 0;
            %         end
            
            
        end
    end
    %% judge whether converges
    TC=tensor_igft(C,S);
    %     res=norm(TC(known)-data)/normdata;
    %     res = norm(TC(known)-data);ratio = res./res0;   reschg = abs(1-ratio);
    res1=norm(TC(:)-opts.Mtr(:))/normM;
    %     if res<1e-8
    %         TC(known) = data;
    %         TC=real(TC);
    %         break;
    %     end
    
    %% CONSTRAINT MATRIX
    TCC=real(TC);
    % E=TC(known)-Oridata(known);
    for i=1:n3
        E{i}=B(:,:,i).*(TCC(:,:,i)-Oridata(:,:,i));
    end
    for i=1:n3
        W{i}=Cons{1}*TCC(:,:,i);
        TT{i}=TCC(:,:,i)*Cons{2}';
        
        %                 W{i}=zeros(10,10);
        %                 TT{i}=zeros(10,10);
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
    %     f2=sum(f2(:));f3=sum(f3(:));f4=sum(f4(:));f5=sum(f5(:));
    %     a=f1^2;
    %     b=f2^2+f3^2;
    %     c=f4^2+f5^2;
    %     v=a+0.01*b+0.001*c;
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
    %      if(k==maxit)&&diff<1e-4
    %     if(k==maxit)
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
end
end
