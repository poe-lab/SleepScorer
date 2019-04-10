function [] = DisplayStateColors()
% This is a subfunction of Sleep Scorer and must be included in the
% "Sleepscorer" folder. It is responsible for filling in colors of states 
% in the 2 minute history bar.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Aug-28-2018
% --Modified handle call to work with latest changes in Sleep Scorer.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Jan-15-2010
% --Created as an independent m-file.
%--------------------------------------------------------------------------
global Statecolors INDEX EPOCHnum
handles=guihandles(SleepScorer_2018a);
currentstateindex=6;
displaycolorsarray = repmat(7,12,1);
if INDEX >= 6
    if (INDEX + 6) > length(EPOCHnum)
        numarray=EPOCHnum(INDEX-5:end);
        displaycolorsarray(currentstateindex-5:length(numarray))...
            = EPOCHnum(INDEX-5:end);
        numzero=find(displaycolorsarray ==0);
        displaycolorsarray(numzero)=7; %#ok<*FNDSB>
    else
        displaycolorsarray(currentstateindex-5:end)=EPOCHnum(INDEX-5:INDEX + 6);
        numzero=find(displaycolorsarray ==0);
        displaycolorsarray(numzero)=7;
    end
elseif INDEX == 1
    displaycolorsarray(currentstateindex:end)=EPOCHnum(INDEX:INDEX + 6);
    numzero=find(displaycolorsarray ==0);
    displaycolorsarray(numzero)=7;
elseif INDEX == 2
    displaycolorsarray(currentstateindex-1:end)=EPOCHnum(INDEX-1:(INDEX+6));
    numzero=find(displaycolorsarray ==0);
    displaycolorsarray(numzero)=7;
elseif INDEX == 3
    displaycolorsarray(currentstateindex-2:end)=EPOCHnum(INDEX-2:(INDEX + 6));
    numzero=find(displaycolorsarray ==0);
    displaycolorsarray(numzero)=7;
elseif INDEX == 4
    displaycolorsarray(currentstateindex-3:end)=EPOCHnum(INDEX-3:(INDEX + 6));
    numzero=find(displaycolorsarray ==0);
    displaycolorsarray(numzero)=7;
elseif INDEX == 5
    displaycolorsarray(currentstateindex-4:end)=EPOCHnum(INDEX-4:(INDEX + 6));
    numzero=find(displaycolorsarray ==0);
    displaycolorsarray(numzero)=7;
end

set(handles.current_minus5,'backgroundcolor',Statecolors(displaycolorsarray(1),:));
set(handles.current_minus4,'backgroundcolor',Statecolors(displaycolorsarray(2),:));
set(handles.current_minus3,'backgroundcolor',Statecolors(displaycolorsarray(3),:));
set(handles.current_minus2,'backgroundcolor',Statecolors(displaycolorsarray(4),:));
set(handles.current_minus1,'backgroundcolor',Statecolors(displaycolorsarray(5),:));
set(handles.current_state,'backgroundcolor',Statecolors(displaycolorsarray(6),:));
set(handles.current_plus1,'backgroundcolor',Statecolors(displaycolorsarray(7),:));
set(handles.current_plus2,'backgroundcolor',Statecolors(displaycolorsarray(8),:));
set(handles.current_plus3,'backgroundcolor',Statecolors(displaycolorsarray(9),:));
set(handles.current_plus4,'backgroundcolor',Statecolors(displaycolorsarray(10),:));
set(handles.current_plus5,'backgroundcolor',Statecolors(displaycolorsarray(11),:));
set(handles.current_plus6,'backgroundcolor',Statecolors(displaycolorsarray(12),:));
