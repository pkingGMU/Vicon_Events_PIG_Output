function [proc_tables, total_OBS] = obstacle_arrange_tables(folder, choice, fr, total_OBS)
    %%%
    % Function specifically designed for looking at obstacle crossing data
    %%%

    
    
    
    %%% Folder conversion %%%
    % Convert to char
    folder = char(folder);
    % File pattern is equal to our folder directory + a csv file 
    filePattern = fullfile(folder, '*.csv');
    % files is an array of all the files in our chosen directory with the csv extension
    files = dir(filePattern);

    %%% Get Subject Name %%%
    % Easy naming convention
    % Regex to get subject name
    subject = char(folder);
    parts = strsplit(subject, 'Data');
    subject_name = parts{2};
    subject_name = regexprep(subject_name, '[\\/]', '');
    % Display subject for debugging
    subject =  'sub' + string(subject_name);
    subject = regexprep(subject, ' ', '_');
    
    %%% Loop through all file names in the files array
    
    % We loop through the amount of times there are files and set the
    % variable file = to which loop we'er on.
    % The first pass file = 1
    % The second pass file = 2
    % Etc.....
    for file = 1:numel(files)
        
        
        
        % Set temp variable to the nth file in our list of files
        file_name = fullfile(folder, files(file).name);
        
        % A shorted file name without the csv extension
        file_name_short = strrep(erase(files(file).name, ".csv"), ' ', '_');
        % Remove any unnecessary numbers
        file_name_short = regexprep(file_name_short, '^[^a-zA-Z]+', '');
        
        % Debugging
        disp(file_name_short)

        % Make a full data table with the file name we'er on
        
        % All of these options are to ensure every csv is imported
        % correctly and every variable is type char
        opts = detectImportOptions(file_name);
        opts = setvartype(opts, 'char');
        opts.VariableNamingRule = 'preserve';
        opts = setvaropts(opts, 'Type', 'char');
        opts.DataLines = [1 Inf];
        

        full_data_table = readtable(file_name, opts);

        full_data_table.Properties.VariableNames{3} = 'Var3';
        
        
        %%% Create new tables for each section (Note this uses a custom function table_processing.m
        % The tables will be added to the struct proc_tables at the file
        % name we'er on at the table we'er trying to create. Structs are
        % great for organizing a lot of data into folder like structures
        % that reduce our variables!


        % Create new data table for devices
        
        proc_tables.(file_name_short).devices_data_table = table_processing('Devices', full_data_table);
        
        % Create new data table for Model Ouputs
        
        proc_tables.(file_name_short).model_data_table = table_processing('Model Outputs', full_data_table);
        
        % Create new data table for Trajectories
        
        proc_tables.(file_name_short).trajectory_data_table = table_processing('Trajectories', full_data_table);

        OBS_Data(file, :) = obstacle_analysis(proc_tables, folder, fr, file_name_short);

        
                
    end

    total_OBS = [total_OBS; OBS_Data];


    %%% Obstacle Crossing %%%

    % SubID = trial_txt(4,1);
    Subject = char(subject_name);

    excel_folder = fullfile(pwd, 'Output', 'Obstacle_Crossing', Subject);
    
    % Create directory if it doesn't exist
    if ~exist(excel_folder, 'dir')
        mkdir(excel_folder);
    end
        
    

    % ***************** Export data to an Excel sheet ***********************
    % Name the excel sheet: (with file path)
    fname2 = fullfile(excel_folder, strcat(Subject, '.xlsx'));
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
    Sheeta = string(Subject);

    % Convert OBS_data to a table
    OBS_table = cell2table(OBS_Data, 'VariableNames', headers);

    writetable(OBS_table, fname2, 'Sheet', Sheeta, 'WriteRowNames', false);

   
        
end
