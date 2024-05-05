% Called as the StopFcn callback found in Model Explorer.

if simParams.verifySimulation
    verifySimulationPath = [fileparts(which(bdroot)) filesep 'verifySimulation.m'];

    if exist(verifySimulationPath, 'file')
        verifySimulation
    else
        warning(['stopCallback: Simulation verification is enabled but no ' ...
            'verification script was found at:\n%s'], verifySimulationPath);
    end
end

if simParams.playOutput
    playOutputPath = [fileparts(which(bdroot)) filesep 'playOutput.m'];

    if exist(playOutputPath, 'file')
        playOutput
    else
        warning(['stopCallback: Output playback is enabled but no ' ...
            'playback script was found at:\n%s'], playOutputPath);
    end
end
