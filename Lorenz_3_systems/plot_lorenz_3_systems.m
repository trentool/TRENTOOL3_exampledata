function plot_lorenz_3_systems(outputpath)

% PLOT_LORENZ_3_SYSTEMS Example script for plotting the results from 
% TRENTOOL TE analysis of simulated data from three coupled Lorenz systems 
% (see script 'analyze_lorenz_3_systems.m'):
%
%           1 ------> 2 ------> 3
% Delta:       20ms      20ms
%
% NeFF/FIAS Software course on Neural Information Dynamics with TRENTOOL,
% the Java Information Dynamics Toolkit and MuTE
% December 10-11th, 2014
%
% The functions plots results from TE estimation as well as results after
% correction for multivariate effects by 'TEgraphanalysis.m'.
%
% OUTPUTPATH is a string that contains the path to a folder, where 
%	     TRENTOOL saved results from previous example analysis using
%	     analyze_lorenz_3_systems.m
%
% patricia.wollstadt@gmx.de

%% get data and results
load('lorenz_3_layout.mat');  % load layout file

cd(outputpath)
files = dir(fullfile(outputpath, 'Lorenzdata_3*TGA_results_GA.mat'));
load(fullfile(outputpath, files(1).name));

%% cfg structure for plotting

cfgPLOT = [];

cfgPLOT.layout        = lay_Lorenz;   	% layout structure, see fieldtrip's ft_prepare_layout.m

cfgPLOT.statstype     = 1;              % 1: corrected; 2:uncorrected; 3: 1-pval; 4:rawdistance; 5:graph analysis
cfgPLOT.alpha         = 0.05;
cfgPLOT.arrowpos      = 2;              % plot arrowheads in the middle
cfgPLOT.arrowcolorpos = [0 0.5 0.8];    % arrow color

cfgPLOT.electrodes    = 'on';           % plot markers for nodes
cfgPLOT.hlmarker      = 'o';            % maker type
cfgPLOT.hlcolor       = [0 0 0];        % marker color
cfgPLOT.hlmarkersize  = 4;              % maerker size

cfgPLOT.showlabels    = 'yes';          % node labels
cfgPLOT.efontsize     = 20;             % text size for node labels

cfgPLOT.plothead      = 0;

%% plot TE results

figure;
TEplot2D(cfgPLOT,TGA_results);

%% plot TE results after correction for multivariate effects

cfgPLOT.arrowcolor   = [0 0.5 0.8];
cfgPLOT.plottype     = 'graphanalysis';
cfgPLOT.statstype    = 'corrected';
cfgPLOT.linktype     = 'graphres';
cfgPLOT.head         = 'off';
cfgPLOT.electrodes   = 'labels';

figure;
TEplot2D_beta(cfgPLOT,TGA_results_GA);