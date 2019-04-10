%##########################################################################
%                              SLEEP SCORER 2018a
%
%                                 Created by 
%                               Brooks A. Gross
%
%                            SLEEP AND MEMORY LAB
%                                   UCLA
%##########################################################################
% DESCRIPTION:
% This program provides the user with the ability to view electro-
% physiological signals and manually score sleep and waking states.  The 
% scored states are automatically saved into an Excel file, whose name is 
% specified within the program itself.  The output can be used as a 
% training template for the Auto-Scorer Program. Scored files can be loaded
% for review and correction.
%##########################################################################
%% Sleep Scorer 2018a
% VERSION 09.06.2018 Modified by Brooks A. Gross
% --Re-arranged the GUI to make more sense from a process flow viewpoint. 
% 
% --There a no longer requirements to have default folders on the C-drive 
% (e.g. C:\SleepData). The program will remember the last folder in which
% you selected a file and will return to the same folder when you select
% the next file. 
% 
% --Neuralynx is now only system supported by program.
% 
% --All default filter settings will load on their own, so there is no need
% to click the 'Reset' button.
% 
% --Added sub-functions to prevent user error in selecting filter settings.
% In addition, the program will check the filters that were used during
% recording to make sure that the user selections are within that range. 
% Any filters that are left empty will be filled with the filter settings 
% that were used for the recording.
% 
% --User does NOT have to score the first epoch of each section.
% 
% --Fixed key pad functionality. Check the box to turn it on, and then 
% click anywhere on the Sleep Scorer background to be able to score using 
% the number keys and navigate using the left and right arrow keys.
% 
% --The output header file now saves as a real Excel file. The user will 
% still have to save the scored file as a real Excel file.
%% Sleep Scorer
% VERSION 08.11.2017 Modified by Brooks A. Gross
% --Added support for DSI EDF files
% VERSION 7
% Modified by Brooks A. Gross on Jan-06-2015
% --Gap in documentation of changes noted.
% --Changed all 'filter' functions to 'filtfilt' in order to correct for
% phase delays caused by filters. This is not very important to sleep
% scoring, but it is important when carrying out any analyses relating EEG
% slow waves to single unit data.
% --Updated filter design of most filters to output zeros and poles instead
% of filter coefficients a and b. This avoids the round-off errors that can
% occur with higher order filters when using the coefficients. This was
% happening when trying to implement high pass filters ~< 1 Hz.
% VERSION 5b
% Modified by Brooks A. Gross on Nov-13-2012
% --Sleep Scorer can now import Plexon .PLX data files.
%   It will work on both the 32-bit and 64-bit version of MATLAB without
%   user intervention.
% --Loading for Correction now works for both manually scored and
%   auto-scored files.
% --Fixed issue with system locking up that was due to button callbacks'
%   default interruptible setting being 'On'.  Changed it to off for all
%   buttons and 
% VERSION 5
% Modified by Brooks A. Gross on Oct-24-2012
% --The CSC import code has been updated to work with the MEX files from Neuralynx.
%   It will work on both the 32-bit and 64-bit version of MATLAB without
%   user intervention.
% VERSION 4a
% Modified by Brooks A. Gross on Jan-15-2010
% --Layout has been modified.
% --Code optimization, including extraction of some sub-functions that are
%   now in separate m-files.
% VERSION 3a
% Modified by Brooks A. Gross on Oct-07-2009
% --Layout has been modified.
% --Added a scored history bar at the top for a 2 hour section. A black
%   indicator below represents location of the 2 minute history bar below.
% --Expanded the small history bar to be 2 minutes.
% 
% VERSION 2b
% Modified by Brooks A. Gross on Jan-23-2008
% --Filter information now in a separate file that is automatically named 
%   based on UI Training file name. It is automatically imported to
%   scorematic.m.
% --Fixed initialization of the filters and check boxes. *Appears to have
%   address the chart loading anomalies.
% 
% VERSION 2a
% Modified by Brooks A. Gross on Jan-10-2008
% --Added two optional customizable inputs
% --Header for .xls file now contains filter settings for EMG and EEG
%   inputs.
% Modified by Brooks A. Gross on Dec-7-2007
% --Added the ability to set/reset bandwidths of Delta, Theta, Sigma,& Beta
%   waves. User must push the 'Set/Reset' button upon opening the GUI.
%
% VERSION 1 
% Created by Apurva Turakhia on Jun-24-2003
%##########################################################################     
%%%%%Original Sleep Scorer Figure code
function varargout = SleepScorer_2018a(varargin)
%    sleepscorer_2018a Application M-file for SleepScorer_2018a.fig
%    FIG = sleepscorer_2018a launch SleepScorer_2018a GUI.
%    sleepscorer_2018a('callback_name', ...) invoke the named callback.
global  Sleepstates Statecolors FileFlag


FileFlag = 1;
Sleepstates=['Active Waking   '; ' Quiet Sleep    '; '     REM        ';'Quiet Waking    ';...
    '   Unhooked     '; '  Trans to REM  ';' Unidentifiable ';'Intermed Waking '];
Statecolors = [ 1 0.97 0; 0.1 0.3 1; 0.97 0.06 0; 0 1 0.1 ; 0 0 0; 0 1 1; 0.85 0.85 0.85; 1 1 1]; 
%Changed UNHOOKED to black to be consistent with Auto-Scorer colors.
if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch ME
        errordlg(ME.message,ME.identifier);
    end
    
end

%%%%%%
% function varargout = SleepScorer_2018a(varargin)
% % SleepScorer_2018a M-file for SleepScorer_2018a.fig
% %      SleepScorer_2018a, by itself, creates a new SleepScorer_2018a or raises the existing
% %      singleton*.
% %
% %      H = SleepScorer_2018a returns the handle to a new SleepScorer_2018a or the handle to
% %      the existing singleton*.
% %
% %      SleepScorer_2018a('CALLBACK',hObject,eventData,handles,...) calls the local
% %      function named CALLBACK in SleepScorer_2018a.M with the given input arguments.
% %
% %      SleepScorer_2018a('Property','Value',...) creates a new SleepScorer_2018a or raises the
% %      existing singleton*.  Starting from the left, property value pairs are
% %      applied to the GUI before sleepscorer2_OpeningFcn gets called.  An
% %      unrecognized property name or invalid value makes property application
% %      stop.  All inputs are passed to sleepscorer2_OpeningFcn via varargin.
% %
% %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
% %      instance to run (singleton)".
% %
% % See also: GUIDE, GUIDATA, GUIHANDLES
% 
% % Edit the above text to modify the response to help SleepScorer_2018a
% 
% % Last Modified by GUIDE v2.5 04-Sep-2018 12:36:00
% 
% % Begin initialization code - DO NOT EDIT
% gui_Singleton = 1;
% gui_State = struct('gui_Name',       mfilename, ...
%                    'gui_Singleton',  gui_Singleton, ...
%                    'gui_OpeningFcn', @SleepScorer_2018a_OpeningFcn, ...
%                    'gui_OutputFcn',  @SleepScorer_2018a_OutputFcn, ...
%                    'gui_LayoutFcn',  [] , ...
%                    'gui_Callback',   []);
% if nargin && ischar(varargin{1})
%     gui_State.gui_Callback = str2func(varargin{1});
% end
% 
% if nargout
%     [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
% else
%     gui_mainfcn(gui_State, varargin{:});
% end
% % End initialization code - DO NOT EDIT
% 
% 
% % --- Executes just before SleepScorer_2018a is made visible.
% function SleepScorer_2018a_OpeningFcn(hObject, eventdata, handles, varargin)
% % This function has no output args, see OutputFcn.
% % hObject    handle to figure
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % varargin   command line arguments to SleepScorer_2018a (see VARARGIN)
% 
% % Choose default command line output for SleepScorer_2018a
% handles.output = hObject;
% 
% % Update handles structure
% guidata(hObject, handles);
% 
% % UIWAIT makes SleepScorer_2018a wait for user response (see UIRESUME)
% % uiwait(handles.figure1);
% 
% 
% % --- Outputs from this function are returned to the command line.
% function varargout = SleepScorer_2018a_OutputFcn(hObject, eventdata, handles) 
% % varargout  cell array for returning output args (see VARARGOUT);
% % hObject    handle to figure
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Get default command line output from handles structure
% varargout{1} = handles.output;
%%%%%%
% global  Sleepstates Statecolors
% Sleepstates=['Active Waking   '; ' Quiet Sleep    '; '     REM        ';'Quiet Waking    ';...
%     '   Unhooked     '; '  Trans to REM  ';' Unidentifiable ';'Intermed Waking '];
% Statecolors = [ 1 0.97 0; 0.1 0.3 1; 0.97 0.06 0; 0 1 0.1 ; 0 0 0; 0 1 1; 0.85 0.85 0.85; 1 1 1]; 
% %Changed UNHOOKED to black to be consistent with Auto-Scorer colors.

%% ########################################################################
%                       FILE SELECTION FUNCTIONS
%--------------------------------------------------------------------------
function timestampfile_open_Callback(hObject, eventdata, handles)
%% Select the time stamp file that specifies the range of time to be scored:
global current_dir
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile('*.xls', 'Pick the timestamp file for these datafiles');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    timestampfile= fullfile(pathname, filename);
    statusTimeStampFile = xlsfinfo(timestampfile);
    if isempty(statusTimeStampFile)
        uiwait(errordlg('The time stamp file is not in Excel 1997-2003 format. Please try loading file again',...
        'ERROR','modal'));
    else
        set(handles.tstampsfile,'string',filename);
        set(handles.tstampsfile,'Tooltipstring',timestampfile);
    end
end

function emgfile_open_Callback(hObject, eventdata, handles)
%% Select the EMG file:
global current_dir

if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile({'*.ncs',...
        'Neuralynx CSC File'},'Pick an EMG data file');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    emgfile= fullfile(pathname, filename);
    set(handles.emgfile,'string',filename);
    set(handles.emgfile,'Tooltipstring',emgfile);
end

function eegfile_open_Callback(hObject, eventdata, handles) %#ok<*INUSL>
%% Select the EEG file:global current_dir
global current_dir
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile({'*.ncs',...
        'Neuralynx CSC File'}, 'Pick an EEG data file');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    eegfile= fullfile(pathname, filename);
    set(handles.eegfile,'string',filename);
    set(handles.eegfile,'Tooltipstring',eegfile); 
end

function input3file_open_Callback(hObject, eventdata, handles)
%% Select the Input 3 file:
global current_dir
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile({'*.ncs',...
        'Neuralynx CSC File'}, 'Pick a file for Input 3');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    Input3file= fullfile(pathname, filename);
    set(handles.Input3file,'string',filename);
    set(handles.Input3file,'Tooltipstring',Input3file); 
end

function input4file_open_Callback(hObject, eventdata, handles)
%% Select the Input 4 file:
global current_dir
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile({'*.ncs',...
        'Neuralynx CSC File'}, 'Pick a file for Input 4');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    Input4file= fullfile(pathname, filename);
    set(handles.Input4file,'string',filename);
    set(handles.Input4file,'Tooltipstring',Input4file); 
end

function manualScored_open_Callback(hObject, eventdata, handles)
%% Select the manually scored file that you want to correct:
global scoreFileCorrectionType
global current_dir
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile('*.xls', 'Pick the manually scored file you want to correct.');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please try loading file again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    manualScoredFullPathName= fullfile(pathname, filename);
    statusScoredFile = xlsfinfo(manualScoredFullPathName);  % Completes the file name for the header file and checks to see if it exists
    if isempty(statusScoredFile)
        uiwait(errordlg('The manually scored file is not in Excel 1997-2003 format. Please try loading file again',...
        'ERROR','modal'));
    else
        set(handles.autoscoredfile,'string',filename);
        set(handles.autoscoredfile,'Tooltipstring',manualScoredFullPathName);
        scoredFileType='Manually Scored';  % Sets the label string to reflect the file type that will be corrected
        scoreFileCorrectionType = 0;  % Variable set to direct to loading a manually scored file
        set(handles.ScoredFileType,'String', scoredFileType);  % Loads the label string to the 'ScoredFileType' field on the GUI

        % Load the settings from when the file was scored using the header file
        % that was created.  The settings can be over-ruled before loading the
        % file for correction.
        savedHeaderFile = regexprep(manualScoredFullPathName, '.xls', '');  % Removes Excel extension from the manual scored file name
        statusHeaderFile = xlsfinfo([savedHeaderFile 'Header.xls']);  % Completes the file name for the header file and checks to see if it exists
        if isempty(statusHeaderFile)
            uiwait(errordlg('The header file associated with the manually scored file . Please try loading file again',...
            'ERROR','modal'));
        else  % The header exists and is in Excel format.
            savedHeadrFiltrs = xlsread([savedHeaderFile 'Header.xls'],'b1:y1')';  % Read in the setting value from the manually scored file.
            if savedHeadrFiltrs(1) ~= -1
                EMG_Fc = savedHeadrFiltrs(1);
                set(handles.EMG_cutoff, 'String', EMG_Fc);
            end
            if savedHeadrFiltrs(3) ~= -1
                EMG_LP_Fc = savedHeadrFiltrs(3);
                set(handles.EMG_Lowpass_cutoff, 'String', EMG_LP_Fc);
                
            end
            if savedHeadrFiltrs(5) ~= -1
                EMG_Notch_enable=1;
                set(handles.Notch60EMG, 'Value',1);
            end
            if savedHeadrFiltrs(7) ~= -1
                EEG_Fc = savedHeadrFiltrs(7);
                set(handles.EEG_cutoff, 'String', EEG_Fc);
            end
            if savedHeadrFiltrs(9) ~= -1
                EEG_HP_Fc = savedHeadrFiltrs(9);
                set(handles.EEG_Highpass_cutoff, 'String', EEG_HP_Fc);
            end
            if savedHeadrFiltrs(11) ~= -1
                EEG_Notch_enable=1;
                set(handles.Notch60, 'Value',1);
            end
            if (savedHeadrFiltrs(13)~= -1||savedHeadrFiltrs(15)~= -1||savedHeadrFiltrs(17)~= -1)
                Input3_enable = 1;
                set(handles.Input3_checkbox, 'Value',1);
            end
            if savedHeadrFiltrs(13) ~= -1
                Input3_HP_Fc = savedHeadrFiltrs(13);
                set(handles.Input3_Highpass_cutoff, 'String', Input3_HP_Fc);
                
            end
            if savedHeadrFiltrs(15) ~= -1
                Input3_LP_Fc = savedHeadrFiltrs(15);
                set(handles.Input3_Lowpass_cutoff, 'String', Input3_LP_Fc);
                
            end
            if savedHeadrFiltrs(17) ~= -1
                Input3_Notch_enable = 1;
                set(handles.Notch60Input3, 'Value',1);
            end
            if (savedHeadrFiltrs(19)~= -1||savedHeadrFiltrs(21)~= -1||savedHeadrFiltrs(23)~= -1)
                Input4_enable = 1;
                set(handles.Input4_checkbox, 'Value',1);
            end
            if savedHeadrFiltrs(19) ~= -1
                Input4_HP_Fc = savedHeadrFiltrs(19);
                set(handles.Input4_Highpass_cutoff, 'String', Input4_HP_Fc);
                
            end
            if savedHeadrFiltrs(21) ~= -1
                Input4_LP_Fc = savedHeadrFiltrs(21);
                set(handles.Input4_Lowpass_cutoff, 'String', Input4_LP_Fc);
                
            end
            if savedHeadrFiltrs(23) ~= -1
                Input4_Notch_enable = 1;
                set(handles.Notch60Input4, 'Value',1);
            end
        end
        clear statusHeaderFile
    end
    clear statusScoredFile
end

function autoscoredfile_open_Callback(hObject, eventdata, handles)
%% Select the Auto-Scored file that you want to correct:
global scoreFileCorrectionType current_dir
 
if exist(current_dir) == 0
    current_dir='C:\';
end
working_dir=pwd;

cd(current_dir);
[filename, pathname] = uigetfile('*.xls', 'Pick an Auto-Scored File');
if isequal(filename,0) || isequal(pathname,0)
    uiwait(errordlg('You need to select a file. Please press the button again',...
        'ERROR','modal'));
    cd(working_dir);
else
    current_dir = pathname;
    cd(working_dir);
    autoscoredfile= fullfile(pathname, filename);
    statusScoredFile = xlsfinfo(autoscoredfile);  % Checks to see if it exists
    if isempty(statusScoredFile)
        uiwait(errordlg('The manually scored file is not in Excel 1997-2003 format. Please try loading file again',...
        'ERROR','modal'));
    else
        set(handles.autoscoredfile,'string',filename);
        set(handles.autoscoredfile,'Tooltipstring',autoscoredfile);
        scoredFileType='Auto-Scored';  % Sets the label string to reflect the file type that will be corrected
        scoreFileCorrectionType = 1;  % Variable set to direct to loading an auto-scored file
        set(handles.ScoredFileType,'String', scoredFileType);  % Loads the label string to the 'ScoredFileType' field on the GUI
    end
    clear statusScoredFile
end
%**************************************************************************


%% ########################################################################
%                       FILTER SETTINGS FOR INPUTS
%--------------------------------------------------------------------------
function EMG_cutoff_Callback(hObject, eventdata, handles)

EMG_cutoff = str2double(get(hObject,'String'));   % returns contents of EMG_cutoff as a double
if isnan(EMG_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function EMG_Lowpass_cutoff_Callback(hObject, eventdata, handles)

EMG_Lowpass_cutoff = str2double(get(hObject,'String'));   % returns contents of EMG_Lowpass_cutoff as a double
if isnan(EMG_Lowpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if EMG_Lowpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function Notch60EMG_Callback(hObject, eventdata, handles)
% --- Executes on button press in Notch60EMG.
if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action

else
    % checkbox is not checked-take approriate action

end

function EEG_Highpass_cutoff_Callback(hObject, eventdata, handles)

EEG_Highpass_cutoff = str2double(get(hObject,'String'));   % returns contents of EEG_cutoff as a double
if isnan(EEG_Highpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if EEG_Highpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function EEG_cutoff_Callback(hObject, eventdata, handles)

EEG_cutoff = str2double(get(hObject,'String'));   % returns contents of EEG_cutoff as a double
if isnan(EEG_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function Notch60_Callback(hObject, eventdata, handles)
% --- Executes on button press in Notch60.
if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action
  
else
    % checkbox is not checked-take approriate action
    
end

function Input3_checkbox_Callback(hObject, eventdata, handles)

if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action

else
    % checkbox is not checked-take approriate action

end
function Input3_Highpass_cutoff_Callback(hObject, eventdata, handles)

Input3_Highpass_cutoff = str2double(get(hObject,'String'));   % returns contents of Input3_Highpass_cutoff as a double
if isnan(Input3_Highpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if Input3_Highpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function Input3_Lowpass_cutoff_Callback(hObject, eventdata, handles)

Input3_Lowpass_cutoff = str2double(get(hObject,'String'));   % returns contents of Input3_Lowpass_cutoff as a double
if isnan(Input3_Lowpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if Input3_Lowpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function Notch60Input3_Callback(hObject, eventdata, handles)
% --- Executes on button press in Notch60Input3.
if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action
  
else
    % checkbox is not checked-take approriate action

end

function Input4_checkbox_Callback(hObject, eventdata, handles)

if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action

else
    % checkbox is not checked-take approriate action

end
function Input4_Highpass_cutoff_Callback(hObject, eventdata, handles)

Input4_Highpass_cutoff = str2double(get(hObject,'String'));   % returns contents of Input4_Highpass_cutoff as a double
if isnan(Input4_Highpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if Input4_Highpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function Input4_Lowpass_cutoff_Callback(hObject, eventdata, handles)

Input4_Lowpass_cutoff = str2double(get(hObject,'String'));   % returns contents of Input4_Lowpass_cutoff as a double
if isnan(Input4_Lowpass_cutoff)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
if Input4_Lowpass_cutoff < 0
    set(hObject, 'String', 0);
    errordlg('Cutoff frequency must be a positive number','Error');
end
function Notch60Input4_Callback(hObject, eventdata, handles)
% --- Executes on button press in Notch60Input4.
if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action
    
else
    % checkbox is not checked-take approriate action

end
%**************************************************************************


%% ########################################################################
%               EEG (INPUT 2) FILTER SETTINGS FOR POWER/EPOCH
%--------------------------------------------------------------------------
function powerdensity_for_epoch_Callback(h, eventdata, handles, varargin)
powerdensity_for_epoch;

function Delta_lo_Callback(hObject, eventdata, handles)

Delta_lo = str2double(get(hObject,'String'));   % returns contents of Delta_lo as a double
if isnan(Delta_lo)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function Delta_hi_Callback(hObject, eventdata, handles)

Delta_hi = str2double(get(hObject,'String'));   % returns contents of EMG_Low as a double
if isnan(Delta_hi)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function Theta_lo_Callback(hObject, eventdata, handles)

Theta_lo = str2double(get(hObject,'String'));   % returns contents of Theta_lo as a double
if isnan(Theta_lo)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function Theta_hi_Callback(hObject, eventdata, handles)

Theta_hi = str2double(get(hObject,'String'));   % returns contents of Theta_hi as a double
if isnan(Theta_hi)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function Sigma_lo_Callback(hObject, eventdata, handles)

Sigma_lo = str2double(get(hObject,'String'));   % returns contents of Sigma_lo as a double
if isnan(Sigma_lo)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function Sigma_hi_Callback(hObject, eventdata, handles)

Sigma_hi = str2double(get(hObject,'String'));   % returns contents of Sigma_hi as a double
if isnan(Sigma_hi)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

function Beta_lo_Callback(hObject, eventdata, handles)

Beta_lo = str2double(get(hObject,'String'));   % returns contents of Beta_lo as a double
if isnan(Beta_lo)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
function Beta_hi_Callback(hObject, eventdata, handles)

Beta_hi = str2double(get(hObject,'String'));   % returns contents of Beta_hi as a double
if isnan(Beta_hi)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

% --- Executes on button press in powerColorMap.
function powerColorMap_Callback(hObject, eventdata, handles)
global EEG_SAMPLES Fs EEG_Fc
PowerColorMapGUI
%freqVersusTimePowerMap
%**************************************************************************


%% ########################################################################
%                       EPOCH NAVIGATION FUNCTIONS
%--------------------------------------------------------------------------
function Nextframe_Callback(h, eventdata, handles, varargin) %#ok<*DEFNU>
%% This section of code is executed when the 'Next Epoch' button is clicked.
global EPOCHSIZE EMG_TIMESTAMPS EPOCHSIZEOF10sec  EPOCHstate moveRight...
    EPOCH_StartPoint INDEX Sleepstates EPOCHnum LO_INDEX BoundIndex ISRECORDED ...
    TRACKING_INDEX  SAVED_index SLIDERVALUE Statecolors moveLeft EPOCHtime

if(length(EMG_TIMESTAMPS)-(EPOCH_StartPoint+EPOCHSIZE) <= 0)
    uiwait(errordlg('End of file reached.Scroll back or CLOSE the program', 'ERROR','modal'));
else
    handles=guihandles(SleepScorer_2018a);
    set(handles.emg_edit,'String','');
    set(handles.delta_edit,'String','');
    set(handles.theta_edit,'String','');
    set(handles.sigma_edit,'String','');
    set(handles.sigmatheta,'String','');
    set(handles.deltatheta,'String','');
    set(handles.beta_edit,'String','');
    EPOCHtime(INDEX) = EMG_TIMESTAMPS(EPOCH_StartPoint); %Added this to record epoch time stamps for unscored epochs.
    INDEX=INDEX+ round(EPOCHSIZE/EPOCHSIZEOF10sec);
    EPOCH_StartPoint =EPOCH_StartPoint + EPOCHSIZE;
    
    plot_epochdata_on_axes_in_GUI_08282018;
    SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
    set(handles.slider1, 'Value', SLIDERVALUE); 
    if ISRECORDED == 1 % If looking at the saved scored data
        if BoundIndex ~=1
            if isequal(SAVED_index(1,1), 1)
                ind=find(SAVED_index==INDEX);
            else
                ind=find((SAVED_index - LO_INDEX+1)==INDEX);
            end
%             ind=find((SAVED_index - LO_INDEX+1)==INDEX);
%                 if isempty(ind)==1
%                     ind=find(SAVED_index==INDEX);  % Changed to this in an attempt to fix the indexing.
%                 end
        else
            ind=find(SAVED_index==INDEX);
        end
        if isempty(ind)==1
            
            statenum(EPOCHstate(TRACKING_INDEX,:))
            set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        else
            statenum(EPOCHstate(ind,:))
            set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
            TRACKING_INDEX=ind;
        end
    else
        if (INDEX>length(EPOCHnum)) || (EPOCHnum(INDEX)==0)
            st='NOT SCORED';
            set(handles.scoredstate,'String',st,...
                'backgroundcolor',Statecolors(7,:));
            
        else
            set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        end
        if (INDEX <= length(EPOCHnum)) 
            if (EPOCHnum(INDEX)==0)||(EPOCHnum(INDEX)==7)
                if isequal(INDEX, 1)
                    TRACKING_INDEX = 2;
                else
                    TRACKING_INDEX = 1 + find(((EPOCHnum(1:INDEX-1) ~= 0) & (EPOCHnum(1:INDEX-1) ~= 7)),1,'last');
                    if isempty(TRACKING_INDEX)
                        TRACKING_INDEX = 1;
                    end
                end
            else
                TRACKING_INDEX = INDEX-1 + find(((EPOCHnum(INDEX:length(EPOCHnum))==0) | (EPOCHnum(INDEX:length(EPOCHnum))==7)),1);
                if isempty(TRACKING_INDEX)
                    TRACKING_INDEX = length(EPOCHnum) +1;
                end

            end
        else
            TRACKING_INDEX = 1 + find(((EPOCHnum(1:length(EPOCHnum)) ~= 0) & (EPOCHnum(1:length(EPOCHnum)) ~= 7)),1,'last');
            if isempty(TRACKING_INDEX)
                TRACKING_INDEX = 1;
            end
        end
    end
end
DisplayStateColors;
viewStates;
if get(handles.PSDvaluescheckbox,'Value') == 1
        powerdensity_for_epoch;
end
moveRight = 1; moveLeft = 1;
guidata(handles.sleepscorer,handles);

function Previousframe_Callback(h, eventdata, handles, varargin)
%% This section of code is executed when the 'Previous Epoch' button is clicked.
global EPOCHSIZE EMG_TIMESTAMPS EPOCHSIZEOF10sec  ISRECORDED TRACKING_INDEX ...
    EPOCHstate  EPOCH_StartPoint  INDEX Sleepstates  EPOCHnum  SAVED_index...
    LO_INDEX BoundIndex SLIDERVALUE Statecolors moveRight moveLeft
handles=guihandles(SleepScorer_2018a);
set(handles.emg_edit,'String','');
set(handles.delta_edit,'String','');
set(handles.theta_edit,'String','');
set(handles.sigma_edit,'String','');
set(handles.sigmatheta,'String','');
set(handles.deltatheta,'String','');
set(handles.beta_edit,'String','');
    
if EPOCH_StartPoint -EPOCHSIZE <=0
    EPOCH_StartPoint=1;
    if INDEX==0
        INDEX=1;
    end
    plot_epochdata_on_axes_in_GUI_08282018;
    SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
    set(handles.slider1, 'Value',SLIDERVALUE);
    uiwait(errordlg('Cannot plot the previous frame.This is the first frame',...
        'ERROR','modal'));
else
    INDEX=INDEX-round(EPOCHSIZE/EPOCHSIZEOF10sec);
    EPOCH_StartPoint =EPOCH_StartPoint-EPOCHSIZE;
    plot_epochdata_on_axes_in_GUI_08282018;
    SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
    set(handles.slider1, 'Value',SLIDERVALUE); 
end

if ISRECORDED ==1     % If looking at the saved scored data
    if BoundIndex ~=1
        if isequal(SAVED_index(1,1), 1)
            ind=find(SAVED_index==INDEX);
        else
            ind=find((SAVED_index - LO_INDEX+1)==INDEX);
        end
%             ind=find((SAVED_index - LO_INDEX+1)==INDEX);
%                 if isempty(ind)==1
%                     ind=find(SAVED_index==INDEX);  % Changed to this in an attempt to fix the indexing.
%                 end
                 
    else
        ind=find(SAVED_index==INDEX);
    end
    if isempty(ind)==0
        statenum(EPOCHstate(ind,:));
        set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
            'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        TRACKING_INDEX=ind;
    else
        if BoundIndex ~=1
            ind=find((SAVED_index - LO_INDEX+5)<=INDEX);
        else
            ind=find(SAVED_index<=INDEX);
        end
        TRACKING_INDEX=ind(end);
        statenum(EPOCHstate(TRACKING_INDEX,:));
        set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
            'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
    end
else
    
    if isempty(EPOCHnum)== 0
        if INDEX >length(EPOCHnum)|| EPOCHnum(INDEX)==0
            st='NOT SCORED';
            set(handles.scoredstate,'String',st,...
                'backgroundcolor',Statecolors(7,:));
        else
            set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        end
        if (INDEX <= length(EPOCHnum))
            if(EPOCHnum(INDEX)==0)||(EPOCHnum(INDEX)==7)
                if isequal(INDEX, 1)
                    TRACKING_INDEX = 2;
                else
                    TRACKING_INDEX = 1 + find(((EPOCHnum(1:INDEX-1) ~= 0) & (EPOCHnum(1:INDEX-1) ~= 7)),1,'last');
                    if isempty(TRACKING_INDEX)
                        TRACKING_INDEX = 1;
                    end
                end
            else
                TRACKING_INDEX = INDEX-1 + find(((EPOCHnum(INDEX:length(EPOCHnum))==0) | (EPOCHnum(INDEX:length(EPOCHnum))==7)),1);
                if isempty(TRACKING_INDEX)
                    TRACKING_INDEX = length(EPOCHnum) + 1;
                end
            end
        else
            TRACKING_INDEX = 1 + find(((EPOCHnum(1:length(EPOCHnum)) ~= 0) & (EPOCHnum(1:length(EPOCHnum)) ~= 7)),1,'last');
            if isempty(TRACKING_INDEX)
                TRACKING_INDEX = 1;
            end
        end
    else
        st='NOT SCORED';
        set(handles.scoredstate,'String', st,'backgroundcolor', Statecolors(7,:));  
    end
end

DisplayStateColors;
viewStates;
if get(handles.PSDvaluescheckbox,'Value') == 1
    powerdensity_for_epoch;
end
moveRight = 1;  moveLeft = 1;
guidata(handles.sleepscorer,handles);

function Moveleft_Callback(h, eventdata, handles, varargin) %#ok<*INUSD>
%% Activates when clicking on the left arrow of the slider
global EMG_TIMESTAMPS EPOCH_StartPoint EPOCH_shiftsize  SLIDERVALUE moveLeft

handles= guihandles(SleepScorer_2018a);
start_point = EPOCH_StartPoint - (EPOCH_shiftsize*moveLeft);
if EPOCH_StartPoint<=0
    EPOCH_StartPoint =1;
end
plot_epochdata_on_axes_in_GUI_08282018(num2str(start_point));
SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
set(handles.slider1, 'Value',SLIDERVALUE); 
moveLeft=moveLeft + 1;
guidata(handles.sleepscorer,handles);

function Moveright_Callback(h, eventdata, handles, varargin)
%% Activates when clicking on the right arrow of the slider
global EMG_TIMESTAMPS EPOCH_StartPoint EPOCH_shiftsize SLIDERVALUE moveRight

start_point = EPOCH_StartPoint + (EPOCH_shiftsize * moveRight);
plot_epochdata_on_axes_in_GUI_08282018(num2str(start_point));
SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
set(handles.slider1, 'Value',SLIDERVALUE); 
viewStates;
moveRight = moveRight + 1;
guidata(handles.sleepscorer,handles);

function slider1_Callback(h, eventdata, handles, varargin)
%% Activates when using the slider
global EMG_TIMESTAMPS SLIDERVALUE Statecolors EPOCHstate  EPOCHnum  SAVED_index EPOCHSIZEOF10sec...
    TRACKING_INDEX LO_INDEX BoundIndex EPOCH_StartPoint INDEX Sleepstates ISRECORDED moveLeft moveRight

X1=get(handles.slider1,'Value');
new_pt=ceil((length(EMG_TIMESTAMPS)*X1)/100);

if new_pt<=0 
% In case there is an error in generating the value of X1 and the value it 
% goes negative, then start from the first value itself.
    new_pt=1;
end
difference=abs(new_pt - EPOCH_StartPoint);
ind_shiftvalue = round(difference/EPOCHSIZEOF10sec);
if new_pt > EPOCH_StartPoint
    INDEX=INDEX + ind_shiftvalue;
    EPOCH_StartPoint = EPOCH_StartPoint + (ind_shiftvalue * EPOCHSIZEOF10sec);
else
    INDEX=INDEX - ind_shiftvalue;
    if INDEX <= 0
        INDEX = 1;
        EPOCHStartPoint = 1; 
    else
        EPOCH_StartPoint = EPOCH_StartPoint - (ind_shiftvalue * EPOCHSIZEOF10sec);
    end
end

if ISRECORDED ==1     % If u r looking at the saved scored data
    if BoundIndex ~=1
        if isequal(SAVED_index(1,1), 1)
            ind=find(SAVED_index==INDEX);
        else
            ind=find((SAVED_index - LO_INDEX+5)==INDEX);
        end
    else
        ind=find(SAVED_index==INDEX);
    end
    if isempty(ind)==0
        statenum(EPOCHstate(ind,:));
        set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
            'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        TRACKING_INDEX=ind;
    else
        if BoundIndex ~=1
            ind=find((SAVED_index - LO_INDEX+5)<=INDEX);
        else
            ind=find(SAVED_index<=INDEX);
        end
        TRACKING_INDEX=ind(end);
        statenum(EPOCHstate(TRACKING_INDEX,:));
        set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
            'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
    end
else
    if isempty(EPOCHnum)== 0
        if (INDEX>length(EPOCHnum)) || (EPOCHnum(INDEX)==0)
            st='NOT SCORED';
            set(handles.scoredstate,'String',st, 'backgroundcolor',Statecolors(7,:));
        else
            set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
        end
        if (INDEX <= length(EPOCHnum)) 
            if (EPOCHnum(INDEX)==0)||(EPOCHnum(INDEX)==7)
                if isequal(INDEX, 1)
                    TRACKING_INDEX = 2;
                else
                    TRACKING_INDEX = 1 + find(((EPOCHnum(1:INDEX-1) ~= 0) & (EPOCHnum(1:INDEX-1) ~= 7)),1,'last');
                    if isempty(TRACKING_INDEX)
                        TRACKING_INDEX = 1;  % may need to change this to = INDEX + 1
                    end
                end
            else
                TRACKING_INDEX = INDEX-1 + find(((EPOCHnum(INDEX:length(EPOCHnum))==0) | (EPOCHnum(INDEX:length(EPOCHnum))==7)),1);
                if isempty(TRACKING_INDEX)
                    TRACKING_INDEX = length(EPOCHnum) +1;
                end

            end
        else
            TRACKING_INDEX = 1 + find(((EPOCHnum(1:length(EPOCHnum)) ~= 0) & (EPOCHnum(1:length(EPOCHnum)) ~= 7)),1,'last');
            if isempty(TRACKING_INDEX)
                TRACKING_INDEX = 1;  % may need to change this to = INDEX + 1
            end
        end
%         if (INDEX <= length(EPOCHnum)) && (EPOCHnum(INDEX)==0)||(EPOCHnum(INDEX)==7)
%             if isequal(INDEX, 1)
%                 TRACKING_INDEX = 1;
%             else
%                 TRACKING_INDEX = find(((EPOCHnum(1:INDEX-1) ~= 0) & (EPOCHnum(1:INDEX-1) ~= 7)),1,'last');
%             end
% 
%         end
    else
        st='NOT SCORED';
        set(handles.scoredstate,'String', st,'backgroundcolor', Statecolors(7,:));
        TRACKING_INDEX = 1;
    end
end
plot_epochdata_on_axes_in_GUI_08282018;
SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
set(handles.slider1, 'Value',SLIDERVALUE);
DisplayStateColors;
viewStates;
if get(handles.PSDvaluescheckbox,'Value') == 1
        powerdensity_for_epoch;
end
set(handles.emg_edit,'String','');
set(handles.delta_edit,'String','');
set(handles.theta_edit,'String','');
set(handles.sigma_edit,'String','');
set(handles.sigmatheta,'String','');
set(handles.deltatheta,'String','');
set(handles.beta_edit,'String','');
moveRight = 1; moveLeft = 1;
guidata(handles.sleepscorer,handles);

function epochSizeMenu_Callback(hObject, eventdata, handles)
%% Changes the epoch size to be scored or viewed
% hObject    handle to epochSizeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epochSizeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epochSizeMenu
global EPOCHSIZE EPOCH_shiftsize EPOCHSIZEOF10sec epochVal
epochVal = get(handles.epochSizeMenu,'Value');

switch epochVal
    case 1.0
        % User selected 2 sec epoch
        EPOCHSIZE = round(EPOCHSIZEOF10sec * 0.2);
        EPOCH_shiftsize = 8;
        plot_epochdata_on_axes_in_GUI_08282018;
        
    case 2.0
        % User selected 10 sec epoch
        EPOCHSIZE = EPOCHSIZEOF10sec;
        EPOCH_shiftsize = 40;
        plot_epochdata_on_axes_in_GUI_08282018;
 
    case 3.0
        % User selected 30 sec epoch
        EPOCHSIZE = EPOCHSIZEOF10sec * 3;
        EPOCH_shiftsize = 120;
        plot_epochdata_on_axes_in_GUI_08282018;
        
    case 4.0 
        % User selected 1 min epoch
        EPOCHSIZE = EPOCHSIZEOF10sec * 6;
        EPOCH_shiftsize = 240;
        plot_epochdata_on_axes_in_GUI_08282018;
        
    case 5.0
        % User selected 2 min epoch
        EPOCHSIZE = EPOCHSIZEOF10sec * 12;
        EPOCH_shiftsize = 480;
        plot_epochdata_on_axes_in_GUI_08282018;
        
    case 6.0
        % User selected 4 min epoch
        EPOCHSIZE = EPOCHSIZEOF10sec * 24;
        EPOCH_shiftsize = 960;
        plot_epochdata_on_axes_in_GUI_08282018;
end
handles.moveright = 1;  handles.moveleft = 1;
guidata(handles.sleepscorer,handles);
%**************************************************************************


%% ########################################################################
%                       SCORING EPOCH FUNCTIONS
%--------------------------------------------------------------------------
function Activewaking_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 1;
stateLetterCode = 'AW';
stateProcessing;

function Quietwaking_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 4;
stateLetterCode = 'QW';
stateProcessing;

function Quietsleep_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 2;
stateLetterCode = 'QS';
stateProcessing;

function transREM_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode
% The EPOCHnum of TR has been changed from 7 to 6
stateNumberCode = 6;
stateLetterCode = 'TR';
stateProcessing;

function REM_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 3;
stateLetterCode = 'RE';
stateProcessing;

function Intermediate_Waking_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 8;
stateLetterCode = 'IW';
stateProcessing;

function Unhooked_Callback(h, eventdata, handles, varargin)

global stateNumberCode stateLetterCode

stateNumberCode = 5;
stateLetterCode = 'UH';
stateProcessing;

function clearstate_Callback(hObject, eventdata, handles)

global stateNumberCode stateLetterCode
stateNumberCode = 7;
stateLetterCode = 'NS';
stateProcessing;

function autofill_Callback(hObject, eventdata, handles)

global EPOCHSIZE EMG_TIMESTAMPS EPOCHtime TRACKING_INDEX EPOCHstate EPOCH_StartPoint INDEX EPOCHnum 
global EPOCHSIZEOF10sec  moveRight Sleepstates LO_INDEX BoundIndex ISRECORDED ...
        SAVED_index SLIDERVALUE Statecolors moveLeft epochScoringSize epochVal TRAINEDEPOCH_INDEX

if isequal(epochScoringSize, epochVal)
    handles=guihandles(SleepScorer_2018a);
    if (INDEX - TRACKING_INDEX >= 0) && (TRACKING_INDEX > 1)
        track_state = EPOCHstate(TRACKING_INDEX-1,:);
        d = TRACKING_INDEX:INDEX;
        track_point = EPOCH_StartPoint - (INDEX - TRACKING_INDEX) * EPOCHSIZE;
        t = track_point:EPOCHSIZE:EPOCH_StartPoint;
        if length(t) > length(d)
            t=t(1:end-1);
        end
        EPOCHstate(d,1) = track_state(1,1);
        EPOCHstate(d,2) = track_state(1,2);
        track_time = double(EMG_TIMESTAMPS(t));
        EPOCHtime(TRACKING_INDEX:INDEX) = single(track_time(1:end));
        EPOCHnum(TRACKING_INDEX:INDEX) = EPOCHnum(TRACKING_INDEX-1);
        for i = TRACKING_INDEX:INDEX
            if ~any(TRAINEDEPOCH_INDEX == i) % add index to indoffset only if it was not done b4 
                TRAINEDEPOCH_INDEX=[TRAINEDEPOCH_INDEX; i]; %#ok<AGROW>
            end
        end
        if(length(EMG_TIMESTAMPS)-(EPOCH_StartPoint+EPOCHSIZE) <= 0)
            uiwait(errordlg('End of file reached.Scroll back or CLOSE the program', 'ERROR','modal'));
        else
            set(handles.emg_edit,'String','');
            set(handles.delta_edit,'String','');
            set(handles.theta_edit,'String','');
            set(handles.sigma_edit,'String','');
            set(handles.sigmatheta,'String','');
            set(handles.deltatheta,'String','');
            set(handles.beta_edit,'String','');

%             INDEX = INDEX + round(EPOCHSIZE/EPOCHSIZEOF10sec);
%             EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZE;
            nIndexSteps = round(EPOCHSIZE/EPOCHSIZEOF10sec);
            if isequal(nIndexSteps, 1)
                INDEX = INDEX + 1;
                EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
            else
                for i = 2:nIndexSteps
                    INDEX = INDEX + 1;
                    EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
                    EPOCHtime(INDEX) = EMG_TIMESTAMPS(EPOCH_StartPoint);
                    EPOCHstate(INDEX,:) = EPOCHstate(INDEX-1,:);
                    EPOCHnum(INDEX) = EPOCHnum(INDEX-1);
                    if ~any(TRAINEDEPOCH_INDEX==INDEX) % add index to indoffset only if it was not done b4 
                        TRAINEDEPOCH_INDEX=[TRAINEDEPOCH_INDEX;INDEX]; %#ok<AGROW>
                    end
                end
                INDEX = INDEX + 1;
                EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
            end
            plot_epochdata_on_axes_in_GUI_08282018;
            SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
            set(handles.slider1, 'Value', SLIDERVALUE); 
            if ISRECORDED == 1 % If looking at the saved scored data
                if BoundIndex ~=1
                    ind=find((SAVED_index - LO_INDEX+5)==INDEX);
                else
                    ind=find(SAVED_index==INDEX);
                end
                if isempty(ind)==1

                    statenum(EPOCHstate(TRACKING_INDEX,:))
                    set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                        'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
                else
                    statenum(EPOCHstate(ind,:))
                    set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                        'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
                    TRACKING_INDEX=ind;
                end
            else
                if (INDEX>length(EPOCHnum)) || (EPOCHnum(INDEX)==0)
                    st='NOT SCORED';
                    set(handles.scoredstate,'String',st,...
                        'backgroundcolor',Statecolors(7,:));
                else
                    set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
                        'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));
                end
                if (INDEX <= length(EPOCHnum)) 
                    if (EPOCHnum(INDEX)==0)||(EPOCHnum(INDEX)==7)
                        TRACKING_INDEX = INDEX;
                    else
                        TRACKING_INDEX = INDEX-1 + find(((EPOCHnum(INDEX:length(EPOCHnum))==0) | (EPOCHnum(INDEX:length(EPOCHnum))==7)),1);
                        if isempty(TRACKING_INDEX)
                            TRACKING_INDEX = length(EPOCHnum) +1;
                        end

                    end
                else
                    TRACKING_INDEX = INDEX;
                end
            end
        end
        DisplayStateColors;
        viewStates;
        if get(handles.PSDvaluescheckbox,'Value') == 1
                powerdensity_for_epoch;
        end
        moveRight = 1; moveLeft = 1;
        guidata(handles.sleepscorer,handles);
    else
        uiwait(errordlg('Cannot use the AutoFill.This is just the next frame',...
            'ERROR','modal'));
    end
else
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
    errordlg(['Epoch setting for scoring is locked to' epochString...
        '.  Please change the epoch size in the drop-down menu to continue scoring.'],'Error');

end

% --- Executes on button press in keyScoreCheckbox.
function keyScoreCheckbox_Callback(hObject, eventdata, handles)
enableKeyScoring = get(handles.keyScoreCheckbox, 'Value');
if isequal(enableKeyScoring, 1)
    set(handles.sleepscorer,'KeyPressFcn',@keyScoring);
else
    set(handles.sleepscorer,'KeyPressFcn','');
end

function keyScoring(src,event)
%src is the gui figure
%evnt is the keypress information

%this line brings the handles structures into the local workspace
%now we can use handles.cats in this subfunction!
handles = guidata(src);
 
%get the value of the key that was pressed
%evnt.Key is the lowercase symbol on the key that was pressed
%so even if you tried "shift + 8", evnt.Key will return 8
k=str2num(event.Character); %#ok<ST2NM>
 
% if k > 0 & k < 8 & isequal(enableKeyScoring, 1)
if isempty(k)
    if isequal(event.Key, 'rightarrow')
        Nextframe_Callback
    elseif isequal(event.Key, 'leftarrow')
        Previousframe_Callback
    end    
else
    switch k
        case 1  %Active Wake
            Activewaking_Callback 
        case 4  %Quiet Wake
            Quietwaking_Callback
        case 2  %Quiet Sleep
            Quietsleep_Callback 
        case 6  %Transition to REM
            transREM_Callback
        case 3  %REM Sleep
            REM_Callback
        case 5  %Unhooked
            Unhooked_Callback
        case 7  %Clear the state of the current epoch
            clearstate_Callback
        case 8  %Fill in current and contiguous prior epochs with state of last scored epoch.
            autofill_Callback
        otherwise
    end
    %updates the handles structures!
    guidata(src, handles);
end
%**************************************************************************


%% ########################################################################
%                       LOAD DATA MENU SELECTIONS
%--------------------------------------------------------------------------
function loadDataForTraining_Callback(hObject, eventdata, handles)

global EPOCHSIZE EMG_TIMESTAMPS EPOCHSIZEOF10sec ISRECORDED EPOCH_shiftsize FileFlag %...
global LBounds UBounds BoundIndex %LO_INDEX P_emg P_delta P_theta P_sigma Statecolors 
global exactLowIndx exactHiIndx epochVal epochScoringSize current_dir
global excelRowIdx newname
cwd = pwd;
cd(tempdir);
cd(cwd);

initialVariableValues;

%% *********** Timestamps extraction *********
filename=get(handles.tstampsfile,'TooltipString');
[path,name,ext]=fileparts(filename);
try
    [tbounds]=xlsread(filename);
catch %#ok<*CTCH>
    uiwait(errordlg('Check if the file is saved in Microsoft Excel format.','ERROR','modal'));
end


switch FileFlag
    case 0
        uiwait(errordlg('Please select a FILE FORMAT first','ERROR','modal'));    
    case 1    % Neuralynx
        terminate = 0;
end

while terminate == 0
    LBounds=tbounds(1:end,1);      % Lowerbounds array
    UBounds=tbounds(1:end,2);      % Upperbounds array         
    exactLowIndx = tbounds(1:end,3);
    exactHiIndx = tbounds(1:end,4);
    BoundIndex=1;
    sectionword=strcat('Section ',num2str( BoundIndex));
    set(handles.sectiontext,'string',sectionword);
    
    [uppertimestamp,lowertimestamp] = extract_samples_timestamps_from_datafile;
    fprintf('filextraction now \n');
    ISRECORDED=0;
    % Get the 10 sec EPOCHSIZE to work without user selecting the default.
    index=find(double(EMG_TIMESTAMPS(1))+9.99 < EMG_TIMESTAMPS...
        & EMG_TIMESTAMPS < double(EMG_TIMESTAMPS(1))+10.001);
    difference=double(EMG_TIMESTAMPS(index(1):index(end)))-(double(EMG_TIMESTAMPS(1))+10);
    [minimum,ind]=min(abs(difference));
    try
        EPOCHSIZE=index(ind);
    catch
        fprintf( 'There is an error in calculating the EPOCHSIZE of 10sec in loadData_for_training function \n' );
    end
    EPOCHSIZEOF10sec=EPOCHSIZE;
    EPOCH_shiftsize=40;
    set(handles.epochSizeMenu,'Value',2); % Set the epochSizeMenu to 10sec epoch
    epochVal = 2;
    epochScoringSize = 0;
    plot_epochdata_on_axes_in_GUI_08282018;
    
    % Setting the slider arrow and trough step EPOCHSIZEOF10sec
    slider_step(1)=0.01188;
    slider_step(2)=0.09509;
    set(handles.slider1,'sliderstep',slider_step);
    working_dir=pwd;
    cd(current_dir);
    if isempty(get(handles.trainingfile,'string')) == 1
        [filename,pathname] = uiputfile('TR_file.xls','Save training file as:');
    else
        file=get(handles.trainingfile,'string');
        [filename,pathname] = uiputfile(file,'Save training file in correct folder:');
    end
    set(handles.trainingfile,'string',filename);
    cd(working_dir);
    
    newname=strcat(pathname,filename);
    sheetName = 'Sheet1';
    columnHeaders = {'Index', 'Timestamp ', 'State'};
    xlswrite(newname ,columnHeaders, sheetName, 'A1');
    excelRowIdx = 2;

    % Write the filter info to a real .XLS file:
    writeHeaderFilterFile(newname);
    
    set(handles.trainingfile,'TooltipString',newname);
    set(handles.loadNextSection_newFile,'Visible','on');
    DisplayStateColors;
    terminate = 1;
    % Initialize the section to lock in epoch size of 10 seconds:
    clearstate_Callback
    Previousframe_Callback
end

function loadDataForCorrection_Callback(hObject, eventdata, handles)

global EPOCHSIZE EMG_TIMESTAMPS EPOCHstate EPOCHSIZEOF10sec EPOCHtime ISRECORDED...
    EPOCH_shiftsize INDEX Sleepstates EPOCHnum SAVED_index newname BoundIndex...
    LBounds UBounds exactLowIndx exactHiIndx exactLowerTS exactUpperTS tbounds FileFlag
global excelRowIdx

cwd = pwd;
cd(tempdir);

cd(cwd);

initialVariableValues;

switch FileFlag
    case 0
        uiwait(errordlg('Please select a FILE FORMAT first','ERROR','modal'));    
    case 1    % Neuralynx
        terminate = 0;
    
end

while terminate == 0
    BoundIndex=1;
    sectionword=strcat('Section ',num2str(BoundIndex));
    set(handles.sectiontext,'string',sectionword);
    
    % *********** Timestamps extraction *********
    filename=get(handles.tstampsfile,'TooltipString');
    [path,name,ext]=fileparts(filename);  
    [tbounds]=xlsread(filename);

    LBounds=tbounds(1:end,1);       % Lowerbounds array
    UBounds=tbounds(1:end,2);       % Upperbounds array    
    exactLowIndx = tbounds(1:end,3);
    exactHiIndx = tbounds(1:end,4);
    % Extract data from the datafile for the given timestamps
    [uppertimestamp,lowertimestamp]=extract_samples_timestamps_from_datafile;
    ISRECORDED=1;
    
    set(handles.loadNextSection_newFile,'Visible','off');
    set(handles.loadNextSection_scoredFile,'Visible','on');
    %set(handles.sectionmenu,'Visible','on');
    
    warning off MATLAB:mir_warning_variable_used_as_function
    currentdate=date;
    prompt={'Enter your name:','Enter the date you are correcting the file on:'};
    def={'Name',currentdate};
    dlgTitle='Input for file management';
    lineNo=1;
    answer=inputdlg(prompt,dlgTitle,lineNo,def);
    name=char(answer(1,:));

    
    filename=get(handles.autoscoredfile,'TooltipString');
    [path,name1,ext]=fileparts(filename);
    newScoredFile = strcat('C_',name1,'_',name(1),currentdate,ext);
    set(handles.trainingfile,'string',newScoredFile);
    newname = fullfile(path,newScoredFile);
    set(handles.trainingfile,'Tooltipstring',newname);
    
    sheetName = 'Sheet1';
    columnHeaders = {'Index', 'Timestamp ', 'State'};
    xlswrite(newname ,columnHeaders, sheetName, 'A1');
    excelRowIdx = 2;
    
    % Write the filter info to a real .XLS file:
    writeHeaderFilterFile(newname);    
    
    exactLowerTS = tbounds(BoundIndex,5);
    exactUpperTS = tbounds(BoundIndex,6);
    %  Reading in the states,tstamps & Index from the SAVED excel file 
    data_tstamp_read(exactLowerTS,exactUpperTS);
    %  Get the 10 sec EPOCHSIZE to work without user selecting the default.
    index=find(double(EMG_TIMESTAMPS(1))+9.99 < EMG_TIMESTAMPS...
        & EMG_TIMESTAMPS < double(EMG_TIMESTAMPS(1))+10.001);
    difference=double(EMG_TIMESTAMPS(index(1):index(end)))-(double(EMG_TIMESTAMPS(1))+10);
    [minimum,ind]=min(abs(difference));
    try
        EPOCHSIZE=index(ind);
    catch %#ok<CTCH>
        fprintf( 'There is an error in calculating the EPOCHSIZE of 10sec in loadData_for_correction function \n' );
    end
    EPOCHSIZEOF10sec=EPOCHSIZE;
    EPOCH_shiftsize=35;
    set(handles.epochSizeMenu,'value',2); % Set the epochSizeMenu to 10sec epoch
    
    numEpochsInSectionOfEMG = floor(size(EMG_TIMESTAMPS,1)/EPOCHSIZEOF10sec);
    numEpochsInSectionOfScoredFile = size(EPOCHtime,1);
    if numEpochsInSectionOfScoredFile < numEpochsInSectionOfEMG
        EPOCHnum = EPOCHnum(1:end-1,:);
        EPOCHstate = EPOCHstate(1:end-1,:);
        EPOCHtime = EPOCHtime(1:end-1,:);
        SAVED_index = SAVED_index(1:end-1,:);
        for i=numEpochsInSectionOfScoredFile:numEpochsInSectionOfEMG
            EPOCHnum = [EPOCHnum;7];
            EPOCHstate = [EPOCHstate; 'NS'];
            tempEpochTimePointIndex = 1+ ((i-1)*EPOCHSIZEOF10sec);
            EPOCHtime= [EPOCHtime;EMG_TIMESTAMPS(tempEpochTimePointIndex)];
            SAVED_index = [SAVED_index; i]; % Adjusts the vector to include the added indeterminant states
        end
    end
    plot_epochdata_on_axes_in_GUI_08282018;
    statenum(EPOCHstate(INDEX,:));
    set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:));
    DisplayStateColors;
    terminate = 1;
end
initSection(EPOCHnum(INDEX))
Previousframe_Callback
%**************************************************************************
        

%% ########################################################################
%                      CODE FOR INITIALIZING VARIABLES
%--------------------------------------------------------------------------

function Set_pushbutton_Callback(hObject, eventdata, handles)
% --- Executes on button press in Reset_pushbutton.
deltaHighPass = 0.4; set(handles.Delta_lo, 'String', deltaHighPass);
deltaLowPass = 4; set(handles.Delta_hi, 'String', deltaLowPass);
thetaHighPass = 5; set(handles.Theta_lo, 'String', thetaHighPass);
thetaLowPass = 9; set(handles.Theta_hi, 'String', thetaLowPass);
sigmaaHighPass = 10; set(handles.Sigma_lo, 'String', sigmaaHighPass);
sigmaLowPass = 14; set(handles.Sigma_hi, 'String', sigmaLowPass);
betaHighPass = 15; set(handles.Beta_lo, 'String', betaHighPass);
betaLowPass = 20; set(handles.Beta_hi, 'String', B_hi);

set(handles.EEG_cutoff, 'String', 30);
set(handles.EEG_Highpass_cutoff, 'String', '');
set(handles.Notch60, 'Value', 0);

set(handles.EMG_cutoff, 'String', 30);
set(handles.Notch60EMG, 'Value', 1);
set(handles.EMG_LP_checkbox, 'String', '');

set(handles.Input3_checkbox, 'Value', 0);
set(handles.Input3_Highpass_cutoff, 'String', '');
set(handles.Input3_Lowpass_cutoff, 'String', '');
set(handles.Notch60Input3, 'Value', 0);

set(handles.Input4_checkbox, 'Value', 0);
set(handles.Input4_Highpass_cutoff, 'String', '');
set(handles.Input4_Lowpass_cutoff, 'String', '');
set(handles.Notch60Input4, 'Value', 0);

function initialVariableValues
global FileFlag D_lo D_hi T_lo T_hi S_lo S_hi B_lo B_hi
global EEG_Fc EEG_HP_Fc EMG_Fc EMG_LP_Fc EEG_Notch_enable EMG_Notch_enable
global Input3_enable Input3_HP_Fc Input3_Notch_enable Input3_LP_Fc
global Input4_enable Input4_HP_Fc Input4_Notch_enable Input4_LP_Fc
global y1min y1max y2min y2max y3min y3max y4min y4max
handles=guihandles(SleepScorer_2018a);
FileFlag = 1;

D_lo = str2double(get(handles.Delta_lo, 'String'));
D_hi = str2double(get(handles.Delta_hi, 'String'));
T_lo = str2double(get(handles.Theta_lo, 'String'));
T_hi = str2double(get(handles.Theta_hi, 'String'));
S_lo = str2double(get(handles.Sigma_lo, 'String'));
S_hi = str2double(get(handles.Sigma_hi, 'String'));
B_lo = str2double(get(handles.Beta_lo, 'String'));
B_hi = str2double(get(handles.Beta_hi, 'String'));

EEG_Fc = str2double(get(handles.EEG_cutoff, 'String'));
if isnan(EEG_Fc)
    EEG_Fc = [];
end
EEG_HP_Fc = str2double(get(handles.EEG_Highpass_cutoff, 'String'));
if isnan(EEG_HP_Fc)
    EEG_HP_Fc = [];
end
EEG_Notch_enable= get(handles.Notch60, 'Value');

EMG_Fc = str2double(get(handles.EMG_cutoff, 'String'));
if isnan(EMG_Fc)
    EMG_Fc = [];
end
EMG_LP_Fc = str2double(get(handles.EMG_Lowpass_cutoff, 'String'));
if isnan(EMG_LP_Fc)
    EMG_LP_Fc = [];
end
EMG_Notch_enable = get(handles.Notch60EMG, 'Value');


Input3_enable= get(handles.Input3_checkbox, 'Value');
Input3_HP_Fc= str2double(get(handles.Input3_Highpass_cutoff, 'String'));
if isnan(Input3_HP_Fc)
    Input3_HP_Fc = [];
end
Input3_LP_Fc= str2double(get(handles.Input3_Lowpass_cutoff, 'String'));
if isnan(Input3_LP_Fc)
    Input3_LP_Fc = [];
end
Input3_Notch_enable= get(handles.Notch60Input3, 'Value');

Input4_enable= get(handles.Input4_checkbox, 'Value');
Input4_HP_Fc= str2double(get(handles.Input4_Highpass_cutoff, 'String'));
if isnan(Input4_HP_Fc)
    Input4_HP_Fc = [];
end
Input4_LP_Fc= str2double(get(handles.Input4_Lowpass_cutoff, 'String'));
if isnan(Input4_LP_Fc)
    Input4_LP_Fc = [];
end
Input4_Notch_enable= get(handles.Notch60Input4, 'Value');
guidata(handles.sleepscorer,handles);

y1min = str2double(get(handles.ymin1, 'String'));
if isnan(y1min)
    y1min = [];
end

y1max = str2double(get(handles.ymax1, 'String'));
if isnan(y1max)
    y1max = [];
end

y2min = str2double(get(handles.ymin2, 'String'));
if isnan(y2min)
    y2min = [];
end

y2max = str2double(get(handles.ymax2, 'String'));
if isnan(y2max)
    y2max = [];
end

y3min = str2double(get(handles.ymin3, 'String'));
if isnan(y3min)
    y3min = [];
end

y3max = str2double(get(handles.ymax3, 'String'));
if isnan(y3max)
    y3max = [];
end

y4min = str2double(get(handles.ymin4, 'String'));
if isnan(y4min)
    y4min = [];
end

y4max = str2double(get(handles.ymax4, 'String'));
if isnan(y4max)
    y4max = [];
end
%**************************************************************************


%% ########################################################################
%                       LOAD NEXT SECTION BUTTONS
%--------------------------------------------------------------------------
function loadNextSection_newFile_Callback(h, eventdata, handles, varargin)

global EMG_TIMESTAMPS EPOCHtime EPOCH_StartPoint EPOCHnum...
     BoundIndex LBounds TRAINEDEPOCH_INDEX SLIDERVALUE newname excelRowIdx

if isempty(TRAINEDEPOCH_INDEX) && isempty(EPOCHtime) 
    uiwait(errordlg('There was no state scored for this section and hence no data shall be appended to file'...
        ,'ERROR','modal'));
else    
    TRAINEDEPOCH_INDEX=sort(TRAINEDEPOCH_INDEX);  % In case the states were not scored in order
    
    numEpochs = length(EPOCHnum);
    for i = 1:numEpochs
        if isequal(EPOCHnum(i), 0)
            EPOCHnum(i) = 7;  % Re-labels to "not-scored"
        end
        if isequal(EPOCHtime(i), 1)
            EPOCHtime(i) = EPOCHtime(i-1) + 10; 
        end

    end     

    sheetName = 'Sheet1';
    targetCell = ['A' num2str(excelRowIdx)];
    xlswrite(newname ,[(1:numEpochs)', EPOCHtime, EPOCHnum], sheetName, targetCell);
    excelRowIdx = excelRowIdx + numEpochs;
    
end

if BoundIndex + 1 > length(LBounds)
    uiwait(errordlg('End of the file. Scored data is saved.'...
        ,'ERROR','modal'));
    set(handles.loadNextSection_scoredFile,'visible','off');
else
       
    clear global EPOCHstate 
    clear global EPOCHtime 
    clear global EPOCHnum 
    clear global TRAINEDEPOCH_INDEX
    BoundIndex=BoundIndex+1;
    sectionword=strcat('Section ',num2str( BoundIndex));
    set(handles.sectiontext,'string',sectionword);
    % If the entire file has been plotted, then just save the training file and
    % move it to the appropriate file folder or else, continue loading the file
    % records
      
    %[uppertimestamp,lowertimestamp]=extract_samples_timestamps_from_datafile;
    % Oct-7-2009: Removed uppertimestamp & lowertimestamp outputs from
    % 'extract_samples..." function. They don't appear to be used anywhere.
    extract_samples_timestamps_from_datafile;
    plot_epochdata_on_axes_in_GUI_08282018;
    %   ^^^^^^^^^ Setting the slider arrow and trough step EPOCHSIZEOF10sec ^^^^^^ 
    slider_step(1)=0.01188;
    slider_step(2)=0.09509;
    set(handles.slider1,'sliderstep',slider_step);
    SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
    set(handles.slider1, 'Value',SLIDERVALUE);
    if get(handles.PSDvaluescheckbox,'Value') == 1
        powerdensity_for_epoch;
    end
end
DisplayStateColors;

% Initialize the section to lock in epoch size of 10 seconds:
clearstate_Callback
Previousframe_Callback


function loadNextSection_scoredFile_Callback(hObject, eventdata, handles)

global EPOCHSIZE EMG_TIMESTAMPS tbounds EPOCHSIZEOF10sec EPOCHtime ISRECORDED...  
    EPOCHstate EPOCH_StartPoint  INDEX Sleepstates EPOCHnum exitAlgorithm...
    SAVED_index UBounds BoundIndex newname SLIDERVALUE exactLowerTS exactUpperTS
global excelRowIdx

sheetName = 'Sheet1';
targetCell = ['A' num2str(excelRowIdx)];
xlswrite(newname ,[SAVED_index, EPOCHtime, EPOCHnum], sheetName, targetCell);
% targetCell = ['C' num2str(excelRowIdx)];
% xlswrite(newname ,cellstr(EPOCHstate), sheetName, targetCell);
excelRowIdx = excelRowIdx + length(SAVED_index);

if BoundIndex <=length(UBounds)
    BoundIndex = BoundIndex+1;
    sectionword = strcat('Section ',num2str( BoundIndex));
    set(handles.sectiontext,'string',sectionword);
    %See 1st instance of function for information
    extract_samples_timestamps_from_datafile;
    ISRECORDED=1;
    % Reading in the states,tstamps & Index from the SAVED excel file 
    exactLowerTS = tbounds(BoundIndex,5);
    exactUpperTS = tbounds(BoundIndex,6);
    data_tstamp_read(exactLowerTS,exactUpperTS); 
    
    if isequal(exitAlgorithm, 1)
        return
    end
    index = find(double(EMG_TIMESTAMPS(1))+9.99 < EMG_TIMESTAMPS...
        & EMG_TIMESTAMPS < double(EMG_TIMESTAMPS(1))+10.1);
    difference = EMG_TIMESTAMPS(index(1):index(end)) - (EMG_TIMESTAMPS(1)+10);
    [minimum,ind] = min(abs(difference));

    try
        EPOCHSIZE=index(ind);
    catch 
        fprintf( 'There is an error in calculating the EPOCHSIZE of 10sec in load_nextsection_savedfile function \n' );
    end
    EPOCHSIZEOF10sec=EPOCHSIZE;

    numEpochsInSectionOfEMG = floor(size(EMG_TIMESTAMPS,1)/EPOCHSIZEOF10sec);
    numEpochsInSectionOfScoredFile = size(EPOCHtime,1);
    if numEpochsInSectionOfScoredFile < numEpochsInSectionOfEMG
        EPOCHnum = EPOCHnum(1:end-1,:);
        EPOCHstate = EPOCHstate(1:end-1,:);
        EPOCHtime = EPOCHtime(1:end-1,:);
        SAVED_index = SAVED_index(1:end-1,:);
        for i=numEpochsInSectionOfScoredFile:numEpochsInSectionOfEMG
            EPOCHnum = [EPOCHnum;7];
            EPOCHstate = [EPOCHstate; 'NS'];
            tempEpochTimePointIndex = 1+ ((i-1)*EPOCHSIZEOF10sec);
            EPOCHtime= [EPOCHtime;EMG_TIMESTAMPS(tempEpochTimePointIndex)];
            SAVED_index = [SAVED_index; i]; % Adjusts the vector to include the added indeterminant states
        end
    end
    
  
    plot_epochdata_on_axes_in_GUI_08282018;
    statenum(EPOCHstate(INDEX,:));
    set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:));
    %Setting the slider arrow and trough step EPOCHSIZEOF10sec 
    slider_step(1)=0.01188;
    slider_step(2)=0.09509;
    set(handles.slider1,'sliderstep',slider_step);
    SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
    set(handles.slider1, 'Value',SLIDERVALUE);
    if get(handles.PSDvaluescheckbox,'Value') == 1
        powerdensity_for_epoch;
    end
    DisplayStateColors;
    initSection(EPOCHnum(INDEX))
    Previousframe_Callback
else
    uiwait(errordlg('End of the file. Scored data is saved.'...
        ,'ERROR','modal'));
    set(handles.loadNextSection_scoredFile,'visible','off');
end
%**************************************************************************


%% ########################################################################
%                            Y-AXES CONTROLS
%--------------------------------------------------------------------------
function ymin1_Callback(hObject, eventdata, handles)
function ymax1_Callback(hObject, eventdata, handles)
function ymin2_Callback(hObject, eventdata, handles)
function ymax2_Callback(hObject, eventdata, handles)
function ymin3_Callback(hObject, eventdata, handles)
function ymax3_Callback(hObject, eventdata, handles)
function ymin4_Callback(hObject, eventdata, handles)
function ymax4_Callback(hObject, eventdata, handles)
%**************************************************************************


%% ########################################################################
%                          INTERNAL SUB-FUNCTIONS
%--------------------------------------------------------------------------
function[] = data_tstamp_read(exactLowerTS,exactUpperTS)

global SAVED_index EPOCHstate EPOCHtime EPOCHnum EMG_TIMESTAMPS EPOCH_StartPoint...
    INDEX Sleepstates LO_INDEX SLIDERVALUE Statecolors scoreFileCorrectionType...
    exitAlgorithm

handles=guihandles(SleepScorer_2018a);
filename=get(handles.autoscoredfile,'TooltipString');

switch scoreFileCorrectionType
    case 0  % Manually scored file will be loaded for correction
        [t_stamp_state,stateTemp] = xlsread(filename);
        trainVsCorrected = size(t_stamp_state,2);
        if isequal(trainVsCorrected, 3) %This is an original manually scored file.
            clear stateTemp
            t_stamps = t_stamp_state(:,1:2);
            state = t_stamp_state(:,3);
            clear t_stamp_state
            lengthState = size(state,1);
            %state = zeros(lengthState);
            EPOCHstate = [];
            for i = 1:lengthState  % This loop creates a vector to be like the state vector from Auto-Scorer
                switch state(i)
                    case 1
                        EPOCHstate = [EPOCHstate; 'AW']; %#ok<*AGROW>
                    case 2
                        EPOCHstate = [EPOCHstate; 'QS'];
                    case 3
                        EPOCHstate = [EPOCHstate; 'RE'];
                    case 4
                        EPOCHstate = [EPOCHstate; 'QW'];
                    case 5
                        EPOCHstate = [EPOCHstate; 'UH'];
                    case 6
                        EPOCHstate = [EPOCHstate; 'TR'];
                    case 7
                        EPOCHstate = [EPOCHstate; 'NS'];
                    case 8
                        EPOCHstate = [EPOCHstate; 'IW'];   
                end
            end
        elseif isequal(trainVsCorrected, 2) % This is a manually corrected file.
            t_stamps = t_stamp_state(:,1:2);
            clear t_stamp_state
            state = stateTemp(3:end,3);
            clear stateTemp
            state = char(state);
            EPOCHstate=[state(:,5) state(:,6)];
        end
    case 1  % Auto-scored file will be loaded for correction
        [t_stamps,state] = xlsread(filename);
        t_stamps = t_stamps(5:end,1:2);
        state = state(5:end,3);
        state = char(state);
        EPOCHstate=[state(:,5) state(:,6)];
end
clear state


exactLowerTime = exactLowerTS/10^6;
exactUpperTime = exactUpperTS/10^6;
    
lowIndex = find((t_stamps(:,2) - exactLowerTime)>=0,1);  %#ok<*ASGLU>
LO_INDEX = lowIndex;
clear lowIndex exactLowerTime
highIndex = find((t_stamps(:,2) < exactUpperTime), 1, 'last');
up_index = highIndex;
clear highDifference highIndex exactUpperTime
try
    SAVED_index=t_stamps(LO_INDEX:up_index,1);
%         if isequal(size(SAVED_index,1),1)
%             errordlg('You have reached the end of the sections that have previously been scored.')
%         end
catch ME
    errordlg(ME.message,ME.identifier);
    errordlg(' There was an error calculating the up_index in the data_tstamp_read function')
end
EPOCHtime = t_stamps(LO_INDEX:up_index,2);   
%     state=state(LO_INDEX:up_index,3);
%     state=char(state);
EPOCHstate = EPOCHstate(LO_INDEX:up_index,:);
% Since this variable is reloaded again, we have to make sure that in case
% the previous length was longer than the current, then delete those values
% which otherwise, would show up on DisplayStatecolors at the end of the
% file... and would get confusing. (Huh?)
%     if length(state) < length(EPOCHstate)
%         EPOCHstate = EPOCHstate(1:length(state),:);
%     end

EPOCHnum = zeros(length(EPOCHstate),1);
for i=1:length(EPOCHnum)
    try
    statenum(EPOCHstate(i,:));
    catch err
        errordlg('You have reached the end of the sections that have previously been scored.')
        exitAlgorithm = 1;
        return
    end
    INDEX = INDEX+1;
end
INDEX = 1;
exitAlgorithm = 0;
clear state t_stamps   
%^^^^^^^^^ Setting the slider arrow and trough step EPOCHSIZEOF10sec ^^^^^^ 
slider_step(1) = 0.01088;
slider_step(2) = 0.09909;
set(handles.slider1,'sliderstep',slider_step);
SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
set(handles.slider1, 'Value',SLIDERVALUE);
statenum(EPOCHstate(INDEX,:));
set(handles.scoredstate,'String',Sleepstates(EPOCHnum(INDEX),:),...
    'backgroundcolor',Statecolors(EPOCHnum(INDEX),:));


function[uppertimestamp,lowertimestamp] = extract_samples_timestamps_from_datafile()

global TRACKING_INDEX EPOCHstate EPOCH_StartPoint INDEX EPOCHtime EPOCHnum... 
    TRAINEDEPOCH_INDEX  LBounds UBounds BoundIndex  Fs...  %FileFlag...
    P_emg P_delta P_theta P_sigma st_power dt_ratio...
    EMG_TIMESTAMPS EMG_SAMPLES EMG_Notch_enable EMG_LP_Fc ...
    EEG_TIMESTAMPS EEG_SAMPLES EEG_HP_Fc EEG_Notch_enable...
    Input3_enable Input3_LP_Fc Input3_Notch_enable Input3_HP_Fc INPUT3_TIMESTAMPS INPUT3_SAMPLES ...
    Input4_enable Input4_HP_Fc Input4_Notch_enable Input4_LP_Fc INPUT4_TIMESTAMPS INPUT4_SAMPLES 
global EEG_Fc EMG_Fc SampFreq1 SampFreq2 SampFreq3 SampFreq4 sampfactor exactLowIndx exactHiIndx sampfactor2 Fs2 sampfactor3 Fs3 sampfactor4 Fs4
global y1min y1max y2min y2max y3min y3max y4min y4max
global EMG_sos EMG_g EEG_sos EEG_g Input3_sos Input3_g Input4_sos Input4_g

% Empty all the time stamp and sample arrays:
EMG_TIMESTAMPS = []; EMG_SAMPLES = []; EEG_TIMESTAMPS = []; EEG_SAMPLES = [];
INPUT3_TIMESTAMPS = []; INPUT3_SAMPLES = []; INPUT4_TIMESTAMPS = []; INPUT4_SAMPLES = [];

nsamp = []; % Number of samples per bin of time
waithandle= waitbar(0,'Loading data ..... ');pause(0.2)
handles=guihandles(SleepScorer_2018a);
exactLow = exactLowIndx(BoundIndex);
exactHi = exactHiIndx(BoundIndex);
lowertimestamp=LBounds(BoundIndex);
uppertimestamp=UBounds(BoundIndex);

%%  ****** NECK EMG FILE extraction *********
filename=get(handles.emgfile,'TooltipString');

if BoundIndex == 1
    [SF,Header] = Nlx2MatCSC(filename,[0 0 1 0 0],1,4,[lowertimestamp uppertimestamp]);
    SampFreq1 = SF(1);
    clear SF
    
    DS = (1:1:10);
    DSampSF = SampFreq1./DS;
    indSampfactor = find(DSampSF >= 1000);
    Fs = round(DSampSF(indSampfactor(end)));
    sampfactor = DS(indSampfactor(end));
%      msgbox({['Orginal Sampling Rate:  ' num2str(SampFreq1) 'Hz'];...
%         ['Down-Sampled Sampling Rate:  ' num2str(Fs) 'Hz']; ['Sampling Factor:  ' num2str(sampfactor) '']});

    [hiPass, loPass] = nlxFilterSettings(Header);
    clear Header
    
    [EMG_Fc, EMG_LP_Fc, EMG_sos, EMG_g, EMG_Notch_enable] = filterSettingsCheck(EMG_Fc, EMG_LP_Fc, hiPass, loPass, SampFreq1, Fs, EMG_Notch_enable);
    clear hiPass loPass

    set(handles.EMG_Lowpass_cutoff, 'String', EMG_LP_Fc);
    set(handles.EMG_cutoff, 'String', EMG_Fc);
    if EMG_Notch_enable == 0
        set(handles.Notch60EMG, 'Value', EMG_Notch_enable);
    end

end

% Load the samples and time stamps:
waitbar(0.1,waithandle,'Converting EMG from Neuralynx CSC to Matlab data ...');
figure(waithandle),pause(0.2),
[Timestamps, Samples] = Nlx2MatCSC(filename,[1 0 0 0 1],0,4,[lowertimestamp uppertimestamp]);
samples = double(Samples(:)');
clear Samples

% Precise time stamps should be calculated here:
[EMG_TIMESTAMPS,EMG_SAMPLES] = generate_timestamps_from_Ncsfiles(Timestamps, samples, exactLow, exactHi, nsamp);
clear samples Timestamps

physInput = 1;  %Needed to select proper error box in HeaderADBit.
ADBit2uV = HeaderADBit(filename, physInput);    %Calls a function to extract the AD Bit Value.
EMG_SAMPLES = EMG_SAMPLES * ADBit2uV;   %Convert EMG amplitude of signal from AD Bits to microvolts.

% Filter data:
waitbar(0.4,waithandle,'Filtering the EMG data ...'); 
figure(waithandle),pause(0.2),
if ~isempty(EMG_g)
    filtered_samples = filtfilt(EMG_sos, EMG_g, EMG_SAMPLES);
else
    filtered_samples = EMG_SAMPLES;
end
clear EMG_SAMPLES

% Optional 60Hz Notch Filter
if EMG_Notch_enable ~= 0
    woB = 60/(SampFreq1/2);
    [B_EMG_Notch,A_EMG_Notch] =  iirnotch(woB, woB/35);   % Default is OFF
    filtered_samples = filtfilt(B_EMG_Notch,A_EMG_Notch, filtered_samples);
end
EMG_TIMESTAMPS = EMG_TIMESTAMPS(1:sampfactor:end);
EMG_SAMPLES = filtered_samples(1:sampfactor:end);
clear physInput ADBit2uV filtered_samples SF

if isempty(y1min) || isempty(y1max)
   y1max =  ceil(mean(abs(EMG_SAMPLES)) + 3*std(abs(EMG_SAMPLES))); set(handles.ymax1, 'String', y1max);
   y1min = -y1max; set(handles.ymin1, 'String', y1min);   
end


%%  ******    EEG FILE extraction   *********
filename=get(handles.eegfile,'TooltipString');

if BoundIndex == 1
    [SF,Header] = Nlx2MatCSC(filename,[0 0 1 0 0],1,4,[lowertimestamp uppertimestamp]);
    SampFreq2 = SF(1);
    clear SF
    DS = (1:1:10);
    DSampSF = SampFreq2./DS;
    indSampfactor = find(DSampSF >= 1000);
    Fs2 = round(DSampSF(indSampfactor(end)));
    sampfactor2 = DS(indSampfactor(end));

    [hiPass, loPass] = nlxFilterSettings(Header);
    clear Header
    
    [EEG_HP_Fc, EEG_Fc, EEG_sos, EEG_g, EEG_Notch_enable] = filterSettingsCheck(EEG_HP_Fc, EEG_Fc, hiPass, loPass, SampFreq2, Fs2, EEG_Notch_enable);
    clear hiPass loPass
    
    set(handles.EEG_Highpass_cutoff, 'String', EEG_HP_Fc);
    set(handles.EEG_cutoff, 'String', EEG_Fc);
    if EEG_Notch_enable == 0
        set(handles.Notch60, 'Value', EEG_Notch_enable);
    end
end

waitbar(0.6,waithandle,' Converting EEG from Neuralynx CSC to Matlab data ...');
figure(waithandle),pause(0.2)
[Timestamps, Samples]=Nlx2MatCSC(filename,[1 0 0 0 1],0,4,[lowertimestamp uppertimestamp]);
samples=double(Samples(:)');
clear Samples


[EEG_TIMESTAMPS,EEG_SAMPLES] = generate_timestamps_from_Ncsfiles(Timestamps,samples, exactLow, exactHi, nsamp);
clear samples Timestamps
physInput = 2;  %Needed to select proper error box in HeaderADBit.
ADBit2uV = HeaderADBit(filename, physInput);    %Calls a function to extract the AD Bit Value.
EEG_SAMPLES = EEG_SAMPLES * ADBit2uV;   %Convert EEG amplitude of signal from AD Bits to microvolts.

%% Filter data:
waitbar(0.8,waithandle,'Filtering the EEG data ...'); 
figure(waithandle),pause(0.2),
if ~isempty(EEG_g)
    filtered_samples = filtfilt(EEG_sos, EEG_g, EEG_SAMPLES);
else
    filtered_samples = EEG_SAMPLES;
end
clear EEG_SAMPLES

%  OPTIONAL 60Hz Notch filter for EEG signals
if EEG_Notch_enable ~= 0
    wo = 60/(SampFreq2/2);
    [B_EEG_Notch,A_EEG_Notch] =  iirnotch(wo, wo/35);   % Default is OFF
    filtered_samples = filtfilt(B_EEG_Notch,A_EEG_Notch, filtered_samples);
end
EEG_TIMESTAMPS = EEG_TIMESTAMPS(1:sampfactor2:end);
EEG_SAMPLES = filtered_samples(1:sampfactor2:end);
clear physInput ADBit2uV filtered_samples

if isempty(y2min) || isempty(y2max)
   y2max =  ceil(mean(abs(EEG_SAMPLES)) + 3*std(abs(EEG_SAMPLES))); set(handles.ymax2, 'String', y2max);
   y2min = -y2max; set(handles.ymin2, 'String', y2min);   
end


%%  ******    INPUT3 FILE extraction   *********
if Input3_enable == 1
    filename=get(handles.Input3file,'TooltipString');

    if BoundIndex == 1
        [SF,Header] = Nlx2MatCSC(filename,[0 0 1 0 0],1,4,[lowertimestamp uppertimestamp]);
        SampFreq3 = SF(1);
        clear SF
        DS = (1:1:10);
        DSampSF = SampFreq3./DS;
        indSampfactor = find(DSampSF >= 1000);
        Fs3 = round(DSampSF(indSampfactor(end)));
        sampfactor3 = DS(indSampfactor(end));

        [hiPass, loPass] = nlxFilterSettings(Header);
        clear Header
    
        [Input3_HP_Fc, Input3_LP_Fc, Input3_sos, Input3_g, Input3_Notch_enable] = filterSettingsCheck(Input3_HP_Fc, Input3_LP_Fc, hiPass, loPass, SampFreq3, Fs3, Input3_Notch_enable);
        clear hiPass loPass
        
        set(handles.Input3_Highpass_cutoff, 'String', Input3_HP_Fc);
        set(handles.Input3_Lowpass_cutoff, 'String', Input3_LP_Fc);
        if Input3_Notch_enable == 0
            set(handles.Notch60Input3, 'Value', Input3_Notch_enable);
        end
    end

    waitbar(0.6,waithandle,' Converting INPUT 3 from Neuralynx CSC to Matlab data ...');
    figure(waithandle),pause(0.2)
    [Timestamps, Samples]=Nlx2MatCSC(filename,[1 0 0 0 1],0,4,[lowertimestamp uppertimestamp]);
    samples=double(Samples(:)');
    clear Samples
    
    

    [INPUT3_TIMESTAMPS,INPUT3_SAMPLES]=generate_timestamps_from_Ncsfiles(Timestamps,samples, exactLow, exactHi, nsamp);
    clear samples Timestamps
    physInput = 3;  %Needed to select proper error box in HeaderADBit.
    ADBit2uV = HeaderADBit(filename, physInput);    %Calls a function to extract the AD Bit Value.
    INPUT3_SAMPLES = INPUT3_SAMPLES * ADBit2uV;   %Convert INPUT3 amplitude of signal from AD Bits to microvolts.
    
    %% Filter data:
    waitbar(0.8,waithandle,'Filtering INPUT 3 data ...'); 
    figure(waithandle),pause(0.2),
    if ~isempty(Input3_g)
        filtered_samples = filtfilt(Input3_sos, Input3_g, INPUT3_SAMPLES);
    else
        filtered_samples = INPUT3_SAMPLES;
    end
    clear INPUT3_SAMPLES

    %  OPTIONAL 60Hz Notch filter for Input 3 signals
    if Input3_Notch_enable ~= 0
        wo = 60/(SampFreq3/2);
        [B_Input3_Notch,A_Input3_Notch] =  iirnotch(wo, wo/35);   % Default is OFF
        filtered_samples = filtfilt(B_Input3_Notch,A_Input3_Notch, filtered_samples);
    end
    INPUT3_TIMESTAMPS = INPUT3_TIMESTAMPS(1:sampfactor3:end);
    INPUT3_SAMPLES = filtered_samples(1:sampfactor3:end);
    if isempty(y3min) || isempty(y3max)
       y3max =  ceil(mean(abs(INPUT3_SAMPLES)) + 3*std(abs(INPUT3_SAMPLES))); set(handles.ymax3, 'String', y3max);
       y3min = -y3max; set(handles.ymin3, 'String', y3min);   
    end
    clear physInput ADBit2uV filtered_samples
end

%%  ******    INPUT4 FILE extraction   *********
if Input4_enable == 1
    filename=get(handles.Input4file,'TooltipString');

    if BoundIndex == 1
        [SF,Header] = Nlx2MatCSC(filename,[0 0 1 0 0],1,4,[lowertimestamp uppertimestamp]);
        SampFreq4 = SF(1);
        clear SF
        DS = (1:1:10);
        DSampSF = SampFreq4./DS;
        indSampfactor = find(DSampSF >= 1000);
        Fs4 = round(DSampSF(indSampfactor(end)));
        sampfactor4 = DS(indSampfactor(end));

        [hiPass, loPass] = nlxFilterSettings(Header);
        clear Header
    
        [Input4_HP_Fc, Input4_LP_Fc, Input4_sos, Input4_g, Input4_Notch_enable] = filterSettingsCheck(Input4_HP_Fc, Input4_LP_Fc, hiPass, loPass, SampFreq4, Fs4, Input4_Notch_enable);
        clear hiPass loPass
        
        set(handles.Input4_Highpass_cutoff, 'String', Input4_HP_Fc);
        set(handles.Input4_Lowpass_cutoff, 'String', Input4_LP_Fc);
        if Input4_Notch_enable == 0
            set(handles.Notch60Input4, 'Value', Input4_Notch_enable);
        end
    end

    waitbar(0.6,waithandle,' Converting INPUT 4 from Neuralynx CSC to Matlab data ...');
    figure(waithandle),pause(0.2)
    [Timestamps, Samples]=Nlx2MatCSC(filename,[1 0 0 0 1],0,4,[lowertimestamp uppertimestamp]);
    samples=double(Samples(:)');
    clear Samples
    
    

    [INPUT4_TIMESTAMPS,INPUT4_SAMPLES]=generate_timestamps_from_Ncsfiles(Timestamps,samples, exactLow, exactHi, nsamp);
    clear samples Timestamps
    physInput = 4;  %Needed to select proper error box in HeaderADBit.
    ADBit2uV = HeaderADBit(filename, physInput);    %Calls a function to extract the AD Bit Value.
    INPUT4_SAMPLES = INPUT4_SAMPLES * ADBit2uV;   %Convert Input4 amplitude of signal from AD Bits to microvolts.
    
    %% Filter data:
    waitbar(0.8,waithandle,'Filtering INPUT 4 data ...'); 
    figure(waithandle),pause(0.2),
    if ~isempty(Input4_g)
        filtered_samples = filtfilt(Input4_sos, Input4_g, INPUT4_SAMPLES);
    else
        filtered_samples = INPUT4_SAMPLES;
    end
    clear INPUT4_SAMPLES

    %  OPTIONAL 60Hz Notch filter for Input 4 signals
    if Input4_Notch_enable ~= 0
        wo = 60/(SampFreq4/2);
        [B_Input4_Notch,A_Input4_Notch] =  iirnotch(wo, wo/35);   % Default is OFF
        filtered_samples = filtfilt(B_Input4_Notch,A_Input4_Notch, filtered_samples);
    end
    INPUT4_TIMESTAMPS = INPUT4_TIMESTAMPS(1:sampfactor4:end);
    INPUT4_SAMPLES = filtered_samples(1:sampfactor4:end);
    if isempty(y4min) || isempty(y4max)
       y4max =  ceil(mean(abs(INPUT4_SAMPLES)) + 3*std(abs(INPUT4_SAMPLES))); set(handles.ymax4, 'String', y4max);
       y4min = -y4max; set(handles.ymin4, 'String', y4min);   
    end
    clear physInput ADBit2uV filtered_samples
end

waitbar(1,waithandle, 'Finished converting.. Now Loading the data ..');
figure(waithandle), pause(0.2);
close(waithandle)

% Initialize the variables for further access
st_power=[];dt_ratio=[];P_emg=[];
P_delta=[]; P_theta=[];P_sigma=[];
EPOCH_StartPoint=1; INDEX=1; 
TRACKING_INDEX=1;
TRAINEDEPOCH_INDEX=[];
%****************This is where the program is defining array lengths in the
%beginning based on 10 second epochs. It will need to be changed.
all_arraylength=ceil((double(EEG_TIMESTAMPS(end))-double(EEG_TIMESTAMPS(1)))/10);
EPOCHnum=zeros(all_arraylength,1); EPOCHtime=ones(all_arraylength,1);
EPOCHstate=[repmat('N',all_arraylength,1) repmat('S',all_arraylength,1)];
viewStates;


function initSection(stateNumber)
switch stateNumber
    case 1
        Activewaking_Callback
    case 2
        Quietsleep_Callback
    case 3
        REM_Callback
    case 4
        Quietwaking_Callback
    case 5
        Unhooked_Callback
    case 6
        transREM_Callback
    case 7
        clearstate_Callback
    case 8
        clearstate_Callback    
end
%**************************************************************************











