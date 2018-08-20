h = gcf;
axesObjs = get(h, 'Children');  %axes handles
dataObjs = get(axesObjs, 'Children');
objTypes = get(dataObjs, 'Type');
xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
ydata = get(dataObjs, 'YData');
%zdata = get(dataObjs, 'ZData'); 