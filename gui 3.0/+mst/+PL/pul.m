function pul(app)
    try
        %% Devices
        instrreset;
        if isfield(app.DV,'wgm')
            wgm = instruments.wfgen(app.DV.wgm,'Main generator');
            wgm.res = app.OP.bias_res;
        end
        gc = app.OP.gc;
        switch gc
            case 1
                gg = instruments.wfgen(app.DV.wgg,'Gate generator');
            case 2
                gg = instruments.dcpws(app.DV.psg,'Gate generator');
        end
        if isfield(app.DV,'mu1')
            mu1 = instruments.mult(app.DV.mu1,'Voltage Multimeter');
        end
        if isfield(app.DV,'brg')
            brg = instruments.resbrg(app.DV.brg.addr,'AVS');
            brg.model = app.DV.brg.model;
            brg.mode = app.DV.brg.mode;
        end
        if isfield(app.DV,'nic')
            daqNI = instruments.nicAQT(app.DV.nic.addr);
            daqNI.ch_id = app.DV.nic.ch_id;
            daqNI.ch_type = 'Voltage';
            daqNI.ch = daqNI.ses.addAnalogInputChannel(daqNI.dev.ID, daqNI.ch_id, daqNI.ch_type);
            daqNI.ses.Rate = app.DV.nic.ses.Rate;
            daqNI.ch.Range = app.DV.ch.Range;
        end
        %% Journal
        sn = app.JO.sn;
        sf = app.JO.sf;
        mkdir(sf);
        bonds = app.JO.bondi;
        %% Options
        md = 'PL';
        gnv = app.OP.gnv;
        gpp = app.PL.gpp;
        gss = app.OP.gss;
        ivb = app.OP.ivb;
        ts = app.OP.ts;
        freq = app.PL.freq;
        intvl = app.PL.pause;
        tc = app.OP.tc;
        %% PL
        data.cur(1) = app.PL.cur;
        dI = app.PL.dI;
        st = app.PL.st;
        gv = app.PL.gv;
        data.pr(1) = 0;
        %% Gate title
        sg = ['Vg = ',num2str(gv)];
        %% Journal&Log
        s0 = app.JO.joPul.add_dir(sf);
        x = app.JO.joPul.add_meas(md,sg);
        sf = [sf,s0,'/',md,'_',x];
        save([sf,'.mat'],'gv','sn','st','data','bonds');
        %% Working figure
        f1 = figure('Name','Probability','NumberTitle','off');
        movegui(f1,'northeast');
        ax1 = axes(f1);
        title(ax1,'Probability curve')
        xlabel(ax1,'I');
        ylabel(ax1,'P');
        %% Probability figure
        %ax1 = app.W_Ax;
        fp = figure('Name','Probability curve','NumberTitle','off');
        movegui(fp,'northwest');
        ax2 = axes(fp);
        title(ax2,[s0,' ',x,' ',sn,' Probability of switching, ',sg]);
        xlabel(ax2,'I');
        ylabel(ax2,'P');
        hold(ax2,'on');
        fp.Visible = 'off';
        %% Voltage responce
        if ts ~= 'n'
            app.AX.fv = figure;
            set(app.AX.fv,'NumberTitle','off','Name','Pulse');
            app.AX.fvax1 = subplot(2,1,1);
            app.AX.fvax2 = subplot(2,1,2);
            %app.AX.fvax1 = subplot(3,1,1);
            %app.AX.fvax2 = subplot(3,1,2);
            %app.AX.fvax3 = subplot(3,1,3);
        end
        %% Pulse parameters
        wgm.freq = freq;
        wgm.dcyc = 50;
        wgm.b_per = intvl;
        wgm.b_ncyc = 1;
        wgm.b_phas = 0;
        save([sf,'.mat'],'wgm','-append');
        %% NI card setup
        daqNI.lh = addlistener(daqNI.ses,'DataAvailable',@(src,event)tech.getni_gui(src,event,app));
        t = 1.2*(1/(wgm.b_per));
        daqNI.ses.DurationInSeconds = st*t;
        daqNI.ses.NotifyWhenDataAvailableExceeds = t*daqNI.ses.Rate;
        %% Measurement
        app.notify(['Measurement started at ',x]);
        wgm.op;
        wgm.set_pulse_temp;
        pause(0.05);
        u = 0;
        j = 1;
        fprintf('-----------------------------------\n');
        [r1,T1] = brg.brg_read; 
        app.JO.lgTem.add_log_temp(r1,T1);
        app.Modules.MstPL_UI.PL_T1_NF.Value = T1; 
        save([sf,'.mat'],'r1','T1','-append');
        if gc
            gg.set_gate(gv,gss,gpp,ivb);
        end
        %% Pulse cycle
        while u<12
            app.PL.pl_n = 0;
            wgm.amp = data.cur(j)*wgm.res;
            wgm.offs = wgm.amp/2;
            wgm.set_pulse_amp;
            pause(0.05);
            %% Pulses
            mu1.op;
            app.PL.offs = mu1.read_vm/gnv;
            startBackground(daqNI.ses);
            for k = 1:st
                %disp(k);
                wgm.trg(tc);
                pause(1/wgm.b_per);
            end
            wait(daqNI.ses);
            %% Probability
            data.pr(j) = app.PL.pl_n/st;
            %app.lgTem.add_log_temp(app.brg);
            if data.pr(j) > 1
                 data.pr(j) = 1;
            end
            save([sf,'.mat'],'data','-append');
            app.notify(sprintf('Current %2.3e Probability %.3e\n',data.cur(j),data.pr(j)));
            plot(ax1,data.cur(1:j),data.pr(1:j),'--o');
            if (1 - data.pr(j)) < 0.05
                u = u + 1;
            else
                u = 0;
            end
            if app.Modules.MstPL_UI.PL_stop_BT.Value
                app.Modules.MstPL_UI.PL_stop_BT.Enable = 'off';
                app.Modules.MstPL_UI.PL_stop_BT.Value = 0;
                break;
            end
            if u<8
                data.cur(j+1) = data.cur(j) + dI;
                j = j + 1;
            end
        end
        %% Middle point control measurement
        lp = length(data.cur);
        q = round(lp/2);
        app.PL.pl_n = 0;
        wgm.amp = data.cur(q)*wgm.res;
        wgm.offs = wgm.amp/2;
        wgm.set_pulse_amp;
        pause(0.05);
        %% Pulses
        mu1.op;
        daqNI.offs = mu1.read_vm/gnv;
        startBackground(daqNI.ses);
        for k = 1:st
            wgm.trg(tc);
            pause(1/wgm.b_per);
        end
        wait(daqNI.ses);
        %% Probability
        pr = app.PL.pl_n/st;
        app.notify(sprintf('Current %2.3e Probability %.3e\n',data.cur(q),pr));
        %% Closing down
        [r2,T2] = brg.brg_read;
        app.JO.lgTem.add_log_temp(r2,T2);
        app.Modules.MstPL_UI.PL_T2_NF.Value = T2; 
        save([sf,'.mat'],'r2','T2','-append');
        if gc
            gg.set_gate(0,gss,0,ivb);
        end
        wgm.set_bm_off;
        wgm.set_outp_off;
        wgm.cl;
        %% Final plot
        fp.Visible = 'on';
        plot(ax2,data.cur,data.pr,'--o');
        saveas(fp,sf,'jpeg');
        savefig(fp,sf);
        %% Notification
        app.notify(['Measurement finished at ',datestr(now,'HH,MM')]);
        %app.TlgBot.sendPhoto([sf,'.jpg']);
        clear daqNI wgm gg mu1 brg
    catch ME
        c{1} = [ME.identifier,' ',ME.message];
        c{2} = [ME.stack(1).name,' ',num2str(ME.stack(1).line)];
        app.notify(sprintf('Error \n %s \n %s',c{1},c{2}));
        rethrow(ME);
    end
end