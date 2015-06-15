function plot_no_info

% FUNCTION PLOT_NO_INFO Plots raw time series for simulated data (see
% script 'simulate_no_info.m').
%
% Note that you may need to adjust the file paths in this example script to 
% run it on your computer.
%
% Version 3.31 by Patricia Wollstadt, Michael Wibral, Raul Vicente, 
% Michael Lindner Frankfurt 2015


%% get data 

cd('~/TRENTOOL_exampledata/No_info/');
files = dir('no_info*');

%% plot

for i=1:length(files)
    load(files(i).name)
    figure
    hold on
    plot(data.trial{1}(2,:),'LineWidth',2);
    plot(data.trial{1}(1,:),'r','LineWidth',2);
    title(strrep(files(i).name(1:end-4), '_', ' '))
    legend('Y - AR process','X - sine wave')
    xlabel('t [ms]');
end