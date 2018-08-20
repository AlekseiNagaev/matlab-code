function x = add_meas(obj,s,q)
% Adds measurement info to the journal
%   Adds:
%   x - Measurement time HH,MM
%   s - Measurement type
%   q - Measurement gate voltage
x = datestr(now,'HH,MM');
fprintf(obj.func,'%s|%s|%s|',x,s,q);
end

