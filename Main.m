%%% MAIN SCRIPT %%%
clc
clear

%%% Local Imports
% Add function folder to search path
addpath(genpath('Functions'))

% Select directory
folder = uigetdir();

%%
% Return a list of subjects to import into process
subjects_list = arrange_subjects(folder);