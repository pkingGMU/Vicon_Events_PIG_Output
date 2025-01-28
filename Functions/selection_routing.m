function selection_routing(outcome_selection, choice, fr)

    switch outcome_selection
        case 'Gait Events'
            dataPath = fullfile(pwd, 'Data');

            % Get a list of folders within the 'Data' directory
            dirInfo = dir(dataPath);
            isFolder = [dirInfo.isdir];
            folderNames = {dirInfo(isFolder).name};

            % Filter out '.' and '..' which represent current and parent directories
            folderNames = folderNames(~ismember(folderNames, {'.', '..'}));

            % Display list dialog to select subject folders
            if isempty(folderNames)
                uialert(uifigure, 'No folders found in Data directory.', 'Folder Error');
            else
                [selection, ok] = listdlg('PromptString', 'Select Subject Folders:', ...
                                          'SelectionMode', 'multiple', ...
                                          'ListString', folderNames);

                % If OK and made a selection
                if ok
                    selectedFolders = fullfile(dataPath, folderNames(selection));
                    disp('Selected folders for processing:');
                    disp(selectedFolders);
                else
                    disp('No folders selected.');
                end
            end
            
                ge_process(selectedFolders, choice, fr)
        case 'Gait Events & Clean Force Strikes'
        case 'R01 Analysis'
        case 'Obstacle Crossing Outcomes'
        otherwise
            

    end
end

