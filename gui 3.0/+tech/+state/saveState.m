 function saveState(app)
 try
    state = [];
    % get all fields from handles
    guiFields = fields(app);
    % iterate through each field
    for k=1:length(guiFields)
        obj = app.(guiFields{k});
        % if the object is a scalar AND a graphics handle and has a field
        % called Style
        if any(isgraphics(obj,'uinumericeditfield')) || any(isgraphics(obj,'uieditfield'))
            state.(guiFields{k}).Val = get(obj,'Value');
            state.(guiFields{k}).Edi = get(obj,'Editable');
        end
        if any(isgraphics(obj,'uistatebutton')) || any(isgraphics(obj,'uicheckbox')) || any(isgraphics(obj,'uiradiobutton')) || any(isgraphics(obj,'uiswitch'))
            state.(guiFields{k}).Val = get(obj,'Value');
            state.(guiFields{k}).Ena = get(obj,'Enable');
        end
        if any(isgraphics(obj,'uilamp'))
            state.(guiFields{k}).Col = get(obj,'Color');
        end
        if any(isgraphics(obj,'uibuttongroup'))
        end
        if any(isgraphics(obj,'uitable'))
        end
        if any(isgraphics(obj,'uilable'))
        end
    end
    % write the state to file
    c = textscan(class(app),'%s','Delimiter','.');
    c = c{1};
    s = c{end};
    app.appMF.States.(s) = state;
catch ME
    app.appMF.err(ME);
end
end