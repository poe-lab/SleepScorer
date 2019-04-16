%   Neuralynx AD bit-value extractor
% VERSION 2.0
% Modified by Brooks A. Gross on Oct-24-2012
% --The CSC import code has been updated to work with the MEX files from Neuralynx.
%   It will work on both the 32-bit and 64-bit version of MATLAB without
%   user intervention.
%Called by the following programs:
%--Auto-Scorer
%--Sleep Scorer
function ADBit2uV = HeaderADBit(filename, physInput)
% Hedr = Nlx2MatCSC(filename,0,0,0,0,0,1,0,1);  %Old version using Nlx2MatCSC.dll
Hedr = Nlx2MatCSC(filename,[0 0 0 0 0],1,1);  %New MEX version for either 32-bit or 64-bit
HedrLngth = length(Hedr);
ADstr = 'ADBitVolts';

for iHedr = 1:HedrLngth
    iADBV = strfind(Hedr{iHedr},ADstr);
    if isempty(iADBV)
        if isequal(iHedr, HedrLngth)
            switch physInput
                case 1
                    errordlg('Please check that your EMG file is in the .CSC format.', 'Incorrect File Format');
                case 2
                    errordlg('Please check that your EEG file is in the .CSC format.', 'Incorrect File Format');
                case 3
                    errordlg('Please check that your Input 3 file is in the .CSC format.', 'Incorrect File Format');
                case 4
                    errordlg('Please check that your Input 4 file is in the .CSC format.', 'Incorrect File Format');
            end
             
        end
    else
        iADBVcell = iHedr;
        break
    end
end
ADBVstr = Hedr{iADBVcell};
clear ADstr Hedr HedrLngth iHedr iADBV iADBVcell

spltADBV = textscan(ADBVstr, '%s %f');
ADBitVal = spltADBV{1,2};
if isempty(ADBitVal)||(ADBitVal <= 0)||isequal(ADBitVal,NaN)
    switch physInput
        case 1
            errordlg('Please check that your EMG file was recorded in Cheetah 4 or 5.', 'Incorrect File Format');
        case 2
            errordlg('Please check that your EEG file was recorded in Cheetah 4 or 5.', 'Incorrect File Format');
        case 3
            errordlg('Please check that your Input 3 file was recorded in Cheetah 4 or 5.', 'Incorrect File Format');
        case 4
            errordlg('Please check that your Input 4 file was recorded in Cheetah 4 or 5.', 'Incorrect File Format');
    end
end
ADBit2uV = 10^6 * ADBitVal;
clear ADBitVal ADBVstr spltADBV physInput

