function add_old_meas(obj)
%Adds old measurements to the journal
%   Detailed explanation goes here
li1 = dir('Data');
li1 = rmfield(li1,{'date';'bytes';'datenum'});
l1 = length(li1);
j = 1;
fprintf('-------------------------\n');
for i = 1:l1
    if (~isempty(regexp(li1(i).name,obj.exp,'once')))&&(li1(i).isdir == 1)
        s1(j) = li1(i); 
    	j = j+1;
    end
end
l2 = length(s1);
for i = 1:l2
	fprintf('%s\n',s1(i).name); 
    if (obj.find_meas(s1(i).name,1)~=1)
        continue
    end
    li2 = dir(['Data/',s1(i).name]);
	li2 = rmfield(li2,{'date';'bytes';'isdir';'datenum'});
	l3 = length(li2);
	k = 1;
    for j = 1:l3-2
        c = textscan(li2(j+2).name,'%s','Delimiter','.');
    	v = c{1};
        c = textscan(v{1},'%s','Delimiter','_');
        m{k} = c{1};
        if (k > 1)
            if (m{k}{2} == m{k-1}{2})
                continue
            end
        end
        k = k +1;
    end
    fprintf('-------------------------\n');
    for j = 1:k-1
        switch length(m{j}) 
        	case 2
            	fprintf('%s|%s|\n',m{j}{2},m{j}{1});
            	fprintf(obj.func,'%s|%s|\n',m{j}{2},m{j}{1});
        	case 3
            	fprintf('%s|%s|%s\n',m{j}{2},m{j}{1},m{j}{3});
            	fprintf(obj.func,'%s|%s|%s\n',m{j}{2},m{j}{1},m{j}{3});
            otherwise
                fprintf('Mistake at reading\n');
        end
    end 
    fprintf('-------------------------\n');
end
end

