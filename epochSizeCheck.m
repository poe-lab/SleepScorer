function epochSizeCheck
global epochScoringSize epochVal

if isequal(epochScoringSize, 0)
    epochScoringSize = epochVal;
    switch epochScoringSize
        case 1
            epochString = '2 seconds';
        case 2
            epochString = '10 seconds';
        case 3
            epochString = '30 seconds';
        case 4
            epochString = '1 minute';
        case 5
            epochString = '2 minutes';
        case 6
            epochString = '4 minutes';
    end
    uiwait(msgbox(['Epoch setting for scoring is now locked to' epochString...
        '.  The epoch size can be changed for viewing purposes, but it must be changed back to this setting for scoring.']));
end