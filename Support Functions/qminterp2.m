function [Zi delx dely xref yref ixlow iylow] = qminterp2(X,Y,Z,xi,yi)
% QMINTERP2 2-dimensional fast interpolation (for a 2D matrix with look-up
%           vectors)
%
% Usage:
%   yi = qminterp2(X,Y,Z,xi,yi)  - Similar usage to interp2
%
% Usage restrictions
%   X and Y must be monotonic and evenly spaced
%   X and Y must be VECTORS
%   Z must be a 2D array.  In this case Z(i,j) is such that Z(i,j)
%     corresponds to Z at x = X(j) and y = Y(i)
%   xi,yi are scalars, not vectors
%   Only bi-linear interpolation is used   
%   Presently, no extrapolation is performed
%
%
% Error checking
%   WARNING: Little error checking is performed on the X or Y arrays. If these
%   are not monotonic and evenly spaced, erroneous results will be
%   returned.
%
% Author: T.L. McKinley - 08 Jan '07
%

%{
% Library checking - makes code super slow for large X and Y
%
% This technique used in the qinterp2 routine from the MATLAB
% user community website.
%
% it is commented out in this version of the code.
%
% DIFF_TOL = 1e-14;
% if ~all(all( abs(diff(diff(X))) < DIFF_TOL*max(max(abs(X))) ))
%     error('%s is not evenly spaced',inputname(1));
% end
% if ~all(all( abs(diff(diff(Y)))  < DIFF_TOL*max(max(abs(Y))) ))
%     error('%s is not evenly spaced',inputname(2));
% end
%}

% find vector increment and lower bounds
delx = X(2)-X(1);
dely = Y(2)-Y(1);
xref = (xi - X(1))/delx;
yref = (yi - Y(1))/dely;
ixlow = floor(xref)+1;
iylow = floor(yref)+1;

if ( ixlow > 0 && ixlow < length(X) && iylow > 0 && iylow < length(Y) )
%
%  interpolate using natural coordinates
%
    xnat = (xi - X(ixlow))/delx;
    ynat = (yi - Y(iylow))/dely;
    Zi = Z(iylow,ixlow)     * (1.0 - xnat) * (1.0 - ynat) + ...
         Z(iylow,ixlow+1)   *     xnat     * (1.0 - ynat) + ...
         Z(iylow+1,ixlow)   * (1.0 - xnat) *     ynat     + ...
         Z(iylow+1,ixlow+1) *     xnat     *     ynat;
else
    Zi = NaN;
end
