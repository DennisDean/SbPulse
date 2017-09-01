function varargout = sb_pulse(varargin)
% SB_PULSE M-file for SB_Pulse.fig
%      SB_PULSE, by itself, creates a new SB_PULSE or raises the existing
%      singleton*.
%
%      H = SB_PULSE returns the handle to a new SB_PULSE or the handle to
%      the existing singleton*.
%
%      SB_PULSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SB_PULSE.M with the given input arguments.
%
%      SB_PULSE('Property','Value',...) creates a new SB_PULSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SB_Pulse_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SB_Pulse_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SB_Pulse

% Last Modified by GUIDE v2.5 14-Feb-2008 13:04:46

% version 1.06


warning('off','MATLAB:dispatcher:InexactMatch')
warning off MATLAB:dispatcher:InexactMatch
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SB_Pulse_OpeningFcn, ...
    'gui_OutputFcn',  @SB_Pulse_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% Begin SB_Pulse initialization


% --- Executes just before SB_Pulse is made visible.
function SB_Pulse_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SB_Pulse (see VARARGIN)


% Choose default command line output for SB_Pulse
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Creat temporary file name
filename = '';
handles.filename = filename;
guidata(hObject, handles);

% Clear text fields for results
set(handles.edit_data_file,'String',' ');
set(handles.text_text_file,'String',' ');
set(handles.text_figure_file,'String',' ');
set(handles.text_jpeg_file,'String',' ');
set(handles.last_path,'String',' ');
set(handles.cb_log,'String', 0);

% Set up assay cov variable
val = 31;
set(handles.popup_assay,'Value',val)
string_list = get(handles.popup_assay,'String');
selected_string = string_list{val};
selected_string = char(selected_string);
assay_cov = str2num(selected_string);
handles.assay_cov = assay_cov;
guidata(hObject, handles);

% Set up cb_log variable
val = [0.0];
set(handles.cb_log,'Value',val);
set(handles.cb_log,'String','Set y-axis to log scale');
cb_log_v = get(handles.cb_log,'Value');
handles.cb_log_v = cb_log_v;
guidata(hObject, handles);

% Set up cb_zero_time variable
val = [0.0];
set(handles.cb_zero_time,'Value',val);
set(handles.cb_zero_time,'String','Adjust start time to zero');
cb_zero_time = get(handles.cb_zero_time,'Value');
handles.cb_zero_time_v = cb_zero_time;
guidata(hObject, handles);

% Set up time unit variable
val = 1;
set(handles.popup_time_unit,'Value',val)
string_list = get(handles.popup_time_unit,'String');
time_unit = get(handles.popup_time_unit,'Value');
%selected_string = char(selected_string);
%time_unit = str2num(selected_string);
handles.time_unit = time_unit;
guidata(hObject, handles);


% Move code to output file so that the start location is placed property
% This is a reccomended fi from Matlab.
%

% % Set Screen Size
% set(0,'Units','pixels')
% screen_height = 4;
% screen_width = 3;
% d_height = 586;
% d_width = 344;
% screen_dim = get(0,'ScreenSize');
% dialog_height = screen_dim(screen_height)- d_height -28;
% left_edge = 3;
% pos1 = [left_edge dialog_height d_width d_height  ];
% % H = SB_PULSE
% set(hObject,'Position',[5   192   344   587]) ;
% set(hObject,'Position',pos1) ;

% set(handles.radiobutton5,'value',1);
% set(handles.radiobutton2,'value',0);
% set(handles.radiobutton3,'value',0);
% set(handles.radiobutton4,'value',0);

% group = [handles.radiobutton2 handles.radiobutton3 handles.radiobutton4 handles.radiobutton5];
% value = return_radio_group_value(group);


% value = get(group,'value');
% radio = -1;
% for i= 1:length(value)
%     test = value{i};
%     test = test(1);
%     if test == 1
%         radio = i;
%     end
% end
% value = radio;



% Clear text fields for results
%set(handles.edit_graph_title,'String','');
%set(handles.edit_x_label,'String','');
%set(handles.edit_y_label,'String','');
%set(handles.edit_comments,'String','');

% UIWAIT makes SB_Pulse wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SB_Pulse_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Set Screen Size
set(0,'Units','pixels')
screen_height = 4;
screen_width = 3;
d_height = 586;
d_width = 344;
screen_dim = get(0,'ScreenSize');
dialog_height = screen_dim(screen_height)- d_height -28;
left_edge = 3;
pos1 = [left_edge dialog_height d_width d_height  ];
% H = SB_PULSE
set(hObject,'Position',[5   192   344   587]) ;
set(hObject,'Position',pos1) ;


% --- Executes during object creation, after setting all properties.
function graph_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function graph_title_Callback(hObject, eventdata, handles)
% hObject    handle to graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of graph_title as text
%        str2double(get(hObject,'String')) returns contents of graph_title as a double


% --- Executes during object creation, after setting all properties.
function assay_cov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to assay_cov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function assay_cov_Callback(hObject, eventdata, handles)
% hObject    handle to assay_cov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of assay_cov as text
%        str2double(get(hObject,'String')) returns contents of assay_cov as a double


% --- Executes during object creation, after setting all properties.
function data_file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function data_file_name_Callback(hObject, eventdata, handles)
% hObject    handle to data_file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of data_file_name as text
%        str2double(get(hObject,'String')) returns contents of data_file_name as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes on button press in pb_get_filename.
function pb_get_filename_Callback(hObject, eventdata, handles)
% hObject    handle to pb_get_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% [ fn pn] = get_data_file_name;
% filename = strcat(pn,fn);
% handles.filename = filename;
% guidata(hObject, handles);
% edit_data_file.string  = filename
% --- Executes during object creation, after setting all properties.
function comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function comments_Callback(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comments as text
%        str2double(get(hObject,'String')) returns contents of comments as a double


% --- Executes on button press in pb_analyze.
function pb_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to pb_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% santen_bardin_mod_2('22M4R2T2.d2.c.dat' , 'test', 7);

% --- Executes on button press in pb_help.
function pb_help_Callback(hObject, eventdata, handles)
% hObject    handle to pb_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit_graph_title_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_graph_title_Callback(hObject, eventdata, handles)
% hObject    handle to edit_graph_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_graph_title as text
%        str2double(get(hObject,'String')) returns contents of edit_graph_title as a double


% --- Executes during object creation, after setting all properties.
function popup_assay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_assay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function popup_assay_Callback(hObject, eventdata, handles)
% hObject    handle to popup_assay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of popup_assay as text
%        str2double(get(hObject,'String')) returns contents of popup_assay as a double
val = get(hObject,'Value');
string_list = get(hObject,'String');
selected_string = string_list{val};
selected_string = char(selected_string);
assay_cov = str2num(selected_string);
handles.assay_cov = assay_cov;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_data_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_data_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_data_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_data_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_data_file as text
%        str2double(get(hObject,'String')) returns contents of edit_data_file as a double


% --- Executes on button press in pb_get_file.
function pb_get_file_Callback(hObject, eventdata, handles)
% hObject    handle to pb_get_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get and set filename
% change current directory just long enough to 
% determine get file
last_path = get(handles.last_path,'String');
current_directory = cd;

if ~strcmp(last_path, ' ')
        cd(last_path)
end

% Load File
[fn,pn] = uigetfile('*.*','Select LH Data File');

cd(current_directory);

if ~isnumeric(fn) & ~isnumeric(pn)
    set(handles.last_path,'String',pn);

    % set last path
    set(handles.last_path,'String',pn);

    % load data file
    filename = strcat(pn,fn);
    handles.filename = filename;
    guidata(hObject, handles);

    % set data file text in dialog box
    set(handles.edit_data_file,'String',fn);

    % Set hormone label
    hormone_text = '';
    val = get(handles.pum_hormone,'Value');
    switch val
        case 1
            hormone_text = 'LH - Urinary';
        case 2
            hormone_text = 'LH - Pituatary';
        case 3
            hormone_text = 'FAS';
        otherwise
            hormone_text = '';
    end
    y_label_text = 'Concentration (IUL)';
    if ~strcmp(hormone_text, 'Other');
        y_label_text = sprintf('%s %s',hormone_text, y_label_text );
    end
    set(handles.edit_y_label,'String',y_label_text);

    % set output_filenames
    txt_fn = strcat(fn,'.txt');
    fig_fn = strcat(fn,'.fig');
    jpg_fn = strcat(fn,'.jpg');
    emf_fn = strcat(fn,'.emf');

    algor_value = handles.assay_cov;

    % Set graph title
    sample_id_text = char(get(handles.edit_sample_id,'String'));
    graph_title_str = fn;
    if  sum(size(sample_id_text))>0;
        graph_title_str = sprintf('%s - %s',sample_id_text,fn);
    end
    set(handles.edit_graph_title,'String',graph_title_str);

    set(handles.text_text_file,'String',txt_fn);
    set(handles.text_figure_file,'String',fig_fn);
    set(handles.text_jpeg_file,'String',jpg_fn);
end
% --- Executes during object creation, after setting all properties.
function edit_comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_comments_Callback(hObject, eventdata, handles)
% hObject    handle to edit_comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_comments as text
%        str2double(get(hObject,'String')) returns contents of edit_comments as a double


% --- Executes on button press in pb_analze.
function pb_analze_Callback(hObject, eventdata, handles)
% hObject    handle to pb_analze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = handles.filename;

if strcmp(filename,'')==1
    msgbox ('Set data file.','Select File','warn')
else
    title      = char(get(handles.edit_graph_title, 'String'));
    x_label    = char(get(handles.edit_x_label,     'String'));
    y_label    = char(get(handles.edit_y_label,     'String'));
    comments   = char(get(handles.edit_comments,    'String'));
    yscale     = get(handles.cb_log,'Value');
    y_max      = str2num(char(get(handles.edit_max_concentration,'String')))
    
    zero_time  = get(handles.cb_zero_time,'Value');
    time_scale = get(handles.popup_time_unit,'Value');

    % set autoscale
    auto_scale = get(handles.rb_auto_scale,'Value');
    if auto_scale == 1
        y_max = 0;
    end
    
    % time scale
    if time_scale ~= 1
        % minutes
        time_scale = double(1/60);
    end
      
    value = 4; % Complete maximum santen bardin pulse analyis

    assay_cov = double(handles.assay_cov);
    sample_id = char(get(handles.edit_sample_id,'String'));
    
    start_peak = 1;
    santen_bardin_mod_12(filename , title, x_label, y_label , comments, assay_cov, value, start_peak,sample_id,yscale,zero_time,time_scale,y_max);
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit_x_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_x_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_x_label_Callback(hObject, eventdata, handles)
% hObject    handle to edit_x_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_x_label as text
%        str2double(get(hObject,'String')) returns contents of edit_x_label as a double


% --- Executes during object creation, after setting all properties.
function edit_y_label_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_y_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_y_label_Callback(hObject, eventdata, handles)
% hObject    handle to edit_y_label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_y_label as text
%        str2double(get(hObject,'String')) returns contents of edit_y_label as a double


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
off = [handles.radiobutton3,handles.radiobutton4,handles.radiobutton5];
set(off,'Value',0)

% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton3
off = [handles.radiobutton2,handles.radiobutton4,handles.radiobutton5];
set(off,'Value',0)

% --- Executes on button press in radiobutton4.
function radiobutton4_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton4
off = [handles.radiobutton2,handles.radiobutton3,handles.radiobutton5];
set(off,'Value',0)

% --- Executes on button press in radiobutton5.
function radiobutton5_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton5
off = [handles.radiobutton2,handles.radiobutton3,handles.radiobutton4];
set(off,'Value',0)
%
% function mutual_exclude(off)
% % function taken from help file to clontrol mutual
% % exclusive nature of radio buttons.
% %
% set(off,'Value',0)

% function radio = return_radio_group_value(group)
% value = get(group,'value');
% radio = -1;
% for i= 1:length(value)
%     test = value{i};
%     test = test(1);
%     if test == 1
%         radio = i;
%     end
% end



% --- Executes on selection change in pum_hormone.
function pum_hormone_Callback(hObject, eventdata, handles)
% hObject    handle to pum_hormone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pum_hormone contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pum_hormone


% --- Executes during object creation, after setting all properties.
function pum_hormone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pum_hormone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_sample_id_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sample_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sample_id as text
%        str2double(get(hObject,'String')) returns contents of edit_sample_id as a double


% --- Executes during object creation, after setting all properties.
function edit_sample_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sample_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in pb_pulse_start.
function pb_pulse_start_Callback(hObject, eventdata, handles)
% hObject    handle to pb_pulse_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get and set filename


filename = handles.filename;

if strcmp(filename,'')==1
    msgbox ('Set data file.','Select File','warn')
else
    title      = char(get(handles.edit_graph_title,'String'));
    x_label    = char(get(handles.edit_x_label,'String'));
    y_label    = char(get(handles.edit_y_label,'String'));
    comments   = char(get(handles.edit_comments,'String'));
    yscale     = get(handles.cb_log,'Value');
    y_max      = str2num(char(get(handles.edit_max_concentration,'String'))); 
    zero_time  = get(handles.cb_zero_time,'Value');
    time_scale = get(handles.popup_time_unit,'Value');
    
    % set autoscale
    auto_scale = get(handles.rb_auto_scale,'Value');
    if auto_scale == 1
        y_max = 0;
    end
    
    % time scale
    if time_scale ~= 1
        % minutes
        time_scale = double(1/60);
    end
    
    %     % Get radio button handle
    %     group = [handles.radiobutton2 handles.radiobutton3 handles.radiobutton4 handles.radiobutton5];
    %     % value = return_radio_group_value(group);
    %
    %     value = get(group,'value');
    %     radio = -1;
    %     for i= 1:length(value)
    %         test = value{i};
    %         test = test(1);
    %         if test == 1
    %             radio = i;
    %         end
    %     end
    %     value = radio;
    value = 4; % Complete maximum santen bardin pulse analyis
    sample_id = char(get(handles.edit_sample_id,'String'));
    assay_cov = double(handles.assay_cov);
    start_peak = 0;
    santen_bardin_mod_12(filename , title, x_label, y_label , comments, assay_cov,value, start_peak, sample_id, yscale, zero_time, time_scale,y_max);
end




function last_path_Callback(hObject, eventdata, handles)
% hObject    handle to last_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of last_path as text
%        str2double(get(hObject,'String')) returns contents of last_path as a double


% --- Executes during object creation, after setting all properties.
function last_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in cb_log.
function cb_log_Callback(hObject, eventdata, handles)
% hObject    handle to cb_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_log

% cb_log = get(hObject,'Value');
% cb_log = str2num(selected_string);
% handles.cb_log = cb_log;
% guidata(hObject, handles);


% --- Executes on button press in pb_about.
function pb_about_Callback(hObject, eventdata, handles)
% hObject    handle to pb_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sb_pulse_about

% --- Executes on button press in pb_sb.
function pb_sb_Callback(hObject, eventdata, handles)
% hObject    handle to pb_sb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit_max_concentration_Callback(hObject, eventdata, handles)
% hObject    handle to edit_max_concentration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_max_concentration as text
%        str2double(get(hObject,'String')) returns contents of edit_max_concentration as a double


% --- Executes during object creation, after setting all properties.
function edit_max_concentration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_max_concentration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pb_close_figures.
function pb_close_figures_Callback(hObject, eventdata, handles)
% hObject    handle to pb_close_figures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close



% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


