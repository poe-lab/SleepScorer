function varargout = TimeStampGenerator2015v01(varargin)
% TIMESTAMPGENERATOR2015V01 M-file for TimeStampGenerator2015v01.fig
% Created by Brooks A. Gross on 02.22.2010
% --This program is used to create 
%      TIMESTAMPGENERATOR2015V01, by itself, creates a new TIMESTAMPGENERATOR2015V01 or raises the existing
%      singleton*.
%
%      H = TIMESTAMPGENERATOR2015V01 returns the handle to a new TIMESTAMPGENERATOR2015V01 or the handle to
%      the existing singleton*.
%
%      TIMESTAMPGENERATOR2015V01('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIMESTAMPGENERATOR2015V01.M with the given input arguments.
%
%      TIMESTAMPGENERATOR2015V01('Property','Value',...) creates a new TIMESTAMPGENERATOR2015V01 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TimeStampGenerator2015v01_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TimeStampGenerator2015v01_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TimeStampGenerator2015v01
% VERSION 2.0
% Modified by Brooks A. Gross on Oct-24-2012
% --The CSC import code has been updated to work with the MEX files from Neuralynx.
%   It will work on both the 32-bit and 64-bit version of MATLAB without
%   user intervention.
%
% Last Modified by GUIDE v2.5 17-Jun-2015 10:23:48
% --Now writes a real Excel file (1997-2003 .XLS) to the same folder as
% where the Neuralynx CSC (.NCS) is located.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TimeStampGenerator2015v01_OpeningFcn, ...
                   'gui_OutputFcn',  @TimeStampGenerator2015v01_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before TimeStampGenerator2015v01 is made visible.
function TimeStampGenerator2015v01_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TimeStampGenerator2015v01 (see VARARGIN)

% Choose default command line output for TimeStampGenerator2015v01
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TimeStampGenerator2015v01 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TimeStampGenerator2015v01_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in browseButton.
% This button opens up a browser window to select the CSC file.
function browseButton_Callback(hObject, eventdata, handles)
global CSCFile working_dir
working_dir = pwd;
current_dir = 'C:\SleepData\Datafiles'; % This is the default directory that opens.
cd(current_dir);
[filename, pathname] = uigetfile('*.ncs', 'Select a CSC file'); %This waits for user input and limits selection to .ncs files.
% Check for whether or not a file was selected
if isempty(filename) || isempty(pathname)
    uiwait(errordlg('You need to select a CSC file. Please try again',...
        'ERROR','modal'));
    cd(working_dir);
else
    cd(pathname);
    CSCFile= fullfile(pathname, filename);
    set(handles.CSCFileName,'string',filename);
    set(handles.CSCFileName,'Tooltipstring',CSCFile);
end

function CSCFileName_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function CSCFileName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in generateButton.  Triggers the time stamp
% generating function
function generateButton_Callback(hObject, eventdata, handles)
% global CSCFile
%timeBinSize = str2double(get(handles.binSize,'String'));   % returns contents of binSize as a double
%msgbox('Time stamp file started','Pop-up');
NeuralynxTimestamp_2hrBins
msgbox('Time stamp file completed.','Pop-up');

% This will be used to specify bin size in future versions if necessary.
function binSize_Callback(hObject, eventdata, handles)
% Code for future use:
% tBin = str2double(get(hObject,'String'));   % returns contents of binSize as a double
% if isnan(tBin)
%     set(hObject, 'String', 2);
%     errordlg('Input must be a number','Error');
% end
% if tBin <= 0
%     set(hObject, 'String', 2);
%     errordlg('Bin size must be > 0 Hours','Error');
% end

% --- Executes during object creation, after setting all properties.
function binSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% This is the code that finds the time stamps and writes them to a file.
% The file must be opened in Excel and saved as a real .xls file.
function NeuralynxTimestamp_2hrBins
global CSCFile working_dir
%##########################################################################
% VARIABLE DEFINITIONS:
%   tsIndexLow - beginning CSC index of the 2 hour block
%   tsLow - CSC start time stamp of the 2 hour block
%   twoHrStart - Interpolated exact start time of the 2 hour block
%   twoHrStartIndex - Index in relation to the full interpolated vector of exact start time of the 2 hour block
%   tsIndexHigh - End CSC index of the 2 hour block
%   tsHigh - CSC end time stamp of the 2 hour block
%   twoHrEnd - Interpolated exact stop time of the 2 hour block
%   twoHrEndIndex - Index in relation to the full interpolated vector of exact stop time of the 2 hour block
%   interp2HrStartIndex - Start index in relation to the CSC time stamp
%   interp2HrEndIndex - Stop index in relation to the CSC time stamp
%##########################################################################
timestamps = Nlx2MatCSC(CSCFile,[1 0 0 0 0],0,1);   % Extract timestamp information from CSC file.
%msgbox('.dll worked','Pop-up');
timestamps = timestamps';
eelen = length(timestamps);
nsamp = 512;    % Default number of valid samples per data packet

m = 1;
n = 0;

interpLength = nsamp * eelen; % Length of interpolated time stamp vector if it were created
fileEndCheck = 1;   % Used to determine when end of CSC time stamp vector has been reached

while m < interpLength && fileEndCheck < eelen
    n =n + 1;   % Counter for index of 2 hour blocks in time stamp file that is created
    remainder = rem(m, nsamp); % Used to determine where in the nsamp bin the interpolated time stamp is in relation to the CSC time stamp.
    if isequal(m, 1)    % Check to see if at first time stamp
        tsIndexLow(n) = 1; %#ok<*AGROW>
        tsLow(n) = timestamps(1);
        %twoHrStart(n) = timestamps(1);
        twoHrStartIndex(n) = 1;
    else
        if remainder > 0
            tsIndexLow(n) = floor(m/nsamp) + 1;
            tsLow(n) = timestamps(tsIndexLow(n));
            twoHrStartIndex(n) = m;
        else
            tsIndexLow(n) = floor(m/nsamp);
            tsLow(n) = timestamps(tsIndexLow(n));
            twoHrStartIndex(n) = m;
        end
    end
    interval = (timestamps(tsIndexLow(n)+1) - tsLow(n))/nsamp; % Determine the time stamp resolution.
    twoHrStart(n) = tsLow(n) + (remainder - 1) * interval;
    highPoint = twoHrStart(n) + 7200*1000000;
    tsIndexHigh(n) = find(timestamps <= highPoint, 1, 'last');
    fileEndCheck = tsIndexHigh(n);
    tsHigh(n) = timestamps(tsIndexHigh(n));
    interpBinTsHigh(1) = tsHigh(n);
    for i = 2:nsamp
        interpBinTsHigh(i) = interval + interpBinTsHigh(i-1);
    end
    interpBinIndex = find(interpBinTsHigh <= highPoint, 1, 'last');
    twoHrEnd(n) = interpBinTsHigh(interpBinIndex);
    clear interpBinTsHigh
    twoHrEndIndex(n) = (nsamp * (tsIndexHigh(n)-1)) + interpBinIndex;
    m = twoHrEndIndex(n) + 1;  
end
clear timestamps        

%Request user input to name time stamp file:
prompt = {'Enter the filename you want to save it as: (just the name)'};
def = {'SubjectNumberDate'};
dlgTitle = 'Input for Timestamp utility';
lineNo = 1;
answer = inputdlg(prompt,dlgTitle,lineNo,def);
filename = char(answer(1,:));
timestampfile = strcat(filename,'.xls');
% fod = fopen(timestampfile,'w'); %Creates and opens user-named file

%Convert twoHr Indices to interp sectioned indices by 2 hr blocks:
for i = 1:n
    interp2HrStartIndex(i) = rem((twoHrStartIndex(i)-1),512) + 1;
    interp2HrEndIndex(i) = twoHrEndIndex(i) - ((tsIndexLow(i) - 1)*nsamp + 1);
%     % Write start & end times for each epoch (can be <2hr):
%     fprintf(fod,'%f\t %f\t %f\t %f\t %f\t %f\n', tsLow(i), tsHigh(i), interp2HrStartIndex(i),...
%         interp2HrEndIndex(i), twoHrStart(i), twoHrEnd(i)); 
end
% Write start & end times for each epoch to a real Excel (1997-2003 .XLS) file (can be <2hr):
xlswrite(timestampfile, [tsLow', tsHigh', interp2HrStartIndex',...
    interp2HrEndIndex', twoHrStart', twoHrEnd'], 'Sheet1');
cd(working_dir);
