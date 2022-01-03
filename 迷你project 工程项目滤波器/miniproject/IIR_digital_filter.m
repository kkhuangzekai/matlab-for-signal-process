%{
An IIR digital filter: (file provided: octave.wav)
1. Generate a low pass analogue transfer function with a single pole
2. Use poke-mapping to convert the analogue transfer function to the
digital transfer function
3. Construct the digital filter with the digital transfer function 
4. Filter the input signal by feeding it sample by sample to the digital
filter
5. The plot shows the attenuation of each tone. Note that after the
frequency at the pole location, subsequent tones are attenuated at roughly
6db per octave (2 times the frequency).
%}

function IIR_digital_filter()
close all
%Frequency of tones in the file octave.wav
%Octave scale:   S=[100 200 400 800 1600 3200 6400 12800];

%Read music: y-audio data, Fs-sampling frequency, ch-num of channels
%y - array to store the audio samples
%Fs- Sampling frequency
%ch- Number of channels
%N - length of audio sequence

[y,Fs,ch,N]=read_file();
Fs

%{
%Filtering a chirp (linear FM) signal
Fs=44100;
t = 0:1/Fs:4;
y = chirp(t,100,2,5000);

[m N]=size(y(:,:));
pspectrum(y,Fs,'spectrogram','TimeResolution',0.1, ...
    'OverlapPercent',99,'Leakage',0.85)
%}

Fi=Fs/N;    %Frequency interval
Ts=1/Fs;    %Sampling interval
SB=100;     %Pole location at 100Hz: Stop band frequency in Hz

%Implement the IIR digital filter 
a=2*pi*SB;
b=exp(-a*Ts);
res=zeros(N,1);
for i=2:N
    res(i)=y(i)+b*res(i-1);
end

[n m]=size(res(:,:));   %Get size of filtered signal
res_abs=abs(res);       %Get magnitude of filtered signal
res_db=20*log10(res_abs);   %Convert to unit of db

plot_func(res_db,n,'Output');   %Plot the filtered signal in db
ylim([0 inf])                   %Only display part with db value >0

%Play the filtered audio clip
sound(res,Fs);
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


function plot_func(g,N,msg)
figure
t = linspace(0, N-1,N);
stem(t,g)
title(msg)
end