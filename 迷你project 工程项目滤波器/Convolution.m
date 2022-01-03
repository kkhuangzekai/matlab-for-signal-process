function Convolution()
clear all
warning off

%A 2 steps function as the input sequence
N=16;
x=zeros(1,N);
for i=1:N/4
    x(i)=0.5;
    x(i+N/4)=1;
end
kk=x
%Unit impulse response of a low-pass filter
h=[1,1,0,0];

%Unit impulse response of a high-pass filter
g=[1,1,-1,-1];

%Output of low-pass filter
y=conv(x,h)
[row ylen]=size(y(:,:))

%Output of high-pass filter
w=conv(x,g)

figure
t = linspace(0,N-1, N);
stem(t,x)
title('Input sequence x')

figure
t = linspace(0,ylen-1, ylen);
stem(t,y)
title('Low-pass sequence y')

figure
t = linspace(0,ylen-1, ylen);
stem(t,w)
title('High-pass sequence w')

end

