
% FIXME: need test

function [Amp, freq, Phi, phi_limit] = fft_calc(x, fs, phi_limit)
arguments
    x
    fs
    phi_limit = [];
end

L = numel(x);
if mod(L, 2) == 1
    L = L - 1;
    x(end) = [];
end
Y = fft(x);
P2 = abs(Y/L);
P1 = P2(1:L/2+1); % FIXME: round?
P1(2:end-1) = 2*P1(2:end-1);
freq = fs*(0:(L/2))/L;
Amp = P1;

if ~isempty(phi_limit)
    range = abs(Amp) < phi_limit;
    Y(range) = 0;
end

Phi = angle((Y*1i))/pi*180;
Phi = Phi(1:L/2+1);

end