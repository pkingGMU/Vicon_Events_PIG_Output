function selection_routing(~, event, outcome_selection, ~)

    global r01

    selected_folders = [];

    fr = r01.project_fr;

    if isempty(fr) == 1
        add2log(0,"Enter a FrameRate for your selected trials", 1,0,0,0,0,1);
        return
    end
    

    % TODO: Add check for subject panel 

    try
        if strcmp(event.Source.Parent.Title, 'Trial Info')
            selected_folders = r01.files.selected_trial;
        else
            selected_folders = r01.files.ready_to_process;
        end
        

    catch
    end
    % Make sure there is a trial selected
    if isempty(selected_folders) == 1
        add2log(0,"No Trial Selected", 1,0,0,0,0,1);
        return
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

            obstacle_process(selected_folders, fr)

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
       
        case 'Test Outcome'

            test_outcome()

        case 'DO NOT SELECT'

            r01.selection_routing.cases = get_cases();    

        

        otherwise
            add2log(0,"This Button Has not been setup up", 1,0,0,0,0,1);

            

    end
end

