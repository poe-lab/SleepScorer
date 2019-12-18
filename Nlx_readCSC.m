function [data,timeStamps,samplingInterval,chNum] = Nlx_readCSC(fileName,computeTS)

% SYNTAX: [data,timeStamps,samplingInterval,chNum] = Nlx_readCSC(fileName,computeTS)
%
% if computeTS is false,timeStamps will be returned as NaN; this can save a
% lot of computational time if you're processing lots of files that all
% have the same timestamps.
%
% This function deals with the fact that Nlx writes its data into columns
% of a matrix, but that in certain circumstances a column will not get
% filled all the way, and in that case, the remaining data in that column
% will be a duplicate of the data from the previous column. This causes
% issues with both the data itself and the timestamps if you just assume
% that the columns are of equal length.
%
% Please note that samplingInterval is in milliseconds, so an interval of
% 0.5 corresponds to an actual sampling rate of 2000 Hz.
%
% Code written by Emily Mankin and distributed under Creative Commons
% Attribution license, which means you can share, but you can't remove the
% attribution. Code is offered without warranty, but tries hard to be
% correct.

if ~exist('computeTS','var')||isempty(computeTS)
    computeTS = 1;
end
%%
[ts,chNum,sampFreq,numSamp,data,hdr] = Nlx2MatCSC(fileName,[1,1,1,1,1],1,1);
toShorten = find(numSamp ~= size(data,1));
for s = 1:length(toShorten)
    data(numSamp(toShorten(s))+1:end,toShorten(s)) = NaN;
end


if length(unique(sampFreq))~=1
    warning('Sampling Frequency is not uniform across data set, please proceed with caution...')
    keyboard
end
if length(unique(chNum))~=1
    warning('You appear to be reading data from more than one channel. This code is not equipped for that...')
    keyboard
end

sampFreq = sampFreq(1)*1e-3; % converts to nSamples per millisecond to be consistent with how we store data for Black Rock
%%
if isempty(hdr)
    ADBitVolts = NaN;
else
    
    findADBitVolts = cellfun(@(x)~isempty(regexp(x,'ADBitVolts', 'once')),hdr);
    ADBitVolts = regexp(hdr{findADBitVolts},'(?<=ADBitVolts\s)[\d\.e\-]+','match');
    if isempty(ADBitVolts)
        ADBitVolts = NaN;
    else
    ADBitVolts = str2double(ADBitVolts{1});
    end
end


data = reshape(data,[],1);
data(isnan(data)) = [];

if ~isnan(ADBitVolts)
    data = -data*ADBitVolts*1e6;
else
    warning('ADBitVolts is NaN; your CSC data will not be scaled')
end

ts = ts*1e-6; % ts now in seconds
samplingInterval = 1/sampFreq; % not in seconds, but gets multiplied by 1e-3 later

if computeTS

%% 
totalSamples = cumsum(numSamp);
timeStamps = zeros(1,totalSamples(end));

for t = 1:length(ts)
    if t==1
        startSample = 1;
    else
        startSample = totalSamples(t-1)+1;
    end
    endSample = startSample+numSamp(t)-1;
    startTS = ts(t);
    theseTS = (1:numSamp(t))*samplingInterval*1e-3+startTS;
    timeStamps(startSample:endSample) = theseTS;
end

else
    timeStamps = NaN;
   
end
