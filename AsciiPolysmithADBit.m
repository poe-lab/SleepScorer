function samples = AsciiPolysmithADBit(filename, physInput, samples) %#ok<*INUSD>
%Called by the following programs:
%--Auto-Scorer
%--Sleep Scorer

fileName = strrep(filename, 'ascii', 'txt');
fidX = fopen(fileName);
Hedr = textscan(fidX, '%s');
fclose(fidX);
clear fileName fidX
ADstr = '(ASCII';
iADBV = strmatch(ADstr, Hedr{1});

if isempty(iADBV)
    switch physInput
        case 1
            errordlg('Please check that have a .TXT file paired with your .ASCII EMG file.', 'Missing File');
        case 2
            errordlg('Please check that have a .TXT file paired with your .ASCII EEG file.', 'Missing File');
        case 3
            errordlg('Please check that have a .TXT file paired with your .ASCII Input 3 file.', 'Missing File');
        case 4
            errordlg('Please check that have a .TXT file paired with your .ASCII Input 4 file.', 'Missing File');
    end 
end
ADBVstr = char(Hedr{1}(iADBV));
clear ADstr Hedr iADBV physInput
strMicroVoltCalculation = strrep(ADBVstr, 'ASCII', 'samples');
samples = eval(strMicroVoltCalculation); 
