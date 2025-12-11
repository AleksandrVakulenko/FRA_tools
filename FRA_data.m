
% TODO:
% 1) Add unit comment for auto plot decoration
% 2) Add function for same code from operators
% 3) 


classdef FRA_data < handle
    properties
        unit
        freq = []
        X = []
        Y = []
    end

    methods (Access = public)
        function obj = FRA_data(unit, freq, data)
            arguments
                unit {mustBeTextScalar};
                freq {mustBeNumeric(freq), mustBeGreaterThan(freq, 0)} = []
                data.R {mustBeNumeric(data.R)} = []
                data.Phi {mustBeNumeric(data.Phi)} = []
                data.X {mustBeNumeric(data.X)} = []
                data.Y {mustBeNumeric(data.Y)} = []
            end
            obj.unit = unit;
            if ~isempty(freq)
                obj.add(freq, 'R', data.R, 'Phi', data.Phi, ...
                    'X', data.X, 'Y', data.Y);
            end
        end

        function add(obj, freq, data)
            arguments
                obj
                freq {mustBeNumeric(freq), mustBeGreaterThan(freq, 0), ...
                    mustBeVector(freq)} = []
                data.R {mustBeNumeric(data.R)} = []
                data.Phi {mustBeNumeric(data.Phi)} = []
                data.X {mustBeNumeric(data.X)} = []
                data.Y {mustBeNumeric(data.Y)} = []
            end
            if ~isempty(freq)
                obj.freq = [obj.freq freq];
                if ~isempty(data.R) && ~isempty(data.Phi)
                    data.X = data.R .* cosd(data.Phi);
                    data.Y = data.R .* sind(data.Phi);
                    obj.X = [obj.X data.X];
                    obj.Y = [obj.Y data.Y];
                elseif ~isempty(data.X) && ~isempty(data.Y)
                    obj.X = [obj.X data.X];
                    obj.Y = [obj.Y data.Y];
                else
                    error('wrong arguments')
                end
            end
            obj.sort_data();
        end

        function union(obj, fra_data)
            arguments
                obj
                fra_data FRA_data
            end
            [f, x, y] = fra_data.XY();
            obj.add(f, "X", x, "Y", y);
        end

        function [freq, X, Y] = XY(obj)
            freq = obj.freq;
            X = obj.X;
            Y = obj.Y;
        end

        function [freq, R, Phi] = RPhi(obj)
            freq = obj.freq;
%             disp('>>>>>>>>>>>>>>>')
%             obj.X
%             obj.Y
%             disp('<<<<<<<<<<<<<<<')
            R = sqrt(obj.X.^2 + obj.Y.^2);
            Phi = atan2(obj.Y, obj.X)*180/pi;
            Phi = FRA_utils.phase_shift_correction(Phi);
        end

        function Data_diff = correction(obj, corr_obj)
            BS = @(f) (1i*2*pi*f);
            Bode_cplx = @(num, den, f) (num(1) + num(2)*BS(f) + num(3)*BS(f).^2)./...
                (den(1) + den(2)*BS(f) + den(3)*BS(f).^2);
            Bode_real = @(num, den, f) real(Bode_cplx(num, den, f));
            Bode_imag = @(num, den, f) imag(Bode_cplx(num, den, f));
            Bode_abs = @(num, den, f) abs(Bode_cplx(num, den, f));
            Bode_phi = @(num, den, f) angle(Bode_cplx(num, den, f))*180/pi;
    
            F_arr = obj.freq;
            vout = get_corr_coeff();

            A_model = Bode_abs(vout(1:3), vout(4:6), F_arr);
            Phi_model = Bode_phi(vout(1:3), vout(4:6), F_arr);

            Data_model = FRA_data("", F_arr, 'R', A_model, 'Phi', Phi_model);
            Data_diff = obj/Data_model;
        end
    end


    methods (Access = public)
        function obj = mrdivide(obj1, obj2)
            if numel(obj1.freq) == numel(obj2.freq)
                if ~array_cmp(obj1.freq, obj2.freq)
                    error("both freq list must be the same")
                end
            else
                error("both freq list must be the same")
            end
            if ~unit_cmp(obj1.unit, obj2.unit)
                % FIXME: do we need to cmp units?
                % error("both unit values must be the same")
            end
            [~, R1, Phi1] = obj1.RPhi;
            [~, R2, Phi2] = obj2.RPhi;
            R_new = R1./R2;
            Phi_new = Phi1 - Phi2;
            obj = FRA_data(obj1.unit, obj1.freq, 'R', R_new, 'Phi', Phi_new);
        end

        function obj = mtimes(obj1, obj2)
            % FIXME: same code as it mrdivide
            if numel(obj1.freq) == numel(obj2.freq)
                if ~array_cmp(obj1.freq, obj2.freq)
                    error("both freq list must be the same")
                end
            else
                error("both freq list must be the same")
            end
            if ~unit_cmp(obj1.unit, obj2.unit)
                % FIXME: do we need to cmp units?
                % error("both unit values must be the same")
            end
            [~, R1, Phi1] = obj1.RPhi;
            [~, R2, Phi2] = obj2.RPhi;
            R_new = R1.*R2;
            Phi_new = Phi1 + Phi2;
            obj = FRA_data(obj1.unit, obj1.freq, 'R', R_new, 'Phi', Phi_new);
        end

        function obj = times(obj1, obj2)
            if numel(obj1) == 1 && numel(obj2) ~= 1
                % swap
                tmp = obj1;
                obj1 = obj2;
                obj2 = tmp;
            elseif numel(obj2) == 1
                % OK
            else
                error("Arrays have incompatible sizes for this operation.")
            end

            N = numel(obj1);
            for i = 1:N
                obj(i) = obj1(i)*obj2;
            end
        end

    end


    methods (Access = private)
        function sort_data(obj)
            [obj.freq, Perm] = sort(obj.freq);
            obj.X = obj.X(Perm);
            obj.Y = obj.Y(Perm);
        end

    end

end



function flag = array_cmp(A, B)
flag = numel(find(A == B)) == numel(A);
end

function flag = unit_cmp(A, B)
flag = string(A) == string(B);
end

function vout = get_corr_coeff()
% vout = [32.40916, ...
%     0.0014015070, ...
%     1.069670e-08,...
%     32.40860,...
%     0.010733275,...
%     7.169878e-07];

vout = [26.3353711788492	0.00153927003610697	1.06728073912233e-08, ...
    26.3358824379767	0.00913182894094471	7.00402262534529e-07];
end

