  function TA = PLfit(data,T1,Rn,ax)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 4
    f = figure;
    ax = axes(f);
    if isfield(data,'pul_i')
        cur = data.pul_i;
    end
    if isfield(data,'cur')
        cur = data.cur;
    end
end 
    k = tech.const.si.k;
    e = tech.const.si.e;
    h = tech.const.si.h;
    hbar = tech.const.si.hbar;
    %F0 = tech.const.si.F0;
    %d = 1.76*k*1.2;
    Ic = 11.75e-7;%2.44*d/e;%pi*d/(2*e*Rn)*tanh(d/(2*k*T) );
    fprintf('\nAttempt\n');
    % fprintf('Ic = %e\n',Ic)
    %Ej = hbar*Ic/(2*e);
    %fprintf('Ej = %e\n',Ej)
    n0 = abs(find(data.pr > 0,1));
    n1 = find(data.pr < 1,1,'last');
    %data.pr(n1:end) = 0.999; 
    if isempty(n1)/
        n1 = length(data.pr);
    end
    if n0 - 5 > 1
        nl0 = n0 - 5;
    else
        nl0 = 1;
    end  
    if n1 + 5 > length(data.pr)
        nl1 = length(data.pr);
    else 
        nl1 = n1 + 5;
    end
    bmin = cur(nl1);
    bmax = 1.9*bmin;
    x1 = cur(nl0:nl1);
    if ~iscolumn(x1)
        x1 = x1.';
    end
    nu = x1;%./Ic;    
    y1 = data.pr(nl0:nl1);
    if ~iscolumn(y1)
        y1 = y1.';
    end
    wp = @(a,b,x) a*sqrt(b)*(1-(x/b).^2).^0.25;
    dU= @(b,x) (2*(hbar/(2*e))*b*(sqrt(1 - (x/b).^2) - (x/b).*acos((x/b))));
    TA.ft = fittype(@(a,b,x) 1 - exp(-wp(a,b,x).*exp(-dU(b,x)/(k*T1))),'independent',{'x'},'dependent',{'y'},'coefficients',{'a','b'});
    TA.f = fit(nu,y1,TA.ft,'lower',[5e8 bmin],'upper',[7e8  1.8e-6]);
    disp(TA.f);
    Ic = TA.f.b;
    plot(TA.f,nu,y1)
    hold(ax,'on');
    xlabel(ax,'I [A]');
    ylabel(ax,'P');
    legend(ax,'Experiment','Fitting TA');
    %fprintf('a = %e\n',TA.f.a);
    wp0 = TA.f.a*2*pi*1e4*sqrt(Ic);
    fprintf('Wp0 = %.3e\n',wp0)
    TA.Tc = hbar*wp0/k;
    fprintf('Tc = %.3e\n',TA.Tc);
    C = 2*e*Ic/((wp0^2)*hbar);
    fprintf('C = %.3e\n',C) 
    MQT.ft = fittype(@(a,b,x) 1 - exp(-12*wp(a,b,x).*(3*dU(b,x)./(h*wp(a,b,x))).*exp(7.2*dU(b,x)./(hbar*wp(a,b,x)))));
    MQT.f = fit(nu,y1,TA.ft,'lower',[1e2 bmin],'upper',[1e7  2e-6],'StartPoint',[1e6  bmin]);
    %disp(MQT.f);
 end

  