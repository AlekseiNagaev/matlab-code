function mrc(x,s)
%Critical current and resistance modulation based on IV+gate   
%   x - date xx.yy.zz
%   s - time xx,yy
%   t - type 'IV+gate'
t = 'IV';
ss = 'D:/Dropbox/Data/';
sn = 'GY1';
%--------------------------------------------------------------------------
fr = figure;
ax = axes(fr);
xlabel(ax,'Gate voltage [V]');
ylabel(ax,'Resistance [Ohm]');
hold(ax,'on');
%--------------------------------------------------------------------------
fc = figure;
ax1 = axes(fc);
xlabel(ax1,'Gate Voltage [V]');
ylabel(ax1,'Critical current [A]');
hold(ax1,'on');
%--------------------------------------------------------------------------
fcr = figure;
ax2 = axes(fcr);
xlabel(ax2,'Gate Voltage [V]');
ylabel(ax2,'Retrapping current [A]');
hold(ax2,'on');
%-------------------------------------------------------------------------
if nargin == 0
    commandwindow;
	s = input('Enter date of the measurement xx.yy.zz\n','s');
    x = input('Enter time of the measurement xx,yy\n','s');
end
    sf = [ss,sn,'/',s,'/',t,'_',x];
    load(sf,'data','gv');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
 	plot(ax,gv,data.res,'-o','MarkerEdgeColor','r');
%--------------------------------------------------------------------------    
%--------------------------------------------------------------------------
    plot(ax1,gv,data.Isw,'-o','MarkerEdgeColor','r');
    plot(ax2,gv,data.Irt,'-o','MarkerEdgeColor','r');
    title(ax,['Sample ',sn,' Resistance modulation']);
    title(ax1,['Sample ',sn,' Critical current modulation']);
    title(ax2,['Sample ',sn,' Retrapping current modulation'])
    mkdir(sf);
    savefig(fr,[sf,'/','R']);
    savefig(fc,[sf,'/','Ic']);
    savefig(fcr,[sf,'/','Irt']);
end

