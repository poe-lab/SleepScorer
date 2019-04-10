function [hiPass, loPass] = nlxFilterSettings(Header)
% This is a subfunction of Sleep Scorer added in Sleep Scorer 2018a. This
% function extracts the header filter settings used when recording from a
% Neuralynx system.

% Revisions:
% 09.12.2018 -- Brooks A. Gross added support for recordings made on the 
% discontinued Cheetah 160. 


%% Find high pass filter in Header:
targ= strfind(Header,'-DspLowCutFrequency');
for i=1:length(targ)
    targIdx(i)= isempty(targ{i}); %#ok<AGROW>
end
LowFreqCutIdx = find(targIdx==0);  
% This IF statement catches Cheetah 160 recordings.
if isempty(LowFreqCutIdx)
    clear targ targIdx
    targ= strfind(Header,'-AmpLowCut');
    for i=1:length(targ)
        targIdx(i)= isempty(targ{i});
    end
    LowFreqCutIdx = find(targIdx==0);
    hiPass = str2double(strrep(Header{LowFreqCutIdx,1}, '-AmpLowCut ', '')); %#ok<*FNDSB>
else
    hiPass = str2double(strrep(Header{LowFreqCutIdx,1}, '-DspLowCutFrequency ', ''));

end 
clear targ targIdx

%% Find low pass filter in Header:
targ= strfind(Header,'-DspHighCutFrequency');

for i=1:length(targ)
    targIdx(i)= isempty(targ{i});
end
HighFreqCutIdx = find(targIdx==0);   
% This IF statement catches Cheetah 160 recordings.
if isempty(HighFreqCutIdx)
    clear targ targIdx
    targ= strfind(Header,'-AmpHiCut');
    for i=1:length(targ)
        targIdx(i)= isempty(targ{i});
    end
    HighFreqCutIdx = find(targIdx==0);
    loPass = str2double(strrep(Header{HighFreqCutIdx,1}, '-AmpHiCut ', ''));
else
    loPass = str2double(strrep(Header{HighFreqCutIdx,1}, '-DspHighCutFrequency ', ''));
end 
clear targ targIdx
    