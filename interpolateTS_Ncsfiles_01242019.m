function[precise_timestamps,precise_samples, medianSampRate]=interpolateTS_Ncsfiles_01242019(TimeStamps,Samples, exactLow, exactHi, nsamp)
% Interpolate the time stamps in between the binned times based on the
% sampling frequency.
if isempty(nsamp)
    nsamp=512;
end
% Find median sampling rate: 
medianSampRate = (nsamp)/median(diff(TimeStamps)) * 10^6;
    
%% Need to first interpolate the time stamps:
timeInterval = 10^6 * 1/medianSampRate;
eelen=length(TimeStamps);
precise_timestamps = zeros(eelen*nsamp, 1);
idx = 1;
for i = 1:eelen
    t1 = TimeStamps(i);
    % Calculate ideal next time stamp in bins of nsamp length:
    t2 = TimeStamps(i) +  timeInterval*nsamp;
    % Interpolate time stamp for each sample in the bin:
    trange =(t1 : timeInterval : t2-timeInterval);
    % Place in the pre-allocated time vector:
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
    % Modify index for next time bin:
    idx = idx + nsamp;
end

precise_timestamps = precise_timestamps/1000000; %Convert from usec to seconds.

% Set exact start and stop times.
if isempty(exactLow)
    exactLow = 1;
    exactHi = length(Samples);
end
precise_timestamps = precise_timestamps(exactLow:exactHi);
precise_samples = Samples(exactLow:exactHi); 