function analyze_lorenz_3_systems

% FUNCTION ANALYZE_LORENZ_3_SYSTEMS Example TRENTOOL analysis script for 
% simulated data from three coupled Lorenz systems:
%
%           1 ------> 2 ------> 3
% Delta:       20ms      20ms
%
% This example was created for the NeFF/FIAS Software course on Neural 
% Information Dynamics with TRENTOOL, the Java Information Dynamics Toolkit 
% and MuTE December 10-11th, 2014
%
% The script estimated TE for all possible directions in the data. In a
% second step, an algorithmical correction for multivariate effects is
% performed on the output ('TEgraphanalysis.m').
%
% patricia.wollstadt@gmx.de


%% set paths to toolboxes

addpath('../utils/')
setpath;


%% load data

datapath = '~/TRENTOOL_exampledata/Lorenz_3_systems/';
outputpath = '~/Lorenz_3_results/';
load([datapath 'lorenz_1-2-3_delay_20_20_ms.mat']);


%% prepare configuration structure for TEprepare.m

cfgTEP = [];

% data
cfgTEP.toi     = [data.time{1}(1) data.time{1}(end)]; % time of interest
cfgTEP.channel = data.label;                          % channels to be analyzed

% ensemble methode
cfgTEP.ensemblemethod = 'no';

% scanning of interaction delays u
cfgTEP.predicttimemin_u    = 15;      % minimum u to be scanned
cfgTEP.predicttimemax_u    = 45;	  % maximum u to be scanned
cfgTEP.predicttimestepsize = 1; 	  % time steps between u's to be scanned

% estimator
cfgTEP.TEcalctype  = 'VW_ds';         % use the new TE estimator (Wibral, 2013)

% ACT estimation and constraints on allowed ACT(autocorelation time)
cfgTEP.maxlag      = 1000;  % max. lag for the calculation of the ACT
cfgTEP.actthrvalue = 100;   % threshold for ACT
cfgTEP.minnrtrials = 15;    % minimum acceptable number of trials

% optimizing embedding
cfgTEP.optimizemethod ='ragwitz';  % criterion used
cfgTEP.ragdim         = 2:9;       % dimensions d to be used
cfgTEP.ragtaurange    = [0.2 0.4]; % tau range to be used
cfgTEP.ragtausteps    = 3;         % steps for ragwitz tau
cfgTEP.repPred        = 100;       % no. local prediction/points used for the Ragwitz criterion

% kernel-based TE estimation
cfgTEP.flagNei = 'Mass' ;           % type of neigbour search (knn)
cfgTEP.sizeNei = 4;                 % number of neighbours in the mass/knn search


%% define cfg for TEsurrogatestats_ensemble.m

cfgTESS = [];

% use individual dimensions for embedding
cfgTESS.optdimusage = 'indivdim';
cfgTESS.embedsource = 'no';

% statistical testing
cfgTESS.tail           = 1;
cfgTESS.numpermutation = 5e4;
cfgTESS.surrogatetype  = 'trialshuffling';

% shift test
cfgTESS.shifttest      = 'no';      % don't test for volume conduction

% prefix for output data
cfgTESS.fileidout  = [outputpath, 'Lorenz_data_3'];


%% TE analysis 

TGA_results = InteractionDelayReconstruction_calculate(cfgTEP,cfgTESS,data);

%% correction 

cfgGA = [];

cfgGA.threshold = 4;    % use a threshold/error tolerance of 4 ms
cfgGA.cmc       = 1;    % use links after correction for multiple comparison

TGA_results_GA = TEgraphanalysis(cfgGA,TGA_results);
save([cfgTESS.fileidout '_CPU_TGA_results_GA.mat'],'TGA_results','TGA_results_GA');


