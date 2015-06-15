function plot_lorenz_2_systems

% FUNCTION PLOT_LORENZ_2_SYSTEMS Plots results from 'analyze_Lorenz_
% 2systems_CPU.m' or 'analyze_Lorenz_2systems_ensemblemethod.m'.
%
% Note that you may need to adjust the file paths in this example script to 
% run it on your computer.
%
% Version 3.31 by Patricia Wollstadt, Michael Wibral, Raul Vicente, 
% Michael Lindner Frankfurt 2015

%% set paths

addpath('../utils/')
setpath;

%% get data and results
outputpath = '~/Lorenz_2_results/';
cd(outputpath)
files = dir('*TGA_results_analyzed_GA.mat');
load(files(1).name);

load('~/TRENTOOL_exampledata/Lorenz_2_systems/lorenz_layout.mat');  % load layout file

%% plotting

cfgPLOT = [];

cfgPLOT.layout        = lay_Lorenz; 		% see fieldtrip's ft_prepare_layout.m
cfgPLOT.electrodes    = 'highlights';
cfgPLOT.statstype     = 1;   		% 1: corrected; 2:uncorrected; 3: 1-pval; 4:rawdistance
cfgPLOT.alpha         = 0.05;
cfgPLOT.arrowpos      = 1;
cfgPLOT.showlabels    = 'yes';
cfgPLOT.electrodes    = 'on';
cfgPLOT.hlmarker      = 'o';
cfgPLOT.hlcolor       = [0 0 0];
cfgPLOT.hlmarkersize  = 4;
cfgPLOT.arrowcolorpos = [0 0.5 0.8];
cfgPLOT.plothead      = 0;

figure; 
TEplot2D(cfgPLOT,TGA_results_GA)