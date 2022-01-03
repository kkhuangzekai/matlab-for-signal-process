function [outputafterLPF,f,originalfrequency,originaloutput]=Hamming_Window_FIR_Bandpass(fs,Wp,Wp3,Ws,Ws3)
close all

%Analogue frequencies associated with the analogue filter
   %Sampling frequency = 10kHz
                %Pass band edge = 500Hz  ����ͨ����ֹ����Ҫ6000


              %Stop band edge = 600Hz    �����������7000
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
[win Nwin]=Hamming_window(fs,TW);       %Step 3: generate hanning window function ���ɾ��δ�����
hd_win=add_window(hd,win,DC,Nwin,N)         %Step 4: apply window function to unit impulse response ��������Ӧ���ڵ�λ������Ӧ
RES1=windowed_filter_transfer_function(hd_win,N);    %tep 5: get the frequency response of the windowed unit impulse response
%RES=windowed_filter_transfer_function(hd_win,N)
                                                    %�õ��Ӵ���λ������Ӧ��Ƶ����Ӧ
%=============================================================================================================================
HD3=lowpass_transfer_function3(DC,Wp_n3,N);    %Step 1: define ideal lowpass filter response ��������ĵ�ͨ�˲�����Ӧ
hd3=unit_impulse_response3(HD3,N);             %Step 2: convert filter response to unit impulse response ���˲�����Ӧת��Ϊ��λ������Ӧh��n��
[win3 Nwin3]=Hamming_window3(fs,TW3);       %Step 3: generate hanning window function ���ɾ��δ�����
hd_win3=add_window3(hd3,win3,DC,Nwin3,N)         %Step 4: apply window function to unit impulse response ��������Ӧ���ڵ�λ������Ӧ
RES3=windowed_filter_transfer_function3(hd_win3,N);    %tep 5: get the frequency response of the windowed unit impulse response
                                                    %�õ��Ӵ���λ������Ӧ��Ƶ����Ӧ
RES=RES3-RES1

%Get maximum sidelobe magnitude ��ȡ����԰����
%The maximum sidelobe can be found in the windowed filter transfer function
%����԰�����ڼӴ��˲������ݺ������ҵ�
RES=abs(RES);
PG=RES(DC)
PS=RES(3366);
A=20*log10(PS/PG)

[output,f,filename,audio_in,Fs,ch,len]=read_file();%ch��������len����������audio_in������������
originaloutput=output;
originalfrequency=f;
name=filename;
newend='_Hamming_Bandpass.wav';
fullname=[name,newend];
Fi=Fs/len;    %Frequency interval Ƶ�ʼ��
Ts=1/Fs;    %Sampling interval �������
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

%Convert digital frequency spectrum to discrete unit impulse response ������Ƶ��ת��Ϊ��ɢ��λ������Ӧ
%using inverse FFT ����FFT
function hd=unit_impulse_response(HD,N)
HD=circshift(fftshift(HD),1); %������Ƶ�׽���ת�����ܹ�����FFT����任��
hd=ifft(HD);

end


%Construct hamming window function
function [win Nwin]=Hamming_window(fs,TW)
Nwin=round(3.44*fs/TW);
if mod(Nwin,2)==0
    Nwin=Nwin+1;
end
win=zeros(1,Nwin);

for i=1:Nwin
    win(i)=0.5-0.46*cos((2*pi*i/(Nwin-1)));
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
[audio_clip,Fs] = audioread(filename); %audio_clip������������
Clip_info=audioinfo(filename); 
ch=Clip_info.NumChannels; %ch������
T=Clip_info.TotalSamples; %T��������
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

%Convert digital frequency spectrum to discrete unit impulse response ������Ƶ��ת��Ϊ��ɢ��λ������Ӧ
%using inverse FFT ����FFT
function hd3=unit_impulse_response3(HD3,N)
HD3=circshift(fftshift(HD3),1); %������Ƶ�׽���ת�����ܹ�����FFT����任��
hd3=ifft(HD3);

end


%Construct hamming window function
function [win3 Nwin3]=Hamming_window3(fs,TW3)
Nwin3=round(3.44*fs/TW3);
if mod(Nwin3,2)==0
    Nwin3=Nwin3+1;
end
win3=zeros(1,Nwin3);

for i=1:Nwin3
    win3(i)=0.5-0.46*cos((2*pi*i/(Nwin3-1)));
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

