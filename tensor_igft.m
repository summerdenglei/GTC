function [ X ] = tensor_igft(  Xhat,L)
%TENSOR_IGFT 此处显示有关此函数的摘要
%   此处显示详细说明
[n1,n2,n3]=size(Xhat);
Xigft=zeros(size(Xhat));

[V,~]=gsp_full_eigen(L);
% [V,~]=gsp_full_eigen(L);
for i=1:n1
    for j=1:n2
        tube=squeeze(Xhat(i,j,:));
        tube_igft=V*tube;%分别对每一个三维tube进行gft
        Xigft(i,j,:)=tube_igft;
    end
end
X=Xigft;
end

