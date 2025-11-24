function [freq_list, min_time] = freq_list_gen(Freq_min, Freq_max, ...
    Freq_num, Freq_permutation)
arguments
Freq_min double {mustBeGreaterThan(Freq_min, 0)}
Freq_max double {mustBeGreaterThan(Freq_max, 0)}
Freq_num double {mustBeGreaterThan(Freq_num, 0)}
Freq_permutation logical = false
% options.Freq_permutation ...
%     {mustBeMember(options.Freq_permutation, "on", "off")} = "off"
end

freq_list = 10.^linspace(log10(Freq_min), log10(Freq_max), Freq_num);
freq_list = flip(freq_list);
periods = 1./freq_list;
min_time = sum(periods);

% if options.Freq_permutation
if Freq_permutation
    freq_list = freq_list(randperm(length(freq_list)));
end

end