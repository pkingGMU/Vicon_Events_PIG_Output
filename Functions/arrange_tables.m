function [proc_tables] = arrange_tables(folder)
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
        file_name = fullfile(folder, files(file).name);
        
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
        
       
        
     
    end
end
