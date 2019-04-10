function stateProcessing
% This is a subfunction of Sleep Scorer and must be included in the
% "Sleepscorer" folder. The function processes all scoring button presses.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Aug-28-2018
% --Modified handle call to work with latest changes in Sleep Scorer.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Jan-15-2010
% --Created as an independent m-file.
%--------------------------------------------------------------------------
global EPOCHSIZE EPOCHSIZEOF10sec EMG_TIMESTAMPS EPOCHtime ISRECORDED TRACKING_INDEX ...
    EPOCHstate EPOCH_StartPoint INDEX Sleepstates EPOCHnum TRAINEDEPOCH_INDEX...
    LO_INDEX BoundIndex SAVED_index SLIDERVALUE Statecolors moveLeft moveRight...
    stateNumberCode stateLetterCode epochScoringSize epochVal

epochSizeCheck
if isequal(epochScoringSize, epochVal)
    handles=guihandles(SleepScorer_2018a);
    set(handles.emg_edit,'String','');
    set(handles.delta_edit,'String','');
    set(handles.theta_edit,'String','');
    set(handles.sigma_edit,'String','');
    set(handles.sigmatheta,'String','');
    set(handles.deltatheta,'String','');
    set(handles.beta_edit,'String','');

    EPOCHstate(INDEX,:) = stateLetterCode;
    EPOCHnum(INDEX) = stateNumberCode;
    if ISRECORDED == 1 % If u r looking at the saved scored data
    else
        EPOCHtime(INDEX)=EMG_TIMESTAMPS(EPOCH_StartPoint);
        if ~any(TRAINEDEPOCH_INDEX==INDEX) % add index to indoffset only if it was not done b4 
            TRAINEDEPOCH_INDEX=[TRAINEDEPOCH_INDEX;INDEX];
        end
    end
    set(handles.scoredstate,'String',Sleepstates(stateNumberCode,:),...
         'backgroundcolor',Statecolors(stateNumberCode,:));

    if(length(EMG_TIMESTAMPS)-(EPOCH_StartPoint+EPOCHSIZE) <= 0)
        uiwait(errordlg('End of file reached.Scroll back or CLOSE the program',...
            'ERROR','modal'));
    else
        nIndexSteps = round(EPOCHSIZE/EPOCHSIZEOF10sec);
        if isequal(nIndexSteps, 1)
            INDEX = INDEX + 1;
            EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
        else
            for i = 2:nIndexSteps
                INDEX = INDEX + 1;
                EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
                EPOCHtime(INDEX) = EMG_TIMESTAMPS(EPOCH_StartPoint);
                EPOCHstate(INDEX,:) = stateLetterCode;
                EPOCHnum(INDEX) = stateNumberCode;
                if ~any(TRAINEDEPOCH_INDEX==INDEX) % add index to indoffset only if it was not done b4 
                    TRAINEDEPOCH_INDEX=[TRAINEDEPOCH_INDEX;INDEX]; %#ok<AGROW>
                end
            end
            INDEX = INDEX + 1;
            EPOCH_StartPoint = EPOCH_StartPoint + EPOCHSIZEOF10sec;
        end
            
        if INDEX-TRACKING_INDEX >=1
            TRACKING_INDEX=INDEX;
        end
        plot_epochdata_on_axes_in_GUI_08282018;
        SLIDERVALUE=(100*EPOCH_StartPoint)/length(EMG_TIMESTAMPS);
        set(handles.slider1, 'Value',SLIDERVALUE); 
        if get(handles.PSDvaluescheckbox,'Value') == 1
            powerdensity_for_epoch;
        end
        if ISRECORDED == 1 % If u r looking at the saved scored data
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
%                 ind=find((SAVED_index - LO_INDEX+1)==INDEX);
% %THIS IS A POINT TO EXAMINE
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
                TRACKING_INDEX=ind;  %Not using Auto-fill for correcting files
            end
        else
            if (INDEX>length(EPOCHnum))|| (EPOCHnum(INDEX)==0)
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
        end
    end
    moveLeft =1; moveRight =1;
    DisplayStateColors;
    viewStates;
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