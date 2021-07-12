function X=lyap3(A,B,C)
%Sylvester方程的解析解法
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
    error('Matlabsky提醒您：矩阵奇异！');
end
