

%求特征值、特征向量：

syms x1 x2 x3 a b c
P=[a b
    b c]
 P=[12 0
     0 12]
A=[0 -1
    1 1.5]
XT=[x1 x2]
X=transpose(XT)
AT=transpose(A)
R=0.25
B=[0
    1]
BT=transpose(B)
P0=P*A+AT*P-P*B*R*BT*P

U=-1/4*BT*P*X
%[a,b,c] = solve(P0==0)
%charpoly(XT*P*X)
% K=[4 0
%     0 -4]
% X=[x1
%     x2]
% XT=transpose(X)
% kk=XT*K*X
% Q1=[1 1 1 1 1 1 1 1 0]
%     Q2=[1 1 1 1 1 1 1 0 1]
%   
%   Q3=[         1 0 0 0 0 0 1 1 1]
%             Q4=[0 1 1 1 1 1 1 1 1]
% 
%         C=[1 0 0
%             0 1 0]
%         C1=[1 1 0
%             0 2 1]
%         P=[1 1 0
%             0 2 1
%             0 0 1]
%         P1=inv(P)
%         A=[1 0 0
%             0 -1 1
%             -1 1 3]
%         B=[1
%             2 
%             1]
%           A1=P*A*P1
%           B1=P*B
%         
%         %TEST2 Q6 1
%         A=[-1 6 0
%             1 0 2
%             0 2 1]
%         AE=eig(A)
%         poly(A)
%         B=[0
%             1
%             1]
%         C=[1 0 0]
%         D=0
%         [b,a] = ss2tf(A,B,C,D)
%         I=[1 0 0
%             0 1 0
%             0 0 1]
%         syms s k1 k2 k3 p
%         K=[k1 k2 k3]
%         A0=s*I-A+B*K
%         DET=det(A0)
%         charpoly(DET)
%         K0=[7/12 -4.5 6]
%         A1=A-B*K0
%         A2=s*I-A+B*K0
%         INV=inv(A2)
%         ADJ=adjoint(A0)
%         HS=C*INV*B*p
%         charpoly(HS)
%         det(HS)