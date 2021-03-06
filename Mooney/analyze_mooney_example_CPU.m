function analyze_mooney_example_CPU(outputpath)

% FUNCTION ANALYZE_MOONEY_EXAMPLE_CPU(OUTPUTPATH) Example transfer entropy 
% (TE) analysis of three data sets obtained in a face recognition task 
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
% Results may be plotted using the function 'plot_mooney_example.m' in this
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
load('mooney_channel_labels.mat');
files = {
    'Mooney_ex_1_Up_VirCh_RawData_10to140Hz'
    'Mooney_ex_2_Up_VirCh_RawData_10to140Hz'
    'Mooney_ex_3_Up_VirCh_RawData_10to140Hz'
    };
load(files{1});

%% define cfg for TEprepare.m

cfgTEP = [];

cfgTEP.toi                 = [0 max(VChannelDataOut.time{1,1})]; % time of interest: stimulus onset until end of trial
cfgTEP.sgncmb             = { ...                                % channel combinations to be analyzed (V1 to all sources)
    channel_labels{12} channel_labels{1};
    channel_labels{12} channel_labels{2};
    channel_labels{12} channel_labels{3};
    channel_labels{12} channel_labels{4};
    channel_labels{12} channel_labels{5};
    channel_labels{12} channel_labels{6};
    channel_labels{12} channel_labels{7};
    channel_labels{12} channel_labels{8};
    channel_labels{12} channel_labels{9};
    channel_labels{12} channel_labels{10};
    channel_labels{12} channel_labels{11};    
    channel_labels{12} channel_labels{13};
    channel_labels{12} channel_labels{14}
    };

% scanning of interaction delays u
cfgTEP.predicttimemin_u    = 3;       % minimum delay u to be scanned
cfgTEP.predicttimemax_u    = 17;	  % maximum delay u to be scanned
cfgTEP.predicttimestepsize = 2; 	  % time steps between u's to be scanned

% estimator
cfgTEP.TEcalctype  = 'VW_ds';         % use the new TE estimator (Wibral, 2013)

% ACT estimation and constraints on allowed ACT(autocorelation time)
cfgTEP.actthrvalue = 60;   % threshold for ACT -> data were filtered at 10 Hz with fs 600 Hz
cfgTEP.maxlag      = 100;  % maximum lag for ACT calculation
cfgTEP.minnrtrials = 15;   % minimum acceptable number of trials

% embedding optimization
cfgTEP.optimizemethod ='ragwitz';  % criterion used
cfgTEP.ragdim         = 2:9;       % criterion dimension
cfgTEP.ragtaurange    = [0.2 0.4]; % range for tau
cfgTEP.ragtausteps    = 5;         % steps for ragwitz tau steps
cfgTEP.repPred        = 100;       % points used for embedding optimization
cfgTEP.flagNei        = 'Mass' ;   % neighbour search type used by Ragwitz criterion
cfgTEP.sizeNei        = 4;         % number of neighbours used

% extra conditioning to handle instantaneous mixing
cfgTEP.extracond = 'Faes_Method';

% set the level of verbosity of console outputs
cfgTEP.verbosity = 'info_minor';

%% define cfg for TEsurrogatestats_ensemble.m

cfgTESS = [];

% use individual dimensions for embedding
cfgTESS.optdimusage = 'indivdim';

% statistical testing and shift testing
cfgTESS.tail           = 1;
cfgTESS.numpermutation = 5e4;
cfgTESS.surrogatetype  = 'trialshuffling';
cfgTESS.shifttest      = 'no';      % we don't need this bc of the extra conditioning

%% TE estimation for each subject

for subj = 1:length(files)
    
    % load data
    load(files{subj});

    % results file name
    cfgTESS.fileidout  = fullfile(outputpath, files{subj}(1:11));
    
    % call TE estimation
    tic;
    TGA_results = InteractionDelayReconstruction_calculate(cfgTEP,cfgTESS,VChannelDataOut);
    t = toc;
    
    % save final results
    save([cfgTESS.fileidout '_TGA_results.mat'], 'TGA_results', 't');
end


