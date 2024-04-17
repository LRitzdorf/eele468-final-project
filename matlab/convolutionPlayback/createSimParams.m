% Set simulation-specific parameters for the associated Simulink model

function simParams = createSimParams(modelParams)

% Audio source file for simulation
impulse = fi([0.5, -1, 0.5]', modelParams.audio.dataType);
stream  = fi([0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0]', modelParams.audio.dataType);
simParams.audioIn = [impulse; stream];
% Control signal for mode (recording vs streaming)
simParams.modeControl = fi([ones(size(impulse)); zeros(size(stream))], modelParams.modeControl.dataType);

% Simulation Parameters
simParams.verifySimulation = true;
simParams.playOutput       = true;
simParams.stopTime         = 25/48000; % seconds

% Model parameters for simulation
wetDryMix = 1;
simParams.wetDryMix = fi(wetDryMix, modelParams.wetDryMix.dataType);
