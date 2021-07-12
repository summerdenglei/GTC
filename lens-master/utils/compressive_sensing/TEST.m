clear all;
load('M.mat')
load('spatial_matrix_half.mat')
load('temporal_matrix_half.mat')
load('fzroad_halfdata_144_217_9.mat')
TS=A(:,:,1);
r=4;
%%2d
[n1,n2]             =        size(TS)                      ;
p                      =        0.1;
Omega                  =        zeros(size(TS))               ;
chosen2                 =        randperm(n1*n2,round(p*n1*n2)) ;                             
Omega(chosen2)          =        1                             ;
O=Omega;
%%3d
[n1,n2,n3]             =        size(A)                      ;
p=0.1;
Omega=zeros(size(A))               ;
chosen2                 =        randperm(n1*n2*n3,round(p*n1*n2*n3)) ;    
Omega(chosen2)          =        1                             ;
O=Omega;

M=O(:,:,1);
X=M.*TS;
Cons = cell(1,2);
Cons{1}=T;
Cons{2}=S;
[U,V,obj,iter,truerel] = SRMF(TS,r,M,Cons);
X_REC=U*V';
RSE=norm(TS-X_REC)/norm(TS)
[P,U,V,W,obj,iter] = SRTF(A,r,O,Cons,alpha,lambda,MaxIter);
RSE=norm(A-P)/norm(A)

%  figure(1);
%  plot(truerel,'r<-','LineWidth',1.5);%t-svd