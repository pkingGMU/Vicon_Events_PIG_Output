function selection_routing(~, event, outcome_selection, fr)

    global r01

    try
        if strcmp(event.Source.Parent.Title, 'Trial Info')
            selected_folders = r01.files.selected_trial;
        else
            selected_folders = r01.files.ready_to_process;
        end
        

    catch
    end

    switch outcome_selection
        case 'Gait Events'
           
                choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');

            
                ge_process(selected_folders, choice, fr)
        case 'Gait Events & Clean Force Strikes'

                choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');
            
                ges_process(selected_folders, choice, fr)
        case 'R01 Analysis'

            choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');
  
            r01_process(selected_folders, choice, fr)
            

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

