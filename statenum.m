function[]=statenum(state)
% This function is called from this M-file from all the callback functions
% to assign appropriate numbers to the scored state
%Called by the following programs:
%--Sleep Scorer

global EPOCHnum INDEX

switch state
    case 'AW'
        EPOCHnum(INDEX)=1;
    case 'QS'
        EPOCHnum(INDEX)=2;
    case 'RE'
        EPOCHnum(INDEX)=3;
    case 'QW'
        EPOCHnum(INDEX)=4;
    case 'UH'
        EPOCHnum(INDEX)=5;
    case 'TR'
        EPOCHnum(INDEX)=6;
    case 'NS'
        EPOCHnum(INDEX)=7;
    case 'IW'
        EPOCHnum(INDEX)=8;    
end