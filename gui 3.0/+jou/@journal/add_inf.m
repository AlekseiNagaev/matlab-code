function add_inf(obj)
    ss = input('Notes for the sample? \\0 to skip\n','s');
    fprintf(obj.func,'-------------------------\n');
    while ~strcmp(ss,'\0')
        fprintf(obj.func,'%s\n',ss);
       	ss = input('','s');
    end
    fprintf(obj.func,'-------------------------\n');
end