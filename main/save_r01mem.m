function r01mem = save_r01mem(type)
% type: 'custom' or 'default'
global r01
% load r01mem to workspace
private_r01mem_path = [prefdir(1) '/r01mem.mat'];
if exist(private_r01mem_path,'file')
    r01mem_path = private_r01mem_path;
    add2log(0,['Using private r01mem.mat in ' prefdir()],1);
else
    r01mem_path = fullfile(r01.intern.install_dir,'main','settings','r01mem.mat');
end

try
    load(r01mem_path);
    r01.intern.prevfile = r01mem.prevfile; %#ok<NODEF>
catch
    add2log(0,'No r01mem available',1);
end

%saving the default settings may replace an unavailable r01mem, if necessary
r01mem.prevfile = r01.intern.prevfile;
r01mem.set.(type) = r01.set;
r01mem.pref.(type) = r01.pref;
try
    save(r01mem_path, 'r01mem');
catch % try the per-user preference path
    save(private_r01mem_path, 'r01mem');
end

end

