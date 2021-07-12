function [ T_dct ] = tensorDCT( T )
%TENSORDCT 此处显示有关此函数的摘要
%   此处显示详细说明
[n1,n2,n3]=size(T);
T_dct=zeros(n1,n2,n3);
for i=1:n1
    for j=1:n2
        a=T(i,j,:);
        adct=zeros(1,n3);
        a=reshape(a,[1,n3]);
        adct=dct(a);
        T_dct(i,j,:)=adct;
    end
end

end

