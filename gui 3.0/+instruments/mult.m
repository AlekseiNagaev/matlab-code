classdef mult < instruments.instr
    % Multimeters control
    properties (Constant)
        res = [1e-5,1e-7,3e-8]*10;
        range = [1e-1,1,10]
        devs = {'34401A','MODEL2450'};
    end
    properties % General
        num = 1;
    end
    methods % Class creation/destruction
        function obj = mult(addr,name,num)
             obj = obj@instruments.instr(addr,name);
             if nargin == 3
                obj.num = num;
             else 
                 obj.num = 1;
             end
             if ~any(strcmp(obj.model,obj.devs))
                warning('mult:WrongModel','Instrument %d is probably not a supported multimeter',v.id);
            end
        end
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    methods %Shortcuts
        function zer(obj)
             obj.send('CALC:FUNC NULL');
             obj.send('CALC:STAT ON');
         end
        function math_off(obj)
             obj.send('CALC:STAT OFF');
        end
        function set_dc_range(obj,rng)
            obj.send(sprintf('VOLT:DC:RANGe %f',rng));
        end
    end
    methods
        function rng = q_dc_range(obj)
            obj.send('VOLT:DC:RANGe?');
            rng = obj.get('%d');
        end
    end
    methods % Measurements
        function set_vm(obj,n)
            obj.set_dc_range(1);
            pause(0.5);
            switch n
                case 4
                    obj.send(sprintf('VOLT:DC:RES %.5f',obj.res(1)));
                    obj.send('VOLT:DC:NPLC 0.2');
                case 5
                    obj.send(sprintf('VOLT:DC:RES %.7f',obj.res(2)));
                    obj.send('VOLT:DC:NPLC 1');
                case 6
                    obj.send(sprintf('VOLT:DC:RES %.8f',obj.res(3)));
                    obj.send('VOLT:DC:NPLC 10');
                otherwise
                    obj.send(sprintf('VOLT:DC:RES %.7f',obj.res(2)));
                    obj.send('VOLT:DC:NPLC 10');
            end
            pause(0.5);
            obj.send('ZERO:AUTO OFF');
            obj.send('TRIG:SOUR IMM');
        end
        function v = read_vm(obj)
            obj.send('INIT');
            obj.send('FETCH?');
            v = obj.get('%f');
        end
        function [v0,fl] = meas_av(obj,q,fl)
            v0 = 0;
            for k = 1:obj.num
                v = obj.read_vm;
                v0=v0+v;
            end
            v0=v0/(obj.num);
            if (((abs(v0) > 1) && ((q == 1)||(q == 3)))||((abs(v0) < 1) && ((q == 2)||(q == 4)))) && (fl == q)
                switch q
                    case 1
                        fl = 2;
                        obj.set_dc_range(10);
                    case 2
                        fl = 3;
                        obj.set_dc_range(1);
                    case 3
                        fl = 4;
                        obj.set_dc_range(10);
                    case 4
                        fl = 1;
                        obj.set_dc_range(1);
                end
            pause(1);
            end
        end
    end
end

