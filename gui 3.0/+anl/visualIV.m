function visualIV
%   Visualize and split the IV+gate
%   x - date xx.yy.zz
%   s - type_time IV+gate_xx,yy
%   t - new folder name = time
t = 'IV';
s = input('Date of the measurement\n','s');
x = input('Time of the measurement\n','s');
global sn
sf = ['Data/',sn,'/',s,'/',t,'_',x];
load(sf,'cur','vol','gv');
f2 = figure;
movegui(f2,'northeast');
set(f2,'NumberTitle','off','Name','IV + gate');
ax2 = axes(f2);
mkdir(['Data/',sn,'/',s,'/',x])
for m = 1:length(gv)
    plot(ax2,cur(:,:,m),vol(:,:,m),'.');
    title(ax2,['IV curve Vg = ',num2str(gv(m),'%.2f')]);
    xlabel(ax2,'I');
    ylabel(ax2,'V');
    saveas(f2,['Data/',sn,'/',s,'/',x,'/',num2str(m,'%.0d')],'jpeg');
end
close(f2);
winopen(['Data/',x,'/',t]);
commandwindow;
j = input('Enter the numbers of the plots, separated by spaces\n','s');
c = sscanf(j,'%d');
for m = 1:length(c)
	figure;
	plot(cur(:,:,c(m)),vol(:,:,c(m)),'.');
	title(['IV curve Vg = ',num2str(gv(c(m)),'%.2f')]);
	xlabel('I');
	ylabel('V');
end
end

