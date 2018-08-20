classdef nicAQT
    %	NI devices class
    %   Made for NI-6251 USB
    properties %-- Device --
        dev;
    end
    properties %-- Session --
        ses;
    end
    properties %-- Channel --
        ch;
        ch_id = 'ai2';
        ch_type = 'Voltage';
        ch2;
    end
    properties %-- Events --
        ev;
        lh;
    end
    properties
        offs;
    end
    
    methods % Class creation/destruction
        function obj = nicAQT(dev)
            d = daq.getDevices;
            x = {d.Model};
            c = regexp(x,dev);
            if ~isempty(c)
                k = find(~cellfun(@isempty,c));
                obj.dev = d(k);
                obj.ses = daq.createSession('ni');
            else
                ME = MException('ni:WrongModel',['Instrument ',obj.dev,' is not found']);
                throwAsCaller(ME);
            end
        end
    end
    
    methods
        function stop(obj)
            stop(obj.ses);
        end        
    end
end

