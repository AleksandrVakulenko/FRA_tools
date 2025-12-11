
% FIXME: need refactor of functions struct

% TODO:
% 1) Add ability to get/set/delete data
% 2) Add ability to replace label
% 3) add() with autoset of x/y-lims
% 4) indexing lines
% 5) linear x scale if log does not need

classdef FRA_plot < handle

    properties (Access = private)
        fig
        axis_top
        axis_bot
        freq_list
        style
        ylabel_top
        ylabel_bot
        nonconst_freq_list
    end

    methods
        function obj = FRA_plot(freq_list, ylabel_top, ylabel_bot, style)
            arguments
                freq_list {mustBeNumeric(freq_list)} = []
                ylabel_top (1,1) string = "Amp, a.u."
                ylabel_bot (1,1) string = "Phase, °"
                style {mustBeMember(style, ["SI", "POW", "auto"])} = "auto"
            end
            if isempty(freq_list)
                freq_list = [1 10];
                obj.nonconst_freq_list = true;
            else
                obj.nonconst_freq_list = false;
            end
            

            obj.freq_list = freq_list;
            obj.style = style;
            obj.ylabel_top = ylabel_top;
            obj.ylabel_bot = ylabel_bot;

            obj.fig = figure('Position', [440 240 690 745], 'Resize', 'on');

            subplot('Position', [0.093    0.568    0.85    0.40])
            hold on
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_top, obj.style)

            subplot('Position', [0.093    0.086    0.85    0.40])
            hold on
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_bot, obj.style)

            ax_arr = obj.fig.Children;
            obj.axis_top = ax_arr(2);
            obj.axis_bot = ax_arr(1);

        end

        function clear_axis(obj)
            figure(obj.fig)
            axes(obj.axis_top)
            cla
            axes(obj.axis_bot)
            cla
        end

        function replace(obj, F_arr, A_arr, P_arr, line_color)
            arguments
                obj
                F_arr
                A_arr
                P_arr
                line_color = 'b';
            end
            if obj.nonconst_freq_list
                obj.freq_list = F_arr;
            end
            figure(obj.fig)
    
            LC = line_color;

            axes(obj.axis_top)
%             cla
            plot(F_arr, A_arr, ['.-' LC], 'MarkerSize', 8);
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_top, obj.style)

            axes(obj.axis_bot)
%             cla
            plot(F_arr, P_arr, ['.-' LC], 'MarkerSize', 8);
            FRA_plot_design(gca, obj.freq_list, obj.ylabel_bot, obj.style)

%             drawnow
        end

        function replace_FRA_data(obj, Dataset)
            obj.clear_axis;

            if numel(Dataset) == 1
                [F_arr, A_arr, P_arr] = Dataset.RPhi;
                obj.replace(F_arr, A_arr, P_arr);
            else
                color_array = 'brgykmcbrgykmc';
                freq_min = inf;
                freq_max = -inf;
                for i = 1:numel(Dataset)
                    Data = Dataset(i);
                    [F_arr, A_arr, P_arr] = Data.RPhi;
                    obj.replace(F_arr, A_arr, P_arr, color_array(i));
                    if min(F_arr) < freq_min
                        freq_min = min(F_arr);
                    end
                    if max(F_arr) > freq_max
                        freq_max = max(F_arr);
                    end
                end
                FRA_plot_design(obj.axis_top, [freq_min freq_max], ...
                    obj.ylabel_top, obj.style)
                FRA_plot_design(obj.axis_bot, [freq_min freq_max], ...
                    obj.ylabel_bot, obj.style)
            end

            drawnow
        end

    end

end





function FRA_plot_design(ax, freq_list, Ylable, Tick_style)
    arguments
        ax
        freq_list {mustBeNumeric(freq_list)}
        Ylable (1,1) string = ""
        Tick_style {mustBeMember(Tick_style, ["SI", "POW", "auto"])} = "auto"
    end
    
    xlabel('f, Hz')
    set(ax, 'xgrid', 'on')
    set(ax, 'xscale', 'log')
    x_lim_freq(ax, freq_list);
    Plotlib.expand_axis(ax, "x", "By_lim");
    Plotlib.log_scale_ticks("x",Tick_style , ax)
    
    if Ylable ~= ""
        ylabel(Ylable)
    end
    set(ax, 'box', 'on')
    set(ax, 'ygrid', 'on')
    [need_y_log, Limits] = check_y_values(ax);
    if need_y_log
        set(ax, 'ylim', Limits);
        set(ax, 'yscale', 'log')
        Plotlib.expand_axis(ax, "y");
        Plotlib.log_scale_ticks("y", Tick_style, ax)
    else
        Plotlib.expand_axis(ax, "y");
    end
    
end
    
    

function x_lim_freq(ax, freq_list)
    Min = min(freq_list);
    Max = max(freq_list);
    if Min == Max
        Min = Min*0.95;
        Max = Max*1.05;
    end
    set(ax, 'xlim', [Min*1 Max*1]);
end



function [need_log, Limits] = check_y_values(ax_frame)
    
    [Span, Limits] = Plotlib.find_limits(ax_frame, 'y');
    
    if isempty(Span)
        need_log = false;
        Limits = [0 1];
        return;
    end
    Min = Limits(1);
    Max = Limits(2);
    
    if (Min == Max) || (Min < 0)
        need_log = false;
    else
        Scale = log10(Max/Min);
        if Scale > 2
            need_log = true;
        else
            need_log = false;
        end
    end
end



