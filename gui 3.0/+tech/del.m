function del( varargin )
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here
for i=1:length(varargin)
    varargin{i}.delete;
end
end

