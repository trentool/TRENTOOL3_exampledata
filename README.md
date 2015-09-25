# TRENTOOL3_exampledata

This repository contains example data to demonstrate the basic use of the [TRENTOOL toolbox](https://github.com/trentool/TRENTOOL3). Every folder contains one or several data sets (.mat-files) together with an analysis script (```analyze_*.m```), a plotting script (```plot_*.m```) and a simulation script (```simulate_*.m```) if applicable.

Prior to running an example analysis, you have to download TRENTOOL3 and the FieldTrip toolbox. Both toolboxes have to be added to your MATLAB path (using ```addpath```) and you have to run ```ft_defaults```. To run an example script, navigate to the subfolder of ```TRENTOOL_exampledata``` and call the respective script as a function. Each script takes a variable ```outputfolder``` as input, which specifies a path to which TRENTOOL will save intermediate results. For example:

```Matlab
addpath('~/TRENTOOL3-master/')
addpath('~/fieldtrip-20150205/');
ft_defaults;
cd('~/TRENTOOL-exampledata/Lorenz_2_systems');
myOutputpath = '~/TRENTOOL_results/';
analyze_lorenz_2_systems_CPU(myOutputpath)
plot_lorenz_2_systems_CPU(myOutputpath)
```

Make sure you have created the respective output folder before you 
start an example analysis.

More information regarding individual examples can be found in the MATLAB
help of each script.

TRENTOOL Version 3.32 - Frankfurt, 2015
