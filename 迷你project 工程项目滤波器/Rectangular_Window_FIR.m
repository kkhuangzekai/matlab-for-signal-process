function Rectangular_Window_FIR()
close all

%Analogue frequencies associated with the analogue filter
fs=10000;   %Sampling frequency = 10kHz
Wp=500;                 %Pass band edge = 300Hz
Ws=600;                 %Stop band edge = 400Hz
cutoff=(Wp+Ws)/2        %Actual Pass band edge
TW=Ws-Wp                %Transition width


%To begin with assume the frequency space is discretized into N samples. 
%N should be large but its value is flexible. 
N=6001;

%Digital frequencies associated with the digital filter obtained from
%sampling the analogue unit impulse response
Wp_n=round(Wp/(fs/N))
Ws_n=round(Ws/(fs/N))
cutoff_n=round(cutoff/(fs/N))

%On the digital frequency axis, the DC (0 Hz) is located at the midpoint of the
%frequency axis
DC=(N-1)/2+1; %Location of DC component (frequency=0)

%=============================================================================================================================
%Five steps to build the discrete unit impulse response of a low-pass
%filter
HD=lowpass_transfer_function(DC,Wp_n,N);    %Step 1: define ideal lowpass filter response
hd=unit_impulse_response(HD,N);             %Step 2: convert filter response to unit impulse response
[win Nwin]=rectangular_window(fs,TW);       %Step 3: generate rectangular window function 
hd_win=add_window(hd,win,DC,Nwin,N)         %Step 4: apply window function to unit impulse response
RES=windowed_filter_transfer_function(hd_win,N);    %Step 5: get the frequency response of the windowed unit impulse response
%=============================================================================================================================

%Get maximum sidelobe magnitude
%The maximum sidelobe can be found in the windowed filter transfer function
RES=abs(RES);
PG=RES(DC)
PS=RES(3366);
A=20*log10(PS/PG)

[audio_in,Fs,ch,len]=read_file();
Fi=Fs/len;    %Frequency interval
Ts=1/Fs;    %Sampling interval
audio_lpf=conv(hd_win,audio_in);
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

%Convert digital frequency spectrum to discrete unit impulse response
%using inverse FFT
function hd=unit_impulse_response(HD,N)
HD=circshift(fftshift(HD),1);
hd=ifft(HD);
figure
t = linspace(0, N-1,N);
stem(t,real(hd))
title('Target unit impulse response')
end


%Construct rectangular window function
function [win Nwin]=rectangular_window(fs,TW)
Nwin=round(0.91*fs/TW);
if mod(Nwin,2)==0
    Nwin=Nwin+1;
end
win=zeros(1,Nwin);

for i=1:Nwin
    n=(i-1)-(Nwin-1)/2;
    win(i)=1;
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
[audio_clip,Fs] = audioread(filename);
Clip_info=audioinfo(filename);
ch=Clip_info.NumChannels;
T=Clip_info.TotalSamples;
end
