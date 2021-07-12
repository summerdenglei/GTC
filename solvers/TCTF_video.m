function [ TC,para ] =TCTF_video( X,Omega,rank_strategy,p,lamda,alpha,rank,st_or_not)

%% produce data

data=X(Omega);
known=Omega;

[n1,n2,n3]=size(X);
B=zeros(size(X));
B(Omega)=1;
%% our method 
opts = [];
opts.maxIter=200;
opts.tol = 1e-3; 
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
% [~,~,TC,~,~,truerel] = TCTF_ST_solver(X,B,data,known,Nway,EstCoreNway,opts);
[~,~,TC,~,~,truerel] = TCTF_ST_solver(X,B,data,known,Nway,EstCoreNway,opts);

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



