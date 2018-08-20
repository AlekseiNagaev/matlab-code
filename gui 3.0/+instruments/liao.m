classdef liao < instruments.instr
    % Lock-In Amplifier
    %   Detailed explanation goes here
    methods 
        %% Class creation
        function obj = liao(addr,name)
            obj = obj@instruments.instr(addr,name);
        end
        %% Class destruction
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    methods
        function [Vx,Vy,ang,R] = read_x_y(obj)
            obj.op;
            obj.send('X.');
            Vx = obj.get('%f');
            obj.send('Y.');
            Vy = obj.get('%f');
            R = sqrt(Vx*Vx+Vy*Vy);
            ang = atan2(Vy,Vx);
            obj.cl;
        end
    end
end

