clear;
ss = 'D:/Dropbox/Data/GY1/';
md = 'IV';
s = '13.03.17';
x = '18,01';
sw = 1e-5;
sf = [ss,s,'/',md,'_',x];
mode = 1; % 1 for Isw and Irt, 2 for data formatting in older files
switch mode
    case 1
        load(sf,'data');
        load(sf,'gv');
        if ~exist('data','var')
            load(sf,'cur','vol');
            data.cur = cur;
            data.vol = vol;
        end
        lgv = length(gv);
        data.Isw = zeros(lgv,1);
        data.Irt = zeros(lgv,1);
        for j = 1:lgv
            data.res(j) = data.vol(1,end,j)/(data.cur(1,end,j));
            m = data.vol(1,:,j);
            h = data.vol(2,:,j);
            k = find( m > sw,1);
            u = find( h < sw,1); 
            if  ~isempty(k)
                data.Isw(j) = data.cur(1,k,j);
                fprintf('Switching current %.2e at Vg = %.2f\n',data.Isw(j),gv(j));
                app.iv_isw.Value = data.Isw(j);
            else
                fprintf('No switching to normal state (criteria %.2e V)\n',sw);
            end
            if  ~isempty(u)
                data.Irt(j) = data.cur(2,u,j);
                fprintf('Retrapping current %.2e at Vg = %.2f\n',data.Irt(j),gv(j));
                app.iv_irt.Value = data.Irt(j);
            else
                fprintf('No retrapping to sc state (criteria %.2e V)\n',sw);
            end
        end
        save([sf,'.mat'],'data','-append');
    case 2
        load(sf,'gv');
        lgv = length(gv);
        load(sf,'cur','vol');
        cur = permute(cur,[2 1 3]);
        vol = permute(vol,[2 1 3]);
        data.cur = cur;
        data.vol = vol;
        save([sf,'.mat'],'vol','cur','-append');
        data.Isw = zeros(lgv,1);
        data.Irt = zeros(lgv,1);
        for j = 1:lgv
            data.res(j) = data.vol(1,end,j)/(data.cur(1,end,j));
            m = data.vol(1,:,j);
            h = data.vol(2,:,j);
            k = find( m > sw,1);
            u = find( h < sw,1); 
            if  ~isempty(k)
                data.Isw(j) = data.cur(1,k,j);
                fprintf('Switching current %.2e at Vg = %.2f\n',data.Isw(j),gv(j));
                app.iv_isw.Value = data.Isw(j);
            else
                fprintf('No switching to normal state (criteria %.2e V)\n',sw);
            end
            if  ~isempty(u)
                data.Irt(j) = data.cur(2,u,j);
                fprintf('Retrapping current %.2e at Vg = %.2f\n',data.Irt(j),gv(j));
                app.iv_irt.Value = data.Irt(j);
            else
                fprintf('No retrapping to sc state (criteria %.2e V)\n',sw);
            end
        end
        save([sf,'.mat'],'data','-append');
end
%clear;