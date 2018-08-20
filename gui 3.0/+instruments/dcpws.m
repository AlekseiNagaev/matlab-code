classdef dcpws < instruments.instr
    % DC power supply control
    %% Generator properties
    properties(Access = private)
        devs = {'E3647A'};
    end
    properties
        out;
    end
    methods
        %% Class creation
        function obj = dcpws(addr,name,out)
            obj = obj@instruments.instr(addr,name);
            if ~any(strcmp(obj.model,obj.devs))
                warning('dcpws:WrongModel','Instrument %d is probably not a supported power supply',obj.id);
            end
            obj.out = out;
        end    
        %% Class destruction
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    %% Measurement
    methods
        function set_volt(obj,v,p)
            obj.send(sprintf('VOLT %f',v));
            obj.send('OUTP ON');
            switch nargin 
                case 3
                    pause(p);
                case 2
                    pause(0.1);
            end
        end
        function set_outp(obj,i)
            switch nargin
                case 1
                    obj.send(['INST OUTP',num2str(obj.out)]);
                case 2
                    obj.send(['INST OUTP',num2str(i)]);
            end
        end
        function set_gate(obj,v,st,p)
            global gc
            if gc ~= 0
                obj.op;
                obj.set_outp;
                obj.send('VOLT?');
                v1 = obj.get('%f');
                if v ~= v1
                    n = abs(round((v-v1)/st));
                    for i = 1:n
                        obj.set_volt(v1+(v-v1)*i/n,0.05);
                    end
                    obj.set_volt(v,0);
                    fprintf('Vg = %f\n',v);
                end
                obj.cl;
                if v~= v1
                    pause(p);
                end
            end
        end
    end
end

