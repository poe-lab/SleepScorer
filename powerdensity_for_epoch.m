function [] = powerdensity_for_epoch
% This is a subfunction of Sleep Scorer and must be included in the
% "Sleepscorer" folder. It calculates the estimated power values for the
% current 10 second epoch.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Aug-28-2018
% --Modified handle call to work with latest changes in Sleep Scorer.
% --Updated power spectral analyses to be in line with other lab programs.
%--------------------------------------------------------------------------
% Modified by Brooks A. Gross on Nov-2-2012
% --Turned off Spectrum obsolete warning.  It will need to be updated
% before Mathworks removes it.

% Modified by Brooks A. Gross on Jan-15-2010
% --Created as an independent m-file.
%--------------------------------------------------------------------------
global EPOCHSIZE EMG_SAMPLES EEG_SAMPLES EPOCH_StartPoint D_lo D_hi T_lo...
    T_hi S_lo S_hi B_lo B_hi P_emg st_power dt_ratio EEG_TIMESTAMPS EEG_Fc

% This is taking integral in time domain 
Vj=double(EMG_SAMPLES(EPOCH_StartPoint:EPOCH_StartPoint+EPOCHSIZE-1));
absVj=abs(Vj).^2;                       % absolute square
P_emg=sum(absVj)/length(absVj);  % sum of all squared Vj's


%% Calculate the power spectrum
epochDuration = EEG_TIMESTAMPS(EPOCHSIZE+1) - EEG_TIMESTAMPS(1);
dt = epochDuration/EPOCHSIZE; % Define the sampling interval.
df = 1/epochDuration; % Determine the frequency resolution.
fNyquist = 1/(2*dt); % Determine the Nyquist frequency.

% Construct the frequency axis:
freqVector = (0:df:fNyquist); 
lastFreqIndex = find(freqVector <= EEG_Fc, 1, 'last');
freqVector = freqVector(1:lastFreqIndex);

% Compute the power spectrum of the Hann tapered data:
epochSamples = EEG_SAMPLES(EPOCH_StartPoint:EPOCH_StartPoint+EPOCHSIZE-1);
xh = hann(length(epochSamples)).*epochSamples; 
Sxx = 2*dt^2/epochDuration * fft(xh).*conj(fft(xh)); % Compute the power spectrum of Hann tapered data.
Sxx=real(Sxx); %Ignores imaginary component.	
Sxx = Sxx(:);
epochPowerSpectra = Sxx(1:lastFreqIndex);
clear Sxx

%% Compute band power:
freqVector = freqVector(:);
width = diff(freqVector);
lastRectWidth = 0;  % Don't include last point of PSD data.
width = [width; lastRectWidth];

freqBands = [D_lo D_hi; T_lo T_hi; S_lo S_hi; B_lo B_hi];
numBands = size(freqBands,1);
epochBandpwr = zeros(numBands,1);
for i = 1:numBands
    idx1 = find(freqVector<=freqBands(i,1), 1, 'last' );
    idx2 = find(freqVector>=freqBands(i,2), 1, 'first');
    epochBandpwr(i) = width(idx1:idx2)'*epochPowerSpectra(idx1:idx2);
    clear idx1 idx2
end

st_power=abs(epochBandpwr(3) * epochBandpwr(2));   % Used to indicate waking
dt_ratio=abs(epochBandpwr(1) / epochBandpwr(2));   

handles=guihandles(SleepScorer_2018a);
set(handles.emg_edit,'String',P_emg);
set(handles.delta_edit,'String',epochBandpwr(1));
set(handles.theta_edit,'String',epochBandpwr(2));
set(handles.sigma_edit,'String',epochBandpwr(3));
set(handles.beta_edit,'String',epochBandpwr(4));
set(handles.sigmatheta,'String',st_power);
set(handles.deltatheta,'String',dt_ratio);