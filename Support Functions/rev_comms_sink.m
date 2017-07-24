function rev_comms_sink()
%REV_COMMS_SINK handles generating a unique identification tag for FROM
%   blocks in APS Toolbox components.
%
%   REV_COMMS_SINK is called in the block Callbacks for the Sink block in 
%   APST_Liv/Support Components
%
%   Developed by Matthew Williams - UIUC

H           = get_param(gcb,'handle');  % Get block handle                           
Hblock      = get(H);                   % Parse out handles structure         
str         = [Hblock.Path, Hblock.Name];
str(~ismember(str,['A':'Z' 'a':'z' '0':'9' '_'])) = '';                      
set_param([gcb, '/Goto'],'GotoTag',['gdata_',str]);
                                                                                 
clear H Hblock str           