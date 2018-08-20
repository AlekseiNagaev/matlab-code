function getcha( src,event, varargin )
%Measure and analyze with NI card
%   Detailed explanation goes here
global ts 
global gnv sw
global n k
global axpm axpf axpr
global ev
ev = event;
d_ni = varargin{1};
data = event.Data/gnv - d_ni.offs;
lpFilt = designfilt('lowpassiir','FilterOrder',20, ...
         'PassbandFrequency',5e3,'PassbandRipple',0.2, ...
         'SampleRate',200e3);
out = filter(lpFilt,data);
%in = event.Data(:,2);
if ts ~= 'n'
    plot(axpm,data,'LineStyle',':','Color','r','Marker','.','MarkerFaceColor','b');
    plot(axpf,out,'LineStyle',':','Color','b','Marker','.','MarkerFaceColor','r');
    %plot(axpr,in,'LineStyle',':','Color','r','Marker','.','MarkerFaceColor','b');
    title(axpm,'Measured data');
    title(axpf,'After filtering');
    %title(axpr,'Input');
end
k = find(out > sw);
j = 0;
for i = 2:length(k)
    if k(i)-k(i-1) == 1
        j = j + 1;
        if j == 10
            n = n + 1;
        end
    else
        j = 0;
    end
end
end

