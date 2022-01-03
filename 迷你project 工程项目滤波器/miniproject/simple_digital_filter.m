%{
A simple digital filter: (file provided: octave.wav)
1. Generate a low pass analogue transfer function with a single pole
2. Compute the unit impulse response
3. Sample the unit impulse response (Truncate to a finit length manually)
4. Filter the input signal by convolving it with the filter unit impulse
response
5. Due to the truncation of filter length, the transfer function is
only a rough approximation of the target response.
6. The plot shows the attenuation of each tone. Note that after the
frequency at the pole location, subsequent tones are attenuated at roughly
6db per octave (2 times the frequency).
%}

function simple_digital_filter()
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
Fi=Fs/N;    %Frequency interval
Ts=1/Fs;    %Sampling interval
SB=100;     %Pole location: Stop band frequency in Hz


%Unit impulse response
Nh=512;         %Length of filter = Nh
h=zeros(1,Nh);  %Initialize a filter with Nh taps
%Generate unit impulse response according to pole location
for n=1:Nh
    h(n)=exp(-2*pi*SB*n*Ts);
end
%Plot unit impulse response
plot_func(h,Nh,'Unit impulse response of filter');

%Convolve audio sequence with the digital filter
res=conv(y,h);
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