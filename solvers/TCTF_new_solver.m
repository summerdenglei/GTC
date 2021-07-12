function [X,Y,TC,TotalRes,TrueRel,truerel] = TCTF_new_solver(data,known,Nway,coreNway,opts)
%% Data preprocessing and initialization
n1=Nway(1);
n2=Nway(2);
n3=Nway(3);
rank_adj = opts.rank_adj;
rank_min = opts.rank_min;
maxit=opts.maxIter;

[known,id] = sort(known);
data = data(id);
normdata=norm(data(:));
normM=norm(opts.Mtr(:));

%% initialization X and Y
TC=randn(Nway);
TC(known)=data;
TC=fft(TC,[],3);
for i = 1:n3
    [Uk,Sigmak,Vk]=svds(TC(:,:,i),coreNway(i));
    X{i} = Uk*Sigmak;
    Y{i} = Vk';
end


%% compute the initialization residual
TotalRes = [];
TrueRel = [];
C=zeros(n1,n2,n3);
for n = 1:n3
    C(:,:,n)=X{n}*Y{n};
end
TC=ifft(C,[],3);
TotalRes = [TotalRes,norm(TC(known)-data)];
TrueRel = [TrueRel, norm(TC(:)-opts.Mtr(:))/norm(opts.Mtr(:))];

TC(known) = data;
TC=real(TC);
C=fft(TC,[],3);

rho=0.95;
mu=1.01;
for k = 1:maxit

    %% update (X,Y)
    for n = 1:n3
        X{n}=C(:,:,n)*Y{n}'*pinv(Y{n}*Y{n}');
        Xsq{n} = X{n}'*X{n};
        Y{n} = pinv(Xsq{n})*X{n}'*C(:,:,n);
        C(:,:,n)=X{n}*Y{n};
    end
    
    %% adjust the rank of (X,Y)
    if rank_adj(n) == -1 && rho<1
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
                        [U,S,V] = svd(Rx*Ry');
                        sigv = diag(S);
                        X{n} = Qx*U(:,1:coreNway(n))*spdiags(sigv(1:coreNway(n)),0,coreNway(n),coreNway(n));
                        Y{n} = (Qy*V(:,1:coreNway(n)))';
                        C(:,:,n)=X{n}*Y{n};
                    end
                end
            end
            rho=rho*mu;
        end
    end
    
    
    %% judge whether converges
    TC=ifft(C,[],3);
    res=norm(TC(known)-data)/normdata;
    res1=norm(TC(:)-opts.Mtr(:))/normM;
    if res<1e-8
        TC(known) = data;
        TC=real(TC);
        break;
    end
    
    TC(known) = data;
    TC=real(TC);
    if(k==maxit)
        break;
    end
     truerel(k) = norm(TC(:)-opts.Mtr(:))/norm(opts.Mtr(:)); 
    %% update C
    C=fft(TC,[],3);
end
end