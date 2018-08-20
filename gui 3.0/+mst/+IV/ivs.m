function ivs(app)
    try
        %% Import parameters
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
        if isfield(app.DV,'mu2')
            mu2 = instruments.mult(app.DV.mu2,'Voltage Multimeter');
        end
        if isfield(app.DV,'brg')
            brg = instruments.resbrg(app.DV.brg.addr,'AVS');
            brg.model = app.DV.brg.model;
            brg.mode = app.DV.brg.mode;
            %disp(brg);
        end
        %% Journals
        sn = app.JO.sn;
        sf = app.JO.sf;
        mkdir(sf);
        bonds = app.JO.bondi;
        %% Options
        gnv = app.OP.gnv;
        gnc = app.OP.gnc;
        gp = app.IV.gp;
        sw = app.OP.sw;
        gss = app.OP.gss;
        ivsp = app.IV.ivsp;
        ivb = app.OP.ivb;
        pola = app.IV.pola;
        %% IV
        md = 'IV';
        amp = app.IV.amp;
        st = app.IV.st;
        gv = app.IV.gv;
        %% Variable setup
        lv = amp/st + 1;
        num_b = 4;
        Vo = zeros(num_b,lv);
        Vo(1,1:end) = 0:st:amp;
        Vo(2,1:end) = amp:-st:0;
        Vo(3,1:end) = 0:-st:-amp;
        Vo(4,1:end) = -amp:st:0;
        lgv = length(gv);
        data.vol = zeros(num_b,lv,lgv);
        data.cur = zeros(num_b,lv,lgv);
        data.res = 0*gv;
        %% Gate title
        if lgv == 1
            sg = ['Vg = ',num2str(gv)];
        else
            sgv = (gv(lgv)-gv(1))/(lgv-1);
            sg = ['Vg = ',sprintf('%.2f:%.2f:%.2f',gv(1),sgv,gv(lgv))];
        end
        %% Multiple IV cycle
        fl = 1;
        al = 1;
        %% Journal&Log entries
        s0 = app.JO.joIVs.add_dir(sf);
        x = app.JO.joIVs.add_meas(md,sg);
        sf = [sf,s0,'/',md,'_',x];
        save([sf,'.mat'],'amp','st','gv','sn','bonds');
        [r1,T1] = brg.brg_read;
        %disp(T1);
        app.JO.lgTem.add_log_temp(r1,T1);
        save([sf,'.mat'],'r1','T1','-append');
        app.Modules.MstIV_UI.IVs_mst_T1_NF.Value = T1;
        %% Working figure
        f1 = figure('Name','Working figure','NumberTitle','off');
        movegui(f1,'northeast');
        ax1 = axes(f1);
        %% Results figure
        f2 = figure('Name','Results','NumberTitle','off');
        movegui(f2,'northwest');
        ax2 = axes(f2);
        ttl = [s0,' ',x,' ',sn,' ',md,' ',sg];
        title(ax2,ttl);        
        xlabel(ax2,'I[A]');
        ylabel(ax2,'V[V]');
        hold(ax2,'on');
        %% Measurement
        app.notify(['Measurement started at ',x]);
        app.notify([md,' ',sg]);
        tech.opn(wgm,mu1)
        mu1.set_vm(5);
        switch ivb
            case 'cur'
                mu2.op;
                mu2.set_vm(5);
            otherwise
        end
        if wgm.get_dc ~= 0
            wgm.set_gate(0,gss,0,ivb);
            wgm.op;
        end
        %% Gate cycle
        for m = 1:lgv
            if gc
                app.notify(sprintf('Vg = %.2f V',gv(m)));
                gg.set_gate(gv(m),gss,gp,ivb);
            end
            mu1.zer;
            switch ivb
                case 'cur'
                    mu2.zer;
                otherwise
            end
            %% IV cycle
            for q = 1:num_b
                %% Branch cycle
                for x = 1:lv
                    wgm.set_dc(Vo(q,x),ivsp,ivb);
                    [data.vol(q,x,m),fl] = mu1.meas_av(q,fl);
                    switch pola
                        case 0
                            data.vol(q,x,m) = data.vol(q,x,m)/gnv;
                        case 1
                            data.vol(q,x,m) = - data.vol(q,x,m)/gnv;
                    end
                    switch ivb
                        case 'cur'
                            [data.cur(q,x,m),al] = mu2.meas_av(q,al);
                            data.cur(q,x,m) = -2*data.cur(q,x,m)/gnc;
                        case 'vol'
                            data.cur(q,x,m) = Vo(q,x)/wgm.res;
                    end
                    %% Live plot
                    if q > 1
                        plot(ax1,data.cur(1:q-1,:,m),data.vol(1:q-1,:,m),'.');
                        hold(ax1,'on');
                    end
                    plot(ax1,data.cur(q,1:x,m),data.vol(q,1:x,m),'--o');
                    title(ax1,[md,' Vg = ',num2str(gv(m))]);
                    xlabel(ax1,'I');
                    ylabel(ax1,'V');
                    hold(ax1,'off');
                    save([sf,'.mat'],'data','-append');
                    if app.Modules.MstIV_UI.BREAK_BT.Value
                        break;
                    end
                end
            end
            mu1.math_off;
            data.res(m) = data.vol(1,lv,m)/(data.cur(1,lv,m));
            save([sf,'.mat'],'data','-append');
            fprintf('RES = %.3f\n',data.res(m));
            app.Modules.MstIV_UI.IVs_mst_res_NF.Value = data.res(m);
            %% Final plot
            plot(ax2,data.cur(:,:,m),data.vol(:,:,m),'.');
            savefig(f2,sf);
            saveas(f2,sf,'jpeg');
            %app.TlgBot.sendPhoto([sf,'.jpg']);
            %% Stop gate sweep
            if app.Modules.MstIV_UI.IVs_mst_stop_BT.Value
                data.cur = data.cur(:,:,1:m);
                data.vol = data.vol(:,:,1:m);
                data.res = data.res(1:m);
                gv = gv(1:m);
                lgv = length(gv);
                save([sf,'.mat'],'data','gv','-append');
                app.Modules.MstIV_UI.IVs_mst_stop_BT.Value = 0;
                app.Modules.MstIV_UI.IVs_mst_stop_BT.Enable = 'off';
                app.Modules.MstIV_UI.BREAK_BT.Enable = 'off';
                break;
            end
        end
        if gc
            gg.set_gate(0,gss,0,ivb);
        end
        tech.cls(wgm,mu1);
        switch ivb
            case 'cur'
                app.mu2.cl;
            otherwise
        end        
        %--------------------------------------------------------------------------
        %% Final temperature measurement
        [r2,T2] = brg.brg_read;
        app.JO.lgTem.add_log_temp(r2,T2);
        app.Modules.MstIV_UI.IVs_mst_T2_NF.Value = T2; 
        save([sf,'.mat'],'r2','T2','-append');
        %% Switching current
        data.Isw = zeros(lgv,1);
        data.Irt = zeros(lgv,1);
        for j = 1:lgv
            m = data.vol(1,:,j);
            h = data.vol(2,:,j);
            k = find( m > sw,1);
            u = find( h < sw,1); 
            if  ~isempty(k)
                data.Isw(j) = data.cur(1,k,j);
                s = sprintf('Switching current %.2e at Vg = %.2f\n',data.Isw(j),gv(j));
                app.notify(s);
                app.Modules.MstIV_UI.IVs_mst_Isw_NF.Value = data.Isw(j);
            else
                fprintf('No switching to normal state (criteria %.2e V)\n',sw);
            end
            if  ~isempty(u)
                data.Irt(j) = data.cur(2,u,j);
                s = sprintf('Retrapping current %.2e at Vg = %.2f\n',data.Irt(j),gv(j));
                app.notify(s);
                app.Modules.MstIV_UI.IVs_mst_Irt_NF.Value = data.Irt(j);
            else
                app.notify(sprintf('No retrapping to sc state (criteria %.2e V)\n',sw));
            end
        end
        save([sf,'.mat'],'data','-append');
        app.notify(['Measurement finished at ',datestr(now,'HH,MM')]);
        clear wgm gg mu1 brg
    catch ME
        c{1} = [ME.identifier,' ',ME.message];
        c{2} = [ME.stack(1).name,' ',num2str(ME.stack(1).line)];
        app.notify(sprintf('Error \n %s \n %s',c{1},c{2}));
        app.err(ME);
    end
end