function [dataFolder, fileName, numberOfDataFiles] = batchLoadFiles(fileType)
% Loads all files of specified type that are found in the selected folder
% Used by the following programs:
%--StateTimeBinAnalysis.m

%% Define variables
dataFolder = []; %This will be the folder that the user selects.
fileName = [];  %This will be the array of strings of all files with the 
                %NTT extension found in the selected folder.
%% Select folder for location of the files

% The WHILE loop below prompts the user to select the folder containing the
% files to be batch loaded for further analysis.
while isempty(dataFolder)
    dataFolder = uigetdir;
    fileName = ls(fullfile(dataFolder, fileType));
    
    % This IF loop checks to see if there are files with the defined extension
    % in the selected folder. If there are no files in the selected folder,
    % the user will be prompted again to select a folder.
    if isempty(fileName)
        msgbox(['No data files with extension' fileType 'exist in the selected folder. Please select a different folder.']);
        dataFolder = [];
    end
end

[numberOfDataFiles,~] = size(fileName); % Finds the number of data files in the selected folder.

