function import_data(type_selection)

global r01
r01.current.fileopen_ok = 0;

% selection_types = struct(...
%     'single_trial',...
%     'single_subject',...
%     'multiple_subjects');

data_folder = fullfile(pwd, 'Data');

files = uipickfiles('FilterSpec', data_folder);

persistent file_list

if isempty(file_list)
    file_list = {};
end

switch type_selection

    case 'single_trial'

        if ismember(files, file_list)

        else

            path_parts = strsplit(files{1}, {'/', '\'});
            subject_name = path_parts(end - 1);
            trial_file_name = path_parts(end);
            trial_name = strsplit(trial_file_name{1}, '.csv');
            trial_name = trial_name{1};

            



            file_list = [file_list; [files, subject_name, trial_name, trial_file_name]];
            disp(file_list);
        end
        

        
    case 'single_subject'

        files_dir = dir(files{1});
        files_list = files_dir(~ismember({files_dir.name}, {'.', '..'}));

        for file = 1:length(files_list)

            file_name = fullfile(files_list(file).folder, files_list(file).name);
            
            if ismember(file_name, file_list)

            else

                path_parts = strsplit(file_name, {'/', '\'});
                subject_name = path_parts(end - 1);
                trial_file_name = path_parts(end);
                trial_name = strsplit(trial_file_name{1}, '.csv');
                trial_name = trial_name{1};

                file_list = [file_list; [file_name, subject_name, trial_name, trial_file_name]];

                disp(file_list);
            end

        end

    case 'multiple_trials'

        for file = 1:length(files)

            file_name = files(file);
            
            if ismember(file_name, file_list)

            else

                path_parts = strsplit(file_name, {'/', '\'});
                subject_name = path_parts(end - 1);
                trial_file_name = path_parts(end);
                trial_name = strsplit(trial_file_name{1}, '.csv');
                trial_name = trial_name{1};

                file_list = [file_list; [file_name, subject_name, trial_name, trial_file_name]];

                disp(file_list);
            end

        end

        
        
        
    case 'multiple_subjects'

     
        

        for subject = 1:length(files)

            % Catch if nothing is picked %

            try
        
                files_dir = dir(files{subject});
                files_list = files_dir(~ismember({files_dir.name}, {'.', '..'}));
                for file = 1:length(files_list)
    
                    file_name = fullfile(files_list(file).folder, files_list(file).name);
                    
                    if ismember(file_name, file_list)
        
                    else
    
                        path_parts = strsplit(file_name, {'/', '\'});
                        subject_name = path_parts(end - 1);
                        trial_file_name = path_parts(end);
                        trial_name = strsplit(trial_file_name{1}, '.csv');
                        trial_name = trial_name(1);
    
                        file_list = [file_list; [file_name, subject_name, trial_name, trial_file_name]];
    
                        disp(file_list);
                    end
    
                end

            catch
                disp('No file selected')
            end

        end
        
    otherwise
        
end




if ~isempty(r01.files.file_list)
    add2log(1, ['Files added successfully'], 1,1,1,1,0,1);
else
    add2log(1, ['Files not selected'], 1,1,1,1,0,1);

end



r01.files.file_list = cellfun(@strtrim, file_list, 'UniformOutput', false);

if ~isempty(r01.files.file_list) 

    
    subject_update_list = unique(r01.files.file_list(:, 2));
    r01.files.subjects = subject_update_list;
     
    set(r01.gui.subject_list_dropdown, 'String', subject_update_list)


end



