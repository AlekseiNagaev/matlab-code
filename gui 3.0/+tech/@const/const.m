classdef const
    % Class that defines values of physical constants in SI and eV 
    properties (Constant)
        ev = struct('k',8.62e-5,'h',4.14e-15,'hbar',6.582e-16);
        si = struct('k',1.38e-23,'h',6.63e-34,'F0',2e-15,'e',1.6e-19,'hbar',1.054e-34);
    end
end