function [proc_tables, event_table] = arrange_tables(folder)
    %%%
    % 
    %%%
    
    %%% Make an array of the file names
    

    folder = fullfile(folder.folder, folder.name)
    
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
        file_name = fullfile(folder, files(file).name)
        
        % A shorted file name without the csv extension
        file_name_short = strrep(erase(files(file).name, ".csv"), ' ', '_')
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

        [lhs,lto,rhs,rto, frame_start, FR] = gait_detection(proc_tables.(file_name_short).trajectory_data_table, proc_tables.(file_name_short).model_data_table);


       

        

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

        [gen, gen_frames] = gen_detection(proc_tables.(file_name_short).devices_data_table, proc_tables.(file_name_short).event_data_table);

          
        proc_tables.(file_name_short).gen_events = gen;


        %%% Appending gen_frames vertically %%%
        % Number of gen_frames
        num_gen_frames = length(gen_frames);
        
        % Create new rows for gen_frames
        gen_data = cell(num_gen_frames, 5);
        for i = 1:num_gen_frames
            gen_data{i, 1} = subject_id;          % Subject
            gen_data{i, 2} = 'General';           % Context
            gen_data{i, 3} = 'General';           % Name
            gen_data{i, 4} = gen_frames(i);       % Time (s)
            gen_data{i, 5} = '';                  % Description (empty)
        end
        
        % Convert gen_data to table
        gen_table = cell2table(gen_data, 'VariableNames', {'Subject', 'Context', 'Name', 'Time (s)', 'Description'});
        
        % Append gen_table to event_table
        event_table = [event_table; gen_table];
        
        % Save the updated event table in proc_tables
        proc_tables.(file_name_short).event_data_table = event_table;



        
        %%% Create excel
        
        existing_data = readcell(file_name);

        new_data = table2cell(event_table);
        
        % Add empty row
        empty_row = repmat({''}, 1, size(existing_data, 2));  % Empty row with the same number of columns

        size(existing_data)
        size(new_data)
        size(empty_row)

        % Step 3: Get the size of the existing data
        [~, existing_cols] = size(existing_data);
        
        % Pad columns
        new_data_padded = [new_data, repmat({''}, size(new_data, 1), existing_cols - size(new_data, 2))];
        
        % Concat csv with event data
        combined_data = [new_data_padded; empty_row; existing_data];
        
        %%% Rearrange Data

        % Find the row containing 'events' and 'Devices'
        events_row = find(strcmp(combined_data, 'Events'));  % Find the row with 'Events'
        devices_row = find(strcmp(combined_data, 'Devices'));  % Find the row with 'Devices'
        
        % If both 'events' and 'Devices' are found
        if ~isempty(events_row) && ~isempty(devices_row)
            % Ensure that the 'Devices' row comes after the 'events' row
            if devices_row > events_row
                % Delete all rows between 'events' and 'Devices'
                combined_data(events_row + 3 : devices_row - 1, :) = [];
            end
        end
        
        % Find events row again
        events_row = find(strcmp(combined_data, 'Events'));  % Find the row with 'Events'

        % If 'events' row is found, move it and the next row to the top
        if ~isempty(events_row)
            % Ensure the row below 'events' is included
            frame_rate_row = events_row + 1;

            label_row = events_row +2;
            
            % Extract the 'events' row and the row below it
            events_data = combined_data(events_row:label_row, :);
            
            % Remove the 'events' and the row below it from their original position
            combined_data(events_row:label_row, :) = [];
            
            % Add 'events' data to the top
            combined_data = [events_data; combined_data];
        else 
             % If 'events' row is not found, create a custom 'events_data'
             events_data = {'Events', [], [], [], []; 100, [], [], [], []; 'Subject', 'Context', 'Name', 'Time (s)', 'Description'};  % Creating a 2x1 cell array
            
             % Pad out new events data
             % Step 3: Get the size of the existing data
             
             events_data_padded = [events_data, repmat({''}, size(events_data, 1), existing_cols - size(events_data, 2))];

             % Add 'events_data' to the top
             combined_data = [events_data_padded; combined_data];
        end

        % Replace missing values with a specific value, e.g., empty string or NaN
        
        % If it's a cell array
        
        mask = cellfun(@(x) any(isa(x,'missing')), combined_data); % using isa instead of ismissing allows white space through
        combined_data(mask) = {[]};
                
        % Write the modified data to a new Excel file
        new_excel_filename = strcat(file_name_short, '_events', '.xlsx');
        new_full_file_path = fullfile(folder, new_excel_filename);
        writecell(combined_data, new_full_file_path);

        % Step 7: Write the combined data to a new Excel file
        % new_excel_filename = 'updated_file.xlsx';
        % writecell(combined_data, new_excel_filename);
        


        % % Extract variable names
        % % Step 2: Extract variable names and convert them into rows
        % header1 = event_table.Properties.VariableNames;
        % header2 = proc_tables.(file_name_short).devices_data_table.Properties.VariableNames;  % Variable names from table1
        % header3 = proc_tables.(file_name_short).model_data_table;  % Variable names from table2
        % header4 = proc_tables.(file_name_short).trajectory_data_table.Properties.VariableNames;  % Variable names from table3
        % 
        % % Step 3: Convert tables to cell arrays (to remove variables and keep data)
        % data1 = table2cell(event_table);  % Skip header row and get data
        % data2 = table2cell(proc_tables.(file_name_short).devices_data_table);  % Skip header row and get data
        % data3 = table2cell(proc_tables.(file_name_short).model_data_table);  % Skip header row and get data
        % data4 = table2cell(proc_tables.(file_name_short).trajectory_data_table);  % Skip header row and get data
        % 
        % % Step 4: Add the header (variable names) to the top of each data section
        % data1_with_header = [header1; data1];  % Add header to table1 data
        % data2_with_header = [header2; data2];  % Add header to table2 data
        % data3_with_header = [header3; data3];  % Add header to table3 data
        % data4_with_header = [header4; data4];  % Add header to table3 data
        % 
        % % Step 5: Skip a row between each section (create empty row)
        % empty_row = repmat({''}, 1, size(data3_with_header, 2));  % Empty row with the same number of columns
        % 
        % % Step 6: Combine all sections into a single cell array
        % combined_data = [data1_with_header; empty_row; data2_with_header; empty_row; data3_with_header];
        % 
        % % Step 7: Write the combined data to a new CSV file
        % new_csv_filename = 'combined_data.csv';
        % writecell(combined_data, new_csv_filename);




     



        
     
     end
end
