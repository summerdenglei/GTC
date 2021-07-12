function T1=tensor_transpose(T)
%% 自己写的张量转置
[n1,n2,n3]=size(T);
T1=zeros(n2,n1,n3);

b=T(:,:,1);
T1(:,:,1)=b';
for i=2:n3
    a=T(:,:,i);
    T1(:,:,n3+2-i)=a';
end







end