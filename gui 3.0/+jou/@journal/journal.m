classdef journal
    % Measurement journal & temperature log
    %   Detailed explanation goes here 
    properties
        path;
        func;
    end
    properties
        exp ='(\d\d)[.](\d\d)[.](\d\d)';
    end
    methods % Class creation/destruction
        function obj = journal(name,ext)
            obj.path = [name,ext];
            obj.func = fopen(obj.path,'a+');
        end
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    methods
        s = add_dir(obj,sf)
        add_date(obj,s)
        x = add_meas(obj,s,q)
        add_com(obj,com,co)
        add_inf(obj)
        add_old_meas(obj)
        i = find_meas(obj,x,varargin)
        add_temp(obj,T);
        add_log_temp(obj,r,T)
    end
end