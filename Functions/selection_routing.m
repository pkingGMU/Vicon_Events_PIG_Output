function selection_routing(outcome_selection, fr)

    switch outcome_selection
        case 'Gait Events'
            [folderNames, dataPath, choice] = folder_names(1);

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
            [folderNames, dataPath, choice] = folder_names(1);

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
            
                ges_process(selectedFolders, choice, fr)
        case 'R01 Analysis'
            dataPath = fullfile(pwd, 'Output/', 'Gait_Events_Strikes/', 'Overground');
    
            % Get a list of folders within the 'Data' directory
            dirInfo = dir(dataPath);
            isFolder = [dirInfo.isdir];
            folderNames = {dirInfo(isFolder).name};
            
            % Filter out '.' and '..' which represent current and parent directories
            folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
            
            
            choice = questdlg('Is this treadmill or overground walking?', ...
                'Select Gait Type ', ...
                'Treadmill', 'Overground', 'Cancel', 'Treadmill');
            
                
            

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

            r01_process(selectedFolders, selection, choice, fr)
            

        case 'Obstacle Crossing Outcomes'
            [folderNames, dataPath, choice] = folder_names(1);

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

            obstacle_process(selectedFolders, choice, fr)

        case 'Margin Of Stability'
            [folderNames, dataPath, choice] = folder_names(1);

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

            mos_process(selectedFolders, selection, choice, fr)

        otherwise
            

    end
end

