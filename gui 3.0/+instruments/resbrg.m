classdef resbrg < instruments.instr
    % Resistance bridge 
    %   Detailed explanation goes here
    %% Properties
    properties
        ch = [0 1 2 3 4 5 6 7];
        exc = [5 5 5 5 0 0 0 0];
        ran = [];
        ave = 2;
        sdy = 10;
    end
    properties
        mode;
    end
    properties
        chn;
    end
    %% Temperature conversion coefficients
    properties (Constant)
        A = 0.9471;
        B = 6.653;
    end
    methods 
        %% Class creation
        function obj = resbrg(addr,name)
            obj = obj@instruments.instr(addr,name);
        end
        %% Class destruction
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    %%
    methods
        function rmt_on(obj)
            fprintf(obj.func,'REM 1');
        end
        function set_inp(obj,n)
            fprintf(obj.func,'INP %d',n);
        end
        function srq = spol(obj)
            [~,srq]=spoll(obj.func);
            srq = bitand(srq,15);
        end
        function ready(obj)
            srq = obj.spol;
            while srq ~=0
                srq = obj.spol;
                pause(1);
            end
        end
        function rmt_off(obj)
            fprintf(obj.func,'REM 0');
        end
        function brg_check(obj)
            obj.op;
            obj.cl;
        end
        function brg_set(obj,chn,rng,exc)
            if nargin==0
                chn=4; 
                rng=4; 
                exc=2; 
            end
            if isempty(find(chn==0:7,1)) || (nargin>2 && isempty(find(rng==0:7,1))) || (nargin>3 && isempty(find(exc==0:7,1)))
                disp('Warning: invalid parameter. Configuration not changed.');
                return;
            end
            [chn0,rng0,exc0] = obj.brg_get;
            if nargin<4
                exc=exc0; 
                if nargin<3
                    rng=rng0;
                end
            end
            conf=''; %configuration string
            if chn~=chn0 
                conf=[conf 'CH' num2str(chn) ';'];
            end
            if rng~=rng0
                conf=[conf 'RAN' num2str(rng) ';']; 
            end
            if exc~=exc0
                conf=[conf 'EXC' num2str(exc) ';'];
            end
            if ~isempty(conf)
                obj.op;
                obj.send(conf);
                obj.cl;
            end
        end
        function [chn,rng,exc] = brg_get(obj)
            obj.op;
            obj.send('CH?;RAN?;EXC?'); 
            s = obj.get('%s');
            chn = str2double(s(1));
            rng = str2double(s(3)); 
            exc = str2double(s(5));
            obj.cl;
        end
        function brg_set_0(obj)
            obj.op;
            obj.send('CH?');
            s = obj.get('%s');
            obj.send('REFID0;CH0');
            obj.cl;
        end
        function [R,T] = brg_read(obj,avg)
            %% Get resistance from picobridge
            switch obj.mode
                case 1
                    if nargin<2
                        avg=1;
                    end 
                    %by default, measure only once
                    avg = max(1,round(avg));%make sure that avg is a positive integer
                    try %communication commands are inside a try&catch loop to prevent errors from crashing the measurement program
                        obj.op; %connect and open
                        str = sprintf('RES %d;RES?',avg);
                        obj.send(str);
                        pause(.2*avg); %wait for the averaging to finish
                        R = obj.get('%f'); %read resistance value
                        obj.cl;
                        T = tech.res2tem(R);
                    catch ME%if there was a problem
                        if numel(dbstack)<2 
                            disp(['Warning: reading resistance bridge at serial port ' obj.addr ' failed.']);
                            rethrow(ME);
                        end %display warning unless the function was called by a script
                        R=0; %return zero value
                    end
                case 0
                    R = 0;
                    T = 0;
            end
        end
    end
    %%
    methods %AVS-47   
        function [r,T] = meas(obj,n)
            op(obj);
            fprintf(obj.func,'*ESE 1;*SRE 32');
            pause(0.5);
            fprintf(obj.func,'*CLS; HDR 0;ADC;RES?;*OPC');
            pause(0.5);
            r = fscanf(obj.func,'%f');
            if r < 1050
                r1 = r - 33.8;
            elseif r < 1500
                r1 = r - 40.5;
            else
                r1 = r - 48.7;
            end
            T = (obj.A/(log(r1)-obj.B))^4;
            x = datestr(now,'HH,MM');
            fprintf('%s|RES %i = %.1f -> T = %f\n',x,n,r,T);
            cl(obj);
        end
    end 
end

