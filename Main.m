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

%% test MOS

%%
gen = gen_detection(subjects.sub09.proc_tables.DT_Walk09.devices_data_table, subjects.sub09.proc_tables.DT_Walk09.event_data_table);

%%

addpath(genpath('Gait_Analysis_Code'));

gait_cycles = getGaitCycles(table2array(subjects.sub09.proc_tables.DT_Walk09.model_data_table(:, :)), all_events, lhs, rhs);

%%
[rhs, rto, lhs, lto, all_events] = getGaitEvents(table2array(subjects.sub09.proc_tables.DT_Walk09.event_data_table(:,{'Context', 'Name'})), table2array(subjects.sub09.proc_tables.DT_Walk09.event_data_table(:,{'Time (s)'})),100);

%%

ouput = MarginOfStability('09',100,1000,subjects.sub09.proc_tables.DT_Walk09.model_data_table.Properties.VariableNames,subjects.sub09.proc_tables.DT_Walk09.model_data_table,subjects.sub09.proc_tables.DT_Walk09.trajectory_data_table,subjects.sub09.proc_tables.DT_Walk09.trajectory_data_table.Properties.VariableNames, all_events, 1);




