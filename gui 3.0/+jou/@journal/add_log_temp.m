function [r,T] = add_log_temp(obj,r,T)
% Adds resistance/temperature to the temperature log
%   Reads temperature from AVS-47B's 3rd channel
s = datestr(now,'dd.mm.yy');
switch obj.find_meas(s,2)
    case 1
        obj.add_date(s);
    otherwise
end
s = datestr(now,'HH,MM');
fprintf(obj.func,'%s|RES 3 = %.1f -> T = %.4f\n',s,r,T);
end

