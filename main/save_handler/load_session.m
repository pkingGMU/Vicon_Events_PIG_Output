function load_session

global r01

clc
close all hidden;

[filename, pathname] = uigetfile(' *.mat','Choose a Session file');

r01.file.filename = filename;
r01.file.pathname = pathname;

if all(filename == 0) || all(pathname == 0) %Cancel
    return
end

file = fullfile(pathname, filename);

%Try to open file
try
    
    r01session = load(file, '-mat');
 
catch
    add2log(0,['Unable to open ',file],1,1,0,1,0,1);
    return;
end



r01 = r01session.r01;
r01.file_saved = 1;

