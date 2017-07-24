%% Generate a Fluid Property Lookup Table using CoolProp

%% Setup

load('Fluids')

% Use to verify CoolProp against the RefProp Water Table
% Fluid_Name = 'Water2';
% CP_Name = 'Water';
% T = Fluid.Water.T;
% P = Fluid.Water.P;

% Use for 50% Propylene Glycol Solution
Fluid_Name = 'PG50';
CP_Name = 'MPG-50%';
T = linspace(-30,100,100); % C
P = linspace( 10,300,100); % kPa
Bulk_Mod = 3.4*10^6;       % Hard code bulk modulus, kPa

%% Generate lookup tables

Rho_pt = zeros(length(T),length(P));
C_pt   = zeros(length(T),length(P));
Mu_pt  = zeros(length(T),length(P));
K_pt   = zeros(length(T),length(P));
for m=1:length(T)
    for n=1:length(P)
        Rho_pt(m,n) = PropsSI('D','T',T(m)+273.15,'P',P(n)*1000,CP_Name);      % Density
        C_pt(m,n)   = PropsSI('C','T',T(m)+273.15,'P',P(n)*1000,CP_Name)/1000; % Cp
        Mu_pt(m,n)  = PropsSI('V','T',T(m)+273.15,'P',P(n)*1000,CP_Name);      % Mu
        K_pt(m,n)   = PropsSI('L','T',T(m)+273.15,'P',P(n)*1000,CP_Name)/1000; % K
    end
end

% Transpose CoolProp Maps
Rho_pt = Rho_pt';
C_pt   = C_pt';
Mu_pt  = Mu_pt';
K_pt   = K_pt';

%% Test

% Ptest = 200;
% Ttest = 50;
% 
% Ptest = 600;
% Ttest = 50;
% 
% Rho_test_REF  = qminterp2(Fluid.Water.P, Fluid.Water.T, Fluid.Water.Rho_pt, Ptest, Ttest)
% Rho_test_COOL = qminterp2(P, T, Rho_pt, Ptest, Ttest)
%
% Cp_test_REF   = qminterp2(Fluid.Water.P, Fluid.Water.T, Fluid.Water.C_pt,   Ptest, Ttest)
% Cp_test_COOL  = qminterp2(P, T, C_pt,   Ptest, Ttest)
%
% Mu_test_REF   = qminterp2(Fluid.Water.P, Fluid.Water.T, Fluid.Water.Mu_pt,  Ptest, Ttest)
% Mu_test_COOL  = qminterp2(P, T, Mu_pt,  Ptest, Ttest)
%
% K_test_REF    = qminterp2(Fluid.Water.P, Fluid.Water.T, Fluid.Water.K_pt,    Ptest, Ttest)
% K_test_COOL   = qminterp2(P, T, K_pt,   Ptest, Ttest)
% 
% figure(1)
% surf(Fluid.Water.Mu_pt)
% figure(2)
% surf(Fluid.Water2.Mu_pt)

%% Save

% Bundle fluid properties
Fluid.(Fluid_Name).P = P;
Fluid.(Fluid_Name).T = T;
Fluid.(Fluid_Name).Rho_pt   = Rho_pt;
Fluid.(Fluid_Name).C_pt     = C_pt;
Fluid.(Fluid_Name).Mu_pt    = Mu_pt;
Fluid.(Fluid_Name).K_pt     = K_pt;
Fluid.(Fluid_Name).Bulk_Mod = Bulk_Mod;

% Append onto existing map
save('Fluids','Fluid')