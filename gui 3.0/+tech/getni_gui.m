function getni_gui(src,event,app)
%GETMI_GUI Summary of this function goes here
%   Detailed explanation goes here
%Measure and analyze with NI car
data = event.Data/app.OP.gnv - app.PL.offs;
lpFilt = designfilt('lowpassiir','FilterOrder',20, ...
         'PassbandFrequency',4.5e3,'PassbandRipple',0.2, ...
         'SampleRate',200e3);
out = filter(lpFilt,data);
n = 73;
%av = arrayfun(@(i) mean(data(i:i+n-1)),1:n:length(data)-n+1)';
if app.OP.ts ~= 'n'
    plot(app.AX.fvax1,data,'LineStyle',':','Color','r','Marker','.','MarkerFaceColor','b');
    plot(app.AX.fvax2,out,'LineStyle',':','Color','b','Marker','.','MarkerFaceColor','r');
    %plot(app.AX.fvax3,av,'LineStyle',':','Color','b','Marker','.','MarkerFaceColor','g');
    title(app.AX.fvax1,'Measured data');
    title(app.AX.fvax2,'After filtering');
    %title(app.AX.fvax3,sprintf('Averaging n = %d',n));
end
k = find(out > app.OP.sw);
%disp(k);
j = 0;
for h = 2:length(k)
    if k(h)-k(h-1) == 1
        j = j + 1;
        if j == 10
            app.PL.pl_n = app.PL.pl_n + 1;
        end
    else
        j = 0;
    end
end
end

