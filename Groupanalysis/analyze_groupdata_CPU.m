function analyze_groupdata_CPU(outputpath)

% FUNCTION ANALYZE_GROUPDATA_CPU(OUTPUTPATH) Example transfer entropy 
% (TE) group analysis of four data sets obtained in a face recognition task 
% described in:
%
%   Gruetzner C, Uhlhaas PJ, Genc E, Kohler A, Singer W, et al. (2010)
%   Neuroelectromagnetic correlates of perceptual closure processes. 
%   J Neurosci 30:8342–8352.
%
% Data consist of virtual channels obtained from beamformer source 
% reconstruction and are analyzed using the CPU work flow for TE estimation 
% in TRENTOOL. The time of interest 0ms 1200ms starts with stimulus 
% presentation and includes the whole task interval. Transfer entropy is 
% estimated from V1 to all other reconstructed sources.
%
% Results may be plotted using the function 'plot_group_example.m' in this
% folder. Note that you may need to adjust the file paths in this example
% script to run it on your computer.
%
% OUTPUTPATH is a string that contains the path to a folder, where 
%	     TRENTOOL will save analysis results
%
% Version 3.31 by Patricia Wollstadt, Michael Wibral, Raul Vicente, 
% Michael Lindner Frankfurt 2015

%% define data paths

if ~isdir(outputpath)
  error([outputpath ' is not a path. Please check!'])
end

%% get data
cd data/
files = dir('*.mat');

fprintf('Processing the following %.0f subjects:\n', length(files));
for i=1:length(files)
    fprintf('\t%s\n', files(i).name(1:5));
end;

load(['data/' files(1).name])

%% create cfg

cfgTEP                  = [];
cfgTEP.TEcalctype       = 'VW_ds'; 
cfgTEP.channel = data.label;
cfgTEP.predicttimemin_u    = 3;
cfgTEP.predicttimemax_u    = 7;
cfgTEP.predicttimestepsize = 2;
cfgTEP.toi = [0 0.7];
cfgTEP.maxlag      = 1000;    % orig: 1000/90
cfgTEP.actthrvalue = 40;                           % treshold for ACT (orig: 150/100), kann auf 40/45/50 gesetzt werden
cfgTEP.optimizemethod ='ragwitz';   % criterion used
cfgTEP.ragdim         = 5:11;       % criterion dimension
cfgTEP.ragtaurange    = [0.2 0.4];  % range for tau [0.5 1]
cfgTEP.ragtausteps    = 5;          % steps for ragwitz tau steps
cfgTEP.repPred        = 100;         % original: 100, kann auf 25-50 gesetzt werden
cfgTEP.flagNei = 'Mass' ;           % neigbour analyse type
cfgTEP.sizeNei = 4;                 % neigbours to analyse
cfgTEP.extracond = 'Faes_Method';
cfgTEP.ensemblemethod  = 'no';

cfgTESS               = [];
cfgTESS.shifttest     = 'no';
cfgTESS.surrogatetype = 'trialshuffling';
cfgTESS.MIcalc        = 1;
cfgTESS.optdimusage   = 'indivdim';   % dimension to use

%% group prepare

fileCell = {files(:).name};

cfgTEP.outputpath = outputpath;
TEgroup_prepare(cfgTEP, fileCell)

%% estimate TE

for i=1:length(files)
    load([outputpath files(i).name])
    cfgTESS.fileidout = strcat(outputpath, files(i).name(1:5));
    TEpermtest = InteractionDelayReconstruction_calculate(cfgTEP, cfgTESS, data);
end


%% group statistics

cd(outputpath)
files = dir([outputpath '*TEpermtest_output.mat']);
fileCell = {files(:).name};   

cfgGSTAT = [];
cfgGSTAT.alpha = 0.05;
cfgGSTAT.correctm = 'BONF';
cfgGSTAT.design = [1:4; 1 1 2 2];   % independent samples t-test
%cfgGSTAT.design = [1 2 3 4; 1 1 2 2]; % dependent samples t-test (ordered input)
%cfgGSTAT.design = [1 2 4 3; 1 1 2 2]; % dependent samples t-test (unordered input)
cfgGSTAT.uvar   = 1;  % unit of observation, dependent variable (e.g., subject)
cfgGSTAT.ivar   = 2;  % independent variable (e.g., experimental condition)
cfgGSTAT.permstatstype = 'indepsamplesT';

% compare TE values
cfgGSTAT.datatype = 'TE';
cfgGSTAT.fileidout   = [outputpath 'groupstatsTE'];
TEgroup_stats(cfgGSTAT, fileCell);

% compare MI values
cfgGSTAT.datatype = 'MI';
cfgGSTAT.fileidout   = [outputpath 'groupstatsMI'];
TEgroup_stats(cfgGSTAT, fileCell);

%% single subject statistics

file1 = load(files(1).name);
file2 = load(files(2).name);
cfgGSTAT.fileidout   = [outputpath 'condstatssingle'];
TEgroup_conditionstatssingle(cfgGSTAT, file1.TEpermtest, file2.TEpermtest);

%%
close all
fclose(fid);
exit
