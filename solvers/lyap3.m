function X=lyap3(A,B,C)
%Sylvester���̵Ľ����ⷨ
%rewrited by dynamic
%more information
if nargin==2
C=B;
B=A';
end
[nr,nc]=size(C);
A0=kron(A,eye(nc))+kron(eye(nr),B');
try
    C1=C';
    X0=-inv(A0)*C1(:);
    X=reshape(X0,nr,nc);
catch
    error('Matlabsky���������������죡');
end
