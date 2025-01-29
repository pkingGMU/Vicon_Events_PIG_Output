function [folderNames, dataPath, choice] = folder_names(varagin)
    dataPath = fullfile(pwd, 'Data');
    
    % Get a list of folders within the 'Data' directory
    dirInfo = dir(dataPath);
    isFolder = [dirInfo.isdir];
    folderNames = {dirInfo(isFolder).name};
    
    % Filter out '.' and '..' which represent current and parent directories
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
    
    if nargin == 1
        choice = questdlg('Is this treadmill or overground walking?', ...
            'Select Gait Type ', ...
            'Treadmill', 'Overground', 'Cancel', 'Treadmill');
    else
        choice = 0;
    end

end

