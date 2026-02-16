function Data_out = interp_FRA_data(Data_in, Data_target)

[Freq_tg, ~, ~] = Data_target.RPhi();
[Freq_in, R_in, Phi_in] = Data_in.RPhi();

R_new = interp1(Freq_in, R_in, Freq_tg);
Phi_new = interp1(Freq_in, Phi_in, Freq_tg);

Data_out = FRA_data(Data_in.unit, Freq_tg, "R", R_new, "Phi", Phi_new);

end