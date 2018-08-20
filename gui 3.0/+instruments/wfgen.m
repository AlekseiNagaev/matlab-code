classdef wfgen < instruments.instr
    % Waveform generators control
    %% Private properties
    properties (Access = private)
        %% Generator properties
        shp = {'SIN','SQU','RAMP','NRAMP','TRI','NOIS','PRBS','ARB'}
        r_ch = [0.3169 0.6319 1.259 2.519 5.019];%OUTP:LOAD INF
        devs = {'33120A','33509B','33522A'};
    end
    %% Public properties
    properties
        %% General
        res;
        sh = 'SQU';
        freq = 1e3;
        amp = 1;
        offs = 0;
        dcyc = 50;
        %% Pulse
        %--33120A--
        b_per = 1;
        b_ncyc = 1;
        b_phas = 0;
        %--33509B--
        pul_edge;
        pul_wid;
        pul_per;
        gg = 0;
    end
    %% Methods
    methods 
        %% Class creation
        function obj = wfgen(addr,name,res)
            obj = obj@instruments.instr(addr,name);
            if nargin == 3
                obj.res = res;
            end
            if strcmp(obj.model,obj.devs{1})
                obj.gg = 1;
            elseif strcmp(obj.model,obj.devs{2})||strcmp(obj.model,obj.devs{3})
                obj.gg = 2;
            end
            if obj.gg == 0
                warning('gen:WrongModel','Instrument %d is probably not a supported generator',obj.id);
            end
        end
        %% Class destruction
        function delete(obj)
            fclose(obj.func);
            delete(obj.func);
        end
    end
    methods
        function trg(obj,tc)
            if strcmp(tc,'y')
                obj.send('*TRG');
            end
        end
        %% General
        function set_sh(obj,s)
            switch obj.gg
                case 1
                    obj.send(sprintf('FUNC:SHAP %s',s));
                case 2
                    obj.send(sprintf('FUNC %s',s));
            end
        end
        function apply(obj,sh,freq,amp,offs)
            obj.send(sprintf('APPL:%s %f,%f,%f',sh,freq,amp,offs));
        end
        %% Basic parameters
        function set_dcycle(obj)
            switch obj.gg
                case 1
                    obj.send(sprintf('PULS:DCYC %d',obj.dcyc));
                case 2
                    obj.send(sprintf('FUNC:SQU:DCYC %d',obj.dcyc));
            end
        end
        function set_freq(obj,f)
            switch nargin
                case 1
                    obj.send(sprintf('FREQ %f',obj.freq));
                case 2
                    obj.send(sprintf('FREQ %f',f));
            end
        end
        function set_amp(obj,amp)
            switch nargin
                case 1
                    obj.send(sprintf('VOLT %f',obj.amp));
                case 2
                    obj.send(sprintf('VOLT %s',num2str(amp)));
            end
        end
        function set_offs(obj,offs)
            switch nargin
                case 1
                    obj.send(sprintf('VOLT:OFFS %f',obj.offs));
                case 2
                    obj.send(sprintf('VOLT:OFFS %f',offs));
            end
        end
        function set_trg_s(obj,s)
            switch nargin
                case 1
                    obj.send('TRIG:SOUR BUS');
                case 2
                    obj.send(sprintf('TRIG:SOUR %s',s));
            end
        end
        %% Querry
        function vo = get_dc(obj)
            obj.set_sh('DC');
            obj.send('VOLT:OFFS?');
            vo = obj.get('%f');
        end
    	%% DC
        function set_dc(obj,v,p,ivb)
            obj.set_sh('DC');
            switch ivb
                case 'cur'
                    obj.set_outp_l('DEF');
                case 'vol' 
                    obj.set_outp_l;
                otherwise
            end
            v1 = obj.get_dc;
            obj.set_offs(v);
            obj.set_outp_on;
            switch obj.model
                case '33120A'
                    if any(obj.r_ch((abs(v1) < obj.r_ch)&(abs(v) > obj.r_ch)))||any(obj.r_ch((abs(v1) > obj.r_ch)&(abs(v) < obj.r_ch)))
                        pause(1);
                    end
                case '33509B'
                    if ((abs(v1) < obj.r_ch(1))&&(abs(v) > obj.r_ch(1)))||((abs(v1) > obj.r_ch(1))&&(abs(v) < obj.r_ch(1)))
                        pause(1);
                    end
            end
            switch nargin 
                case 3
                    pause(p);
                case 2
                    pause(0.1);
            end
        end
        function set_gate(obj,v,st,p,ivb)
                obj.op;
                obj.set_sh('DC');
                obj.send('VOLT:OFFS?');
                v1 = obj.get('%f');
                if v ~= v1
                    n = abs(round((v-v1)/st));
                    for i = 1:n
                        obj.set_dc(v1+(v-v1)*i/n,0.05,ivb);
                    end
                    obj.set_dc(v,0,ivb);
                    fprintf('Vg = %f\n',v);
                end
                obj.cl;
                if v~= v1
                    pause(p);
                end
        end
        %% Output
        function set_outp_on(obj)
            switch obj.model
                case '33509B'
                    obj.send('OUTP 1');
                case '33522A'
                    obj.send('OUTP 1');
            end
        end
        function set_outp_off(obj)
            switch obj.model
                case '33509B'
                    obj.send('OUTP 0');
            end
        end
        function set_outp_l(obj,l)
            switch obj.model
                case '33509B'
                    switch nargin
                        case 1
                            obj.send('OUTP:LOAD INF');
                        case 2
                            obj.send(sprintf('OUTP:LOAD %s',l));
                    end
            end
        end
        %% Burst mode
        function set_bm(obj)
            switch obj.gg
                case 1
                    obj.send(sprintf('BM:INT:RATE %f',1/obj.b_per));
                    obj.send(sprintf('BM:NCYC %d',obj.b_ncyc));
                    obj.send(sprintf('BM:PHAS %f',obj.b_phas));
                case 2
                    obj.send('BURS:MODE TRIG');
                    obj.send(sprintf('BURS:INT:PER %f',obj.b_per));
                    obj.send(sprintf('BURS:NCYC %d',obj.b_ncyc));
                    obj.send(sprintf('BURS:PHAS %f',obj.b_phas));
            end
        end
        function set_bm_on(obj)
            switch obj.gg
                case 1
                    obj.send('BM:STAT ON'); 
                case 2
                    obj.send('BURS:STAT ON');
            end
        end
        function set_bm_off(obj)
            switch obj.gg
                case 1
                    obj.send('BM:STAT OFF');
                case 2
                    obj.send('BURS:STAT OFF');
            end
        end
        %% Pulse
        function set_pulse_temp(obj)
            obj.set_sh('SQU');
            obj.set_freq;
            obj.set_dcycle;
            obj.set_amp('MIN');
            obj.set_offs(0);
            obj.set_outp_l;
            obj.set_bm;
            obj.set_trg_s;
            obj.set_bm_on;
            obj.set_outp_on;
        end
        function set_pulse_amp(obj,amp)
            switch nargin
                case 2
                    obj.amp = amp;
                    obj.offs = obj.amp/2;
            end
            obj.set_amp;
            obj.set_offs;
        end
    end
end