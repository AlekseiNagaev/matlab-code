function lft_top(app)
% Left top anchor to MF
%   Detailed explanation goes here
[xmf,ymf,~,hmf] = tech.amf_pos.mfp(app.appMF);
w = app.UI.Position(3);
h = app.UI.Position(4);
x = xmf - w;
y = (ymf + hmf) - h;
if x<0
    x = 0;
end
if y<0
    y = 0;
end
app.UI.Position = [x,y,w,h];
end

