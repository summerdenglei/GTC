function [ Xhat ] = tensor_gft( X,L )
%TENSOR_GFT 此处显示有关此函数的摘要
%   此处显示详细说明:输入：X:（时刻*天*节点）大小的张量；
%                        L：节点对应的Laplace矩阵
%                   输出：Xhat:变换结果，等大的张量
[n1,n2,n3]=size(X);
Xhat=zeros(size(X));
% [V,~]=gsp_full_eigen(L);
[V,~]=gsp_full_eigen(L);
% V=sqrt(n3).*V;
for i=1:n1
    for j=1:n2
        tube=squeeze(X(i,j,:));
        tube_gft=V'*tube;
        Xhat(i,j,:)=tube_gft;
    end
end
end

