function fillInBreaksCSC
[CSCFilename, CSCFilePath] = uigetfile({'*.ncs',...
'Pick CSC files.'},'Select Continuously Sampled Channel File');
cscFile = fullfile(CSCFilePath, CSCFilename);
[TimeStamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(cscFile, [1 1 1 1 1], 1, 1, [] );
ChannelNumbers = ChannelNumbers(1);
SampleFrequencies = SampleFrequencies(1);
NumberOfValidSamples =NumberOfValidSamples(1);
A= min(diff(TimeStamps));
T=find(diff(TimeStamps)>1.1*A);
numBreaks = size(T,2);
T = [0 T];
newTimeStamps = [];
newSamples = [];
nsamp = 512;

for j = 1:numBreaks
    tempTS = TimeStamps((T(j)+1):T(j+1));
    tempSamp = Samples(:,(T(j)+1):T(j+1));
    precise_samples=tempSamp(:);
    clear tempSamp
    eelen=length(tempTS);
    precise_timestamps = zeros(eelen*nsamp, 1);
    idx = 1;
    for i = 1:eelen
      if i < eelen
        t1 = tempTS(i);
        t2 = tempTS(i+1);
        interval = (t2-t1)/nsamp;
        trange =([t1 : interval : t2-interval]);
        precise_timestamps(idx:idx+nsamp-1,1) = trange;
      else
        t1 = tempTS(i);
        t2 = t1+interval*nsamp;
        trange =([t1 :interval : t2-interval]);
        precise_timestamps(idx:idx+nsamp-1,1) = trange;
      end
      idx = idx + nsamp;
    end
    gapTime = TimeStamps(T(j+1)+1) - precise_timestamps(end);
    numFillTs = floor(gapTime/interval - 1);
    fillTime = interval:interval:(numFillTs*interval);
    fillTime = precise_timestamps(end) + fillTime;
    fillTime = fillTime(:);
    fillSamp = fillTime .* 0;
    newTimeStamps = [newTimeStamps; precise_timestamps; fillTime];
    newSamples = [newSamples; precise_samples; fillSamp];
end

tempTS = TimeStamps((T(end)+1):end);
tempSamp = Samples(:,(T(end)+1):end);
precise_samples=tempSamp(:);
clear tempSamp
eelen=length(tempTS);
precise_timestamps = zeros(eelen*nsamp, 1);
idx = 1;
for i = 1:eelen
  if i < eelen
    t1 = tempTS(i);
    t2 = tempTS(i+1);
    interval = (t2-t1)/nsamp;
    trange =([t1 : interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  else
    t1 = tempTS(i);
    t2 = t1+interval*nsamp;
    trange =([t1 :interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  end
  idx = idx + nsamp;
end

newTimeStamps = [newTimeStamps; precise_timestamps];
newSamples = [newSamples; precise_samples];
newEnd = floor(length(newSamples)/nsamp);
newLength = nsamp * newEnd;
newTimeStamps = newTimeStamps(1:nsamp:newLength)';
newSamples = newSamples(1:newLength);
newSamples = reshape(newSamples, nsamp, newEnd);
newChannelNumbers(1:newEnd) = ChannelNumbers;
newSampleFrequencies(1:newEnd) = SampleFrequencies;
newNumberOfValidSamples(1:newEnd) = NumberOfValidSamples;

fixedNttFilename = ['fillTimeGaps' CSCFilename ];
cscFile = fullfile(CSCFilePath, fixedNttFilename);
Mat2NlxCSC(cscFile, 0, 1, [], [1 1 1 1 1 1], newTimeStamps, newChannelNumbers,...
    newSampleFrequencies, newNumberOfValidSamples, newSamples, Header);
clear all

