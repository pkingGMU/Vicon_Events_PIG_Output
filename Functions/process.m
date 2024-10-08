
function [subjects] = process(subjects_list)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [proc_tables, event_table] = arrange_tables(subject);
    
        % Easy naming convention
        % Display subject for debugging
        subject =  'sub' + string(subject.name)

        subjects.(subject).proc_tables = proc_tables;

        subjects.(subject).event_table = event_table;

        

        
    end
end
