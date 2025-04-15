% Callback function
function update_trial_text(src, ~)

    global r01

    % Get selected item
    selectedIdx = src.Value;
    selectedStr = src.String{selectedIdx};

    % Update the text field
    r01.gui.info_panel_name.String = ['Selected: ' selectedStr];

    % Checks %
    value_num = r01.gui.subject_list_dropdown.Value;
    subject = r01.files.subjects(value_num);

    full_trial_list = r01.files.file_list;

    sub_idx = strcmp(full_trial_list(:,2), subject(1));
    trial_idx = strcmp(full_trial_list(:,3), selectedStr);

    idx = full_trial_list(sub_idx & trial_idx, :);

    file_name = split(strcat(idx{3}, '_events.xlsx'));
    
    % Gait Event Check %
    gait_path = '';
    gait_folders_to_search = {fullfile(pwd, 'Output', 'Gait_Events', 'Overground', idx{2})...
        fullfile(pwd, 'Output', 'Gait_Events', 'Treadmill', idx{2})};
    
    for i = 1:length(gait_folders_to_search)
        gait_candidate = fullfile(gait_folders_to_search{i}, file_name);
        if isfile(gait_candidate)
            gait_path = gait_candidate;
            break;
        end
    end

    if ~isempty(gait_path)
        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Run';
        
    else
        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Not Run';
    end

    % Gait Strike Check %

    gait_force_path = '';
    gait_force_fld_search = {fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Overground', idx{2})...
        fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Treadmill', idx{2})};

    for i = 1:length(gait_force_fld_search)
        gait_force_candidate = fullfile(gait_force_fld_search{i}, file_name);
        if isfile(gait_force_candidate)
            gait_force_path = gait_force_candidate;
            break;
        end
    end
    if ~isempty(gait_force_path)
        set(r01.gui.trial_panel_gait_force_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_gait_force_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_force_check.String = 'Gait Force: Run';

        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Run';
        
    else
        set(r01.gui.trial_panel_gait_force_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_force_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_force_check.String = 'Gait Force: Not Run';

        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Not Run';
    end

    % R01 Analysis Check %

    r01_path = '';
    gait_force_fld_search = {fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Overground', idx{2})...
        fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Treadmill', idx{2})};

    for i = 1:length(gait_force_fld_search)
        gait_force_candidate = fullfile(gait_force_fld_search{i}, file_name);
        if isfile(gait_force_candidate)
            gait_force_path = gait_force_candidate;
            break;
        end
    end
    if ~isempty(gait_force_path)
        set(r01.gui.trial_panel_gait_force_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_gait_force_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_force_check.String = 'Gait Force: Run';

        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Run';
        
    else
        set(r01.gui.trial_panel_gait_force_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_force_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_force_check.String = 'Gait Force: Not Run';

        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait: Not Run';
    end




    


 
end