% Lucas Ritzdorf
% 02/25/2024
% EELE 468

sampledir = "inputs";
wetdry = 1.00;

%% Select and load input

[file, path] = uigetfile('*.wav', "Select an Input Sample", sampledir);
if file == 0
    error("File does not exist, or selection cancelled. Please try again.")
end
[input, fs] = audioread(fullfile(path, file));
plot(input);

%% Select and load impulse

[file, path] = uigetfile('*.wav', "Select an Impulse Response", sampledir);
if file == 0
    error("File does not exist, or selection cancelled. Please try again.")
end
[impulse, fs_imp] = audioread(fullfile(sampledir, file));
plot(impulse);

%% Alternatively, record a live impulse response
duration = 1;

recObj = audiorecorder;
disp("Recording...");
recordblocking(recObj, duration);
disp("Finished recording");
impulse = getaudiodata(recObj);
fs_imp = recObj.SampleRate;

%% Ensure both signals have matching sample rates and are in stereo

% Resample the impulse so it matches the input's sample rate
impulse = audioresample(impulse, InputRate=fs_imp, OutputRate=fs);
% If either file has only one audio stream (i.e. mono audio), copy it to
% create two equivalent stereo channels
impulse = stereoify(impulse);
input = stereoify(input);

%% Perform convolution

result = zeros(size(input,1)+size(impulse,1)-1, 2);
% Convolve each channel individually
for channel = 1:2
    result(:, channel) = ...
        wetdry * conv(impulse(:, channel), input(:, channel)) ...
        + (1-wetdry) * padarray(input(:, channel), size(impulse,1)-1, 0, "post");
end

%% Play and plot the result

plot((1:length(result))/fs, result);
soundsc(result, fs);
