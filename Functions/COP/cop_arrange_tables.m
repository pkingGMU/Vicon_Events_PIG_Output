function [proc_tables] = cop_arrange_tables(files, choice, fr)
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
        save_gesture = save_gesture_events(full_data_table);


        % Create new data table for devices
        
        proc_tables.(file_name_short).devices_data_table = table_processing('Devices', full_data_table);
        
        % Create new data table for Model Ouputs
        
        proc_tables.(file_name_short).model_data_table = table_processing('Model Outputs', full_data_table);
        
        % Create new data table for Trajectories
        
        proc_tables.(file_name_short).trajectory_data_table = table_processing('Trajectories', full_data_table);
        

        %%% GAIT EVENTS

        [lhs,lto,rhs,rto, frame_start, FR, failed] = gait_detection(proc_tables.(file_name_short).trajectory_data_table, proc_tables.(file_name_short).model_data_table, proc_tables.(file_name_short).devices_data_table, choice, fr);
        if failed == true
            continue
        end
       
        clear full_data_table;
        

        % Define the subject
        subject_id = files{file, 2};
        
        % Find max length of events
        max_left = max([length(lhs), length(lto)]);
        max_right = max([length(rhs), length(rto)]);

        % Pad shorter arrays with NaN
        lhs = [lhs; NaN(max_left - length(lhs), 1)];
        lto = [lto; NaN(max_left - length(lto), 1)];
        rhs = [rhs; NaN(max_right - length(rhs), 1)];
        rto = [rto; NaN(max_right - length(rto), 1)];

        % Total number of rows (for left and right events)
        total_rows = (max_left + max_right) * 2;
        
        % Prepare a cell array for output (4 columns: Subject ID, Side, Event, Value, Description)
        output_data = cell(total_rows, 5);
        
        % Fill in the left side events first (alternating between heel strike and toe off)
        row_counter = 1;
        for i = 1:max_left
            % Left heel strike
            output_data{row_counter, 1} = subject_id;
            output_data{row_counter, 2} = 'Left';
            output_data{row_counter, 3} = 'Foot Strike';
            output_data{row_counter, 4} = lhs(i);
            row_counter = row_counter + 1;
            
            % Left toe off
            output_data{row_counter, 1} = subject_id;
            output_data{row_counter, 2} = 'Left';
            output_data{row_counter, 3} = 'Foot Off';
            output_data{row_counter, 4} = lto(i);
            row_counter = row_counter + 1;
        end
        
        % Fill in the right side events (alternating between heel strike and toe off)
        for i = 1:max_right
            % Right heel strike
            output_data{row_counter, 1} = subject_id;
            output_data{row_counter, 2} = 'Right';
            output_data{row_counter, 3} = 'Foot Strike';
            output_data{row_counter, 4} = rhs(i);
            row_counter = row_counter + 1;
            
            % Right toe off
            output_data{row_counter, 1} = subject_id;
            output_data{row_counter, 2} = 'Right';
            output_data{row_counter, 3} = 'Foot Off';
            output_data{row_counter, 4} = rto(i);
            row_counter = row_counter + 1;
        end

        % Convert to table
        event_table = cell2table(output_data, 'VariableNames', {'Subject', 'Context', 'Name', 'Time (s)', 'Description'});
        
        % Add saved gesture events if any
        if ~isempty(save_gesture)
            
            save_gesture.Properties.VariableNames = event_table.Properties.VariableNames;
            % Convert cell to numeric values if the content is numeric in a cell
            save_gesture.("Time (s)") = cellfun(@str2double, save_gesture.("Time (s)"));

            
            event_table = [save_gesture; event_table];
        end

        
        % Add event table to proc tables
        proc_tables.(file_name_short).event_data_table = event_table;

        [gen, gen_frames] = gen_detection(proc_tables.(file_name_short).trajectory_data_table, proc_tables.(file_name_short).devices_data_table, proc_tables.(file_name_short).event_data_table, fr);
        %cop_analysis(proc_tables, gen, fr, file_name_short);
        
        

        % SubID = trial_txt(4,1);
        Subject = char(subject);

        excel_folder = fullfile(pwd, 'Output', 'COP', Subject, file_name_short_prefix);
        
        % Create directory if it doesn't exist
        if ~exist(excel_folder, 'dir')
            mkdir(excel_folder);
        end

        fname = fullfile(excel_folder, strcat(file_name_short_prefix, '.xlsx'));
        Sheeta = string(Subject);
        headers = {'Frame', 'Time', 'Foot', 'Plate Label', '-', 'Mean COP Velocity', 'Clean', 'Start_Idx', 'End_Idx', 'Displacement_X', 'Displacement_Y', 'Propulsion Fz', 'Breaking Fz'};

        % Convert OBS_data to a table
        if height(gen) == 1
            COP_table = struct2table(gen, 'AsArray',true);
        else
            COP_table = struct2table(gen);
        end
        

        writetable(COP_table, fname, 'Sheet', Sheeta, 'WriteRowNames', false);

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
