function save_session(save_as)

global r01

if nargin < 1
    save_as = 0;
end

r01.file.saved = 0;

if save_as
    [filename, pathname] = uiputfile([r01.file.filename], 'Save file as ..');
    if all(filename == 0) || all(pathname == 0) %Cancel
        return
    end

    %filename = strcat(filename, '.mat')

    r01.file.filename = filename;
    r01.file.pathname = pathname;
elseif isempty(r01.file.filename) || isempty(r01.file.pathname)
    [filename, pathname] = uiputfile('*.mat', 'Save file as ..', [r01.file.filename, '.mat']);
    if all(filename == 0) || all(pathname == 0) %Cancel
        return
    end

    %filename = strcat(filename, '.mat')

    r01.file.filename = filename;
    r01.file.pathname = pathname;
else
    filename = r01.file.filename;
    pathname = r01.file.pathname;

end
file = fullfile(pathname, filename);


%Prepare data for saving
fileinfo.version = r01.intern.version;
fileinfo.date = clock;
fileinfo.log = r01.file.log;

save(file)

