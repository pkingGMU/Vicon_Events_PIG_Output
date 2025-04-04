
function [subjects] = obstacle_process(subjects_list, choice, fr)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    total_OBS = [];

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [proc_tables, total_OBS] = obstacle_arrange_tables(subject, choice, fr, total_OBS);

        %%% new arrange table for Obstacle Crossing?
    
        % Easy naming convention
        % Regex to get subject name
        subject = char(subject);
        parts = strsplit(subject, 'Data');
        subject_name = parts{2};
        subject_name = regexprep(subject_name, '[\\/]', '');

        % Display subject for debugging
        subject =  'sub' + string(subject_name);

        subject = regexprep(subject, ' ', '_');

        subjects.(subject).proc_tables = proc_tables;

    end

    % ***************** Export data to an Excel sheet ***********************
    % Name the excel sheet: (with file path)
    fname2 = fullfile('Output', 'Obstacle_Crossing', strcat('total', '.xlsx'));
    % headers = {'Trial','Lead Foot','Obstacle_approach_dist_trail','Obstacle_landing_dist_lead',...
    %     'Obstacle_approach_dist_lead','Obstacle_landing_dist_trail',...
    %     'Lead_toe_clearance','Trail_toe_clearance','Lead_heel_clearance','Trail_heel_clearance',...
    %     'Obstacle Height', 'Start', 'End', 'Lead Step Length', 'Trail Step Length', 'Lead Step Width'...
    %     , 'Trail Step Width', 'LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to',...
    %     'LMoS_ML_to','RMoS_ML_to'};

    headers = {'Subject', 'Trial','Lead Foot','Obstacle_approach_dist_trail','Obstacle_landing_dist_lead',...
        'Obstacle_approach_dist_lead','Obstacle_landing_dist_trail',...
        'Lead_toe_clearance','Trail_toe_clearance','Lead_heel_clearance','Trail_heel_clearance',...
        'Obstacle Height', 'Start', 'End', 'Lead Step Length', 'Trail Step Length', 'Lead Step Width'...
        , 'Trail Step Width', 'LMoS_AP_Double_Before','RMoS_AP_Double_Before','LMoS_ML_Double_Before','RMoS_ML_Double_Before','LMoS_AP_Double_After','RMoS_AP_Double_After',...
        'LMoS_ML_Double_After','RMoS_ML_Double_After'};
    

    % Convert OBS_data to a table
    OBS_table = cell2table(total_OBS, 'VariableNames', headers);

    writetable(OBS_table, fname2, 'WriteRowNames', false);
end
