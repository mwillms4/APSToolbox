%DEFINE_MISSION defines the altitude, Mach number, ambient conditions,
%   engine bypass conditions, and ram air conditions for an aircraft
%   mission.  The mission is used for testing in,
%   Williams, M. A., "A Framework for the Control of Electro-Thermal 
%   Aircraft Power Systems," PhD Dissertation, University of Illinois at
%   Urbana-Champaign, 2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    SECTION #1: MISSION DEFINITION                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Dist.DT = 60;        % disturbance discretization (s)
Sim_Time = 14000;    % mission length (s)
PI_c = 3;            % pressure ratio of fan 
k_load = 1;
% Mission segments:
% ground, takeoff, climb, ingress, dash, engage, dash, egress, decent, hold
SegTimeVec           = [0  30  1  10  60  5   10  5   60  15  45 ]*60;
AltVec               = [.5 .5 0.5 10  10  4   4   8   8   2   2  ]*1000;
MachVec              = [0  0  0.2 0.8 0.8 1.3 1.3 0.9 0.9 0.9 0.5];
MassVec1             = [1  1  5   0.9 0.9 3   3   0.7 0.7 1.5 1.5];
MassVec2             = MachVec;
TempVec              = 15.04 - 0.00649*AltVec;
RamTempVec           = (TempVec+273) .* (1 + MachVec.^2 * (0.4/2)) - 273;

Mission.ALT          = timeseries(AltVec',cumsum(SegTimeVec));
Mission.ALT          = resample(Mission.ALT,(0:Dist.DT:Sim_Time));
Mission.ALT.Name     = '[km]';

Mission.Mach         = timeseries(MachVec',cumsum(SegTimeVec));
Mission.Mach         = resample(Mission.Mach,(0:Dist.DT:Sim_Time));
Mission.Mach.Name    = '[$\sim$]';

Mission.Tamb         = timeseries(TempVec',cumsum(SegTimeVec));
Mission.Tamb         = resample(Mission.Tamb,(0:Dist.DT:Sim_Time));
Mission.Tamb.Name    = '[$^{\circ}C$]';

Mission.Tbypass      = PI_c ^(0.4/1.4) * (Mission.Tamb + 273) - 273;
Mission.Tbypass.Name = '[$^{\circ}C$]';

Mission.Mbypass      = timeseries((MassVec1*10 +50)',cumsum(SegTimeVec));
Mission.Mbypass      = resample(Mission.Mbypass,(0:Dist.DT:Sim_Time));
Mission.Mbypass.Name = '[kg/s]';

Mission.Tram         = timeseries(RamTempVec',cumsum(SegTimeVec));
Mission.Tram         = resample(Mission.Tram,(0:Dist.DT:Sim_Time));
Mission.Tram.Name    = '[$^{\circ}C$]';

Mission.Mram         = timeseries((MassVec2*3)',cumsum(SegTimeVec));
Mission.Mram         = resample(Mission.Mram,(0:Dist.DT:Sim_Time));
Mission.Mram.Name    = '[kg/s]';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       SECTION #2: LOAD PROFILE                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% electrical loads: HVAC: wing icing & other; HVDC: hydraulics & other;
% HVAC: wing icing & AEE & other; LVDC: fadec, shed/no shed; LVAC: misc.,
% shed/no shed
SegTimeVec           = [0  30   1  10  60   5   10  5   60  15  45 ]*60;
LoadVec              =    [20  20  20  50   0   0   20  50  20   0  0;... %  HVACL Other
                            0 100 100 120   0   0    0  80  60   0  0;... %  HVACL Wing Deice
                           20 120 120  60 120 150  120  60 120  40  0;... %  HVDC Hydr
                           20  20  20  50   0   0   20  50  20   0  0;... %  HVDC Other
                          250 300 300 200 400 200  250 200 300 200  0;... %  HVACR Other
                            0 100 100 120   0   0    0  80  60   0  0;... %  HVACR Wing Deice
                            0   0   0   0 200 600    0   0   0   0  0;... %  HVAC AEE
                           40  40  40  50  40  40   40  40  40  40  0;... %  LVDC FADECs
                           20  40  40  60  40  30   40  70  50  20  0;... %  LVDC Shed
                           20  40  40  60  40  70   40  70  50  20  0;... %  LVDC No Shed
                           50  50  50  50  50  50   50  50  50  50  0;... %  LVAC misc.
                           20  40  40  60  40  30   40  70  50  20  0;... %  LVAC Shed
                           20  40  40  60  40  70   40  70  50  20  0;... %  LVAC No Shed
                           15  15  15  15  15  15   15  15  15  15  0];   %  cabin

LoadVec([1 4 5 9 12],:) = k_load*LoadVec([1 4 5 9 12],:);
                       
Mission.HVACL_Other         = timeseries(LoadVec(1,:)',cumsum(SegTimeVec));
Mission.HVACL_Other.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVACL_Other         = resample(Mission.HVACL_Other,(0:Dist.DT:Sim_Time));
Mission.HVACL_Other.Name    = '[kW]';

Mission.HVACL_Wing         = timeseries(LoadVec(2,:)',cumsum(SegTimeVec));
Mission.HVACL_Wing.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVACL_Wing         = resample(Mission.HVACL_Wing,(0:Dist.DT:Sim_Time));
Mission.HVACL_Wing.Name    = '[kW]';

Mission.HVDC_Hydr         = timeseries(LoadVec(3,:)',cumsum(SegTimeVec));
Mission.HVDC_Hydr.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVDC_Hydr         = resample(Mission.HVDC_Hydr,(0:Dist.DT:Sim_Time));
Mission.HVDC_Hydr.Name    = '[kW]';

Mission.HVDC_Other         = timeseries(LoadVec(4,:)',cumsum(SegTimeVec));
Mission.HVDC_Other.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVDC_Other         = resample(Mission.HVDC_Other,(0:Dist.DT:Sim_Time));
Mission.HVDC_Other.Name    = '[kW]';

Mission.HVACR_Other         = timeseries(LoadVec(5,:)',cumsum(SegTimeVec));
Mission.HVACR_Other.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVACR_Other         = resample(Mission.HVACR_Other,(0:Dist.DT:Sim_Time));
Mission.HVACR_Other.Name    = '[kW]';

Mission.HVACR_Wing         = timeseries(LoadVec(6,:)',cumsum(SegTimeVec));
Mission.HVACR_Wing.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVACR_Wing         = resample(Mission.HVACR_Wing,(0:Dist.DT:Sim_Time));
Mission.HVACR_Wing.Name    = '[kW]';

Mission.HVAC_AEE         = timeseries(LoadVec(7,:)',cumsum(SegTimeVec));
Mission.HVAC_AEE.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVAC_AEE         = resample(Mission.HVAC_AEE,(0:Dist.DT:Sim_Time));
Mission.HVAC_AEE.Name    = '[kW]';

Mission.LVDC_FADECs         = timeseries(LoadVec(8,:)',cumsum(SegTimeVec));
Mission.LVDC_FADECs.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVDC_FADECs         = resample(Mission.LVDC_FADECs,(0:Dist.DT:Sim_Time));
Mission.LVDC_FADECs.Name    = '[kW]';

Mission.LVDC_Shed         = timeseries(LoadVec(9,:)',cumsum(SegTimeVec));
Mission.LVDC_Shed.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVDC_Shed         = resample(Mission.LVDC_Shed,(0:Dist.DT:Sim_Time));
Mission.LVDC_Shed.Name    = '[kW]';

Mission.LVDC_NoShed         = timeseries(LoadVec(10,:)',cumsum(SegTimeVec));
Mission.LVDC_NoShed.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVDC_NoShed         = resample(Mission.LVDC_NoShed,(0:Dist.DT:Sim_Time));
Mission.LVDC_NoShed.Name    = '[kW]';

Mission.LVAC_Misc         = timeseries(LoadVec(11,:)',cumsum(SegTimeVec));
Mission.LVAC_Misc.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVAC_Misc         = resample(Mission.LVAC_Misc,(0:Dist.DT:Sim_Time));
Mission.LVAC_Misc.Name    = '[kW]';

Mission.LVAC_Shed         = timeseries(LoadVec(12,:)',cumsum(SegTimeVec));
Mission.LVAC_Shed.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVAC_Shed         = resample(Mission.LVAC_Shed,(0:Dist.DT:Sim_Time));
Mission.LVAC_Shed.Name    = '[kW]';

Mission.LVAC_NoShed         = timeseries(LoadVec(13,:)',cumsum(SegTimeVec));
Mission.LVAC_NoShed.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVAC_NoShed         = resample(Mission.LVAC_NoShed,(0:Dist.DT:Sim_Time));
Mission.LVAC_NoShed.Name    = '[kW]';

Mission.Cabin               = timeseries(LoadVec(14,:)',cumsum(SegTimeVec));
Mission.Cabin.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.Cabin               = resample(Mission.Cabin,(0:Dist.DT:Sim_Time));
Mission.Cabin.Name          = '[kW]';


BusVec               =    [1 1 1 1 1 1 1 1 1 1 1;... %  HVDC Bus (1 = Left 0 = Right)
                           1 1 1 1 0 0 1 1 1 1 1;... %  LVDC Bus (0 = Left 1 = Right)
                           1 1 1 1 0 0 1 1 1 1 1];   %  LVAC Bus (0 = Left 1 = Right)
                       
Mission.HVDC_Bus         = timeseries(BusVec(1,:)',cumsum(SegTimeVec));
Mission.HVDC_Bus.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.HVDC_Bus         = resample(Mission.HVDC_Bus,(0:Dist.DT:Sim_Time));
Mission.HVDC_Bus.Name    = '[-]';        

Mission.LVDC_Bus         = timeseries(BusVec(2,:)',cumsum(SegTimeVec));
Mission.LVDC_Bus.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVDC_Bus         = resample(Mission.LVDC_Bus,(0:Dist.DT:Sim_Time));
Mission.LVDC_Bus.Name    = '[-]';  

Mission.LVAC_Bus         = timeseries(BusVec(3,:)',cumsum(SegTimeVec));
Mission.LVAC_Bus.DataInfo.Interpolation = tsdata.interpolation('zoh');
Mission.LVAC_Bus         = resample(Mission.LVAC_Bus,(0:Dist.DT:Sim_Time));
Mission.LVAC_Bus.Name    = '[-]';  


%%
if 0; return; end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         SECTION #3: PLOTTING                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% default values
set(0,'defaultLineLineWidth', 2)
set(0,'defaultAxesFontName' , 'Times')
set(0,'defaultTextFontName' , 'Times')
set(0,'defaultAxesFontSize' , 11)
set(0,'defaultTextFontSize' , 11)
set(0,'defaulttextinterpreter','latex')
set(0,'defaultAxesGridLineStyle','-.')

% figure;plot(Mission.HVACL_Other);leg{1} = 'HVACL Other';hold on
%        plot(Mission.HVACL_Wing);leg{2} = 'HVACL Wing';
%        plot(Mission.HVDC_Hydr);leg{3} = 'HVDC Hydr';
%        plot(Mission.HVDC_Other);leg{4} = 'HVDC Other';
%        plot(Mission.HVACR_Other);leg{5} = 'HVACR Other';
%        plot(Mission.HVACR_Wing);leg{6} = 'HVACR Wing';
%        plot(Mission.HVAC_AEE);leg{7} = 'HVAC AEE';
%        plot(Mission.LVDC_FADECs);leg{8} = 'LVDC FADECs';
%        plot(Mission.LVDC_Shed);leg{9} = 'LVDC Shed';
%        plot(Mission.LVDC_NoShed);leg{10} = 'LVDC No Shed';
%        plot(Mission.LVAC_Misc);leg{11} = 'LVAC Misc';
%        plot(Mission.LVAC_Shed);leg{12} = 'LVAC Shed';
%        plot(Mission.LVAC_NoShed);leg{13} = 'LVAC No Shed';
%        hold off; legend(leg)
%%
% time vector and marker locations
t = cumsum(SegTimeVec);
t_marker = mean([t(1:end-1)' t(2:end)'],2);
t_marker = t_marker([1 3:end])-75;
phase_marker = {'1','2','3','4','5','6','7','8','9'};

clearvars SegTimeVec AltVec MachVec MassVec1 MassVec2 TempVec RamTempVec LoadVec

%%

MissionCritLoads = sum([Mission.HVAC_AEE.data,Mission.LVDC_NoShed.data,Mission.LVAC_NoShed.data,Mission.LVAC_Misc.data]');
FlightCritLoads = sum([Mission.HVACL_Wing.data,Mission.HVDC_Hydr.data,Mission.HVACR_Wing.data,Mission.LVDC_FADECs.data]');
ShedLoads = sum([Mission.LVDC_Shed.data,Mission.LVAC_Shed.data,Mission.HVACL_Other.data,Mission.HVDC_Other.data]');

figure('Units','inches'); hold on; box on; grid on;
set(gcf,'Position',[8 4 8.5 3])

a = area(Mission.HVAC_AEE.time,[FlightCritLoads;MissionCritLoads;ShedLoads]');
xlabel('Time [s]'); ylabel('[kW]')
set(a(3),'FaceColor',[.75 .75 .75])
set(a(2),'FaceColor',[.5 .5 .5])
set(a(1),'FaceColor',[.25 .25 .25])

legend('Flight Critical','Mission Critical','Sheddable')
plot(t         , ones(size(t))*1100,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*1100,'k+','LineWidth',1)
text(t_marker,ones(size(t_marker))*1100+35,phase_marker)
xlim([0 14000])
set(gca,'XTick', 0:2500:Sim_Time);

if 0
export_fig load_profile -pdf -transparent
end 
return
%%
h = figure; 
set(gcf,'Position',[680 231 965 650])

%% altitude
subplot(4,2,1:2); box on; grid on; hold on; 
plot(Mission.ALT/1000,'k','LineWidth',2);  
title(''); xlabel(''); ylabel({'Altitude','[km]'},'interpreter','tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.ALT)*1.1/1000,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.ALT)*1.1/1000,'k+','LineWidth',1)
text(t_marker,ones(size(t_marker))*max(Mission.ALT)*1.25/1000,phase_marker)

YL = ylim;
xlim([0 Sim_Time]); ylim([-2 max(Mission.ALT)*1.45/1000])
set(gca,'XTick', 0:2500:Sim_Time);

%% mach number
subplot(4,2,3); box on; grid on; hold on; 
plot(Mission.Mach,'k','LineWidth',2);  
title(''); xlabel(''); ylabel({'Mach','[-]'},'Interpreter', 'tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Mach)*1.1,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Mach)*1.1,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Tamb)*2,phase_marker)

xlim([0 Sim_Time]); ylim([-0.1 1.6])
set(gca,'XTick', 0:2500:Sim_Time);

%% ambient temperature
subplot(4,2,4); box on; grid on; hold on; 
plot(Mission.Tamb,'k','LineWidth',2);  
title(''); xlabel(''); ylabel({'Amb. Temp.','[°C]'},'Interpreter', 'tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Tamb)*1.5,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Tamb)*1.5,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Tamb)*2,phase_marker)

xlim([0 Sim_Time]); ylim([-55 25])
set(gca,'XTick', 0:2500:Sim_Time);

%% bypass temperature
subplot(4,2,5); box on; grid on; hold on; 
plot(Mission.Tbypass,'k','LineWidth',2); 
title(''); xlabel(''); ylabel({'Bypass Temp.','[°C]'},'Interpreter', 'tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Tbypass)*1.1,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Tbypass)*1.1,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Tbypass)*1.2,phase_marker)

xlim([0 Sim_Time]); ylim([20 140]); 
set(gca,'YTick', 20:40:140); set(gca,'XTick', 0:2500:Sim_Time);

%% ram air temperature
subplot(4,2,6); box on; grid on; hold on; 
plot(Mission.Tram,'k','LineWidth',2); 
title(''); xlabel(''); ylabel({'RAM Air Temp.','[°C]'},'Interpreter', 'tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Tram)*1.1,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Tram)*1.1,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Tram)*1.25,phase_marker)

YL = ylim;
xlim([0 Sim_Time]); ylim([-35 100])
set(gca,'XTick', 0:2500:Sim_Time);

%% bypass flow rate
subplot(4,2,7); box on; grid on; hold on; 
plot(Mission.Mbypass,'k','LineWidth',2); ylabel({'Bypass Flow Rate','[kg/s]'},'Interpreter', 'tex')
title(''); xlabel('Time [s]');

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Mbypass)*1.05,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Mbypass)*1.05,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Mbypass)*1.1,phase_marker)

xlim([0 Sim_Time]); ylim([45 115])
set(gca,'YTick', 50:25:125); set(gca,'XTick', 0:2500:Sim_Time);

%% ram air flow rate
subplot(4,2,8); box on; grid on; hold on; 
plot(Mission.Mram,'k','LineWidth',2); 
title(''); xlabel('Time [s]');  ylabel({'RAM Air Flow Rate','[kg/s]'},'Interpreter', 'tex')

% mission phase markers
plot(t         , ones(size(t))*max(Mission.Mram)*1.1,'k','LineWidth',2)
plot(t(3:end-1), ones(size(t(3:end-1)))*max(Mission.Mram)*1.1,'k+','LineWidth',1)
% text(t_marker,ones(size(t_marker))*max(Mission.Mram)*1.2,phase_marker)

xlim([0 Sim_Time]); ylim([ -0.1 5])
set(gca,'XTick', 0:2500:Sim_Time);
set(gca,'yticklabel',num2str(get(gca,'ytick')','%.1f'))

subplot(4,2,1:2); YL = ylim;
text(13500,(YL(2)-YL(1))*0.12+YL(1),['(',char(97),')'])
for i = 3:8
    subplot(4,2,i);
    YL = ylim;
    text(13100,(YL(2)-YL(1))*0.12+YL(1),['(',char(95+i),')'])
end


% export_fig mission_profile -pdf -transparent

clearvars h i phase_marker PI_c t t_marker YL