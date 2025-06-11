
function [subjects] = ge_process(selection, choice, fr)
% Takes in the list of subjects and arranges the data for each one. Returns
% the struct 'subjects' for each subject for each file.

    
         ge_arrange_tables(selection, choice, fr);

         add2log(0,['>>>> ', 'Found Gait Events for Selected Trials'],1,1);

    
end
