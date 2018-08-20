switch rg
    case 1
        data2.cur = data(1).data.cur;
        data2.vol = data(1).data.vol;
        data2.Isw = data(1).data.Isw;
        data2.Irt = data(1).data.Irt;
        data2.res = data(1).data.res;
        gv2 = gv(1).gv;
        lgv = length(gv2);
        lgv2 = length(gv(2).gv);
        n1 = length(data2.cur);
        n2 = length(data(2).data.cur);
        if n1 == n2
        else
            if n1>n2
            else
            end
            for j = 1:lgv
                for i = n1:n2  
                    for q = 1:4
                        data2.cur(q,i,j) = data(2).data.cur(q,i,1);
                        data2.vol(q,i,j) = data(1).data.res(j) * data2.cur(q,i,j);
                    end
                end
            end
        end
        for j = 1:lgv2
            for q = 1:4
                data2.cur(q,1:n2,lgv + j) = data(2).data.cur(q,1:n2,j);
                data2.vol(q,1:n2,lgv + j) = data(2).data.vol(q,1:n2,j);
            end
            gv2(lgv + j) = gv(2).gv(j);
            data2.Isw(lgv+j) = data(2).data.Isw(j);
            data2.Irt(lgv+j) = data(2).data.Irt(j);
            data2.res(lgv+j) = data(2).data.res(j);
        end
        data = data2;
        gv = gv2;
        tech.surf_gv_I_V(data,gv,T(1).T1);
    case 2
        sf = 'Results/Raw';
        md = 'IV';
        i = 1;
        q = 1;
        while i == 1
            s = input('Enter date of the measurement xx.yy.zz\n','s');
            x = input('Enter time of the measurement xx,yy\n','s');
            str = [sf,'/',s,'/',md,'_',x];
            data(q) = load(str,'data');
            gv(q) = load(str,'gv');
            T(q) = load(str,'T1');
            q = q + 1;
            i = input('Load another file?\n');
        end
        clear i md q s sf str x;
end