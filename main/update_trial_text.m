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

    r01.files.selected_trial = idx;

    file_name = split(strcat(regexprep(idx{3}, ' ', '_'), '_events.xlsx'));
    
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
        r01.gui.trial_panel_gait_check.String = 'Gait Events: Run';
        
    else
        set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_check.String = 'Gait Events: Not Run';
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
        r01.gui.trial_panel_gait_force_check.String = 'Gait Events & Force: Run';

        % set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'green');
        % set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        % r01.gui.trial_panel_gait_check.String = 'Gait: Run';
        
    else
        set(r01.gui.trial_panel_gait_force_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_gait_force_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_gait_force_check.String = 'Gait Events & Force: Not Run';

        % set(r01.gui.trial_panel_gait_check, 'BackgroundColor', 'red');
        % set(r01.gui.trial_panel_gait_check, 'ForegroundColor', 'Black');
        % r01.gui.trial_panel_gait_check.String = 'Gait: Not Run';
    end

    % R01 Analysis Check %

    r01_path = '';
    r01_fld_search = {fullfile(pwd, 'Output', 'R01_Analysis', 'Overground', idx{2}, idx{3}, strcat(idx{2}, '_', idx{3}, '_EachGaitCycleData.xlsx'))...
        fullfile(pwd, 'Output', 'R01_Analysis', 'Treadmill', idx{2}, idx{3}, strcat(idx{2}, '_', idx{3}, '_EachGaitCycleData.xlsx'))};

    for i = 1:length(r01_fld_search)
        r01_candidate = r01_fld_search{i};
        if isfile(r01_candidate)
            r01_path = r01_candidate;
            break;
        end
    end
    if ~isempty(r01_path)
        set(r01.gui.trial_panel_r01_check, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_r01_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_r01_check.String = 'R01 Analysis: Run';

    else
        set(r01.gui.trial_panel_r01_check, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_r01_check, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_r01_check.String = 'R01 Analysis: Not Run';        
    end

    % Obstacle Crossing Check %

    obstacle_path = '';
    obstacle_fld_search = {fullfile(pwd, 'Output', 'Obstacle_Crossing', idx{2}, idx{3}, strcat(idx{3}, '.xlsx'))};
    for i = 1:length(obstacle_fld_search)
        obstacle_candidate = obstacle_fld_search{i};
        if isfile(obstacle_candidate)
            obstacle_path = obstacle_candidate;
            break;
        end
    end
    
    if ~isempty(obstacle_path)
        set(r01.gui.trial_panel_obs_crossing, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_obs_crossing, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_obs_crossing.String = 'Obstacle Crossing: Run';

    else
        set(r01.gui.trial_panel_obs_crossing, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_obs_crossing, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_obs_crossing.String = 'Obstacle Crossing: Not Run';
    end

    % COP Check %

    cop_path = '';
    cop_fld_search = {fullfile(pwd, 'Output', 'COP', idx{2}, idx{3}, strcat(idx{3}, '.xlsx'))};
    for i = 1:length(cop_fld_search)
        cop_candidate = cop_fld_search{i};
        if isfile(cop_candidate)
            cop_path = cop_candidate;
            break;
        end
    end
    
    if ~isempty(cop_path)
        set(r01.gui.trial_panel_cop, 'BackgroundColor', 'green');
        set(r01.gui.trial_panel_cop, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_obs_cop.String = 'COP: Run';

    else
        set(r01.gui.trial_panel_cop, 'BackgroundColor', 'red');
        set(r01.gui.trial_panel_cop, 'ForegroundColor', 'Black');
        r01.gui.trial_panel_cop.String = 'COP: Not Run';
    end




    


 
end
