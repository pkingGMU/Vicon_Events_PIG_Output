function selection_routing(~, event, outcome_selection, ~)

    global r01

    selected_folders = [];

    fr = r01.project_fr;
    xy = r01.project_xy;

    if isempty(fr) == 1
        add2log(0,"Enter a FrameRate for your selected trials", 1,0,0,0,0,1);
        return
    end

    if isempty(xy) == 1
        add2log(0,"Enter a Direction XY for your selected trials", 1,0,0,0,0,1);
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

                add2log(0,"Gait Events Started", 1,1,1,1,0,1);
                ge_process(selected_folders, choice, fr)

                

        case 'Gait Events & Clean Force Strikes'

                choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');
            add2log(0,"Gait Events and Force Strikes Started", 1,1,1,1,0,1);
                ges_process(selected_folders, choice, fr)
        case 'R01 Analysis'

            choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');
            add2log(0,"R01 Analysis Started", 1,1,1,1,0,1);
            r01_process(selected_folders, choice, fr)
            

        case 'Obstacle Crossing Outcomes'
            add2log(0,"OBS Crossing Started", 1,1,1,1,0,1);
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
            add2log(0,"MOS Started", 1,1,1,1,0,1);

            mos_process(selectedFolders, selection, choice, fr)  

        case 'COP'
            choice = questdlg('Is this treadmill or overground walking?', ...
                    'Select Gait Type ', ...
                    'Treadmill', 'Overground', 'Cancel', 'Treadmill');

            disp('test_cop')
            cop_process(selected_folders, choice, fr)

        

        otherwise
            add2log(0,"This Button Has not been setup up", 1,0,0,0,0,1);

            

    end
    
    add2log(0,"Finished!", 1,1,1,1,0,1);



end

