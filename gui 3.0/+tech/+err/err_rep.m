function err_rep(src,ME)
            c{1} = [ME.identifier,' ',ME.message];
            c{2} = [ME.stack(1).name,' ',num2str(ME.stack(1).line)];
            %src.notify(sprintf('Error \n %s \n %s',c{1},c{2}));
            d = dialog('Position',[300 300 250 150],'Name','Error');
            txt = uicontrol('Parent',d,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String',sprintf('%s \n %s',c{1},c{2}));
            btn = uicontrol('Parent',d,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
            %delete(gcf);
end