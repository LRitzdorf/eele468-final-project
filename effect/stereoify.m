function stereo_signal = stereoify(signal)
% STEREOIFY convert a mono audio signal into two equivalent stereo channels
%   If the input signal is already stereo, it will be returned unmodified.
%   If it has more than two channels, only the first two will be returned.

    % Ensure the given signal has generally the expected shape
    if ndims(signal) > 2
        error("The given signal has too many (%d) dimensions", ndims(signal));
    end

    % Deal with signals containing different numbers of channels:
    switch size(signal, 2)
        case 1
            % Signal is mono; copy its channel into stereo
            stereo_signal = repmat(signal, [1, 2]);
        case 2
            % Signal is already stereo; do nothing
            stereo_signal = signal;
        otherwise
            % Signal has extra channels; return the first two
            stereo_signal = signal(1:2);
    end
end
