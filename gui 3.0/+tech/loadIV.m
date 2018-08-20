sf = 'Results/Raw/IVG';
md = 'IV';
li1 = dir(sf);
li1 = rmfield(li1,{'date';'bytes';'datenum';'folder'});
l1 = length(li1);
k = 1;
s = strings;
for i = 3:l1
    if li1(i).isdir
        s(k) = li1(i).name;
        k = k + 1;
    end
end
q = length(s);
n = 1;
for i = 1:q
    str = sprintf('%s%s/',sf,s(i));
    li2 = dir(str);
    li2 = rmfield(li2,{'date';'bytes';'isdir';'datenum';'folder'});
    l2 = length(li2);
    for j = 3:l2
         c = textscan(li2(j).name,'%s','Delimiter','.');
         v = c{1};
         p = textscan(v{1},'%s','Delimiter','_');
         if strcmp(p{1}{1},md)
             if strcmp(v{2},'mat')
                 st = [str,v{1}];
                 data(n) = load(st,'data');
                 gv(n) = load(st,'gv');
                 T1(n) = load(st,'T1');
                 n = n + 1;
             end
         end
    end
end
%clear c i j k l1 li1 l2 li2 md v sf st str s q m
sf = 'Results/Processed/Ic(V,G)@';
len = length(data);
for i=1:len
    tech.surf_gv_I_V(sf,data(i).data,gv(i).gv,T1(i).T1)
end
sf = 'Results/Processed/R(T,G)@';
for i=1:len
    tech.rgt(sf,data(i).data,gv(i).gv,T1(i).T1)
end