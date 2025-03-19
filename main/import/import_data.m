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
            file_list = [file_list files];
            disp(file_list);
        end
        

        
    case 'single_subject'

        files_dir = dir(files{1});
        files_list = files_dir(~ismember({files_dir.name}, {'.', '..'}));

        for file = 1:length(files_list)

            file_name = fullfile(files_list(file).folder, files_list(file).name);
            
            if ismember(file_name, file_list)

            else
                file_list = [file_list file_name];
                disp(file_list);
            end

        end

    case 'multiple_trials'

        for file = 1:length(files)

            file_name = files(file);
            
            if ismember(file_name, file_list)

            else
                file_list = [file_list file_name];
                disp(file_list);
            end

        end

        
        
        
    case 'multiple_subjects'

     
        

        for subject = 1:length(files)
        
            files_dir = dir(files{subject});
            files_list = files_dir(~ismember({files_dir.name}, {'.', '..'}));
            for file = 1:length(files_list)

                file_name = fullfile(files_list(file).folder, files_list(file).name);
                
                if ismember(file_name, file_list)
    
                else
                    file_list = [file_list file_name];
                    disp(file_list);
                end

            end

        end
        
    otherwise
        
end




if ~isempty(files)
    add2log(1, ['Files added successfully'], 1,1,1,1,0,1);
else
    add2log(1, ['Files not selected'], 1,1,1,1,0,1);

end

r01.files.file_list = file_list;
set(r01.gui.file_list_dropdown, 'String', r01.files.file_list)


