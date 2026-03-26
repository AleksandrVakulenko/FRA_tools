
% FIXME: need test

function [amp, phi, freq] = fft_plot(sig, fs, phi_limit)
arguments
    sig
    fs
    phi_limit = []
%     fig = []
end

figure('position', [522 281 631 666])
% if isempty(fig)
%     figure('position', [522 281 631 666])
% else
%     figure(fig)
% end

[N, ind] = min(size(sig));
if ind == 2
    sig = sig';
end

for i = 1:N
    % [amp, freq] = fft_calc(sig, fs);
    [amp, freq, phi, phi_limit] = fft_calc(sig(i, :), fs, phi_limit);

    subplot(2, 1, 1)
    hold on
    plot(freq, amp)
    set(gca, 'xscale', 'log')
    set(gca, 'yscale', 'log')
    xlabel('f, Hz')
    ylabel('amp')
    if ~isempty(phi_limit)
        yline(phi_limit)
    end

    subplot(2, 1, 2)
    hold on
    plot(freq, phi)
    set(gca, 'xscale', 'log')
    % set(gca, 'yscale', 'log')
    xlabel('f, Hz')
    ylabel('phi, [deg]')
end

subplot(2, 1, 1)
hold off
subplot(2, 1, 2)
hold off

if nargout == 0
    amp = [];
end

end

