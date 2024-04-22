% Set simulation-specific parameters for the associated Simulink model

function simParams = createSimParams(modelParams)

% Audio source file for simulation
impulse = getAudio('../effect/inputs/yop.wav', ...
    modelParams.audio.sampleFrequency, 'left', modelParams.audio.dataType);
stream  = getAudio('../effect/inputs/Congo Drummer.wav', ...
    modelParams.audio.sampleFrequency, 'left', modelParams.audio.dataType);
simParams.audioIn = [impulse; stream];
% Control signal for mode (recording vs streaming)
simParams.modeControl = fi([ones(size(impulse)); zeros(size(stream))], modelParams.modeControl.dataType);

% Simulation Parameters
simParams.verifySimulation = true;
simParams.playOutput       = true;
simParams.stopTime         = 5; % seconds

% Model parameters for simulation
wetDryMix = 1;
simParams.wetDryMix = fi(wetDryMix, modelParams.wetDryMix.dataType);
