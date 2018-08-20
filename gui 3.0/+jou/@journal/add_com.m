function add_com(obj,com,co)
%Adds measurement comments to the journal
switch co
	case 'n'
    	fprintf(obj.func,'\n');
	case 'y'
        fprintf(obj.func,'%s\n',com);
    otherwise
    	fprintf(obj.func,'%s\n',co);
end
end

