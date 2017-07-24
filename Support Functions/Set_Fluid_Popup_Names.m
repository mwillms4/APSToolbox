function Set_Fluid_Popup_Names( Fluid )
%Set_Fluid_Popup_Names This function adds all the available fluids in 'Fluids.mat' to the 
%   "Fluid Type" popup lists in the APS Toolbox. For more info, see: 
%   http://www.mathworks.com/matlabcentral/answers/82930-dynamically-populating-mask-parameter-popup-list

% Note that the options for ALL POPUPS in the mask will be set to the list 
% of fluids.  

% Create a string of the available fluids
list = fieldnames(Fluid);

% loop through each entry in Fluid and create a concatenated list
fluids_str = [];
for i=1:length(list)-1
    fluids_str = strcat(fluids_str,list(i),'|');
end
fluids_str = strcat(fluids_str,list(length(list)));
popup_str = strcat('popup(',fluids_str,')');

% Set the popup string for popups named 'fld' in the mask
MaskStylesVar = get_param(gcb, 'MaskStyles');
Params        = get_param(gcb, 'DialogParameters');
Names         = fieldnames(Params);
for i=1:length(MaskStylesVar)
    if strncmpi(MaskStylesVar(i),'popup',5) && strncmpi(Names(i),'fld',3)
        MaskStylesVar(i,:) = popup_str;
    end
end
set_param(gcb, 'MaskStyles', MaskStylesVar)

% Clear the open function so that the block mask opens properly
a = get_param(gcb, 'OpenFcn');
set_param(gcb, 'OpenFcn', '');
open_system(gcb); %With no OpenFcn defined, this line will call Mask Parameter Dialog
set_param(gcb, 'OpenFcn', a); %Restore your original OpenFcn code