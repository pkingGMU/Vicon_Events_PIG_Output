function add2log(includetime, newinfo, r01log, sessionlog, filelog, display, replaceline, showmsgbox)
%add2log(includetime, newinfo, r01log, sessionlog, filelog, display, replaceline, showmsgbox)

global r01

if nargin < 8
    showmsgbox = 0;
end
if nargin < 7
    replaceline = 0;
end
if nargin < 6
    display = 0;
end
if nargin < 5
    filelog = 0;
end
if nargin < 4
    sessionlog = 0;
end

if includetime
    newinfo = [datestr(now,13),': ',newinfo];
end

if r01log
    fid_ll = fopen(fullfile(r01.intern.install_dir,'r01log.txt'),'a');
    if fid_ll ~= -1
        fprintf(fid_ll,'%s\r\n', newinfo);
        fclose(fid_ll);
    end
end

if sessionlog && ~r01.intern.batchmode
    if replaceline
        r01.intern.sessionlog = [{newinfo}; r01.intern.sessionlog(2:end)];
    else
        r01.intern.sessionlog = [{newinfo}; r01.intern.sessionlog];
    end
    set(r01.gui.infobox,'String',r01.intern.sessionlog);
    %drawnow;
end

if ~isfield(r01.file,'log')
    r01.file.log = {};
end

if filelog
    r01.file.log = [r01.file.log; {newinfo}];
end

if display
    disp(newinfo)
end

if showmsgbox && r01.intern.prompt && ~r01.intern.batchmode
    msgbox(newinfo,'Info','warn')
end
