function scale_shift()
close all

a=input('Input scale a ');
b=input('Input shift b ');
hold on
t = [0:0.1:4*pi];
t2=(t-b)/a;
f1 = abs(sin(t));
f2 = abs(sin(t2));
p1=plot(t,f1);M1 = "Original waveform";
p2=plot(t,f2);M2 = "Shifted and scaled waveform";
legend([p1,p2], [M1, M2]);
end

