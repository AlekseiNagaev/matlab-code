function find_meas_opt(sf)
%	Display option to load if file format is present
%   .fig .mat .jpg
if exist([sf,'.fig'],'file') == 2
	fprintf('1 - .fig\n');
end
if exist([sf,'.mat'],'file') == 2
	fprintf('2 - .mat\n');
end
if exist([sf,'.jpg'],'file') == 2
	fprintf('3 - .jpg\n');
end
end

