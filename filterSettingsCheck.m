function [highPassFreq, lowPassFreq, sos, g, notchSetting] = filterSettingsCheck(highPassFreq, lowPassFreq, recordHighPass, recordLowPass, recordSampFreq, newSampFreq, notchSetting)
% Modified on 9/20/2018: Added calculation for minimum filter order for
% each filter design. (BAG)

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
    rPassMax = 1; % Rp: Maximum of 1 dB ripple in the passband signal.
    rStopMin = 60; % Rs: Minimum of 60 dB attenuation in the stopband signal.
    if highPassEnable && lowPassEnable
        % Design bandpass filter:
        wp = [highPassFreq lowPassFreq]/(recordSampFreq/2);
        ws = [(highPassFreq-0.1), (lowPassFreq+0.1)]/(recordSampFreq/2);
        [n,wp] = ellipord(wp, ws, rPassMax, rStopMin);
        [z, p, k] = ellip(n, rPassMax, rStopMin, wp, 'bandpass');
        
        highPassFreq = wp(1) * (recordSampFreq/2);
        lowPassFreq = wp(2) * (recordSampFreq/2);
    elseif highPassEnable
        % Design high pass filter:
        wp = highPassFreq/(recordSampFreq/2);
        ws = (highPassFreq-0.1)/(recordSampFreq/2);
        [n,wp] = ellipord(wp, ws, rPassMax, rStopMin);        
        [z, p, k] = ellip(n, rPassMax, rStopMin, wp, 'high');
        
        highPassFreq = wp * (recordSampFreq/2);
    elseif lowPassEnable
        % Design low pass filter:
        wp = lowPassFreq/(recordSampFreq/2);
        ws = (lowPassFreq+0.1)/(recordSampFreq/2);
        [n,wp] = ellipord(wp, ws, rPassMax, rStopMin);       
        [z, p, k] = ellip(n, rPassMax, rStopMin, wp);
        
        lowPassFreq = wp * (recordSampFreq/2);
    end
    [sos, g] = zp2sos(z,p,k);
end

%% Determine if notch filter should be used:
if notchSetting == 1 && (60 < highPassFreq || 60 > lowPassFreq)
    notchSetting = 0;
end

