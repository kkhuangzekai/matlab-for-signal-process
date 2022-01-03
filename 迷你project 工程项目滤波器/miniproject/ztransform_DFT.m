%Computing DFT from z transform
function ztransform_DFT()
clear All
warning off
N=16;   %Length of input sequence x[n]
x=zeros(1,N);
F=zeros(1,2*N); %Frequency spectrum, extend frequency range to 2*N

%Generate ramp function
for i=1:N/2
    x(i)=i-1;
end
    
a=2*pi/N;   %Frequency resolution: separation between adjacent frequency samples

%Compute DFT via z transform
for k=1:2*N
    F(k)=0;
    for n=1:N
        F(k)=F(k)+x(n)*exp(-j*(n-1)*(k-1)*a);
    end
    
end

%Plot magnitude frequency spectrum
t = linspace(0,4*pi*(N-1)/N, 2*N);
stem(t,abs(F))
title('DFT from z transform function')

end

