%function pulse_fit(pul_i,pr,T)
% global sn
% t = 'Pulse';
% commandwindow;
% %switch nargin
%     %case 0
%         x = '19.03.17';%input('Date of the measurement? xx.yy.zz\n','s');
%         s = '22,32';%input('Time of the measurement? xx.yy.zz\n','s');
%         sf = ['Data/',sn,'/',x,'/',t,'_',s];
%         %load(sf,'pul_i','pr','T1','res');
%         load(sf,'data');
%         %T = T1;
% %end
%     k = const.si.k;
%     e = const.si.e;
%     T = T1;%input('Temperature?\n');
%     Rn = 61.5;%input('Normal state resistance?\n');
%     d = 1.76*k*1.2;
%     Ic = pi*d/(2*e*Rn)*tanh(d/(2*k*T));
%     n0 = find(data.pr > 0,1);
%     n1 = find(data.pr == 1,1);
%     data.pr(n1:end) = 0.999; 
%     if isempty(n1)
%         n1 = length(pr);
%     end
%     if n0 - 5 > 1
%         nl0 = n0 - 5;
%     else
%         nl0 = 1;
%     end
%     if n1 + 5 > length(data.pr)
%         nl1 = length(data.pr);
%     else
%         nl1 = n1 + 5;
%     end
    x1 = data.pul_i(nl0:nl1).';
    y1 = data.pr(nl0:nl1).';
    x2 = (Ic - x1).^1.5;
    x3 = (Ic - x1).^1.25;
    y2 = log(1 - y1).';
    y3 = log(1 - y1).';
    f2 = fit(x2,y2,'exp1');
    f3 = fit(x3,y3,'exp1'); 
    y2f = 1 - exp(f2.a*exp(f2.b*x2));
    y3f = 1 - exp(f3.a*exp(f3.b*x3));
    yqf = 1 - exp(-275*exp(-2e11*x2));
    figure;
    plot(x1,y1,'b',x1,y2f,'r',x1,y3f,'m',x1,yqf,'g');
    title([x,' ',s,' Pulse fitting result'])
    xlabel('I [A]');
    ylabel('P');
    a=-2e11;
    b=1e-10;
    legend('Experiment','Fitting TA','Fitting MQT');
    Tc = - ((2*const.si.F0*Ic)/(3*2*pi*const.si.k*a*Ic^1.5))*2^1.5;
    Ec = ((const.si.h*275/b/0.46)^2)*(2*pi/(8*const.si.F0*Ic));
    C = ((const.si.e)^2)/(2*Ec);
%end
