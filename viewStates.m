function viewStates
%Called by the following programs:
%--Sleep Scorer
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Aug-28-2018
% --Modified handle call to work with latest changes in Sleep Scorer.
%--------------------------------------------------------------------------
global EPOCHnum Cmap INDEX

handles=guihandles(SleepScorer_2018a);

A = EPOCHnum;
l = length(A);
for i = 1:l
    if A(i)==0;
        A(i) = 7;
    end
end
A = A';
B = 7 * ones(2,l);
B(1,:) = A;
j = 6;
for i = 1:6
    if INDEX - i < 1
        j = i - 1;
        break
    end
end

k = 5;
for i = 1:5
    if INDEX + i > l
        k = i - 1;
        break
    end
end

B(2, INDEX-j:INDEX+k) = 5;
% Setup the colormap for the states.
Cmap(1,:)=[1 0.8 0];  % Yellow   => Active Waking
Cmap(2,:)=[0 0 1];    % Blue     => Quiet Sleep
Cmap(3,:)=[1 0 0];    % Red      => REM
Cmap(4,:)=[0 1 0.1];  % Green    => Quiet Waking
Cmap(5,:)=[0 0 0];    % Black    => Unhooked
Cmap(6,:)=[0 1 1];    % Cyan     => Transition to REM
Cmap(7,:)= [0.85 0.85 0.85];    % Clear    => Cleared State
Cmap(8,:)=[1 1 1];    % White    => Intermediate Waking

axes(handles.viewSectionStates)
colormap(Cmap);
image(B);
axis off
guidata(gcf,handles);
