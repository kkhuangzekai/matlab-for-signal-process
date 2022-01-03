function [outputafterLPF,f,originalfrequency,originaloutput]=Hanning_Window_FIR(fs,Wp,Ws)
close all

%Analogue frequencies associated with the analogue filter
   %Sampling frequency = 10kHz
              %Pass band edge = 300Hz
                 %Stop band edge = 400Hz
cutoff=(Wp+Ws)/2;        %Actual Pass band edge
TW=Ws-Wp;                %Transition width


%To begin with assume the frequency space is discretized into N samples. 首先假设频率空间被离散化为 N 个样本。
%N should be large but its value is flexible. N 应该很大但它的值是灵活的。
N=6001;

%Digital frequencies associated with the digital filter obtained fromsampling the analogue unit impulse response
%与从模拟单位脉冲响应采样获得的数字滤波器相关的数字频率
Wp_n=round(Wp/(fs/N));
Ws_n=round(Ws/(fs/N));
cutoff_n=round(cutoff/(fs/N)); %取整函数round

%On the digital frequency axis, the DC (0 Hz) is located at the midpoint of the
%frequency axis
DC=(N-1)/2+1; %Location of DC component (frequency=0)直流分量的位置

%=============================================================================================================================
%Five steps to build the discrete unit impulse response of a low-pass
%filter
HD=lowpass_transfer_function(DC,Wp_n,N);    %Step 1: define ideal lowpass filter response 定义理想的低通滤波器响应
hd=unit_impulse_response(HD,N);             %Step 2: convert filter response to unit impulse response 将滤波器响应转换为单位脉冲响应h（n）
[win Nwin]=rectangular_window(fs,TW);       %Step 3: generate rectangular window function 生成矩形窗函数
hd_win=add_window(hd,win,DC,Nwin,N)         %Step 4: apply window function to unit impulse response 将窗函数应用于单位脉冲响应
RES=windowed_filter_transfer_function(hd_win,N);    %tep 5: get the frequency response of the windowed unit impulse response
                                                    %得到加窗单位脉冲响应的频率响应
%=============================================================================================================================

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
newend='_Hanning_Window.wav';
fullname=[name,newend]
Fi=Fs/len;    %Frequency interval 频率间隔
Ts=1/Fs;    %Sampling interval 采样间隔
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


%Construct rectangular window function TW是传输带宽
function [win Nwin]=rectangular_window(fs,TW)
Nwin=round(3.32*fs/TW);
if mod(Nwin,2)==0
    Nwin=Nwin+1;
end
win=zeros(1,Nwin);

for i=1:Nwin
    win(i)=0.5*(1-cos(2*pi*i/(Nwin-1)));
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