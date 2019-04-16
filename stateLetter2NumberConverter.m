function [stateNumber]=stateLetter2NumberConverter(stateAbbreviation)
% This function is used to convert state scored dat from 2-letter
% abreviations to corresponding numbers.
%Called by the following programs:
%--SeqPSDvFrequencyAnalysis
%--Sleep Scorer
stateNumber = zeros(size(stateAbbreviation));
for i = 1:size(stateAbbreviation)
    switch stateAbbreviation{i,1}
        case '    AW'
            stateNumber(i)=1;
        case '    QS'
            stateNumber(i)=2;
        case '    RE'
            stateNumber(i)=3;
        case '    QW'
            stateNumber(i)=4;
        case '    UH'
            stateNumber(i)=5;
        case '    TR'
            stateNumber(i)=6;
        case '    NS'
            stateNumber(i)=7;
        case '    IW'
            stateNumber(i)=8;    
    end
end