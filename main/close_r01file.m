function close_r01file
global r01

if ~r01.file.open
    return;
end

%Unsaved data can be saved now
if r01.file.changed && ~r01.intern.batchmode
    choice = questdlg('Do you want to save the current file?','Save File','Yes','No','Cancel','Yes');
    if strcmp(choice,'Yes')
        save_r01file;
    elseif strcmp(choice,'Cancel')
        return
    end
end

%clear filedependent vars
r01.data.events.event = [];
r01.data.events.N = 0;
r01.file.version = 0;
r01.file.date = 0;
delete_fit(0);

r01.file.open = 0;
