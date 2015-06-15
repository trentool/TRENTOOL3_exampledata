TRENTOOL - EXAMPLE DATA

This folder contains example data to demonstrate the basic use of the 
TRENTOOL toolbox. Every folder contains one or several data sets 
(.mat-files) together with an analysis script ('analyze_*.m'), a plotting 
script ('plot_*.m'), and a simulation script ('simulate_*.m') if 
applicable.

To run an examplescript, you have to download TRENTOOL3 and the FieldTrip
toolbox. Both toolboxes have to be added to yout MATLAB path (using 
'addpath'), you furthermore have to run 'ft_defaults'. To run an 
examplescript, navigate to the subfolder of 'TRENTOOL_exampledata' and
call the respective script as a function. Each script takes a variable
'outputfolder' as input, that specifies the path to where TRENTOOL should
save intermediate results. For example:

addpath('~/TRENTOOL3-master/')
addpath('~/fieldtrip-20150205/');
ft_defaults;
cd('~/TRENTOOL-exampledata/Lorenz_2_systems');
myOutputpath = '~/TRENTOOL_results/';
analyze_lorenz_2_systems_CPU(myOutputpath)
plot_lorenz_2_systems_CPU(myOutputpath)

Make sure you have created the respective output folder before you 
start an example analysis.

More information regarding individual examples can be found in the MATLAB
help of each script.

TRENTOOL Version 3.32 - Frankfurt, 2015