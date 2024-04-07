% Set HDL-specific parameters for the associated Simulink model

function hdlParams = createHdlParams(~)
% Input is the modelParams struct from createModelParams()
% Output is the hdlParams struct containing HDL related information

% Speed of FPGA clock that we will connect to in the FPGA fabric
FPGA_clock_frequency = 98304000; % Hz
hdlset_param(gcs, "TargetFrequency", FPGA_clock_frequency);

hdlParams = struct();
