function [event_table] = ge_arrange_tables(files, choice, fr)
    %%%
    % Function specifically designed for ONLY looking for Gait Events. We
    % take in a folder which is generally the data folder. It will parse
    % out Subject name and get a list of all the *.csv files.
    % It will process each file for each subject into 3 different processed
    % tables. This includes the devices data table, model_outputs data
    % table, and trajectory data table. It will then auto detect gait events (hs, opp_to, opp_hs, to).
    % It will NOT look for general events like force plate strikes. The data will then be rebuilt into a new
    % .xlsx file using a chunk method because of the opening time for
    % excel. Writing in smaller multiple chunks reduces memory allocation
    % for worse computers. 
    %%%
    
    global r01
    clear file
   
    
    %%% Loop through all file names in the files array
    
    % We loop through the amount of times there are files and set the
    % variable file = to which loop we'er on.
    % The first pass file = 1
    % The second pass file = 2
    % Etc.....
    for file = 1:height(files)

        log_file = fullfile(pwd, 'logs', 'error_log.csv');

        
        try
       
        
        csv_name = files{file, 1};
 
        file_name_short_prefix = strrep(erase(files{file, 3}, ".csv"), ' ', '_');
        file_name_short = regexprep(file_name_short_prefix, '^[^a-zA-Z]+', '');
        
        
        % Debugging
        disp(file_name_short_prefix)
        full_trial_list = r01.files.file_list;
        file_list_idx = find(cellfun(@(i) isequal(full_trial_list(i, :), files), num2cell(1:size(full_trial_list, 1))));

        r01.files.file_list(file_list_idx, 5) = {file_name_short};

        % Make a full data table with the file name we'er on
        
        % All of these options are to ensure every csv is imported
        % correctly and every variable is type char
        opts = detectImportOptions(csv_name);
        opts = setvartype(opts, 'char');
        opts.VariableNamingRule = 'preserve';
        opts = setvaropts(opts, 'Type', 'char');
        opts.DataLines = [1 Inf];
        

        full_data_table = readtable(csv_name, opts);
        
        
        full_data_table.Properties.VariableNames{3} = 'Var3';
        full_data_table.Properties.VariableNames{1} = 'Var1';
        
        %%% Create new tables for each section (Note this uses a custom function table_processing.m
        % The tables will be added to the struct proc_tables at the file
        % name we'er on at the table we'er trying to create. Structs are
        % great for organizing a lot of data into folder like structures
        % that reduce our variables!

        %%% Find gesture data %%% 
        % Mainly used for Mackenzies Obstacle
        %%% Crossing
        save_gesture = save_gesture_events(full_data_table);


        % Create new data table for devices
        
        devices_data_table = table_processing('Devices', full_data_table);
        
        % Create new data table for Model Ouputs
        
        model_data_table = table_processing('Model Outputs', full_data_table);
        
        % Create new data table for Trajectories
        
        trajectory_data_table = table_processing('Trajectories', full_data_table);
        
        clear full_data_table;
        drawnow;

        %%% GAIT EVENTS

        [lhs,lto,rhs,rto, frame_start, FR, failed] = gait_detection(trajectory_data_table, model_data_table, devices_data_table, choice, fr);

        clear trajectory_data_table
        drawnow;

        if failed == true
                add2log(0,['>>>> ', strcat(file_name_short_prefix, ' Failed due to not enough gait events')],1,1);
            continue
        end
       
        
        

        % Define the subject
        % [~,subject_id, ~] = fileparts(folder);
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
        
        %%% Sorting for R01 Analyis

        % Sort the event_table by Context and then by Name
        event_table = sortrows(event_table, {'Context', 'Name'}, {'ascend', 'ascend'});

        event_table.("Time (s)") = round(event_table.("Time (s)"), 3);

        fprintf("Add new info to old csv")

        clearvars -except event_table choice subject_id csv_name fr file_name_short_prefix files r01
        
        
        %%% Create Excel
        % Existing data

        % Convert event_table to cell
        new_data = table2cell(event_table);
        
        % Open file for streaming read
        fid = fopen(csv_name, 'r');
        
        % Preallocate small cell array to store existing data line-by-line
        existing_data = {};
        
        while ~feof(fid)
            % Read one line
            line = fgetl(fid);
            if ischar(line)
                split_line = regexp(line, ',', 'split');
                converted_line = cellfun(@(x) try_str2num_else_keep(x), split_line, 'UniformOutput', false);
                existing_data{end+1, 1} = converted_line;
            end
        end
        fclose(fid);
        
        % Find max width (variable columns per row)
        max_cols = max(cellfun(@length, existing_data));
        
        % Normalize into full cell array with consistent width
        existing_data_matrix = cell(size(existing_data,1), max_cols);
        for i = 1:size(existing_data,1)
            row = existing_data{i};
            existing_data_matrix(i,1:length(row)) = row;
            if length(row) < max_cols
                existing_data_matrix(i,length(row)+1:end) = {''}; % pad missing columns
            end
        end
        
        % Get number of columns for later padding
        num_existing_cols = size(existing_data_matrix, 2);
        
        % Pad new event data to match width
        new_data_padded = [new_data, repmat({''}, size(new_data,1), num_existing_cols - size(new_data,2))];
        
        % Combine: insert event data above existing file
        empty_row = repmat({''}, 1, num_existing_cols);
        combined_data = [new_data_padded; empty_row; existing_data_matrix];
        
        clear existing_data existing_data_matrix new_data new_data_padded empty_row;
        
        fprintf("Debug 2\n");
        
        %%% Rearrange Data (same logic as your original)
        
        % Logical indexing to locate 'Events' and 'Devices' rows
        events_idx = find(strcmp(combined_data(:, 1), 'Events'), 1);
        devices_idx = find(strcmp(combined_data(:, 1), 'Devices'), 1);
        
        % Only remove rows if 'Events' and 'Devices' are found in the correct order
        if ~isempty(events_idx) && ~isempty(devices_idx) && devices_idx > events_idx
            combined_data(events_idx + 3 : devices_idx - 1, :) = [];  
        end
        
        % Move 'Events' and associated rows to the top if 'Events' is found
        if ~isempty(events_idx)
            events_data = combined_data(events_idx : events_idx + 2, :);
            combined_data(events_idx : events_idx + 2, :) = [];
            combined_data = [events_data; combined_data];
        else
            events_data = {'Events', [], [], [], []; fr, [], [], [], []; 'Subject', 'Context', 'Name', 'Time (s)', 'Description'};
            events_data = [events_data, repmat({''}, size(events_data, 1), num_existing_cols - size(events_data, 2))];
            combined_data = [events_data; combined_data];
        end
        
        clear events_data;
        
        %%% Replace missing cells (defensive, but should rarely trigger)
        combined_data(cellfun(@(x) isa(x, 'missing'), combined_data)) = {[]};

        

        % combined_data = cellfun(@(x) try_str2num_else_keep(x), combined_data, 'UniformOutput', false);

        

        %%% write to csv
        % Create folder if it doesn't exist
        root_folder = pwd;
        excel_folder = fullfile(root_folder, 'Output', 'Gait_Events', choice, subject_id);
        if ~exist(excel_folder, 'dir')
            mkdir(excel_folder);
        end
        
        % Define new CSV filename
        new_csv_filename = strcat(file_name_short_prefix, '_events', '.csv');
        new_full_file_path = fullfile(excel_folder, new_csv_filename);
        
        % Delete if it already exists
        if exist(new_full_file_path, 'file') == 2
            delete(new_full_file_path);
        end
        
        
        %writecell(combined_data, new_full_file_path);
        
        fid = fopen(new_full_file_path, 'w');

        for i = 1:size(combined_data, 1)
            row = combined_data(i, :);
            out = cell(1, numel(row));
            for j = 1:numel(row)
                value = row{j};
                if (isscalar(value) && ismissing(value)) || isempty(value)
                    out{j} = '';
                elseif isnumeric(value) && isscalar(value)
                    out{j} = num2str(value);
                elseif ischar(value) || (isstring(value) && isscalar(value))
                    out{j} = char(value);  % Convert string to char to avoid quotes
                else
                    out{j} = '[UNSUPPORTED]';  % Fallback for structs, arrays, etc.
                end
            end
            fprintf(fid, '%s\n', strjoin(out, ','));
        end
        
        fclose(fid);


        catch ME
            failed_file = string(csv_name);  % or use your own file variable
            error_msg  = string(ME.message);
            timestamp  = string(datetime('now'));
            log_row    = {timestamp, failed_file, error_msg};
        
            % Create folder if needed
            [log_folder, ~, ~] = fileparts(log_file);
            if ~exist(log_folder, 'dir')
                mkdir(log_folder);
            end
        
            % Append row to CSV
            if ~isfile(log_file)
                % write header if new file
                header = {'Timestamp', 'File', 'ErrorMessage'};
                writecell([header; log_row], log_file);
            else
                % append to existing file
                fid = fopen(log_file, 'a');
                fprintf(fid, '"%s","%s","%s"\n', timestamp, failed_file, error_msg);
                fclose(fid);
            end
        end

    end

        

    

    function val = try_str2num_else_keep(x)
            if ischar(x) || isstring(x)
                num = str2double(x);
                if ~isnan(num) && ~isempty(x)
                    val = num;  % convert numeric strings like '3.14' to 3.14
                else
                    val = x;    % keep as string like 'Context' or empty
                end
            else
                val = x;        % already numeric, empty, or a non-string type
            end
    end

    end
