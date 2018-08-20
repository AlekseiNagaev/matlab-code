function i = find_meas(obj,x,t)
%Find measurements in the journal
%   t = 0 to search with output/options
%   t = 1 to search silently
frewind(obj.func);
s = fgetl(obj.func);
while (ischar(s))&&(~strcmp(s,x))
	s = fgetl(obj.func);
end
s = fgetl(obj.func);
i = 1;
while (ischar(s))&&(isempty(regexp(s,obj.exp,'once')))
	c = textscan(s,'%s','Delimiter','|');
	v{i} = c{1};
	i = i +1;
	s = fgetl(obj.func);
end
switch i
    case 1
        switch t
            case 0
                fprintf(['No records for ',x,'\n']);
            case 2
                fprintf(['No records for ',x,'\n']);
        end
    otherwise
        n = length(v) - ischar(s);
        switch t
            case 0
                fprintf('-------------------------\n');
                for j = 2:n
                	fprintf('%d) %s %s %s %s\n',j-1,v{j}{1},v{j}{2},v{j}{3},v{j}{4});
                end
                fprintf('-------------------------\n');
                lm = length(v);
                l = 'y';
                while l ~= 'n'
                    k = input('# to load?(0 to exit)\n');
                    if (k > 0)&&(k < lm - 1)
                        k = k + 1;
                        type = v{k}{2};
                        time = v{k}{1};
                        s = [type,'_',time];
                        fprintf('%s\n',s);
                        sf = ['Data/',x,'/',s];
                        find_meas_opt(sf);
                        j = input('Choice?\n');
                        find_meas_choice(j,sf,s,type,time)
                    elseif k ~= 0
                        fprintf('Wrong pick\n');
                    end
                    l = input('Anything else?(y or n)\n');
                end        
        end
end
end

