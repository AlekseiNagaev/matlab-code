function find_meas_choice(j,sf,s,type,time)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
switch j
	case 1
        open([sf,'.fig']);
	case 2 
        if strcmp(type,'IV+gate')
        	n = input(['1 - Visualise and split IV+gate\n'...
                        '2 - Modulation of resistance and critical current\n'...
                      	'Else - load variables\n']);
            switch n
            	case 1
                	visualIV(x,s,time)
             	case 2
                    mod_res_cur(x,time)
                otherwise
                    load([sf,'.mat'])
            end
        else
        	load([sf,'.mat'])
        end
	case 3
    	winopen([sf,'.jpg']);
    otherwise
    	fprintf('Wrong choice\n');
end
end

