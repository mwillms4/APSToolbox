function varargout = data_manager(varargin)
% DATA_MANAGER MATLAB code for data_manager.fig
%      DATA_MANAGER GUI allows the user to select from supported data
%      signals in the toolset.  Data sink blocks
%
%      H = DATA_MANAGER returns the handle to a new DATA_MANAGER or the handle to
%      the existing singleton*.
%
%      DATA_MANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_MANAGER.M with the given input arguments.
%
%      DATA_MANAGER('Property','Value',...) creates a new DATA_MANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before data_manager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to data_manager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Originally created by Matt Williams 15-Apr-2014
% Last Modified by Matt Williams 12-Jun-2017

% Change log:
% 12-Jun-2017 -- Fixed a bug that broke from/goto links if the model name
% changes; fixed a bug that would link the wrong signal if the apply button
% was hit after additional signals had been added to the variable list

% Begin initialization code - DO NOT EDIT 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @data_manager_OpeningFcn, ...
                   'gui_OutputFcn',  @data_manager_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - ^^^^^^^^^^^^^^^^ DO NOT EDIT ^^^^^^^^^^^^^^^^


% --- Executes just before data_manager is made visible.
function data_manager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to data_manager (see VARARGIN)

% Choose default command line output for data_manager
handles.output = hObject;

% find all FROM blocks in the data manager block.  This corresponds to the
% blocks that were previously selected
ff    = find_system(handles.blk,'FollowLinks','on','LookUnderMasks','all','BlockType','From');

if ~isempty(ff)     % if not empty
    s=cellfun(@size,ff,'uniform',false);
    [trash is]=sortrows(cat(1,s{:}),[1 2]);
    ff=ff(is);
    for i = 1:length(ff)
        h = get_param(ff{i},'handle');                  % from block handle
        hblock = get(h);                                % from block parameters
        sig_str{i} = hblock.UserData{1,1};              % signal for the corresponding from block
%         handles.var_ind(i,1) = hblock.UserData{1,2};
        index = find(strcmp(handles.full_var_list, sig_str{i}));
        handles.var_ind(i,1) = index;                   % variable index for the signal
    end

    % initializes the list for output_vars_listbox
    set(handles.output_vars_listbox,'string',sig_str)     

end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes data_manager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = data_manager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function global_vars_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to global_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% grabs the full array of global data goto tags and places them into a cell structure
goto_arr = find_system(bdroot,'LookUnderMasks','all','FollowLinks','on','Name','global_data_goto');

cnt = 1;    % initialized counter for var_list indexing
for i = 1:size(goto_arr,1)

    h_i = get_param(goto_arr{i},'handle');              % grabs the handle of the i-th global data goto block
    hblock = get(h_i);                                  % output of the block properties for the i-th global data goto block
    GotoTag = hblock.GotoTag;                           % GoTo tag for the i-th global data goto block
    h_2 = get_param(hblock.Parent,'handle');            % grab the handle of the data_sink block
    hblock_2 = get(h_2);                                % grab the block properties of the data_sink block
    bus_handle = hblock_2.PortConnectivity.SrcBlock;    % grab the handle of the bus input for the data_sink block
    comp_name = hblock_2.Parent;                        % name of the component block
    comp_name = comp_name(size(bdroot,2)+2:end);        % trimming off the simulink model name
    hblock_bus = get(bus_handle);                       % grab the block properties of the signal bus
    bus_var_list = hblock_bus.InputSignalNames;         % variable list of inputs to the bus         

    for j = 1:size(bus_var_list,2)
        var_list{cnt} = [comp_name, '/',bus_var_list{j}];   % full list of variables and their corresponding components
        tag_list{cnt} = GotoTag;                            % full list of corresponding goto tags
        cnt = cnt + 1;      % index incremental counter
    end

end

set(hObject,'String',var_list); % fills the globar_vars_listbox with the list of variables

handles.full_var_list = var_list;    % storing the variable list in guidata
handles.full_tag_list = tag_list;    % storing the goto tag list in guidata
handles.var_ind = 0;                 % initializing var_ind
handles.blk = gcb;                   % store current block handle in guidata

% Update handles structure
guidata(hObject, handles);





% --- Executes during object creation, after setting all properties.
function output_vars_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcbo);       % grabs current guidata

var_list = get(handles.global_vars_listbox,'string');           % grabs full variable list from global_vars_listbox
curr_var = var_list(get(handles.global_vars_listbox,'value'));  % grabs current selected variable

curr_var_list = get(handles.output_vars_listbox,'string');      % grabs full variable list from output_vars_listbox

if ~isempty(curr_var_list)
    new_var_list = [curr_var_list; curr_var];                   % concatenates the old list with the selected var
    set(handles.output_vars_listbox,'string',new_var_list);     % sets the new list for output_vars_listbox
    
    % tracking indeces for the selected variables
    handles.var_ind(size(handles.var_ind,1)+1,1) = get(handles.global_vars_listbox,'value');
else
    set(handles.output_vars_listbox,'string',curr_var);         % sets the new list for output_vars_listbox
    
    % tracking indeces for the selected variables
    handles.var_ind(1,1) = get(handles.global_vars_listbox,'value');
end

% advances the cursor to select the next variable unless it is currently
% the last variable in the list
curr_place = get(handles.global_vars_listbox,'value');
if  curr_place < size(get(handles.global_vars_listbox,'string'),1)
    set(handles.global_vars_listbox,'value',curr_place+1);      % moves the highlighted cursor forward 1
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcbo);       % grabs current guidata

var_list = get(handles.output_vars_listbox,'string');           % grabs full variable list from global_vars_listbox

if ~isempty(var_list)       % execute when output_vars_listbox has entries
    curr_var = var_list(get(handles.output_vars_listbox,'value'));  % grabs current selected variable
    curr_place = get(handles.output_vars_listbox,'value');          % determines current selected variable

    % if the current selected variable is the last one, but not the only selected signal
    if curr_place == size(get(handles.output_vars_listbox,'string'),1) && curr_place ~= 1; 
        new_var_list = var_list(1:curr_place-1);                % populating the new list
        set(handles.output_vars_listbox,'value',curr_place-1);  % setting the list
        handles.var_ind = handles.var_ind(1:curr_place-1);      % updating variable indeces
        
    % if the current selected variable is the only variable in the selected signal list
    elseif curr_place == size(get(handles.output_vars_listbox,'string'),1) && curr_place == 1; 
        new_var_list = '';          % this removes the list
        handles.var_ind = 0;        % updating variable indeces
        
    elseif curr_place == 1;     % if the current selected signal is the first on the list
        new_var_list = var_list(2:end);             % removing the first entry
        handles.var_ind = handles.var_ind(2:end);   % updating variable indeces
        
    else        % if the selected variable is in the middle
        new_var_list = [var_list(1:curr_place-1); var_list(curr_place+1:end)];
        % updating variable indeces
        handles.var_ind = [handles.var_ind(1:curr_place-1); handles.var_ind(curr_place+1:end)];
    end

    set(handles.output_vars_listbox,'string',new_var_list);         % sets the new list for output_vars_listbox
    
end
% Update handles structure
guidata(hObject, handles);

% --- Executes on selection change in output_vars_listbox.
function output_vars_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to output_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output_vars_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_vars_listbox

% --- Executes on selection change in output_format.
function output_format_Callback(hObject, eventdata, handles)
% hObject    handle to output_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns output_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from output_format

% --- Executes on selection change in global_vars_listbox.
function global_vars_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to global_vars_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns global_vars_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from global_vars_listbox

% --- Executes during object creation, after setting all properties.
function output_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in apply_pushbutton.
function apply_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to apply_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_param(gcb, 'LinkStatus', 'inactive')    % disable the library link

handles = guidata(gcbo);       % grab GUI data
blk = handles.blk;             % current data manager block

handles.out_list = get(handles.output_vars_listbox,'string');  

% all blocks under the data manager
ff    = find_system(blk,'FollowLinks','on','LookUnderMasks','all','BlockType','From');
fbs   = find_system(blk,'FollowLinks','on','LookUnderMasks','all','BlockType','BusSelector');
fbus  = find_system(blk,'FollowLinks','on','LookUnderMasks','all','BlockType','BusCreator');
fmux  = find_system(blk,'FollowLinks','on','LookUnderMasks','all','BlockType','Mux');
fsys  = find_system(blk,'FollowLinks','on','LookUnderMasks','all','SearchDepth',1,'BlockType','SubSystem');

% deleting the blocks before creation of new blocks
delete_block(ff); delete_block(fbs); delete_block(fmux); delete_block(fbus);
delete_block(fsys(2:end));

% data output block
fout  = find_system(blk,'FollowLinks','on','LookUnderMasks','all','BlockType','Outport');

% delete remaining unconnected lines
delete_unconnected_lines(blk);

% position vectors; dP is delta position on each block addition
posf = [20, 108, 60, 122]; posbs = [300, 105, 305, 125];  dP = 30 ;
posmuxbus = [700, 100, 705, 100+size(handles.var_ind,1)*dP]; 
possys = [420, 102, 480, 128]; 

mask_str ='str =''' ;

% EXECUTES IF THERE ARE SELECTED OUTPUT VARIABLES
if handles.var_ind(1,1) ~= 0
    
    % adding the MUX block
    if get(handles.output_format, 'Value') == 1
        fbus = add_block('built-in/BusCreator', [blk '/Bus Creator'], 'Position', posmuxbus,...
            'Inputs', num2str(size(handles.var_ind,1)), 'DisplayOption', 'bar', 'ShowName', 'off');
        fff = fbus;
    elseif get(handles.output_format, 'Value') == 2
        fmux = add_block('built-in/Mux', [blk '/Mux'],'Position', posmuxbus,...
        'Inputs', num2str(size(handles.var_ind,1)), 'DisplayOption', 'bar', 'ShowName', 'off');
        fff = fmux;
    else
        error('Only bus and mux structures of output signals are supported')
    end

    % adding LINE between MUX and OUT blocks
    ln1 = get(fff, 'PortHandles');
    ln2 = get_param(fout{1}, 'PortHandles');
    add_line(blk, ln1.Outport, ln2.Inport, 'autorouting', 'on');


    for i = 1:length(handles.var_ind)
        % name of the signal
        str = handles.full_var_list{handles.var_ind(i,1)};

        
        
        % adding the FROM block
        ff = add_block('built-in/From',[blk '/From' num2str(i)],'Position',posf+[0 dP*(i-1) 0 dP*(i-1)], 'ShowName', 'off');
        set(ff,'GotoTag',handles.full_tag_list{handles.var_ind(i,1)}) 
        
        % the following two lines save index information in UserData and
        % ensure that the data is saved with the model
        set(ff,'UserData',{str,handles.var_ind(i,1)})
        set_param(ff, 'UserDataPersistent', 'on');
        
        % adding the BUS SELECTOR block
        fbs = add_block('built-in/BusSelector',[blk '/Bus Selector' num2str(i)],'Position',posbs+[0 dP*(i-1) 0 dP*(i-1)], 'ShowName', 'off');
        set(fbs,'OutputSignals',str(max(strfind(str,'/'))+1:end));

        % adding LINES between FROM and BUS SELECTOR blocks
        ln1 = get(ff,'PortHandles'); ln2 = get(fbs,'PortHandles');
        hline = add_line(blk,ln1.Outport,ln2.Inport,'autorouting','on');
        set_param(hline,'Name',str)

        % adding the SUBSYSTEM block -- allows change of signal names
        fsys = add_block('built-in/SubSystem',[blk '/SubSystem' num2str(i)],'Position',possys+[0 dP*(i-1) 0 dP*(i-1)], 'ShowName', 'off');
        fin = add_block('built-in/Inport',[blk '/SubSystem' num2str(i) '/Rename']);
        fout = add_block('built-in/Outport',[blk '/SubSystem' num2str(i) '/Bus']);
        ln1 = get(fin,'PortHandles'); ln2 = get(fout,'PortHandles');
        add_line([blk '/SubSystem' num2str(i)],ln1.Outport,ln2.Inport,'autorouting','on');

        % adding LINES between BUS SELECTOR and SUBSYSTEM blocks
        ln1 = get(fbs,'PortHandles'); ln2 = get(fsys,'PortHandles');
        add_line(blk,ln1.Outport,ln2.Inport,'autorouting','on');

        % adding LINES between SUBSYSTEM and MUX/BUS blocks
        ln1 = get(fsys,'PortHandles'); ln2 = get(fff,'PortHandles');
        hline = add_line(blk,ln1.Outport,ln2.Inport(i),'autorouting','on');
        
%         % shortening the signal name to include component & signal only
%         str_ndx = strfind(str,'/');
%         str_ndx = str_ndx(end-1);
%         str = str(str_ndx+1:end);
    
        set_param(hline,'Name',str)     % setting bus signal name to shortened string
        
        % string to be printed on mask of data manager block
        mask_str = [mask_str, str, '\n'];
    end 
else
    mask_str = [mask_str, 'Data Manager\n(Double click to select variables for output)  '];
end
   
% set the block mask display to a listing of the chosen variables
mask_str = [mask_str(1:end-2) '''; fprintf(str)'];
set_param(blk,'MaskDisplay',mask_str);

% Update handles structure
guidata(hObject, handles);
% close the figure window
close(handles.figure1)
