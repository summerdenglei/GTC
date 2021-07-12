function [ Xhat ] = tensor_gft( X,L )
%TENSOR_GFT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��:���룺X:��ʱ��*��*�ڵ㣩��С��������
%                        L���ڵ��Ӧ��Laplace����
%                   �����Xhat:�任������ȴ������
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

