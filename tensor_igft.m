function [ X ] = tensor_igft(  Xhat,L)
%TENSOR_IGFT �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[n1,n2,n3]=size(Xhat);
Xigft=zeros(size(Xhat));

[V,~]=gsp_full_eigen(L);
% [V,~]=gsp_full_eigen(L);
for i=1:n1
    for j=1:n2
        tube=squeeze(Xhat(i,j,:));
        tube_igft=V*tube;%�ֱ��ÿһ����άtube����gft
        Xigft(i,j,:)=tube_igft;
    end
end
X=Xigft;
end

