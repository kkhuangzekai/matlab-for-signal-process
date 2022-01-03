%该程序读wav文件,然后显示频谱以及波形。注意wav文件不要太长，否则运算会很慢。

[y,fs]=audioread('octave.wav');

fs

sigLength=length(y);

Y = fft(y,sigLength);

Pyy = Y.* conj(Y) / sigLength;

halflength=floor(sigLength/2);

f=fs*(0:halflength)/sigLength;

figure;plot(f,Pyy(1:halflength+1));xlabel('频率/Hz'); ylabel('幅度');

t=(0:sigLength-1)/fs;

figure;plot(t,y);xlabel('时间/s');ylabel('幅度');

%%%%画出声音对应的频谱图

%clear all;

%clc;

[w,fs]=audioread('octave.wav');%读取声音数据，fs表示采样频率(Hz)，bits表示采样位数。



%subplot(1,3,1);
audiowrite(kk.wav,w,fs)
