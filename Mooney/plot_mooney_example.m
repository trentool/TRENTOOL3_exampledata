function plot_mooney_example(outputpath)

% FUNCTION PLOT_MOONEY_EXAMPLE(OUTPUTPATH) Plots results from 
% 'analyze_mooney_example_CPU.m' and conducts a binomial test for the 
% results.
%
% Note that you may need to adjust the file paths in this example script to 
% run it on your computer.
%
% OUTPUTPATH is a string that contains the path to a folder, where 
%	     TRENTOOL saved results from previous analyses using
%	     analyze_mooney_example_CPU.m
%
% Version 3.31 by Patricia Wollstadt, Michael Wibral, Raul Vicente, 
% Michael Lindner Frankfurt 2015

%% get data and results

files = dir(fullfile(outputpath, 'Mooney*TGA_results.mat'));
load(fullfile(outputpath, files(1).name));

%% plot results

for subj=1:length(files)
    
    % load results
    load([outputpath files(subj).name]);    
    id = files(subj).name(1:11);
    
    % change labels from virtual channels to anatomical labels
    load('mooney_2D_layout.mat');      % layout file
    [TGA_results,lay] = change_labels(TGA_results,lay);
    
    
    cfgPLOT = [];    
    cfgPLOT.layout        = lay; 		
    cfgPLOT.electrodes    = 'highlights';
    cfgPLOT.statstype     = 2;   		% 1: corrected; 2:uncorrected; 3: 1-pval; 4:rawdistance
    cfgPLOT.alpha         = 0.05;
    cfgPLOT.arrowpos      = 1;
    cfgPLOT.showlabels    = 'yes';
    cfgPLOT.electrodes    = 'on';
    cfgPLOT.hlmarker      = 'o';
    cfgPLOT.hlcolor       = [0 0 0];
    cfgPLOT.hlmarkersize  = 4;
    cfgPLOT.arrowcolorpos = [1 0 0];
    
    % plot and save figure
    figure('name',id);
    TEplot2D(cfgPLOT,TGA_results)
    saveas(gcf,[outputpath id '.fig']);
    saveas(gcf,[outputpath id '.eps'],'epsc');

end

%% conduct a binomial test on results and plot output

% create a cell array of file names
load('mooney_2D_layout.mat');      % layout file
cd(outputpath);
filenames = {files(:).name};
binomstats = TEsurrogate_binomstats([],filenames);
[binomstats,lay] = change_labels(binomstats,lay);

% plot results from binomial testing
cfgPLOT.plottype   = 'binomstats';
cfgPLOT.statstype  = 'corrected';
cfgPLOT.linktype   = 'noccur';           % arrow color indicates number of occurences
cfgPLOT.electrodes = 'labels';
figure;
TEplot2D_beta(cfgPLOT, binomstats)

end

function [data,lay] = change_labels(data,lay)

% FUNCTION CHANGE_LABELS change labels from virtual channel numbers to
% anatomical labels for plotting
        
        load ~/TRENTOOL_exampledata/Mooney/mooney_source_labels.mat;
        
        n_ch = size(data.sgncmb,1);
        
        for i=1:n_ch
            
            data.sgncmb{i,1} = voxel2label{strcmp(voxel2label(:,2), data.sgncmb{i,1}(16:19)),1};
            data.sgncmb{i,2} = voxel2label{strcmp(voxel2label(:,2), data.sgncmb{i,2}(16:19)),1};
            
        end
        
        n_la = size(lay.label,1) - 2;
        
        for i=1:n_la
            
            lay.label{i} = voxel2label{strcmp(voxel2label(:,2), lay.label{i}(16:19)),1};
        end
        
    end