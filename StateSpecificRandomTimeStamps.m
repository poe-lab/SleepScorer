function randomTimeSets = StateSpecificRandomTimeStamps(numShuffles, numEvents)
%% Select Stage Scored File:
working_dir=pwd;
current_dir='C:\SleepData';
cd(current_dir);
scoredCheck = 0;
while isequal(scoredCheck, 0)
    [scoredFile, scoredPath] = uigetfile({'*.xls','Excel 1997-2003 File (*.xls)'},...
        'Select the Sleep Scored File');
    if isequal(scoredFile,0) || isequal(scoredPath,0)
        uiwait(errordlg('You need to select a file. Please try again',...
            'ERROR','modal'));
    else
        cd(working_dir);
        stageScoredFile= fullfile(scoredPath, scoredFile);
        %Load sleep scored file:
        try
            [numData, stringData] = xlsread(stageScoredFile);
            scoredCheck = 1;
        catch %#ok<*CTCH>
            % If file fails to load, it will notify user and prompt to
            % choose another file.
            uiwait(errordlg('Check if the scored file is saved in Microsoft Excel format.',...
             'ERROR','modal'));
         scoredCheck = 0;
        end

    end
end

%% Detect if states are in number or 2-letter format:
if isequal(size(numData,2),3)
    scoredStates = numData(:,2:3);
    clear numData stringData
else
    scoredStates = numData(:,2);
    clear numData
    stringData = stringData(3:end,3);
    [stateNumber] = stateLetter2NumberConverter(stringData);
    scoredStates = [scoredStates stateNumber];
    clear stateNumber stringData
end
epochInSeconds = scoredStates(2,1) - scoredStates(1,1);
startTime = scoredStates(1,1) * 10^6;
endTime = (scoredStates(end,1) + epochInSeconds) * 10^6;

%% Load Neuralynx continuous file
[CSCFilename, CSCFilePath] = uigetfile({'*.ncs',...
        'Pick CSC files.'},'Select Continuously Sampled Channel File');
cscFile = fullfile(CSCFilePath, CSCFilename);
Timestamps = Nlx2MatCSC(cscFile, [1 0 0 0 0], 0, 4, [startTime endTime]);
nsamp = 512;

% Fill in the time stamps:
eelen=length(Timestamps);
precise_timestamps = zeros(eelen*nsamp, 1);
idx = 1;
for i = 1:eelen
  if i < eelen
    t1 = Timestamps(i);
    t2 = Timestamps(i+1);
    interval = (t2-t1)/nsamp;
    trange =([t1 : interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  else
    t1 = Timestamps(i);
    t2 = t1+interval*nsamp;
    trange =([t1 :interval : t2-interval]);
    precise_timestamps(idx:idx+nsamp-1,1) = trange;
  end
  idx = idx + nsamp;
end
clear Timestamps eelen t1 t2 interval trange
% Convert from usec to seconds:
timeStamps = precise_timestamps/1000000;
clear precise_timestamps
Fs = 1/(timeStamps(2)-timeStamps(1));

%% Downsample Signal:
targetFs = 1000;
DsFactor = floor(Fs/targetFs); % Determine downsampling factor to get to target sampling frequency
timeStamps = timeStamps(1:DsFactor:end);

%% Assign states to each data point as a new vector:
lengthSignal = length(timeStamps);
sleepsamp = zeros(lengthSignal,1);
for i = 1:size(scoredStates, 1)
    if isequal(i, size(scoredStates, 1))
        subIntervalIndx = find(timeStamps >= scoredStates(i,1) & timeStamps < (scoredStates(i,1) + 10));
    else
        subIntervalIndx = find(timeStamps >= scoredStates(i,1) & timeStamps < scoredStates(i+1,1));
    end
    if ~isempty(subIntervalIndx)
        sleepsamp(subIntervalIndx) = scoredStates(i,2);
        clear subIntervalIndx
    end
end

%% Isolate time stamp vector:
isoTimeStamps = timeStamps(sleepsamp==2 | sleepsamp==6);
lengthIsoTime = length(isoTimeStamps);

%% Generate random shuffles:
randomTimeSets = zeros(numEvents, numShuffles);
for i = 1:numShuffles
    randomTimeSets(:,i) = sort(isoTimeStamps(randperm(lengthIsoTime, numEvents)));
end




