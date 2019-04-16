function[precise_timestamps,precise_samples]=generate_timestamps_from_Ncsfiles(TimeStamps,samples, exactLow, exactHi, nsamp);
% This function reads the data from the Neuralynx files and converts them
% to useable Matlab format. It needs information in the form of the
% timestamp values and the samples. Depending on the sampling rate acquired
% from the Header information, it interpolates the time stamp values. Once we
% have the required information ready, it converts to suitable 'single' and
% 'int16' data storage types and returns them in 2 arrays named 'precise_samples'
% and 'precise_timestamps'.
%Called by the following programs:
%--Auto-Scorer
%--Sleep Scorer

eelen=length(TimeStamps);
if isempty(nsamp)
    nsamp=512;
end
precise_samples = zeros(eelen*nsamp, 1);
precise_timestamps = zeros(eelen*nsamp, 1);
idx = 1;
for i = 1:eelen
  precise_samples(idx:idx+nsamp-1,:) = samples(512*(i-1)+1:512*i);
  if i < eelen
    t1 = TimeStamps(i);
    t2 = TimeStamps(i+1);
    interval = (t2-t1)/nsamp;
    trange =([t1 : interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  else
    t1 = TimeStamps(i);
    t2 = t1+interval*nsamp;
    trange =([t1 :interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  end
  idx = idx + nsamp;
end 
precise_timestamps=precise_timestamps/1000000; %Convert from usec to seconds.

% Set exact 2Hr start and stop times.
precise_timestamps = precise_timestamps(exactLow:exactHi);
precise_samples = precise_samples(exactLow:exactHi); 

clear trange