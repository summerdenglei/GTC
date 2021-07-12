function [X,Y,TC,TotalRes,TrueRel,truerel] = TCTF_ST_solver(Oridata,B,data,known,Nway,coreNway,opts)
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

Cons{1}=eye(Nway(1));
Cons{2}=eye(Nway(2));
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
TC=rand(Nway);
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
%         [A,b] = XM2Ab(Oridata(:,:,n),B(:,:,n));
%         Cons =ConfigSRTF(A,b,Oridata(:,:,n),B(:,:,n),[n1,n2],coreNway(n));
%         Cons{1}=ST_FFT(:,:,1);
%         Cons{2}=TT_FFT(:,:,1);
%         Cons{1}=fft(SM);
%         Cons{2}=fft(TM);
%         Cons{1}=SM;
%         Cons{2}=TM;
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