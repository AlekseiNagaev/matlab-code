function res(app)
    try
        %% Values input
        md = 'RE';
        amp = app.iv_amp_v;
        gv = app.iv_gv_v;
        %% Variable setup
        lv = 2;
        num_b = 1;
        Vo = [0 amp];
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
        %% Working figure
        ax1 = app.W_Ax;
        xlabel(ax1,'I');
        ylabel(ax1,'V');
        hold(ax1,'on');
        %% Multiple IV cycle
        fl = 1;
        al = 1;
        %% Journal&Log entries
        s0 = app.joIV.add_dir(app.sf);
        x = app.joIV.add_meas(md,sg);
        sf = [app.sf,s0,'/',md,'_',x];
        bonds = app.bondi;
        sn = app.sn;
        save([sf,'.mat'],'amp','gv','sn','bonds');
        [r1,T1] = app.lgTem.add_log_temp(app.brg,app.ts);
        save([sf,'.mat'],'r1','T1','-append');
        %app.NF_IV_t1.Value = T1;
        %% Results figure
        f = figure;
        movegui(f,'northeast');
        set(f,'NumberTitle','off','Name','RES');
        ax2 = axes(f);
        title(ax2,[s0,' ',x,' ',sn,' ',md,' ',sg]);
        xlabel(ax2,'Vg[V]');
        ylabel(ax2,'R[{\Omega}]');
        hold(ax2,'on');
        %% Measurement
        app.notify(['Measurement started at ',x]);
        tech.opn(app.wgm,app.mu1);
        app.mu1.set_vm(5);
        switch app.ivb
            case 'cur'
                app.mu2.op;
                app.mu2.set_vm(5);
            otherwise
        end
        %% Gate cycle
        for m = 1:lgv
            if app.gc
                app.gg.set_gate(gv(m),app.gss,app.gp);
            end
            switch app.ivb
                case 'cur'
                    app.mu2.zer;
                otherwise
            end
            %% IV curve branches
            for q = 1:num_b
                %% Branch cycle
                for x = 1:lv
                    app.wgm.set_gate(Vo(q,x),app.gss,0);
                    [data.vol(q,x,m),fl] = app.mu1.meas_av(q,fl);
                    switch app.pola
                        case 0
                            data.vol(q,x,m) = data.vol(q,x,m)/app.gnv;
                        case 1
                            data.vol(q,x,m) = - data.vol(q,x,m)/app.gnv;
                    end
                    switch app.ivb
                        case 'cur'
                            [data.cur(q,x,m),al] = app.mu2.meas_av(q,al);
                            data.cur(q,x,m) = -2*data.cur(q,x,m)/app.gnc;
                        case 'vol'
                            data.cur(q,x,m) = Vo(q,x)/app.wgm.res;
                    end
                end
            end
            data.res(m) = data.vol(1,lv,m)/(data.cur(1,lv,m));
            plot(ax1,gv(m),data.res(m),'--o');
            title(ax1,[md,' Vg = ',num2str(gv(m))]);
            save([sf,'.mat'],'data','-append');
            fprintf('RES = %.3f\n',data.res(m));
            %app.NF_IV_res.Value = data.res(m);
            %% Final plot
            plot(ax2,gv(m),data.res(m),'.');
            savefig(f,sf);
            saveas(f,sf,'jpeg');
            %app.wgm.set_gate(0,app.gs,1);
            if app.IVs_mst_stop_BT.Value
                data.cur = data.cur(:,:,1:m);
                data.vol = data.vol(:,:,1:m);
                data.res = data.res(1:m);
                gv = gv(1:m);
                lgv = length(gv);
                save([sf,'.mat'],'data','gv','-append');
                break;
            end
        end
        app.wgm.set_gate(0,app.gss,0);
        if app.gc
            app.gg.set_gate(0,app.gss,0);
        end
        cls(app.wgm,app.mu1);
        switch app.ivb
            case 'cur'
                app.mu2.cl;
            otherwise
        end        
        %--------------------------------------------------------------------------
        %% Final temperature measurement-
        [r2,T2] = app.lgTem.add_log_temp(app.brg,app.ts);
        save([sf,'.mat'],'r2','T2','-append');
        %app.iv_t2.Value = T2;
        app.notify(['Measurement finished at ',datestr(now,'HH,MM')]);
    catch ME
        c{1} = [ME.identifier,' ',ME.message];
        c{2} = [ME.stack(1).name,' ',num2str(ME.stack(1).line)];
        app.notify(sprintf('Error \n %s \n %s',c{1},c{2}));
        rethrow(ME);
    end
end