
function [subjects] = ge_process(files_list, choice, fr)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    
        [proc_tables] = ge_arrange_tables(files_list, choice, fr);
    
end
