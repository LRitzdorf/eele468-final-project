% Set general model parameters for the associated Simulink model

function modelParams = createModelParams()

% Audio signal
modelParams.audio.wordLength     = 24;     % word size of audio signal
modelParams.audio.fractionLength = 23;     % fraction size of audio signal
modelParams.audio.signed         = true;   % audio is a signed signal type
modelParams.audio.dataType = numerictype(modelParams.audio.signed, ...
                                         modelParams.audio.wordLength, ...
                                         modelParams.audio.fractionLength);
modelParams.audio.sampleFrequency = 48000;  % sample rate (Hz)
modelParams.audio.samplePeriod    = 1/modelParams.audio.sampleFrequency;

% Number of convolution cores
% NOTE: changing this also requires manual architecture changes in the
% Simulink model!
modelParams.numCores = 24;

% Control parameters, to be made accessible via memory-mapped registers
% NOTE: the actual values are set in createSimParams.m
modelParams.modeControl.wordLength     = 1;
modelParams.modeControl.fractionLength = 0;
modelParams.modeControl.signed         = false;
modelParams.modeControl.dataType = numerictype(modelParams.modeControl.signed, ...
                                   modelParams.modeControl.wordLength, ...
                                   modelParams.modeControl.fractionLength);

modelParams.wetDryMix.wordLength     = 16;
modelParams.wetDryMix.fractionLength = 16;
modelParams.wetDryMix.signed         = false;
modelParams.wetDryMix.dataType = numerictype(modelParams.wetDryMix.signed, ...
                                             modelParams.wetDryMix.wordLength, ...
                                             modelParams.wetDryMix.fractionLength);

modelParams.volume.wordLength     = 16;
modelParams.volume.fractionLength = 16;
modelParams.volume.signed         = false;
modelParams.volume.dataType = numerictype(modelParams.volume.signed, ...
                                          modelParams.volume.wordLength, ...
                                          modelParams.volume.fractionLength);