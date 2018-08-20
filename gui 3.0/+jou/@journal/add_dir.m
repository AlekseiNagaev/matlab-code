function s = add_dir(obj,sf)
%Folder check
%  Create folder for current date if none exist and 
%add date int the journal if no entry for it but a folder exists
s = datestr(now,'dd.mm.yy');
if ~exist([sf,s],'dir')
	mkdir([sf,s]);
end
switch obj.find_meas(s,2)
    case 1
        obj.add_date(s);
    otherwise
end
end

