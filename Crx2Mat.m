%%%%%%%%%%%%%%% Begin Matlab Script %%%%%%%%%%%%%%%%%%
function[eegtime,eegampl,samp_rate,nsamp] = Crx2Mat(filename,lowerts,upperts)
% This is an utility to convert the CRextract binary files into Matlab
% variables. It needs upper and lower timestamp values,a filename and
% sampling factor value as its input and gives out the samples and the 
% time in seconds as the output which can be further used in program 
% for display. The output is compatible with the neuroread format as
% well to avoid incompatability issues.

% Developed by Apurva Turakhia , University of Michigan
% First Version: Jan 10, 2003
%Called by the following programs:
%--Auto-Scorer
%--Sleep Scorer
fid = fopen(filename,'rb');  %open file
linein = '';
eegdir = dir(filename);
eegfilelen = eegdir.bytes;
eegdat=[];
% Read in Header and STOP

while isempty(findstr('ENDHE',linein))==1
  linein = fgets(fid); % read in single character
end
fseek(fid,0,'cof');
dataidx=1; sampleflag=0;
while ftell(fid) < eegfilelen
%fprintf('%.2f|',ftell(fid)/eegfilelen);
  ts = fread(fid, 1,'*uint32');       %uint32=>uint32
  nsamp = fread(fid, 1,'*ushort');    %fread equiv int16=>double default
  srate = fread(fid, 1,'*uint32');    %*short equiv to int16=>int16
  data = fread(fid,double(nsamp),'*int16'); %preserve short by *short
  if ts == uint32(lowerts)
      sampleflag=1;
  elseif ts == uint32(upperts)
      %data = fread(fid,double(nsamp),'*int16'); %preserve short by *short
      eegdat(dataidx).ts = ts;
      eegdat(dataidx).nsamp = (nsamp);
      eegdat(dataidx).srate = (srate);
      %eegdat(dataidx).srate = 1002;
      eegdat(dataidx).data = data;
      dataidx = dataidx+1;
      sampleflag=0;
      fprintf('data collected\n');
      break;  % If read till upperts, then break from the while loop
  end
  if sampleflag ==1
      %data = fread(fid,double(nsamp),'*int16'); %preserve short by *short
      eegdat(dataidx).ts = ts;
      eegdat(dataidx).nsamp = (nsamp);
      %eegdat(dataidx).srate = 1002;
      eegdat(dataidx).srate = (srate);
      eegdat(dataidx).data = data;
      dataidx = dataidx+1;
  end
end
fclose(fid);

linearts = double(eegdat(2).ts) - double(eegdat(1).ts);
ed(1) = eegdat(1).ts; edskipidx = 1;
for i = 2:length(eegdat)
  ed(i) = eegdat(i).ts;
  if double(ed(i)) - double(ed(i-1)) ~= linearts;
    edskip(1,edskipidx) = i;
    edskip(2,edskipidx) = ed(i);
    edskip(3,edskipidx) = double(ed(i)) - double(ed(i-1));
    edskipidx = edskipidx + 1;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Import now Convert
eelen = length(eegdat); 
nsamp = length(eegdat(1).data);
eegampl = int16(zeros(nsamp,eelen));
eegtime = uint32(zeros(eelen,1));
idx = 1;

% Read in the samples into eegampl and the starting timestamp values into
% the eegtime.

for i = 1:eelen
% eegampl(idx:idx+nsamp-1,:) = eegdat(i).data; % original one
  eegampl(1:nsamp,i) = eegdat(i).data;   % Creates '3072 x i' matrix
  eegtime(i)=eegdat(i).ts;
  idx = idx + nsamp;
end
%eegtime=double(eegtime)/1000;
nsamp=double(eegdat(1).nsamp);
samp_rate=double(eegdat(1).srate);
eegtime=double(eegtime(:)');
eegampl=double(eegampl(:)');

clear trange eegdat

%%%%%%% End Matlab Script for Conversion