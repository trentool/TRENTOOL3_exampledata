function analyze_no_info(outputpath)

% FUNCTION ANALYZE_NO_INFO(OUTPUTPATH) Analyzes a toy example with two 
% coupled systems X and Y. X is a 50 Hz sine wave with amplitude 1 
% fixed phase shift of 0.2 ms. Y is an autoregressive process of order
% 2. X is linearly coupled to Y with a delay of 7 ms and a variable
% coupling strength gamma. 
%
% This function analyzes data with a coupling of 0.5 and with no noise
% added to the source time series X. The folder further contains example
% data sets with a coupling of 0.75 and with random noise added to the
% source time series X (change the file name in lines 31-32 to analyze a
% different data set).
%
% Data were sampled at 1000 Hz (100 trials). For more information see the
% cfg structure for each simulated data set and the script 
% 'simulate_no_info.m' in this folder.
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
filename = 'no_info_zero_noise_gamma=0.5.mat';
load(filename);

%% define cfg for TEprepare.m

cfgTEP = [];

% data
cfgTEP.toi                 = [0 max(data.time{1,1})]; % time of interest is the whole trial
cfgTEP.channel             = data.label;  % channels to be analyzed

% scanning of interaction delays u
cfgTEP.predicttimemin_u    = 1;      % minimum u to be scanned
cfgTEP.predicttimemax_u    = 10;	  % maximum u to be scanned
cfgTEP.predicttimestepsize = 1; 	  % time steps between u's to be scanned

% estimator
cfgTEP.TEcalctype  = 'VW_ds'; % use the new TE estimator (Wibral, 2013)

% ACT estimation and constraints on allowed ACT(autocorelation time)
cfgTEP.actthrvalue = 100;  % threshold for ACT
cfgTEP.maxlag      = 100;
cfgTEP.minnrtrials = 15;   % minimum acceptable number of trials

% optimizing embedding
cfgTEP.optimizemethod ='ragwitz';  % criterion used
cfgTEP.ragdim         = 1:5;       % criterion dimension
cfgTEP.ragtaurange    = [0.2 0.4]; % range for tau
cfgTEP.ragtausteps    = 5;         % steps for ragwitz tau steps
cfgTEP.repPred        = 100;       % points used for embedding optimization
cfgTEP.flagNei        = 'Mass' ;   % neighbour search type used by Ragwitz criterion
cfgTEP.sizeNei        = 4;         % number of neighbours used

% extra conditioning to handle instantaneous mixing
cfgTEP.extracond = 'Faes_Method';

%% define cfg for TEsurrogatestats_ensemble.m

cfgTESS = [];

% use individual dimensions for embedding
cfgTESS.optdimusage = 'indivdim';

% statistical and shift testing
cfgTESS.tail           = 1;
cfgTESS.numpermutation = 5e4;
cfgTESS.surrogatetype  = 'trialshuffling';
cfgTESS.shifttest      = 'no';      % we don't need this bc of the extra conditioning

% results file name
cfgTESS.fileidout  = fullfile(outputpath,filename(1:end-4));

%% calculation - scan over specified values for u

tic;
TGA_results = InteractionDelayReconstruction_calculate(cfgTEP,cfgTESS,data);
t = toc;

% save final results
save([cfgTESS.fileidout '_TGA_results.mat'], 'TGA_results', 't');

