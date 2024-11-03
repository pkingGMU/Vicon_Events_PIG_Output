
function [subjects] = process(subjects_list)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [proc_tables] = arrange_tables(subject);
    
        % Easy naming convention
        % Regex to get subject name
        subject = char(subject);
        parts = strsplit(subject, 'Data\');
        subject_name = parts{2};


        % Display subject for debugging
        subject =  'sub' + string(subject_name);

        subjects.(subject).proc_tables = proc_tables;

        

        

        
    end
end
