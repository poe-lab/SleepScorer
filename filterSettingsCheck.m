function [highPassFreq, lowPassFreq, sos, g, notchSetting] = filterSettingsCheck(highPassFreq, lowPassFreq, recordHighPass, recordLowPass, recordSampFreq, newSampFreq, notchSetting)
%% Adjust filter range if necessary:
highPassEnable = false;
lowPassEnable = false;

if isempty(highPassFreq) || highPassFreq <= recordHighPass
    highPassFreq = recordHighPass;
else
    highPassEnable = true;
end

if newSampFreq/3 < recordLowPass
    recordLowPass = newSampFreq/3;
    lowPassEnable = true;
else
    recordLowPass = recordLowPass - 0.1;
end


if isempty(lowPassFreq) || lowPassFreq > recordLowPass
    lowPassFreq = recordLowPass; %Max allowed low pass frequency based on Nyquist rule
    
else 
    lowPassEnable = true;
end

%% Design filter:
if ~highPassEnable && ~lowPassEnable
    sos = [];
    g = [];
else
    if highPassEnable && lowPassEnable
    %Design bandpass filter:
    [z, p, k] = ellip(7,1,60, [highPassFreq lowPassFreq]/(recordSampFreq/2),'bandpass');   % Default is OFF
    elseif highPassEnable
        %Design high pass filter:
        [z, p, k] = ellip(7,1,60, highPassFreq/(recordSampFreq/2), 'high');
    elseif lowPassEnable
        %Design low pass filter:
        [z, p, k] = ellip(7,1,60, lowPassFreq/(recordSampFreq/2));
    end
    [sos, g] = zp2sos(z,p,k);
end

%% Determine if notch filter should be used:
if notchSetting == 1 && (60 < highPassFreq || 60 > lowPassFreq)
    notchSetting = 0;
end

