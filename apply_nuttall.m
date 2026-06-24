
function [Signal_out, F_lim] = apply_nuttall(Signal, Fs, freq)
arguments
    Signal
    Fs
    freq = inf;
end
% Freq limit by number of points (For Nuttall window)
F_lim_window = Fs*(10.^(-1*log10(numel(Signal)) + 0.765)); % NOTE: read line 47

% FIXME: do not check here
if freq/F_lim_window > 1.5 % FIXME: magic constant
    Use_window = true;
else
    Use_window = false;
end

% Use_window = false;
% Use_window = true;

% disp(['Use window: ' num2str(Use_window)])
% disp(['Freq = ' num2str(freq) ' Hz'])
% disp(['F_lim = ' num2str(F_lim_window) ' Hz'])
% disp(['R = ' num2str(freq/F_lim_window)])
% disp(' ')

if Use_window
    F_lim = F_lim_window;
else
    F_lim = [];
end

if Use_window
    Window = nuttallwin(numel(Signal)); % Nuttall
    Win_scale = 2.7521;
    Signal_w = Signal.*Window'*Win_scale;
    Signal_out = Signal_w;
else
    Signal_out = Signal;
end

end



% FIXME: put TEST section to separate file

% %% some experimental data
% 
% pn = [
% 1000  
% 2000  
% 5000  
% 10000 
% 20000 
% 50000 
% 100000
% 200000
% ];
% 
% 
% F_lim = [
% 0.004883
% 0.002441
% 0.0008545
% 0.0004272
% 0.0002136
% 8.392e-5
% 4.196e-5
% 2.098e-5
% ];
% 
% 
% pn_log = log10(pn);
% F_lim_log = log10(F_lim);
% 
% plot(pn, F_lim)
% set(gca, 'xscale', 'log')
% set(gca, 'yscale', 'log')
% 
% 
% %% Number of points by freq limit (For Nuttall window)
% F_lim = 1; % [Hz]
% Fs = 10e3; % [1/s]
% pn = round(10.^(0.765 - log10(F_lim/Fs))) % [points]
% Dur = pn/Fs % [s]
% 
% %% Freq limit by number of points (For Nuttall window)
% 
% Fs = 10e3; % [1/s]
% F_lim = Fs*(10.^(-1*log10(pn) + 0.765))

