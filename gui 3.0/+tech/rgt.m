function rgt(sf,data,gv,T1)
    res = data.res; 
    f = figure;
    ax = axes(f);
    plot(ax,gv,res,'-o');
    xlabel(ax,'Gate Voltage');
    ylabel(ax,'Resistance');
    title(ax,sprintf('Resistance gate modulation at T = %.2f K',T1))
    sf = [sf,sprintf('%.2fK',T1)];
    saveas(f,[sf,'.fig']);
    saveas(f,[sf,'.png']);
end