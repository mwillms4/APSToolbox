%SQRT_LIP approximimates the sqrt() function near 0 such that Lipschitz
%   continuity is satisfied.  SQRT_LIP supports negative values for input 
%   arguments and returns sgn(x)SQRT_LIP(x)
function y = sqrt_Lip(x)
y = x/(1e-5+x^2)^0.25;