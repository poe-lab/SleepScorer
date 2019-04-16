function rmsSignal = calculateRMS(signal, windowSeconds, Fs)
%% Calculate the root mean square at each point with a given window size:
lengthSignal = length(signal);
squaredSignal = signal.^2;
windowSize = windowSeconds * Fs;
halfWindow = floor(windowSize/2);
rmsStart = halfWindow+1;
rmsEnd = lengthSignal - halfWindow;
rmsSignal = zeros(lengthSignal,1);
for i = rmsStart:rmsEnd
    rmsSignal(i) = sqrt(sum(squaredSignal(i-halfWindow:i+halfWindow))/(2*halfWindow+1));
end
clear squaredSignal
end