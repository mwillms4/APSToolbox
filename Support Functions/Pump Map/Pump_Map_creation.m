% This file generates the pump maps for the Swiftech MCP35X
% The input file data was collected in Feb, 2016 by M. Williams
% Raw data can be found in:
%         \\Experimental System\Sensor Calibration Data\Pumps\Compiled.xlsx

% loading pump data
load MAP_DATA

% NOTE: all pressures are in terms of (Pout-Pin)
Q   = data.q;           % flow rate [GPM]
P   = data.pres_Pa;     % dynamic pressure [Pa]
ETA = data.eta;         % efficiency [%]
PWM = data.PWM/100;     % PWM duty cycle [%]
H   = data.h;           % theoretical head [mPG] 
WHP = data.whp;         % water horse power



%% FLOW RATE MAP CREATION 

% array for determing linear coefficiencts of h = k1 + k2*P + k3*PWM
X_h = [ones(size(H)) P PWM ];
% solving for coefficients by least-squares
a_h = X_h\H;

% determining error between the model and the data
H_model = X_h*a_h;
error = (H_model-H);
MaxErr = max(abs(error))

% Generating a lookup table 
PWMmap = 0.2:.005:0.6;
Pmap = 0:500:48000;
for c1 = 1:length(PWMmap)
    for c2 = 1:length(Pmap)
        h_map(c1,c2) =  a_h(1) + a_h(2)*Pmap(c2) + a_h(3)*PWMmap(c1);
    end
end

% plotting the map 
figure; hold on; grid on;
xlabel('Dynamic Pressure [kPa]','FontSize',12); ylabel('PWM Duty Cycle [%]','FontSize',12); zlabel('Head [m]','FontSize',12); 
surf(Pmap./1000,PWMmap,h_map,'LineStyle','none'); alpha(0.5)
% plotting the raw data
scatter3(data.pres_Pa./1000,data.PWM/100,data.h,500,'.k');
ylim([0.2 0.6]); xlim([0 max(Pmap)/1000]); view([-34 16]);
colormap jet

% Generating a flow rate look up table
rho = 1041; g = 9.81; A = 0.000126676869768334;
clear Q_calc
for c1 = 1:length(PWMmap)
    for c2 = 1:length(Pmap)
        if ((h_map(c1,c2)-(Pmap(c2))/rho/g)*2*g) > 0
            Q_map(c1,c2) = (((h_map(c1,c2)-(Pmap(c2))/rho/g)*2*g)^(1/2) * A)*60*1000/3.78541;  % GPM
        else
            Q_map(c1,c2) = 0;
        end
    end
end
figure; surf(Pmap./1000,PWMmap,Q_map,'LineStyle','none'); hold on; xlabel('Dynamic Pressure [kPa]'); 
ylabel('PWM Duty Cycle [%]'); zlabel('Flow Rate');
alpha(0.5)
scatter3(data.pres_Pa./1000,data.PWM/100,data.q,500,'.k');

%% DATA STORAGE
% Store the input vectors and lookup table array in a structure
PumpProp.units     = {'Pascals','%','GPM','kg/s','meter','Watt','%'};
PumpProp.note      = {'Pressures are Pout-Pin'};
PumpProp.P         = Pmap;
PumpProp.PWM       = PWMmap.*100;
PumpProp.Q         = Q_map;
PumpProp.mdot      = Q_map.*1.04/15.85;
PumpProp.Head      = h_map;




%% EFFICIENCY MAP CREATION
% array for determing coefficiencts of 
%      eta = k1 + k2*WHP + k3*PWM + k4*WHP^2 + k5*PWM^2 + k6*WHP*PWM
X_eta = [ones(size(PWM)) WHP PWM WHP.^2 PWM.^2 WHP.*PWM];
% solving for coefficients by least-squares
a_eta = X_eta\ETA;

% determining error between the model and the data
ETA_model = X_eta*a_eta;
error = (ETA_model-ETA);
MaxErr = max(abs(error))

Wmap = 0:.1:6.5;
PWMmap = 0.2:.005:0.6;

for c1 = 1:length(Wmap)
    for c2 = 1:length(PWMmap)
        eta_map(c1,c2) = a_eta(1) + a_eta(2)*Wmap(c1) + a_eta(3)*PWMmap(c2) + a_eta(4)*Wmap(c1)^2 + a_eta(5)*PWMmap(c2)^2 + a_eta(6)*Wmap(c1)*PWMmap(c2)  ;
    end
end

% plotting the map 
figure; surf(PWMmap,Wmap,eta_map,'LineStyle','none'); hold on; 
xlabel('PWM Duty Cycle [%]'); ylabel('Water HP [Watt]'); zlabel('Efficiency [%]');
alpha(0.5)
% plotting the raw data
scatter3(PWM,WHP,ETA,500,'.k');

h = colorbar;
ylabel(h, 'Efficiency [%]')
zlim([0 30]); ylim([0 6.5]); xlim([0.2 0.6]); view(-49,11); caxis([0 30])

%% DATA STORAGE
% Store the input vectors and lookup table array in a structure
PumpProp.WHP       = Wmap;
PumpProp.eta       = eta_map;
save PumpProp
