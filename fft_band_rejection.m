
% FIXME: need test
% FIXME: Remember about f = 0 on fft calc data

function Signal_filt = fft_band_rejection(Signal, Fs, ValueDB, Freq_min, Freq_max)
    if ~isempty(Freq_max) && Freq_min >= Freq_max
        Signal_filt = Signal;
    else
        if mod(numel(Signal), 2) == 1
            Signal(end) = [];
            append_point = true;
        else
            append_point = false;
        end

        L = numel(Signal);
        FFT_freq = Fs*(0:(L/2-1))/L;
        
        FFT = fft(Signal)/numel(Signal);
        FFT = fft_erase_zone(FFT, FFT_freq, ValueDB, Freq_min, Freq_max);
        
        FFT2 = flip(fft(FFT));
        
        FFT2(2:end+1) = FFT2;
        FFT2(1) = FFT2(2);
        FFT2(end) = [];
        
        Signal_filt = real(FFT2);
        if append_point
            Signal_filt(end+1) = Signal_filt(end);
        end
    end
end


function FFT = fft_erase_zone(FFT, FFT_freq, ValueDB, Freq_min, Freq_max)
arguments
    FFT
    FFT_freq
    ValueDB
    Freq_min
    Freq_max = []
end
    if isempty(Freq_max) || Freq_max == inf
        Freq_max = FFT_freq(end);
    end
    if Freq_max < 0 || Freq_min < 0
        error('f must be > 0')
    end
    [~, ind11] = min(abs(FFT_freq - Freq_min));
    if ind11 < 2
        ind11 = 2;
    end
    ind12 = 2 + numel(FFT) - ind11;

    [~, ind21] = min(abs(FFT_freq - Freq_max));
    if ind21 < 2
        ind21 = 2;
    end
    ind22 = 2 + numel(FFT) - ind21;

    FFT(ind11:ind21) = FFT(ind11:ind21)*10^(ValueDB/20);
    FFT(ind22:ind12) = FFT(ind22:ind12)*10^(ValueDB/20);

end
