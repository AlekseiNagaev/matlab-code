function surf_gv_I_V(sf,data,gv,T1)
    cur = data.cur(1,:,:); 
    vol = data.vol(1,:,:);
    cur = squeeze(cur);
    vol = squeeze(vol);
    f = figure;
    ax = axes(f);
    s = surf(ax,gv,cur,vol);
    view(0,90);
    xlabel(ax,'Gate Voltage');
    ylabel(ax,'Current');
    zlabel(ax,'Voltage');
    title(ax,sprintf('Critical current gate modulation at T = %.2f K',T1))
    s.EdgeColor = 'none';
    c = colorbar;
    ylabel(c,'Voltage');
    sf = [sf,sprintf('%.2fK' ,T1)];
    saveas(f,[sf,'.fig']);
    saveas(f,[sf,'.png']);
end