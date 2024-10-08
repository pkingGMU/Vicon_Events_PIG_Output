
function [subjects] = process(subjects_list)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [] = arrange_tables(subject);
    
        % Easy naming convention
        subject =  'sub' + string(subject.name);

        % Struct setup data
        %subjects.(subject).cwa_data = cwa_data;

        

        
    end
end
