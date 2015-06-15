function [cfg, data] = simulate_no_info(n_trials, gamma)

% FUNCTION [CFG, DATA] = SIMULATE_NO_INFO(N_TRIALS, GAMM) Simulates a sine 
% wave X coupled to an AR process Y with linear coupling. Function takes
% the number of trials 'n_trials' and the coupling strength 'gamma' ([0;1])
% as input. Simulated data are returned in the fieldtrip raw data format;
% cfg contains simulation parameters.
%
% Version 3.31 by Patricia Wollstadt, Felix Siebenhuehner, Michael Wibral, 
% Raul Vicente, Michael Lindner Frankfurt 2015

%Code was taken from AR_coupling2.m (Felix' generation method).


%% set parameters, taken from timing paper and Felix' code

order    = 2;                       % AR order
nSamples = 1000;                    % samples per trial
cutoff   = 1500;                    % this is later thrown away
%eta_x    = 0.1;                     % strength of the innovation term for the AR process in x
eta_x    = 0;                     % strength of the innovation term for the AR process in x
eta_y    = 0.1;                     % strength of the innovation term for the AR process in y

theta_x  = 0.1;                     % strength of the noise signal added to x
theta_y  = 0.1;                     % strength of the noise signal added to y

%gamma    = 1;                       % coupling strength
%n_trials = 150;                     % number of trials

fsample  = 1000;                    % samples per second                         
dt       = 7;                       % coupling delay in samples
%n_trials = 150;
phi_0    = 0.2;                     % relative size of AR parameters
time     = [1:nSamples]./fsample;   % time vector for data structure

ampl = 1;                           % amplitude of simulated sine wave
phase = 0.2;                        % phase shift in ms
sin_freq = 50;                      % frequency

% generate output structures, remember parameters for later
data     = [];
cfg          = [];
cfg.order    = order;
cfg.nSamples = nSamples;
cfg.eta_x    = eta_x;
cfg.eta_y    = eta_y;
cfg.theta_x  = theta_x;
cfg.theta_y  = theta_y;
cfg.gamma    = gamma;
cfg.fsample  = fsample;
cfg.dt       = dt;
cfg.phi_0    = phi_0;
cfg.ampl     = ampl;
cfg.phase    = phase;
cfg.sin_freq = sin_freq;


for trial = 1:n_trials
    
    %% generation of start values and parameters -  Felix' mode of AR simulation

    goon = true;
    
    while goon==true
        
        %%%% generate random start values and parameters
        
        x(1:order) = randn(1,order);
        y(1:order) = randn(1,order);
        par_x      = phi_0*(rand(1,order)-0.5);  % generate random parameters for x
        par_y      = phi_0*(rand(1,order)-0.5);  % generate random parameters for y
        
        %%%% check if stationary
        
        coef_x(1)=1;
        coef_y(1)=1;
        coef_x(2:order+1)=par_x;
        coef_y(2:order+1)=par_y;
        
        roots_xy(1:order,1) = roots(coef_x);
        roots_xy(1:order,2) = roots(coef_y);
        
        abso(1:order,1) = abs(roots(coef_x));
        abso(1:order,2) = abs(roots(coef_y));
        
        
        if isempty(find(abso>=1,1))                             
            goon = false;
        else
            display('WS stationarity not fulfilled, generating new AR parameters')
        end
        
    end
    
    %% calculate x series
    x_time = [1:nSamples+cutoff]./fsample;
    x = ampl * sin(sin_freq * x_time + phase);
    x = x + eta_x*randn(1,nSamples + cutoff);
    %x2 = x.^2;         % this is optional and can be used to implement
                        % quadratic coupling
    %plot(x_time,x)
    %plot(time,x2)
    
    %% calculate y series           - Felix
    
    % initialize y time series as random noise
    y = eta_y*randn(1,nSamples + cutoff);
    
    % calculate y samples prior to coupling
    for a = (order+1) : dt        
        y(a) = y(a) + sum(par_y .* y(a-order:a-1));        
    end
    
    % calculate y samples after coupling, depending on method for coupling
    for a = (dt+1) : (nSamples+cutoff)
        y(a) = y(a) + sum(par_y .* y(a-order:a-1)) + gamma*x(a-dt);
    end    
    
    % cut off first 1500 samples from x and y series
    x(1:cutoff) = [];  
    y(1:cutoff) = [];                                     
    
    %% normalize and add noise     - Felix
    
    
    var_x = var(x);
    var_y = var(y);
    data.gamma = gamma;
    
    x = x./sqrt(var_x);             % normalize x series
    y = y./sqrt(var_y);             % normalize y series    
    
    % PW: apparently this is done twice? I checked this in the original code
    % and it seems that after one normailzation the variance is still not
    % truely 1 (floating point error?)
    
    var_x = var(x);
    var_y = var(y);
    x = x./sqrt(var_x);             % normalize x series
    y = y./sqrt(var_y);             % normalize y series

    
    
    %% append trial to data
    data.time{trial}  = time;
    data.trial{trial} = [x;y];
    
end

data.label    = {'X' 'Y'};
data.fsample = fsample;