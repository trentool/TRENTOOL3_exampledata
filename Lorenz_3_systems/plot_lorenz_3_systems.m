function plot_lorenz_3_systems

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
% patricia.wollstadt@gmx.de

%% set paths

addpath('../utils/')
setpath;

%% load layout file and results

load('~/TRENTOOL_exampledata/Lorenz_3_systems/lorenz_3_layout.mat');
load('~/Lorenz_3_results/Lorenz_data_3_CPU_TGA_results_GA.mat');

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