function [outputafterLPF,f,originalfrequency,originaloutput]=Blackman_Window_FIR_HIGHPASS(fs,Wp,Wp3,Ws,Ws3)
close all

%Analogue frequencies associated with the analogue filter
   %Sampling frequency = 10kHz
                %Pass band edge = 500Hz  ，，通带截止上限要6000


               %Stop band edge = 600Hz    ，，阻带上限7000
cutoff=(Wp+Ws)/2;%Actual Pass band edge  
cutoff3=(Wp3+Ws3)/2;  
TW=Ws-Wp;                %Transition width
TW3=Ws3-Wp3; 

%To begin with assume the frequency space is discretized into N samples. 首先假设频率空间被离散化为 N 个样本。
%N should be large but its value is flexible. N 应该很大但它的值是灵活的。
N=6001;

%Digital frequencies associated with the digital filter obtained fromsampling the analogue unit impulse response
%与从模拟单位脉冲响应采样获得的数字滤波器相关的数字频率
Wp_n=round(Wp/(fs/N));
Ws_n=round(Ws/(fs/N));

Wp_n3=round(Wp3/(fs/N));
Ws_n3=round(Ws3/(fs/N));
cutoff_n=round(cutoff/(fs/N)); %取整函数round

%On the digital frequency axis, the DC (0 Hz) is located at the midpoint of the
%frequency axis
DC=(N-1)/2+1; %Location of DC component (frequency=0)直流分量的位置

%=============================================================================================================================
%Five steps to build the discrete unit impulse response of a low-pass
%filter
HD=lowpass_transfer_function(DC,Wp_n,N);    %Step 1: define ideal lowpass filter response 定义理想的低通滤波器响应
hd=unit_impulse_response(HD,N);             %Step 2: convert filter response to unit impulse response 将滤波器响应转换为单位脉冲响应h（n）
[win Nwin]=Blackman_window(fs,TW);       %Step 3: generate hanning window function 生成矩形窗函数
hd_win=add_window(hd,win,DC,Nwin,N)         %Step 4: apply window function to unit impulse response 将窗函数应用于单位脉冲响应
RES1=windowed_filter_transfer_function(hd_win,N);    %tep 5: get the frequency response of the windowed unit impulse response
%RES=windowed_filter_transfer_function(hd_win,N)
                                                    %得到加窗单位脉冲响应的频率响应
%=============================================================================================================================
HD3=lowpass_transfer_function3(DC,Wp_n3,N);    %Step 1: define ideal lowpass filter response 定义理想的低通滤波器响应
hd3=unit_impulse_response3(HD3,N);             %Step 2: convert filter response to unit impulse response 将滤波器响应转换为单位脉冲响应h（n）
[win3 Nwin3]=Blackman_window3(fs,TW3);       %Step 3: generate hanning window function 生成矩形窗函数
hd_win3=add_window3(hd3,win3,DC,Nwin3,N)         %Step 4: apply window function to unit impulse response 将窗函数应用于单位脉冲响应
RES3=windowed_filter_transfer_function3(hd_win3,N);    %tep 5: get the frequency response of the windowed unit impulse response
                                                    %得到加窗单位脉冲响应的频率响应
RES=RES3-RES1


%Get maximum sidelobe magnitude 获取最大旁瓣幅度
%The maximum sidelobe can be found in the windowed filter transfer function
%最大旁瓣可以在加窗滤波器传递函数中找到
RES=abs(RES);
PG=RES(DC)
PS=RES(3366);
A=20*log10(PS/PG)

[output,f,filename,audio_in,Fs,ch,len]=read_file();%ch声道数、len总样本数、audio_in代表样本数据
originaloutput=output;
originalfrequency=f;
name=filename;
newend='_Blackman_Highpass.wav';
fullname=[name,newend];
Fi=Fs/len;    %Frequency interval 频率间隔
Ts=1/Fs;    %Sampling interval 采样间隔
hd_win=hd_win3-hd_win;
audio_lpf=conv(hd_win,audio_in);
sigLength=length(audio_lpf);
t=(0:sigLength-1)/Fs;

Y = fft(audio_lpf,sigLength);
Pyy = Y.* conj(Y) / sigLength;
halflength=floor(sigLength/2);
f=Fs*(0:halflength)/sigLength;

outputafterLPF=Pyy(1:halflength+1);
sound(audio_lpf,Fs)
audiowrite(fullname,audio_lpf,Fs)
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


end

%Convert digital frequency spectrum to discrete unit impulse response 将数字频谱转换为离散单位脉冲响应
%using inverse FFT 用逆FFT
function hd=unit_impulse_response(HD,N)
HD=circshift(fftshift(HD),1); %将数字频谱进行转换，能够进行FFT的逆变换。
hd=ifft(HD);

end


%Construct blackman window function
function [win Nwin]=Blackman_window(fs,TW)
Nwin=round(5.98*fs/TW);
if mod(Nwin,2)==0
    Nwin=Nwin+1;
end
win=zeros(1,Nwin);

for i=1:Nwin
    win(i)=0.42-0.5*cos((2*pi*i/(Nwin-1)))+0.08*cos((4*pi*i/(Nwin-1)));
end

end


%Apply window function to ideal impulse response
function hd_win=add_window(hd,win,DC,Nwin,N)
hd=fftshift(hd);
hd_win=zeros(1,N);
DC_win=(Nwin-1)/2;
hd_win(DC-DC_win:DC+DC_win)=hd(DC-DC_win:DC+DC_win).*win;

end


function RES=windowed_filter_transfer_function(hd_win,N)
hd_win=circshift(fftshift(hd_win),1);
HD_win=fft(hd_win);
%RES=abs(HD_win);
RES=fftshift(HD_win);
%RES=RES/max(RES(:));

end

function [output,f,filename,audio_clip,Fs,ch,T]=read_file()
[Name, folder] = uigetfile('*.wav;*.mp3;*.ogg');
filename = fullfile(folder, Name);
clear sound;
[audio_clip,Fs] = audioread(filename); %audio_clip代表样本数据
Clip_info=audioinfo(filename); 
ch=Clip_info.NumChannels; %ch声道数
T=Clip_info.TotalSamples; %T总样本数
sigLength=length(audio_clip);
t=(0:sigLength-1)/Fs;

Y = fft(audio_clip,sigLength);
Pyy = Y.* conj(Y) / sigLength;
halflength=floor(sigLength/2);
f=Fs*(0:halflength)/sigLength;
output=Pyy(1:halflength+1);

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


end

%Convert digital frequency spectrum to discrete unit impulse response 将数字频谱转换为离散单位脉冲响应
%using inverse FFT 用逆FFT
function hd3=unit_impulse_response3(HD3,N)
HD3=circshift(fftshift(HD3),1); %将数字频谱进行转换，能够进行FFT的逆变换。
hd3=ifft(HD3);

end


%Construct blackman window function
function [win3 Nwin3]=Blackman_window3(fs,TW3)
Nwin3=round(5.98*fs/TW3);
if mod(Nwin3,2)==0
    Nwin3=Nwin3+1;
end
win3=zeros(1,Nwin3);

for i=1:Nwin3
    win3(i)=0.42-0.5*cos((2*pi*i/(Nwin3-1)))+0.08*cos((4*pi*i/(Nwin3-1)));
end

end


%Apply window function to ideal impulse response
function hd_win3=add_window3(hd3,win3,DC,Nwin3,N)
hd3=fftshift(hd3);
hd_win3=zeros(1,N);
DC_win3=(Nwin3-1)/2;
hd_win3(DC-DC_win3:DC+DC_win3)=hd3(DC-DC_win3:DC+DC_win3).*win3;

end


function RES3=windowed_filter_transfer_function3(hd_win3,N)
hd_win3=circshift(fftshift(hd_win3),1);
HD_win=fft(hd_win3);
%RES=abs(HD_win);
RES3=fftshift(HD_win);
%RES=RES/max(RES(:));

end

