
function [subjects] = ges_process(subjects_list, choice, fr)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    % Each subject folder
    for i = 1:length(subjects_list)
        subject = subjects_list(i);

        % Get subject data for subject folder
        [proc_tables] = ges_arrange_tables(subject, choice, fr);

        %%% new arrange table for Obstacle Crossing?
    
        % Easy naming convention
        % Regex to get subject name
        subject = char(subject);
        parts = strsplit(subject, 'Data');
        subject_name = parts{2};
        subject_name = regexprep(subject_name, '[\\/]', '');

        % Display subject for debugging
        subject =  'sub' + string(subject_name);

        subject = regexprep(subject, ' ', '_');

        subjects.(subject).proc_tables = proc_tables;

    end
end
