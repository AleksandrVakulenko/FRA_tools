
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

    Range_1 = ind11:ind21;
    Range_2 = ind22:ind12;

    ValueDB_1 = make_rej_arr(Range_1, ValueDB);
    ValueDB_2 = make_rej_arr(Range_2, ValueDB);

    FFT(Range_1) = FFT(Range_1).*10.^(ValueDB_1/20);
    FFT(Range_2) = FFT(Range_2).*10.^(ValueDB_2/20);

end



% FIXME: unused
function FFT = fft_erase_single_freq(FFT, FFT_freq, Freq_filt)
    [~, ind1] = min(abs(FFT_freq - Freq_filt));
    ind2 = 2 + numel(FFT) - ind1;
    FFT(ind1) = 0;
    FFT(ind2) = 0;
end


function Value_DB_arr = make_rej_arr(Range_1, ValueDB)
if ValueDB > 0
    ValueDB = 0;
end

N = numel(Range_1);
if N > 2
    X = 1:numel(Range_1);
    Value_DB_arr =  ValueDB + abs((X - mean(X))*ValueDB/mean(X));
else
    Value_DB_arr = ValueDB * ones(size(Range_1));
end

Min_v = min(Value_DB_arr);
if Min_v > ValueDB
Range = Value_DB_arr == Min_v;
Value_DB_arr(Range) = ValueDB;
end

end