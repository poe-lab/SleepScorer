%DESCRIPTION: This function is called in Sleep Scorer to graph the signal
%             inputs onto the specified charts in the Sleep Scorer GUI.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Aug-28-2018
% --Modified handle call to work with latest changes in Sleep Scorer.
%--------------------------------------------------------------------------
%VERSION 2b
% Modified by Brooks A. Gross on Oct-6-2009
% --Code for y-axis min and max for all charts. 
% --Y-axis units now inserted into each chart dependent on type of
%   data acquisition system.
%VERSION 2a
% Modified by Brooks A. Gross on Jan-10-2007
% --Added code for optional inputs 3 and 4
%--------------------------------------------------------------------------
function[] =plot_epochdata_on_axes_in_GUI_08282018(varargin)

global EPOCHSIZE EMG_TIMESTAMPS EEG_TIMESTAMPS EMG_SAMPLES EEG_SAMPLES  
global EPOCH_StartPoint FileFlag
global INPUT3_TIMESTAMPS INPUT3_SAMPLES INPUT4_TIMESTAMPS INPUT4_SAMPLES Input3_enable Input4_enable
global y1min y1max y2min y2max y3min y3max y4min y4max
handles=guihandles(SleepScorer_2018a);

if length(varargin) == 1
    start_point=str2num(char(varargin(1,1)));
    end_point=start_point+EPOCHSIZE-1;
else
    start_point=EPOCH_StartPoint;
    end_point=start_point+EPOCHSIZE-1;
end

% The 'str2num' must be used for the y-axes limits since they eventually
% are placed in a vector. 'str2double' will result in an error.
y1min=str2num(get(handles.ymin1,'string')); %#ok<*ST2NM>
y1max=str2num(get(handles.ymax1,'string'));

y2min=str2num(get(handles.ymin2,'string'));
y2max=str2num(get(handles.ymax2,'string'));

y3min=str2num(get(handles.ymin3,'string'));
y3max=str2num(get(handles.ymax3,'string'));

y4min=str2num(get(handles.ymin4,'string'));
y4max=str2num(get(handles.ymax4,'string'));

% Plot the channels data on the GUI
if length(EMG_SAMPLES)-end_point <= 0
    uiwait(errordlg('End of section reached.Scroll back or LOAD the next section',...
        'ERROR','modal'));
    
% Check whether the remaining data points do make upto 10 seconds of data
% or not... If there are only few samples more then the current 10 sec,
% then add it and take whe whole thing as one epoch...
elseif length(EMG_SAMPLES)-end_point <= EPOCHSIZE/9
    % The only reason for adding this part of the code was to make sure
    % that when we are trying to find the LO_INDEX and up_index in the
    % 'savedload' functions, we do not get 2 values which are near to the
    % lowertimestamp value... This will ensure that when we are scoring an
    % epoch, we do not consider 1 sec epoch as one to be scored and
    % misalign the INDEX values for further calculations... 
    set(handles.startTimeOfEpoch, 'String', EMG_TIMESTAMPS(start_point));
    axes(handles.channelplot1)
    plot(EMG_TIMESTAMPS(start_point:length(EMG_TIMESTAMPS)),...
        EMG_SAMPLES(start_point:length(EMG_SAMPLES)),'color',[0 0 1]);
    axis tight
    
    if isempty(y1max)==0
        if isempty(y1min)==0
            set(gca,'ylim',[y1min y1max]);
        else
            set(gca,'ylim',[y1max y1max]);
        end
    else
        set(gca,'ylim',[-120 120]);
    end
    %Insert code in this 'if' statement to specify the units for amplitude
    %in your recording.  Repeat for all similar statements that follow in
    %this m-file.
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
        ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('Movement (? units)')
    end
    set(gca,'XMinorTick','on')
    grid on
    
    axes(handles.channelplot2)
    plot(EEG_TIMESTAMPS(start_point:length(EEG_TIMESTAMPS)),...
        EEG_SAMPLES(start_point:length(EEG_SAMPLES)),'color',[0 0 1]);
    axis tight
    if isempty(y2max)==0
        if isempty(y2min)==0
            set(gca,'ylim',[y2min y2max]);
        else
            set(gca,'ylim',[y2max y2max]);
        end
    else
        set(gca,'ylim',[-120 120]);
    end
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
            ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('EEG (V)')
    end
    set(gca,'XMinorTick','on')
    grid on
    
    if Input3_enable>0
        axes(handles.channelplot3)
        plot(INPUT3_TIMESTAMPS(start_point:length(INPUT3_TIMESTAMPS)),...
            INPUT3_SAMPLES(start_point:length(INPUT3_SAMPLES)),'color',[0 0 1]);
        axis tight
        if isempty(y3max)==0
            if isempty(y3min)==0
                set(gca,'ylim',[y3min y3max]);
            else
                set(gca,'ylim',[y3max y3max]);
            end
        else
            set(gca,'ylim',[-120 120]);
        end
    end
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
        ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('Temp (C)')
    end
    set(gca,'XMinorTick','on')
    grid on
    
    if Input4_enable>0
        axes(handles.channelplot4)
        plot(INPUT4_TIMESTAMPS(start_point:length(INPUT4_TIMESTAMPS)),...
            INPUT4_SAMPLES(start_point:length(INPUT4_SAMPLES)),'color',[0 0 1]);
        axis tight
        if isempty(y4max)==0
            if isempty(y4min)==0
                set(gca,'ylim',[y4min y4max]);
            else
                set(gca,'ylim',[y4max y4max]);
            end
        else
            set(gca,'ylim',[-120 120]);
        end
    end
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
        ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('EEG (V)')
    end
    set(gca,'XMinorTick','on')
    grid on
else
    set(handles.startTimeOfEpoch, 'String', EMG_TIMESTAMPS(start_point));
    axes(handles.channelplot1)
    plot(EMG_TIMESTAMPS(start_point:end_point),...
        EMG_SAMPLES(start_point:end_point),'color',[0 0 1]);
    axis tight
    if isempty(y1max)==0
        if isempty(y1min)==0
            set(gca,'ylim',[y1min y1max]);
        else
            set(gca,'ylim',[y1max y1max]);
        end
    else
        set(gca,'ylim',[-120 120]);
    end
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
        ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('Movement (? units)')
    end
    set(gca,'XMinorTick','on')
    grid on
    
    axes(handles.channelplot2)
    plot(EEG_TIMESTAMPS(start_point:end_point),...
        EEG_SAMPLES(start_point:end_point),'color',[0 0 1]);
    axis tight
    if isempty(y2max)==0
        if isempty(y2min)==0
            set(gca,'ylim',[y2min y2max]);
        else
            set(gca,'ylim',[y2max y2max]);
        end
    else
        set(gca,'ylim',[-120 120]);
    end
    if isequal(FileFlag, 2) % AD System
        ylabel('? units')
    elseif isequal(FileFlag, 1) % Neuralynx System
        ylabel('uV')
    elseif isequal(FileFlag, 3) % ASCII - Polysmith
        ylabel('uV units')
    elseif isequal(FileFlag, 4) % ASCII - EMZA
        ylabel('? units')
    elseif isequal(FileFlag, 5) % Plexon
        ylabel('mV units')
    elseif isequal(FileFlag, 6) % DSI EDF
        ylabel('EEG (V)')
    end
    set(gca,'XMinorTick','on')
    grid on
    
    if Input3_enable>0
        axes(handles.channelplot3)
        plot(INPUT3_TIMESTAMPS(start_point:end_point),...
            INPUT3_SAMPLES(start_point:end_point),'color',[0 0 1]);
        axis tight
        if isempty(y3max)==0
            if isempty(y3min)==0
                set(gca,'ylim',[y3min y3max]);
            else
                set(gca,'ylim',[y3max y3max]);
            end
        else
            set(gca,'ylim',[-120 120]);
        end
        if isequal(FileFlag, 2) % AD System
            ylabel('? units')
        elseif isequal(FileFlag, 1) % Neuralynx System
            ylabel('uV')
        elseif isequal(FileFlag, 3) % ASCII - Polysmith
            ylabel('uV units')
        elseif isequal(FileFlag, 4) % ASCII - EMZA
            ylabel('? units')
        elseif isequal(FileFlag, 5) % Plexon
            ylabel('mV units')
        elseif isequal(FileFlag, 6) % DSI EDF
            ylabel('Temp (C)')
        end
        set(gca,'XMinorTick','on')
        grid on
    end
    
    if Input4_enable>0
        axes(handles.channelplot4)
        plot(INPUT4_TIMESTAMPS(start_point:end_point),...
            INPUT4_SAMPLES(start_point:end_point),'color',[0 0 1]);
        axis tight
        if isempty(y4max)==0
            if isempty(y4min)==0
                set(gca,'ylim',[y4min y4max]);
            else
                set(gca,'ylim',[y4max y4max]);
            end
        else
            set(gca,'ylim',[-120 120]);
        end
        if isequal(FileFlag, 2) % AD System
            ylabel('? units')
        elseif isequal(FileFlag, 1) % Neuralynx System
            ylabel('uV')
        elseif isequal(FileFlag, 3) % ASCII - Polysmith
            ylabel('uV units')
        elseif isequal(FileFlag, 4) % ASCII - EMZA
            ylabel('? units')
        elseif isequal(FileFlag, 5) % Plexon
            ylabel('mV units')
        elseif isequal(FileFlag, 6) % DSI EDF
            ylabel('EEG (V)')
        end
        set(gca,'XMinorTick','on')
        grid on
    end
end
%EPOCH_StartPoint=end_point+1;
guidata(gcf,handles);