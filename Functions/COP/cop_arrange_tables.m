function [proc_tables] = cop_arrange_tables(files, fr)
    %%%
    % Function specifically designed for looking at obstacle crossing data
    %%%

    global r01
    clear file

    for file = 1:height(files)
        
        
        
        csv_name = files{file, 1};
 
        file_name_short_prefix = strrep(erase(files{file, 3}, ".csv"), ' ', '_');
        file_name_short = regexprep(file_name_short_prefix, '^[^a-zA-Z]+', '');
        
        subject = files{file, 2};
        % Debugging
        disp(file_name_short_prefix)
        full_trial_list = r01.files.file_list;
        file_list_idx = find(cellfun(@(i) isequal(full_trial_list(i, :), files), num2cell(1:size(full_trial_list, 1))));

        r01.files.file_list(file_list_idx, 5) = {file_name_short};
        
        % All of these options are to ensure every csv is imported
        % correctly and every variable is type char
        opts = detectImportOptions(csv_name);
        opts = setvartype(opts, 'char');
        opts.VariableNamingRule = 'preserve';
        opts = setvaropts(opts, 'Type', 'char');
        opts.DataLines = [1 Inf];
        

        full_data_table = readtable(csv_name, opts);

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
      
             cop_analysis(proc_tables, csv_name, fr, file_name_short, subject);
        
        

            % SubID = trial_txt(4,1);
        Subject = char(subject);

        excel_folder = fullfile(pwd, 'Output', 'COP', Subject, file_name_short_prefix);
        
        % Create directory if it doesn't exist
        if ~exist(excel_folder, 'dir')
            mkdir(excel_folder);
        end

        % % ***************** Export data to an Excel sheet ***********************
        % % Name the excel sheet: (with file path)
        % fname2 = fullfile(excel_folder, strcat(file_name_short_prefix, '.xlsx'));
        % 
        % headers = {'Subject', 'Trial','Lead Foot','Obstacle_approach_dist_trail','Obstacle_landing_dist_lead',...
        %            'Obstacle_approach_dist_lead','Obstacle_landing_dist_trail',...
        %            'Lead_toe_clearance','Trail_toe_clearance','Lead_heel_clearance','Trail_heel_clearance',...
        %            'Obstacle Height', 'Start', 'End', 'Lead Step Length', 'Trail Step Length', 'Lead Step Width'...
        %            , 'Trail Step Width', 'LMoS_AP_Double_Before','RMoS_AP_Double_Before','LMoS_ML_Double_Before','RMoS_ML_Double_Before','LMoS_AP_Double_After','RMoS_AP_Double_After',...
        %            'LMoS_ML_Double_After','RMoS_ML_Double_After'};
        % Sheeta = string(Subject);
        % 
        % % Convert OBS_data to a table
        % OBS_table = cell2table(OBS_Data, 'VariableNames', headers);
        % 
        % writetable(OBS_table, fname2, 'Sheet', Sheeta, 'WriteRowNames', false);

                
    end

  
end
