% Set computed parameters for the associated Simulink model

function computeParams(hdlParams)

% Speed of FPGA clock that we will connect to in the FPGA fabric
FPGA_clock_frequency = hdlParams.clockFrequency;

% Ensure the model is up-to-date, and retrieve the fastest sampling rate
set_param(bdroot, 'SimulationCommand', 'Update')
fastestPeriod = min(cellfun(@(a) a(1,1), ...
    get_param(gcb, 'CompiledSampleTime')));

% Compute the HDL Coder oversampling factor
% https://www.mathworks.com/help/hdlcoder/ug/generating-a-global-oversampling-clock.html
oversampling = FPGA_clock_frequency*fastestPeriod;
if mod(oversampling, 1) == 0  % check if it is an integer
    % Oversampling factor is listed in Model Settings (Ctrl+E), under:
    % HDL Code Generation/Global Settings/Clock settings.
    % NOTE: we can't use a variable name for this, so we have to explicitly set
    % it with hdlset_param().
    hdlset_param(gcs, 'Oversampling', oversampling)
else
    % Note the Simulink Diagnostic Viewer doesn't provide the stack trace, so
    % we need to provide the location where this error is coming from if there
    % is an error.
    st = dbstack;
    disp(['Error in ' st.name]);
    error('Error: The clock oversampling factor must be an integer.')
end
