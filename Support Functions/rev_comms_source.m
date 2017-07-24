function rev_comms_source(n_flows)
%REV_COMMS_SOURCE handles finding the unique identification tags for FROM
%   blocks in APS Toolbox components. REV_COMMS_SOURCE searches for
%   downstream blocks in a model and finds which components are connected
%   in order to grab the correct FROM TAG.
%
%   REV_COMMS_SOURCE is called in the Initialization tab of the Source
%   block in APST_Liv/Support Components
%
%   Developed by Matthew Williams - UIUC

H               = get_param(gcb,'handle');  % Get block handle
Hblock_current  = get(H);                   % Parse out handles structure
H_parent        = get_param(Hblock_current.Parent,'handle');
Hblock_parent   = get(H_parent);

%%% downstream block goto tag
n_inPorts = Hblock_parent.Ports(1);

if isempty(Hblock_parent.PortConnectivity(n_inPorts+n_flows,1).DstBlock)
    hblock_goto.GotoTag = 'NULL';   % when there is no downstream sink
else
    % loop through ports of the desination block
    for i=1:size(Hblock_parent.PortConnectivity(n_inPorts+n_flows,1).DstBlock,2)
        % downstream block parameters
        hblock_dwn = get(Hblock_parent.PortConnectivity(n_inPorts+n_flows,1).DstBlock(i));
        prt = Hblock_parent.PortConnectivity(n_inPorts+n_flows,1).DstPort(i);
        if strcmp(hblock_dwn.BlockType,'Goto')
            % get a list of the From blocks
            froms = find_system(bdroot, 'BlockType', 'From');
            % get a list of the From tags
            fromTags = get_param(froms, 'GotoTag');
            gotoTag = hblock_dwn.GotoTag;
            % get the indices of gotoTags that do not have fromTags
            indices = find(strcmp(fromTags,gotoTag));
            % get the first corresponding from tag (should only be one)
            from = froms(indices(1));
            from =  cell2mat(from);
            h_from = get_param(from,'handle');
            Hblock_parent = get(h_from);
            hblock_dwn = get(Hblock_parent.PortConnectivity(1,1).DstBlock(1));
            for j = 1:max(size(hblock_dwn.PortConnectivity))
                if hblock_dwn.PortConnectivity(j).SrcBlock == h_from
                    prt = hblock_dwn.PortConnectivity(j).Type;
                end
            end
            prt = str2num(prt) - 1;
        end
        %     str = [bdroot,'/',hblock_dwn.Name,'/Sink',num2str(prt+1),'/Goto'];
        str = [hblock_dwn.Path,'/',hblock_dwn.Name,'/Sink',num2str(prt+1),'/Goto'];
        try
            H = get_param(str,'handle');
            hblock_goto = get(H);
        catch
            %error('test')
        end
    end
end

%%% local goto block
str = [gcb,'/From'];
set_param(str,'GotoTag',hblock_goto.GotoTag);