function P_arr = phase_shift_correction(P_arr)
D_P_Arr = diff(P_arr);
range_p = D_P_Arr > 180;
range_n = D_P_Arr < -180;

range_p = [false range_p];
range_n = [false range_n];

Phase_shift_array = zeros(size(P_arr));
Phase_shift = 0;
for i = 1:numel(range_p)
    if range_p(i)
        Phase_shift = Phase_shift - 360;
    end
    if range_n(i)
        Phase_shift = Phase_shift + 360;
    end
    Phase_shift_array(i) = Phase_shift;
end

P_arr = P_arr + Phase_shift_array;
end