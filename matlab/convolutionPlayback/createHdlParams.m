% Set HDL-specific parameters for the associated Simulink model

function hdlParams = createHdlParams(~)
% Input is the modelParams struct from createModelParams()
% Output is the hdlParams struct containing HDL related information

% Speed of FPGA clock that we will connect to in the FPGA fabric
FPGA_clock_frequency = 98.304; % MHz
hdlset_param(gcs, "TargetFrequency", FPGA_clock_frequency);

hdlParams.clockFrequency = FPGA_clock_frequency*10^6;

% Oversampling rate (assuming the fastest clock in the system is the specified fabric clock)
hdlset_param(gcs, 'Oversampling', 1)
