%�ó����wav�ļ�,Ȼ����ʾƵ���Լ����Ρ�ע��wav�ļ���Ҫ̫������������������

[y,fs]=audioread('octave.wav');

fs

sigLength=length(y);

Y = fft(y,sigLength);

Pyy = Y.* conj(Y) / sigLength;

halflength=floor(sigLength/2);

f=fs*(0:halflength)/sigLength;

figure;plot(f,Pyy(1:halflength+1));xlabel('Ƶ��/Hz'); ylabel('����');

t=(0:sigLength-1)/fs;

figure;plot(t,y);xlabel('ʱ��/s');ylabel('����');

%%%%����������Ӧ��Ƶ��ͼ

%clear all;

%clc;

[w,fs]=audioread('octave.wav');%��ȡ�������ݣ�fs��ʾ����Ƶ��(Hz)��bits��ʾ����λ����



%subplot(1,3,1);
audiowrite(kk.wav,w,fs)
