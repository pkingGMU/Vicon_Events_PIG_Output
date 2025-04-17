function r01preset
global r01

r01.files.file_list = {};


r01.intern.sessionlog = {};
r01.intern.prevfile = [];
r01.intern.prompt = 1;

r01.gui.rangeview.start = 0;
r01.gui.rangeview.range = 60;
r01.gui.rangeview.fit_component = 0;
r01.gui.eventinfo.showEvent = 0;
r01.gui.rangeview.fitcomps = [];
r01.file.open = 0;
r01.file.filename = '';
r01.file.pathname = '';
r01.data.events.event = [];
r01.data.events.N = 0;

r01.files.ready_to_process = [];
r01.files.master_file_list = [];
r01.project_fr = [];

r01.gui.overview.driver = [];
r01.gui.overview.tonic_component = [];
r01.gui.overview.phasic = [];

r01.analysis = [];

% define structure for GUI of leda_split.m
r01.gui.split = [];


%Default Setting:


%NNDECO
r01.set.template = 2;
r01.set.smoothwin = .2;
r01.set.tonicGridSize = 60;
r01.set.sigPeak = .001;
r01.set.d0Autoupdate = 1;
r01.set.tonicIsConst = 0;
r01.set.tonicSlowIncrease = 0;
r01.set.tau0 = [.50 30];     %see Benedek & Kaernbach, 2010, Psychophysiology

%SDECO
r01.set.tonicGridSize_sdeco = 10;
r01.set.tau0_sdeco = [1 3.75];  %see Benedek & Kaernbach, 2010, J Neurosc Meth
r01.set.d0Autoupdate_sdeco = 0;
r01.set.smoothwin_sdeco = .2;


% get peaks
r01.set.initVal.hannWinWidth = .5;
r01.set.initVal.signHeight = .01;
r01.set.initVal.groundInterp = 'spline'; %'pchip' keeps only S(x)' continuous
r01.set.tauMin = .001; %.1
r01.set.tauMax = 100;
r01.set.tauMinDiff = .01;
r01.set.dist0_min = .001;

% %Export (ERA)
r01.set.export.SCRstart = 1.00; %sec
r01.set.export.SCRend   = 4.00; %sec
r01.set.export.SCRmin   = .01; %muS
r01.set.export.savetype = 1;
r01.set.export.zscale = 0;


% settings for leda_split.m
r01.set.split.start = -1;   % sec
r01.set.split.end = 5;        % sec
r01.set.split.variables = {'driver','phasicData'}; % possible variables, 2012-03-13 only one by now.
r01.set.split.var = 1;        % index for VARIABLES
r01.set.split.stderr = 0;
%r01.set.split.variable = 'phasicData';
%r01.set.split.selectedconditions = [];
%r01.set.split.plot = 1;


%Ledapref
r01.pref.showSmoothData = 0;
r01.pref.showMinMax = 0;
r01.pref.showOvershoot = 1;
%not settable inside of Ledalab
r01.pref.eventWindow = [5, 15];
r01.pref.oldfile_maxn = 5;
r01.pref.scalewidth_min = .6; %muS
r01.gui.col.fig = [.8 .8 .8];
r01.gui.col.frame1 = [.85 .85 .85];


%Save defaults
r01mem = save_r01mem('default');

%Apply custom settings if available
if isfield(r01mem.set,'custom') && isstruct(r01mem.set.custom)
    r01.set = mergestructs(r01mem.set.custom, r01mem.set.default);
end
if isfield(r01mem.pref,'custom') && ~isempty(r01mem.pref.custom)
    r01.pref = mergestructs(r01mem.pref.custom, r01mem.pref.default);
end
end

function old = mergestructs(old,new)
% merges the supplid structs without overwriting contents in the first
    fn = fieldnames(new);
    for i=1:length(fn)
        f = fn{i};
        if ~isfield(old,f)
            old.(f) = new.(f);
        elseif isstruct(old.(f)) && isstruct(new.(f))
            old.(f) = mergestructs(old.(f),new.(f));
        end
    end
end
