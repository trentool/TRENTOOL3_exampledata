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
% estimated between three sources, SPL, cITG, and STG.
%
% The script performs a group analysis on TE and MI estimates demonstrating
% two possible analysis settings (see step 3, below):
%    (a) comparison of two groups of data sets, e.g., recordings from 
%	 various subjects randomly assigned to one of two experimental
%	 conditions (unit of observation: subject);
%    (b) comparison of two data sets obtained from the same subject under
%	 two different experimental conditionsi (unit of observation: 
%	 trial).
%
% Results may be plotted using the function 'plot_group_example.m' in this
% folder. Note that this script is intended to be run from the example
% scripts folder 'Groupanalysis'.
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
cfgTEP.maxlag      = 1000;          % max. lag for ACT calculation
cfgTEP.actthrvalue = 40;            % treshold for ACT
cfgTEP.optimizemethod ='ragwitz';   % criterion used for embedding optimization
cfgTEP.ragdim         = 5:11;       % criterion dimension
cfgTEP.ragtaurange    = [0.2 0.4];  % range for tau [0.5 1], fraction of ACT
cfgTEP.ragtausteps    = 5;          % steps for ragwitz tau steps
cfgTEP.repPred        = 100;        % no. points per trial for embedding optimization
cfgTEP.flagNei = 'Mass' ;           % neigbour analyse type
cfgTEP.sizeNei = 4;                 % neigbours to analyse
cfgTEP.extracond = 'Faes_Method';
cfgTEP.ensemblemethod  = 'no';

cfgTESS               = [];
cfgTESS.shifttest     = 'no';	% don't use a shift test, the Faes method takes care of volume conduction
cfgTESS.surrogatetype = 'trialshuffling';  % option for surrogate creation
cfgTESS.MIcalc        = 1;	% calculate the MI between source and target past states
cfgTESS.optdimusage   = 'indivdim';   % dimension to use

%% (1) group prepare
% prepare individual files for group analysis by finding a common,
% maximum embedding dimension.

fileCell = {files(:).name};

cfgTEP.outputpath = outputpath;
TEgroup_prepare(cfgTEP, fileCell);   % adds a field 'groupprepared' to the data

%% (2) estimate TE using a common embedding dimension
% use the files prepared for group analysis

for i=1:length(files)
    load([outputpath files(i).name])  % use data prepared for group analysis in step (1)
    cfgTESS.fileidout = strcat(outputpath, files(i).name(1:5));
    TEpermtest = InteractionDelayReconstruction_calculate(cfgTEP, cfgTESS, data);
end

%% (3a) group statistics
% Assume the first two files represent recordings from two subjects under  
% experimental condition 1, and the other two files represent recordings 
% from two subjects under experimental condition 2.

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

%% (3b) single subject statistics
% Assume two files represent recordings from the same subject under two
% experimental conditions.

load(files(1).name);
res_1 = TEpermtest; clear TEpermtest
load(files(2).name);
res_2 = TEpermtest;
cfgGSTAT.datatype = 'TE';
cfgGSTAT.fileidout   = [outputpath 'condstatssingleTE'];
TEgroup_conditionstatssingle(cfgGSTAT, res_1, res_2);
cfgGSTAT.datatype = 'MI';
cfgGSTAT.fileidout   = [outputpath 'condstatssingleMI'];
TEgroup_conditionstatssingle(cfgGSTAT, res_1, res_2);

%%
exit
