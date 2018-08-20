 function loadState(app)
 c = textscan(class(app),'%s','Delimiter','.');
 c = c{1};
 s = c{end};
 try
    if isfield(app.appMF.States,s)
        state = app.appMF.States.(s);
        if ~isempty(state)
            % get all fields from state
            stateFields = fields(state);
            % iterate through each field
            for k=1:length(stateFields)
                if isfield(state.(stateFields{k}),'Val')
                    set(app.(stateFields{k}),'Value', state.(stateFields{k}).Val);
                end
                if isfield(state.(stateFields{k}),'Edi')
                    set(app.(stateFields{k}),'Editable', state.(stateFields{k}).Edi);
                end
                if isfield(state.(stateFields{k}),'Ena')
                    set(app.(stateFields{k}),'Enable', state.(stateFields{k}).Ena);
                end
                if isfield(state.(stateFields{k}),'Col')
                    set(app.(stateFields{k}),'Color', state.(stateFields{k}).Col);
                end
            end
        end
    end
 catch ME
     app.appMF.err(ME);
 end
 end