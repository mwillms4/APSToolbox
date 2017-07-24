function MAP = generate_turb_map(PR_MAX,MF_MAX,eta_MAX,eta_MIN,plot_flg)
%GENERATE_TURB_MAP generates a scaled turbine efficiency and mass flow rate
%   map as a function of pressure ratio.  
%
%   PR_MAX is the maximum pressure ratio for the turbine.
%   MF_MAX is the maximum mass flow rate for the turbine.
%   eta_MAX is the maximum efficiency for the turbine in percent.
%   eta_MIN is the minimum efficiency for the turbine in percent.
%   plot_flg will plot the efficiency and mass flow rate curves if
%   plot_flg=1.
%
%   MAP contains a linearly spaced vector of pressure ratios from 1 to
%   PR_MAX, and corresponding lookups for mass flow rate (MAP.MDOT) and
%   efficiency (MAP.ETA).
%
%   Note: raw_data.m contains scaled data used to make the turbine map.
%
%   Author: Matthew Williams - May 2017

raw_data;
Data002(:,1) = (Data002(:,1)-1)*(PR_MAX-1)+1;
Data002(:,2) = Data002(:,2)*MF_MAX;


x = Data002(:,1); 
y = Data002(:,2); 
X_MDL = [ones(size(x)) x x.^2 x.^3 ];
k = X_MDL\y;



%% generate 1D lookup tables

MAP.PR_VEC = linspace(1,max(x),20);

MAP.MDOT = zeros(size(MAP.PR_VEC));
for i = 1:max(size(MAP.PR_VEC))
    MAP.MDOT(i) = [1 MAP.PR_VEC(i) MAP.PR_VEC(i).^2 MAP.PR_VEC(i).^3 ]*k;
end

MAP.ETA = zeros(size(MAP.PR_VEC));
for i = 1:max(size(MAP.PR_VEC))
    MAP.ETA(i) = MAP.MDOT(i)/max(MAP.MDOT);
end
MAP.ETA = (MAP.ETA*(eta_MAX-eta_MIN)+eta_MIN)/100;
%%
if plot_flg
    set(0,'defaultLineLineWidth',2)
    set(0,'defaultAxesFontName', 'Times')
    set(0,'defaultTextFontName', 'Times')
    set(0,'defaultAxesFontSize', 11)
    set(0,'defaultTextFontSize', 11)

    figure('Units','inches'); hold on; box on; grid on;
set(gcf,'Position',[8 4 8.5 3])
    plot(MAP.PR_VEC,MAP.MDOT,'k','LineWidth',2);
    ylim([0 5]);
    set(gca,'ycolor','k')
    ylabel('Mass Flow Rate [kg/s]')
    
    ylim([0 3])
    
    yyaxis right
    plot(MAP.PR_VEC,MAP.ETA,'-r','LineWidth',2); 
    ylim([0 eta_MAX]/100);
    set(gca,'ycolor','r')
    ylabel('Efficiency [%]')
    xlabel('$\Pi_T$')
    
    ylim([0.4 0.9])
    set(gca,'YTick', 0.4:0.1:0.9); % set(gca,'XTick', 0:2500:Sim_Time);
    set(gca,'yticklabel',num2str(100*get(gca,'ytick')','%.0f'))

end