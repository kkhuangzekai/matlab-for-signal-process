function Hanning_Window_FIR_HIGHPASS()
close all

%Analogue frequencies associated with the analogue filter
fs=10000;   %Sampling frequency = 10kHz
Wp=500;                 %Pass band edge = 500Hz  ����ͨ����ֹ����Ҫ6000
Wp3=4900;
Ws=600; 
Ws3=4999;               %Stop band edge = 600Hz    �����������7000
cutoff=(Wp+Ws)/2;%Actual Pass band edge  
cutoff3=(Wp3+Ws3)/2;  
TW=Ws-Wp;                %Transition width
TW3=Ws3-Wp3; 

%To begin with assume the frequency space is discretized into N samples. ���ȼ���Ƶ�ʿռ䱻��ɢ��Ϊ N ��������
%N should be large but its value is flexible. N Ӧ�úܴ�����ֵ�����ġ�
N=6001;

%Digital frequencies associated with the digital filter obtained fromsampling the analogue unit impulse response
%���ģ�ⵥλ������Ӧ������õ������˲�����ص�����Ƶ��
Wp_n=round(Wp/(fs/N));
Ws_n=round(Ws/(fs/N));

Wp_n3=round(Wp3/(fs/N));
Ws_n3=round(Ws3/(fs/N));
cutoff_n=round(cutoff/(fs/N)); %ȡ������round

%On the digital frequency axis, the DC (0 Hz) is located at the midpoint of the
%frequency axis
DC=(N-1)/2+1; %Location of DC component (frequency=0)ֱ��������λ��

%=============================================================================================================================
%Five steps to build the discrete unit impulse response of a low-pass
%filter
HD=lowpass_transfer_function(DC,Wp_n,N);    %Step 1: define ideal lowpass filter response ��������ĵ�ͨ�˲�����Ӧ
hd=unit_impulse_response(HD,N);             %Step 2: convert filter response to unit impulse response ���˲�����Ӧת��Ϊ��λ������Ӧh��n��
[win Nwin]=Hanning_window(fs,TW);       %Step 3: generate hanning window function ���ɾ��δ�����
hd_win=add_window(hd,win,DC,Nwin,N)         %Step 4: apply window function to unit impulse response ��������Ӧ���ڵ�λ������Ӧ
RES1=windowed_filter_transfer_function(hd_win,N);    %tep 5: get the frequency response of the windowed unit impulse response
%RES=windowed_filter_transfer_function(hd_win,N)
                                                    %�õ��Ӵ���λ������Ӧ��Ƶ����Ӧ
%=============================================================================================================================
HD3=lowpass_transfer_function3(DC,Wp_n3,N);    %Step 1: define ideal lowpass filter response ��������ĵ�ͨ�˲�����Ӧ
hd3=unit_impulse_response3(HD3,N);             %Step 2: convert filter response to unit impulse response ���˲�����Ӧת��Ϊ��λ������Ӧh��n��
[win3 Nwin3]=Hanning_window3(fs,TW3);       %Step 3: generate hanning window function ���ɾ��δ�����
hd_win3=add_window3(hd3,win3,DC,Nwin3,N)         %Step 4: apply window function to unit impulse response ��������Ӧ���ڵ�λ������Ӧ
RES3=windowed_filter_transfer_function3(hd_win3,N);    %tep 5: get the frequency response of the windowed unit impulse response
                                                    %�õ��Ӵ���λ������Ӧ��Ƶ����Ӧ
RES=RES3-RES1
figure
t = linspace(0, N-1,N);
stem(t,abs(RES))
title('���� Spectrum of windowed unit impulse response �Ĳ�')

%Get maximum sidelobe magnitude ��ȡ����԰����
%The maximum sidelobe can be found in the windowed filter transfer function
%����԰�����ڼӴ��˲������ݺ������ҵ�
RES=abs(RES);
PG=RES(DC)
PS=RES(3366);
A=20*log10(PS/PG)

[audio_in,Fs,ch,len]=read_file();%ch��������len����������audio_in������������
Fi=Fs/len;    %Frequency interval Ƶ�ʼ��
Ts=1/Fs;    %Sampling interval �������
hd_win=hd_win3-hd_win;
audio_lpf=conv(hd_win,audio_in);
sigLength=length(audio_lpf);
t=(0:sigLength-1)/Fs;
figure;
subplot(2,1,1)
plot(t,audio_lpf);xlabel('ʱ��/s');ylabel('����');
Y = fft(audio_lpf,sigLength);
Pyy = Y.* conj(Y) / sigLength;
halflength=floor(sigLength/2);
f=Fs*(0:halflength)/sigLength;
subplot(2,1,2)
plot(f,Pyy(1:halflength+1));xlabel('Ƶ��/Hz'); ylabel('����');
sound(audio_lpf,Fs)
end





%======================Supporting functions================================
function HD=lowpass_transfer_function(DC,Wp_n,N)
%Generate the low-pass function in the digital frequency spectrum
%Gain in passband=1, phase is linear. Gain=0 at stopband
HD=zeros(1,N);
for i=DC-Wp_n:DC+Wp_n
    n=i-DC;
    f=n*2*pi/N;
    HD(i)=1;
end

figure
t = linspace(0,N-1,N);
stem(t,abs(HD))
title('Target frequency spectrum')
end

%Convert digital frequency spectrum to discrete unit impulse response ������Ƶ��ת��Ϊ��ɢ��λ������Ӧ
%using inverse FFT ����FFT
function hd=unit_impulse_response(HD,N)
HD=circshift(fftshift(HD),1); %������Ƶ�׽���ת�����ܹ�����FFT����任��
hd=ifft(HD);
figure
t = linspace(0, N-1,N);
stem(t,real(hd))
title('Target unit impulse response')
end


%Construct hanning window function
function [win Nwin]=Hanning_window(fs,TW)
Nwin=round(3.32*fs/TW);
if mod(Nwin,2)==0
    Nwin=Nwin+1;
end
win=zeros(1,Nwin);

for i=1:Nwin
    n=(i-1)-(Nwin-1)/2;
    win(i)=0.5+0.5*cos(2*pi*n/(Nwin-1));
end
figure
t = linspace(0, Nwin-1,Nwin);
stem(t,win)
title('Window Function')
end


%Apply window function to ideal impulse response
function hd_win=add_window(hd,win,DC,Nwin,N)
hd=fftshift(hd);
hd_win=zeros(1,N);
DC_win=(Nwin-1)/2;
hd_win(DC-DC_win:DC+DC_win)=hd(DC-DC_win:DC+DC_win).*win;
figure
t = linspace(0, N-1,N);
stem(t,abs(hd_win))
title('Windowed unit impulse response')
end


function RES=windowed_filter_transfer_function(hd_win,N)
hd_win=circshift(fftshift(hd_win),1);
HD_win=fft(hd_win);
%RES=abs(HD_win);
RES=fftshift(HD_win);
%RES=RES/max(RES(:));
figure
t = linspace(0, N-1,N);
stem(t,abs(RES))
title('Spectrum of windowed unit impulse response')
end

function [audio_clip,Fs,ch,T]=read_file()
[Name, folder] = uigetfile('*.wav;*.mp3;*.ogg');
filename = fullfile(folder, Name);
clear sound;
[audio_clip,Fs] = audioread(filename); %audio_clip������������
Clip_info=audioinfo(filename); 
ch=Clip_info.NumChannels; %ch������
T=Clip_info.TotalSamples; %T��������
sigLength=length(audio_clip);
t=(0:sigLength-1)/Fs;
figure;
subplot(2,1,1)
plot(t,audio_clip);xlabel('ʱ��/s');ylabel('����');
Y = fft(audio_clip,sigLength);
Pyy = Y.* conj(Y) / sigLength;
halflength=floor(sigLength/2);
f=Fs*(0:halflength)/sigLength;
subplot(2,1,2)
plot(f,Pyy(1:halflength+1));xlabel('Ƶ��/Hz'); ylabel('����');
end

function HD3=lowpass_transfer_function3(DC,Wp_n3,N)
%Generate the low-pass function in the digital frequency spectrum
%Gain in passband=1, phase is linear. Gain=0 at stopband
HD3=zeros(1,N);
for i=DC-Wp_n3:DC+Wp_n3
    n=i-DC;
    f=n*2*pi/N;
    HD3(i)=1;
end

figure
t = linspace(0,N-1,N);
stem(t,abs(HD3))
title('Target frequency spectrum3')
end

%Convert digital frequency spectrum to discrete unit impulse response ������Ƶ��ת��Ϊ��ɢ��λ������Ӧ
%using inverse FFT ����FFT
function hd3=unit_impulse_response3(HD3,N)
HD3=circshift(fftshift(HD3),1); %������Ƶ�׽���ת�����ܹ�����FFT����任��
hd3=ifft(HD3);
figure
t = linspace(0, N-1,N);
stem(t,real(hd3))
title('Target unit impulse response3')
end


%Construct hanning window function
function [win3 Nwin3]=Hanning_window3(fs,TW3)
Nwin3=round(3.32*fs/TW3);
if mod(Nwin3,2)==0
    Nwin3=Nwin3+1;
end
win3=zeros(1,Nwin3);

for i=1:Nwin3
    n=(i-1)-(Nwin3-1)/2;
    win3(i)=0.5+0.5*cos(2*pi*n/(Nwin3-1));
end
figure
t = linspace(0, Nwin3-1,Nwin3);
stem(t,win3)
title('Window Function')
end


%Apply window function to ideal impulse response
function hd_win3=add_window3(hd3,win3,DC,Nwin3,N)
hd3=fftshift(hd3);
hd_win3=zeros(1,N);
DC_win3=(Nwin3-1)/2;
hd_win3(DC-DC_win3:DC+DC_win3)=hd3(DC-DC_win3:DC+DC_win3).*win3;
figure
t = linspace(0, N-1,N);
stem(t,abs(hd_win3))
title('Windowed unit impulse response3')
end


function RES3=windowed_filter_transfer_function3(hd_win3,N)
hd_win3=circshift(fftshift(hd_win3),1);
HD_win=fft(hd_win3);
%RES=abs(HD_win);
RES3=fftshift(HD_win);
%RES=RES/max(RES(:));
figure
t = linspace(0, N-1,N);
stem(t,abs(RES3))
title('Spectrum of windowed unit impulse response3')
end

