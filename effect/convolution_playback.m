% Lucas Ritzdorf
% 02/25/2024
% EELE 468

sampledir = "samples";

%% Select and load impulse

impulsename = uigetfile('*.wav', "Select an Impulse Response", sampledir);
if impulsename == 0
    error("File does not exist, or selection cancelled. Please try again.")
end
impulse = audioread(fullfile(sampledir, impulsename));
plot(impulse);

%% Select and load input

inputname = uigetfile('*.wav', "Select an Input Sample", sampledir);
if inputname == 0
    error("File does not exist, or selection cancelled. Please try again.")
end
[input, fs] = audioread(fullfile(sampledir, inputname));
plot(input);


%% Ensure both signals are in stereo
% If either file has only one audio stream (i.e. mono audio), copy it to
% create two equivalent stereo channels
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
