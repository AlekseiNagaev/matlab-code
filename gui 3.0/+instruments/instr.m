classdef instr
    %	Instrument superclass
    %   Detailed explanation goes here
    %% Instrument properties
    properties
        addr;
        func;
        tag;
        model;                   
    end
    methods
        %% Class constructor
        function obj = instr(addr,tag)
            if regexp(addr,'\d+[.]\d+[.]\d+[.]\d+')
                obj.addr = addr;
                obj.func = visa('ni',['TCPIP::',obj.addr,'::INSTR']);
            elseif regexp(addr,'[COM]\d')
                obj.addr = addr;
                obj.func = serial(obj.addr);
            else
                obj.addr = str2double(addr);
                obj.func = gpib('ni',0,obj.addr);
            end
            if ~isa(obj,'instruments.resbrg')
                obj.model = obj.dev;
            else
                obj.model = 'AVS';
            end
            switch nargin
                case 1
                    obj.tag = obj.model;
                otherwise
                    obj.tag = tag;
            end
        end
        %% Class destructor
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    %% Class methods
    methods
        function send(obj,s)
            fprintf(obj.func,s);
        end
        function x = get(obj,f)
            x = fscanf(obj.func,f);
        end
        function op(obj)
            try
                fopen(obj.func);
            catch ME
                switch ME.message
                    case 'Open failed: OBJ has already been opened.'
                    case 'Unsuccessful open: OBJ has already been opened.'
                    otherwise
                        rethrow(ME);
                end
            end
        end
        function cl(obj)
            fclose(obj.func);
        end
        function rst(obj)
            obj.send('*RST');
        end
        function m = err(obj)
            obj.send('SYST:ERR?');
            s = obj.get('%s');
            m = [obj.model,' ',s];
            warning('instr:err',[m,'\n']);
        end
        function model = dev(obj)
            obj.op;
            obj.send('*IDN?');
            s = obj.get('%s');
            obj.cl;
            v = textscan(s,'%*s %s %*s %*s','Delimiter',',');
            model = v{1}{1};
        end
    end
end