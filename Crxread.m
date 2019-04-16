function[precise_timestamps,precise_samples] = Crxread(TimeStamps,samples,sampfactor,nsamp, exactLow, exactHi)
% Developed by Apurva Turakhia , University of Michigan
% First Version: Jan 10, 2003
%Called by the following programs:
%--Auto-Scorer
%--Sleep Scorer
eelen = length(TimeStamps);
precise_samples = zeros(eelen*nsamp,1);
precise_timestamps = zeros(eelen*nsamp,1);

idx = 1;
for i = 1:eelen
  precise_samples(idx:idx+nsamp-1,:) = samples(nsamp*(i-1)+1:nsamp*i);
  if i < eelen
    t1 = TimeStamps(i);
    t2 = TimeStamps(i+1);
    interval = (t2-t1)/nsamp;
    trange =(t1 : interval : t2-interval);
    precise_timestamps(idx:idx+nsamp-1) = trange;
  else
    t1 = TimeStamps(i);
    t2 = t1+interval*nsamp;
    trange =(t1 :interval : t2-interval);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  end
  idx = idx + nsamp;
end
precise_timestamps=precise_timestamps/10000; %Convert from msec to seconds.

% Set exact 2Hr start and stop times.
precise_timestamps = precise_timestamps(exactLow:exactHi);
precise_samples = precise_samples(exactLow:exactHi); 

% Now Downsample the total acquired samples from CRextract.
% timestamps=single(timestamps(1:sampfactor:end));
% samples=samples(1:sampfactor:end);
clear trange
fprintf('Done with the Crxread\n');