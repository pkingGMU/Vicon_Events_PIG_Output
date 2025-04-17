function [section_data_table] = table_processing(section, data_table)
%%% Creates a table for each section of each file
   
    disp(section)
    
    % Finding the section in the first column of the full data table
    try 
        section_index = find(strcmp(data_table.Var1, section));
        variable = 'Var1';
    catch
        section_index = find(strcmp(data_table.Subject, section));
        variable = 'Subject';
    end
    
    % Getting the size of the full data table
    % We'll need this later
    [numRows, ~] = size(data_table);

    % Get the row index of where the labels we want are
    labelIdx = section_index + 3;

    %%% Setting parameter for new data table
    rowStart = section_index + 5;
    % We will find row end later

    % Every table will include the first column
    colStart = 1;

    % We use the custom function first_nan to get the end of the columns
    % for each section
    colEnd = first_nan(data_table(labelIdx, :));

    
    % A switch is a fancy if statement
    % In the case 'section' is 'Devices', or 'Model Outputs', or
    % 'Trajectories.... Do something different

    % Finding end row and end label column based on which section we'er looking for
    % We want to get a single row table for both our labels and sub labels
    % to use later to make our combind label variable names
    switch section
        case 'Devices'

            % This is one of the few hardcoded searches since the format
            % should stay the same throughout

            % Row end is finding the next section and going up one row
            rowEnd = find(strcmp(data_table.(variable), 'Model Outputs')) - 1;

            % Labels is a new one row table that is the row of the label
            % idx we found early and all the columns up until our column
            % end
            labels = data_table(labelIdx, 1:colEnd);

            % Sub labels is the same as labels but just up one row
            sub_labels = data_table(labelIdx - 1, 1:colEnd);
   
        case 'Model Outputs'
            rowEnd = find(strcmp(data_table.(variable), 'Trajectories')) - 1;
            labels = data_table(labelIdx, 1:colEnd);
            sub_labels = data_table(labelIdx - 1, 1:colEnd);
           
        case 'Trajectories'
            rowEnd = numRows;
            labels = data_table(labelIdx, 1:colEnd);
            sub_labels = data_table(labelIdx - 1, 1:colEnd);
    end

    
    % Convert label to string array for further manipulation
    string_labels = string(labels.Variables);
    
    
    sub_labels = string(sub_labels.Variables);

    % Remove numbers from sub labels
    sub_labels = cellfun(@(x) regexprep(x, '^[^:]*:', ''), cellstr(sub_labels), 'UniformOutput', false);

    sub_labels = string(sub_labels);

   
    


    %%% Creating unique variables by concat labels and sub labels
    
    % Looping through the amount of times there are lables
    for variable = 1:length(string_labels)

        % temp variables we'll call pointers that only move and change when
        % specific conditions are met. We initially set them to be the
        % first column variable 
        label_pointer = string_labels(variable);
        sub_pointer = sub_labels(variable);

        
        % The first 2 columns are always Frame and Sub Frame
        if variable == 1 || variable == 2
            continue

        % Check to see if sub_pointer is not empty. If it is not empty
        % assign the sub variable to our temporary pointer
        elseif sub_pointer ~= ""

            % Removes all unnecesary numbers and spaces
            sub_pointer = strtrim(regexprep(erase(sub_pointer, '-'), '\s+', ''));
            
            % Set a variable for last sub pointer so that the last else can
            % rememeber what pointer we left off on
            last_sub_pointer = sub_pointer;
            
            % Make new variable using concat
            string_labels(variable) = sub_pointer + '_' + string_labels(variable);
        else 
            
            % This section will only run when the sub_pointer is empty. It
            % will use the last_sub_pointer we set before 
            % Make new variable from last pointer
            string_labels(variable) = last_sub_pointer + '_' + string_labels(variable);

            
        end
        
    end

    % Check for duplicates in the string_labels array

    unique_labels = string_labels;  % Create a copy to modify
    
    % Check for duplicates in the unique_labels array
    for i = 1:length(unique_labels)
        % If a label already exists earlier in the list, add a suffix to make it unique
        while sum(unique_labels(1:i-1) == unique_labels(i)) > 0
            unique_labels(i) = unique_labels(i) + "_dup"; % Add a "_dup" suffix to make the name unique
        end
    end

    string_labels = unique_labels;


    
    % Creating the new table
    section_data_table = data_table(rowStart:rowEnd, colStart:colEnd);

    % Apply new labels
    section_data_table.Properties.VariableNames = string_labels;

  
    % We made a new table!

    
    
end
