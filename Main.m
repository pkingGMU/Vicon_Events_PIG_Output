%%% MAIN SCRIPT %%%

%%% Local Imports
% Add function folder to search path
addpath(genpath('Functions'))



%%

% Get our folder full of CSV's
folder = uigetdir();


%%
% Return a list of subjects to import into process

subjects_list = arrange_subjects(folder);

%%


% This function will return TBD

subjects = process(subjects_list);



