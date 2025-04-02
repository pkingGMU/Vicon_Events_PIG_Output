function r01gui
global r01

%Menu
%-File
r01.gui.fig_main = figure('Units','normalized','Position',[.00 .03 1 .92],'Name',[r01.intern.name,' ',r01.intern.versiontxt],'KeyPressFcn','r01_keypress',...
    'MenuBar','none','NumberTitle','off','Color',r01.gui.col.fig,'CloseRequestFcn','exit_r01');  %,'outerposition',[0 0 1 1]

r01.gui.menu.menu_1  = uimenu(r01.gui.fig_main,'Label','File');
r01.gui.menu.menu_1a = uimenu(r01.gui.menu.menu_1,'Label','Open','Callback','open_r01file;','Accelerator','o');   %
r01.gui.menu.menu_1b = uimenu(r01.gui.menu.menu_1,'Label','Import Data...'); %,'Accelerator','i'
r01.gui.menu.menu_1d = uimenu(r01.gui.menu.menu_1,'Label','Export Data...');
r01.gui.menu.menu_1e = uimenu(r01.gui.menu.menu_1,'Label','Save','Callback','save_r01file','Accelerator','s','Separator','on');
r01.gui.menu.menu_1f = uimenu(r01.gui.menu.menu_1,'Label','Save as...','Callback','save_r01file(1)');
r01.gui.menu.menu_1g = uimenu(r01.gui.menu.menu_1,'Label','Exit','Callback','exit_r01','Accelerator','x','Separator','on');

r01.gui.menu.menu_1b1 = uimenu(r01.gui.menu.menu_1b,'Label','Single Trial','Callback','import_data(''single_trial'');');
r01.gui.menu.menu_1b2 = uimenu(r01.gui.menu.menu_1b,'Label','Single Subject','Callback','import_data(''single_subject'');');
r01.gui.menu.menu_1b3 = uimenu(r01.gui.menu.menu_1b,'Label','Multiple Trials','Callback','import_data(''multiple_trials'');');
r01.gui.menu.menu_1b4 = uimenu(r01.gui.menu.menu_1b,'Label','Multiple Subjects','Callback','import_data(''multiple_subjects'');');

% File Panels %
r01.gui.file_list_panel = uipanel(r01.gui.fig_main, "Units", "Normalized", "Title", "Trials", "Scrollable","on");
r01.gui.subject_list_panel = uipanel(r01.gui.fig_main, "Units", "Normalized", "Title", "Subjects", "Scrollable","on");
r01.gui.ondeck_panel = uipanel(r01.gui.fig_main, "Units", "normalized", "Title", "Ready To Process", "Scrollable", "on");

r01.gui.subject_list_panel.Position = [.02 .35 .1 .25];
r01.gui.file_list_panel.Position = [.02 .05 .1 .25];
r01.gui.ondeck_panel.Position = [.15, .05, .1, .55];

% Drop Down For Trial Panel %
r01.gui.file_list_dropdown = uicontrol(r01.gui.file_list_panel, 'Units', 'normalized', 'Style', 'listbox', 'String', r01.files.file_list, "Max", 40, "Min", 1);
r01.gui.file_list_dropdown.Position = [.02 .25 .9 .7];

% Drop Down For Subject Panel %
r01.gui.subject_list_dropdown = uicontrol(r01.gui.subject_list_panel, 'Units', 'normalized', 'Style', 'listbox', 'String', r01.files.file_list);
r01.gui.subject_list_dropdown.Position = [.02 .25 .9 .7];

% Drop Down for On Deck Files %
r01.gui.ondeck_dropdown = uicontrol(r01.gui.ondeck_panel, "Units","normalized", "Style", "listbox", "String", r01.files.file_list);
r01.gui.ondeck_dropdown.Position = [.05 .08 .9 .9];

% Remove File from Ready To Process %
r01.gui.ondeck_remove = uicontrol(r01.gui.ondeck_panel, "Style","pushbutton","String", "Remove", 'Callback', 'remove_rtp()');

% Buttons %
r01.gui.subject_list_select = uicontrol(r01.gui.subject_list_panel, "Style","pushbutton","String", "Select", 'Callback', 'update_trial_list()');
r01.gui.trial_list_select = uicontrol(r01.gui.file_list_panel, "Style","pushbutton","String", "Select", "Callback", 'update_ondeck()');

% Processing Panels %
r01.gui.process_area = uipanel(r01.gui.fig_main, "Title", "Parsing and Processing", "Units", "normalized", "Scrollable","on");
r01.gui.process_area.Position = [.30 .5 .1 .1];

% Trial Info Panel %
r01.gui.info_panel = uipanel(r01.gui.fig_main, "Units", "Normalized", "Title", "Trial Info", "Scrollable","on");
r01.gui.info_panel.Position = [.02 .78 .2 .2];

% Button for Analyze %
r01.gui.process_button = uicontrol(r01.gui.process_area, "Style","pushbutton", "String", "Select", "Callback", 'process_callback()');
%r01.gui.process_button.Position = [0,0,1,1];

% Force Plate Input -- Test -- %
r01.gui.force_input = uipanel(r01.gui.fig_main, "Title", "Force Plate Input", "Units", "normalized", "Scrollable", "on");
r01.gui.force_input.Position = [.24 .78 .2 .2];

% Force Plate Fields -- Test -- %
r01.gui.user_frame = uicontrol(r01.gui.force_input, "Units", "normalized", "Style", "edit", "String", "Enter Potential Clean Foot Strikes (Frame, Foot, Frame, Foot)");
r01.gui.user_frame.Position = [.1 0 .8 .2];

r01.gui.user_num_plates = uicontrol(r01.gui.force_input, "Units", "normalized", "Style", "edit", "String", "Enter Number of Plates");
r01.gui.user_num_plates.Position = [.1 .3 .8 .2];

r01.gui.user_prefix_plates = uicontrol(r01.gui.force_input, "Units", "normalized", "Style", "edit", "String", "Force Plate Prefix (f_, force, etc.)");
r01.gui.user_prefix_plates.Position = [.1 .6 .8 .2];
%-Info
r01.gui.menu.menu_7 =  uimenu(r01.gui.fig_main,'Label','Info');
% r01.gui.menu.menu_7a = uimenu(r01.gui.menu.menu_7,'Label','r01lab Website','Callback','web(''www.r01lab.de'')');
%r01.gui.menu.menu_7b = uimenu(r01.gui.menu.menu_7,'Label','Documentation','Callback','web(''www.r01lab.de/download/r01lab_Documentation.pdf'',''-browser'')');
r01.gui.menu.menu_7c = uimenu(r01.gui.menu.menu_7,'Label','Check for updates','Callback','version_check');
r01.gui.menu.menu_7d = uimenu(r01.gui.menu.menu_7,'Label','About r01lab','Callback','r01logo','Separator','on');


x1 = .05; x2 = .7; x3 = .75; x4 = .98;
y2 = .7; y3 = .27; y5 = .22; y6 = .19; y7 = .17; y8 = .02;
% 
% %Rangeview (= Epoch Display)
% r01.gui.rangeview.ax = axes('Units','normalized','Position',[x1 y3 x2-x1 y2-y3],'XLim',[r01.gui.rangeview.start, r01.gui.rangeview.start + r01.gui.rangeview.range],'YLim',[0,20],'Color',[1 1 1],'DrawMode','fast','ButtonDownFcn','r01_click(2)');
% set(get(r01.gui.rangeview.ax,'YLabel'),'String','Skin Conductance [\muS]')
% set(get(r01.gui.rangeview.ax,'XLabel'),'String','Time [sec]')
% 
% r01.gui.rangeview.edit_start = uicontrol('Units','normalized','Style','edit','Position',[x1 y5 .05 .025],'String',r01.gui.rangeview.start,'HorizontalAlignment','center','Callback','edits_cb(1)');
% r01.gui.rangeview.edit_range = uicontrol('Units','normalized','Style','edit','Position',[.2 y5 .05 .025],'String',r01.gui.rangeview.range,'HorizontalAlignment','center','Callback','edits_cb(1)');
% r01.gui.rangeview.edit_end = uicontrol('Units','normalized','Style','edit','Position',[.65 y5 .05 .025],'String',r01.gui.rangeview.start + r01.gui.rangeview.range,'HorizontalAlignment','center','Callback','edits_cb(2)');
% r01.gui.rangeview.slider = uicontrol('Style','Slider','Units','normalized','Position',[.05 y6 x2-x1 .02],'Min',0,'Max',1,'SliderStep',[.01 .1],'Callback','edits_cb(3)');
% 
% %Driver-Axes
% r01.gui.driver.ax = axes('Units','normalized','Position',[x1 .02 x2-x1 y7-y8],'XLim',[r01.gui.rangeview.start, r01.gui.rangeview.start + r01.gui.rangeview.range],'YLim',[0,20],'Color',[1 1 1],'DrawMode','fast','ButtonDownFcn','r01_click(2)');
% set(get(r01.gui.driver.ax,'YLabel'),'String','Phasic Driver [\muS]')
% 
% %Overview-Info (= Data Info Display)
dy = .40;
x3a = x3 + .04; x3b = x3 + .13;
r01.gui.frame = uicontrol('Units','normalized','Style','frame','Position',[x3 dy x4-x3 .3],'String','Frame Ov','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_title = uicontrol('Units','normalized','Style','text','Position',[x3a+.01 dy+.03*8 .08 .02],'String','DATA ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1,'FontWeight','bold');
% r01.gui.text_N = uicontrol('Units','normalized','Style','text','Position',[x3a dy+.03*7 .08 .02],'String','N: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_time = uicontrol('Units','normalized','Style','text','Position',[x3a dy+.03*6 .08 .02],'String','Time: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_smplrate = uicontrol('Units','normalized','Style','text','Position',[x3a dy+.03*5 .08 .02],'String','Freq: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_conderr = uicontrol('Units','normalized','Style','text','Position',[x3a dy+.03*4 .08 .02],'String','Error: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_Nevents = uicontrol('Units','normalized','Style','text','Position',[x3a dy+.03*3 .08 .02],'String','Events: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_title2 = uicontrol('Units','normalized','Style','text','Position',[x3b+.01 dy+.03*8 .08 .02],'String','DECOMPOSITION ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1,'FontWeight','bold');
% r01.gui.text_method = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*7 .09 .02],'String','Method: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_tau = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*6 .08 .02],'String','Tau: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% %r01.gui.text_adjR2 = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*6 .08 .02],'String','Adj. R2: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% %r01.gui.text_mse = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*6 .08 .02],'String','MSE: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_rmse = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*5 .08 .02],'String','RMSE: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_nPhasic = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*4 .08 .02],'String','SCRs: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
% r01.gui.text_nTonic = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*3 .08 .02],'String','TPs: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1);
%r01.gui.text_df = uicontrol('Units','normalized','Style','text','Position',[x3b dy+.03*1 .06 .02],'String','DF: ','HorizontalAlignment','left','BackgroundColor',r01.gui.col.frame1,'Visible','off');

%Event Info Display
dx1 = .75; dx2 = dx1+ .03; dx3 = dx2 + .08;
% r01.gui.eventinfo.frame = uicontrol('Units','normalized','Style','frame','Position',[dx1 y6 x4-x3 .15],'String','Frame 2','BackgroundColor',r01.gui.col.frame1);
% r01.gui.eventinfo.text_title = uicontrol('Units','normalized','Style','text','Position',[dx1+.005 y6+.125 .2 .02],'String','Events','HorizontalAlignment','left','FontSize',8,'BackgroundColor',r01.gui.col.frame1,'FontWeight','bold');
% r01.gui.eventinfo.txtlab_eventnr  = uicontrol('Units','normalized','Style','text','Position',[dx2 y6+.09 .07 .02],'String','Eventnr:','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% r01.gui.eventinfo.butt_prevevent  = uicontrol('Units','normalized','Style','pushbutton','Position',[dx1+.1 y6+.095 .03 .025],'String','<','BackgroundColor',[.7 .7 .8],'HorizontalAlignment','center','Callback','edits_cb(6)');
% r01.gui.eventinfo.butt_nextevent  = uicontrol('Units','normalized','Style','pushbutton','Position',[dx1+.17 y6+.095 .03 .025],'String','>','BackgroundColor',[.7 .7 .8],'HorizontalAlignment','center','Callback','edits_cb(7)');
% r01.gui.eventinfo.txtlab_name  = uicontrol('Units','normalized','Style','text','Position',[dx2 y6+.06 .1 .02],'String','Name:','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% r01.gui.eventinfo.txtlab_time  = uicontrol('Units','normalized','Style','text','Position',[dx2 y6+.04 .1 .02],'String','Time:','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% r01.gui.eventinfo.txtlab_niduserdata  = uicontrol('Units','normalized','Style','text','Position',[dx2 y6+.02 .1 .02],'String','Nid & Userdata:','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% 
% r01.gui.eventinfo.edit_eventnr  = uicontrol('Units','normalized','Style','edit','Position',[dx1+.13 y6+.095 .04 .025],'String','','HorizontalAlignment','center','Callback','edits_cb(5)'); %,'BackgroundColor',r01.gui.col.frame1
% r01.gui.eventinfo.txt_name  = uicontrol('Units','normalized','Style','text','Position',[dx3 y6+.06 .1 .02],'String','','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% r01.gui.eventinfo.txt_time  = uicontrol('Units','normalized','Style','text','Position',[dx3 y6+.04 .1 .02],'String','','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% r01.gui.eventinfo.txt_niduserdata  = uicontrol('Units','normalized','Style','text','Position',[dx3 y6+.02 .1 .02],'String','','BackgroundColor',r01.gui.col.frame1,'HorizontalAlignment','left');
% 
% %Session History Display
r01.gui.infobox = uicontrol('Units','normalized','Style','listbox','Position',[x3 y8 x4-x3 y7-y8],'Max',2,'String','','HorizontalAlignment','left','FontSize',7);

%Maximize Figure (Version 7.4+ only)
m_version = version;
if str2double(m_version(1:3)) > 7.4
    maxfig(r01.gui.fig_main,1);
end

