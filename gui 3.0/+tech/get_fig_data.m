function [x,y,z] = get_fig_data
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
h = gcf;
axesObjs = get(h, 'Children');
dataObjs = get(axesObjs, 'Children');
x = get(dataObjs, 'XData');
y = get(dataObjs, 'YData');
z = get(dataObjs, 'ZData');
end

