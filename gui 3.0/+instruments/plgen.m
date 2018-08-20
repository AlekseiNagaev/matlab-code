classdef plgen < instruments.instr
    %Pulse generator class
    %   Detailed explanation goes here
    
    properties
        res;
        gg;
    end
    
    methods
        %% Class creation
        function obj = plgen(addr,name,res)
            obj = obj@instruments.instr(addr,name);
            if nargin == 3
                obj.res = res;
            end
        end
        %% Class destruction
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    
end

