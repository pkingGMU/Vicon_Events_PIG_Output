function [proc_tables, event_table] = arrange_tables(folder, choice)
    %%%
    % 
    %%%
    
    %%% Make an array of the file names
    
    % Convert to char
    folder = char(folder);

    %folder = fullfile(folder.folder, folder.name);
    
    % File pattern is equal to our folder directory + a csv file 
    filePattern = fullfile(folder, '*.csv');
    % files is an array of all the files in our chosen directory with the csv extension
    files = dir(filePattern);
    
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
        file_name_short = regexprep(file_name_short, '^[^a-zA-Z]+', '')
        
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
        
        %%% GAIT EVENTS

        [lhs,lto,rhs,rto, frame_start, FR, failed] = gait_detection(proc_tables.(file_name_short).trajectory_data_table, proc_tables.(file_name_short).model_data_table, proc_tables.(file_name_short).devices_data_table, choice);

        if failed == true
            continue
        end
       

        

        % Define the subject
        [~,subject_id, ~] = fileparts(folder);
        
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

        % Add event table to proc tables
        proc_tables.(file_name_short).event_data_table = event_table;



        %%% GEN DETECTION

        % Determine if its overground or treadmill
        % Ask if you are doing overground or treadmill analysis
        % choice = questdlg('Is this treadmill or overground walking?', ...
        %     'Select Gait Type ', ...
        %     'Treadmill', 'Overground', 'Cancel', 'Treadmill');

        switch choice
            case 'Treadmill'
                        [gen, gen_frames] = treadmill_gen_detection(proc_tables.(file_name_short).devices_data_table, proc_tables.(file_name_short).event_data_table, lhs, lto, rhs, rto);

            case 'Overground'
                        [gen, gen_frames] = gen_detection(proc_tables.(file_name_short).devices_data_table, proc_tables.(file_name_short).event_data_table);

        end


          
        proc_tables.(file_name_short).gen_events = gen;


        %%% Appending gen_frames vertically %%%
        % Number of gen_frames
        num_gen_frames = length(gen_frames);
        
        % Create new rows for gen_frames
        gen_data = cell(num_gen_frames, 5);
        for i = 1:num_gen_frames
            gen_data{i, 1} = subject_id;          % Subject
            gen_data{i, 2} = 'General';           % Context
            gen_data{i, 3} = 'Event';           % Name
            gen_data{i, 4} = gen_frames(i);       % Time (s)
            gen_data{i, 5} = '';                  % Description (empty)
        end
        
        % Convert gen_data to table
        gen_table = cell2table(gen_data, 'VariableNames', {'Subject', 'Context', 'Name', 'Time (s)', 'Description'});
        
        % Append gen_table to event_table
        event_table = [event_table; gen_table];
        
        % Save the updated event table in proc_tables
        proc_tables.(file_name_short).event_data_table = event_table;
        

        %%% Sorting for R01 Analyis

        % Sort the event_table by Context and then by Name
        event_table = sortrows(event_table, {'Context', 'Name'}, {'ascend', 'ascend'});

        event_table.("Time (s)") = round(event_table.("Time (s)"), 3);



        
        %%% Create Excel
        existing_data = readcell(file_name);
        
        % Convert table to cell and pad with empty columns if necessary
        new_data = table2cell(event_table);
        empty_row = repmat({''}, 1, size(existing_data, 2));  % Empty row with same number of columns
        new_data_padded = [new_data, repmat({''}, size(new_data, 1), max(0, size(existing_data, 2) - size(new_data, 2)))];
        
        % Combine new data with existing data, adding an empty row in between
        combined_data = [new_data_padded; empty_row; existing_data];
        
        %%% Rearrange Data
        
        % Use logical indexing to locate 'Events' and 'Devices' rows once
        events_idx = find(strcmp(combined_data(:, 1), 'Events'), 1);
        devices_idx = find(strcmp(combined_data(:, 1), 'Devices'), 1);
        
        % Remove rows between 'Events' and 'Devices' if found and in correct order
        if ~isempty(events_idx) && ~isempty(devices_idx) && devices_idx > events_idx
            combined_data(events_idx + 3 : devices_idx - 1, :) = [];
        end
        
        % Move 'Events' and associated rows to the top if 'Events' row is found
        if ~isempty(events_idx)
            % Extract and move 'Events' and its related rows (up to label_row) to the top
            events_data = combined_data(events_idx : events_idx + 2, :);
            combined_data(events_idx : events_idx + 2, :) = [];  % Remove these rows
            combined_data = [events_data; combined_data];        % Prepend to top
        else
            % Create custom 'events_data' if 'Events' row not found
            events_data = {'Events', [], [], [], []; 100, [], [], [], []; 'Subject', 'Context', 'Name', 'Time (s)', 'Description'};
            events_data = [events_data, repmat({''}, size(events_data, 1), max(0, size(existing_data, 2) - size(events_data, 2)))];
            combined_data = [events_data; combined_data];
        end
        
        % Replace any missing values (using `isa` with `cellfun` for efficiency)
        combined_data(cellfun(@(x) isa(x, 'missing'), combined_data)) = {[]};
        
        %%% Define Folder and Save Excel
        
        % Define root folder based on 'choice' variable
        root_folder = pwd;
        excel_folder = fullfile(root_folder, 'Gait_Analysis_Data', choice, subject_id);
        
        % Create directory if it doesn't exist
        if ~exist(excel_folder, 'dir')
            mkdir(excel_folder);
        end
        
        % Write to Excel file
        new_excel_filename = strcat(file_name_short, '_events', '.xlsx');
        new_full_file_path = fullfile(excel_folder, new_excel_filename);
        writecell(combined_data, new_full_file_path);

        
     
     end
end
