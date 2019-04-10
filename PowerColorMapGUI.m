function varargout = PowerColorMapGUI(varargin)
% POWERCOLORMAPGUI M-file for PowerColorMapGUI.fig
%      POWERCOLORMAPGUI, by itself, creates a new POWERCOLORMAPGUI or raises the existing
%      singleton*.
%
%      H = POWERCOLORMAPGUI returns the handle to a new POWERCOLORMAPGUI or the handle to
%      the existing singleton*.
%
%      POWERCOLORMAPGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POWERCOLORMAPGUI.M with the given input arguments.
%
%      POWERCOLORMAPGUI('Property','Value',...) creates a new POWERCOLORMAPGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PowerColorMapGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PowerColorMapGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PowerColorMapGUI

% Last Modified by GUIDE v2.5 04-Feb-2010 16:52:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PowerColorMapGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PowerColorMapGUI_OutputFcn, ...
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
%global EEG_SAMPLES EEG_TIMESTAMPS Fs EEG_Fc

% --- Executes just before PowerColorMapGUI is made visible.
function PowerColorMapGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PowerColorMapGUI (see VARARGIN)

% Choose default command line output for PowerColorMapGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PowerColorMapGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global EEG_TIMESTAMPS Fs EEG_Fc winSize winOverlap fStart fStop fRes tStart tStop tShift
sampRate = Fs; set(handles.samplingRate, 'String', sampRate);
winSize = 0.5; set(handles.windowSize, 'String', winSize);
winOverlap = 0.25; set(handles.windowOverlap, 'String', winOverlap);
fStart = 0; set(handles.freqStart, 'String', fStart);
fStop = EEG_Fc; set(handles.freqStop, 'String', fStop);
fRes = 0.1; set(handles.freqRes, 'String', fRes);

tStart = floor(EEG_TIMESTAMPS(1)); set(handles.timeStart, 'String', tStart);
tStop = floor(EEG_TIMESTAMPS(end)); set(handles.timeStop, 'String', tStop);
clear EEG_Fc

% --- Outputs from this function are returned to the command line.
function varargout = PowerColorMapGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Analyze.
function Analyze_Callback(hObject, eventdata, handles)
global EEG_SAMPLES EEG_TIMESTAMPS Fs winSize winOverlap fStart fStop fRes tStart tStop tShift
window = Fs * winSize; % Note: To obtain the same results for the removed specgram function, specify a 'Hann' window of length 256.
noverlap = floor(winOverlap * Fs); % Is closest whole number to achieve 0.25 s overlap (e.g., 0.25s * 150 samples/s = 37.5).
frequencyRange= fStart:fRes:fStop;

tStartIndex = find(EEG_TIMESTAMPS <= tStart, 1, 'last');
if isempty(tStartIndex)
    tStartIndex = 1;
end
tShift = EEG_TIMESTAMPS(tStartIndex);
tStopIndex = find(EEG_TIMESTAMPS >= tStop, 1);%#########################################
if isempty(tStopIndex)
    tStopIndex = lenght(EEG_TIMESTAMPS);
end
eegData = EEG_SAMPLES(tStartIndex:tStopIndex);
clear EEG_SAMPLES EEG_TIMESTAMPS
[P, F, T] = spectrogram(eegData,window,noverlap,frequencyRange,Fs);
clear eegData

T = T + tShift;
P = 10*log10(P);    %Converts power to decibels


%For SD calculations based on Theta Power mean and standard deviation:
% lengthF = length(F);
% thetaSum = sum(P(51:100,:))/50;
% meanTheta = mean(thetaSum);
% stdTheta = std(thetaSum);
% for i=1:lengthF
%     numStdP(i,:) = (P(i,:) - meanTheta)/stdTheta;
% end
% P = numStdP;
% clear numStdP thetaSum

figure2 = figure('Color',[1 1 1]);
% Create axes
axes('Parent',figure2,...
'Position',[0.13 0.219298245614035 0.775 0.705701754385965],...
'FontSize',20,'FontName','Arial','CLim',[0 20]);
surf(T, F,P,'edgecolor','none');
clear T F P
axis tight;
view(0,90);
xlabel('Time (Seconds)','FontSize',20,'FontName','Arial');
ylabel('Hz','FontSize',20,'FontName','Arial');
title('Power in dB','FontSize',16,'FontName','Arial');
colorbar

function windowSize_Callback(hObject, eventdata, handles)
global winSize
winSize = str2double(get(hObject,'String'));   % returns contents of windowSize as a double
if isnan(winSize)
    errordlg('Input must be a number','Error');
end

function windowOverlap_Callback(hObject, eventdata, handles)
global winOverlap
winOverlap = str2double(get(hObject,'String'));   % returns contents of windowOverlap as a double
if isnan(winOverlap)
    errordlg('Input must be a number','Error');
end

function freqStart_Callback(hObject, eventdata, handles)
global fStart
fStart = str2double(get(hObject,'String'));   % returns contents of freqStart as a double
if isnan(fStart)
    errordlg('Input must be a number','Error');
end

function freqStop_Callback(hObject, eventdata, handles)
global fStop
fStop = str2double(get(hObject,'String'));   % returns contents of freqStop as a double
if isnan(fStop)
    errordlg('Input must be a number','Error');
end

function freqRes_Callback(hObject, eventdata, handles)
global fRes
fRes = str2double(get(hObject,'String'));   % returns contents of freqRes as a double
if isnan(fRes)
    errordlg('Input must be a number','Error');
end

function timeStart_Callback(hObject, eventdata, handles)
global tStart
tStart = str2double(get(hObject,'String'));   % returns contents of timeStart as a double
if isnan(tStart)
    errordlg('Input must be a number','Error');
end

function timeStop_Callback(hObject, eventdata, handles)
global tStop
tStop = str2double(get(hObject,'String'));   % returns contents of timeStop as a double
if isnan(tStop)
    errordlg('Input must be a number','Error');
end

% --- Executes during object creation, after setting all properties.
function windowSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function windowOverlap_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freqStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freqRes_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function timeStart_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function timeStop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function freqStop_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function samplingRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplingRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
