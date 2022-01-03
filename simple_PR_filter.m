function simple_PR_filte()

h0=[0.3415 0.5915 0.1585 -0.0915];
h1=[0.0915 0.1585 -0.5915 0.3415];
g0=[-0.0915 0.1585 0.5915 0.3415];
g1=[0.3415 -0.5915 0.1585 0.0915];

x=[1 2 3 4 5 6 7 8]
rho0=sum(h0)
rho2=h0(1)*h0(3)+h0(2)*h0(4)

lo=upsample(downsample(conv(x,h0),2),2);
hi=upsample(downsample(conv(x,h1),2),2);
y0=conv(lo,g0);
y1=conv(hi,g1);
tmp=2*(y0+y1);

Lh=length(h0);
Lx=length(x);
y=tmp(Lh:Lh+Lx-1)
end

