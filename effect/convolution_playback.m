% Lucas Ritzdorf
% 02/25/2024
% EELE 468

%% Setup

sampledir = "samples";
impulsename = "h080_Outdoor_GrassyField.wav";
inputname = "acoustic.wav";

%% Load impulse and input

impulse = audioread(fullfile(sampledir, impulsename));
plot(impulse);
[input, fs] = audioread(fullfile(sampledir, inputname));
plot(input);

% If either file has only one audio stream (i.e. mono audio), copy it to
% create equivalent stereo channels
impulse = stereoify(impulse);
input = stereoify(input);

%% Perform convolution

result = zeros(size(input,1)+size(impulse,1)-1, 2);
% Convolve each channel individually
for channel = 1:2
    result(:, channel) = conv(impulse(:, channel), input(:, channel));
end

%% Play and plot the result

plot((1:length(result))/fs, result);
soundsc(result, fs);
