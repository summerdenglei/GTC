function [ C ] = GraphTensor_product( A,B,L )
%GRAPHTENSOR_PRODUCT 此处显示有关此函数的摘要
%   此处显示详细说明
[n1,n2,n3]=size(A);
[n2,n4,n3]=size(B);
C=zeros(n1,n4,n3);
for i=1:n1
    for j=1:n4
        c=zeros(n3,1);
        for k=1:n2
            a=squeeze(A(i,k,:));
            b=squeeze(B(k,j,:));
            ab=graph_cov(a,b,L);
            c=c+ab;
        end
        C(i,j,:)=c;
    end
end
end
%% 图卷积
function c =graph_cov(a,b,L)
    %求向量a和b的图卷积
    [V,~]=gsp_full_eigen(L);
    c=V*((V'*b).*(V'*a));
end


