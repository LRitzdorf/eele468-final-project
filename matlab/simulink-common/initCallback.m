% Called as the InitFcn callback found in Model Explorer.

% create/initialize the Simulink model parameters
modelParams = createModelParams();

% create/set the Simulation parameters
simParams   = createSimParams(modelParams);

% create/set the HDL parameters
hdlParams   = createHdlParams(modelParams);
