

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UI APPLICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


function dataProcessingApp()
    
    clc
    close all hidden
    
    % Local imports
    addpath(genpath('Functions'))
    addpath(genpath('Data'))
    addpath(genpath('Gait_Analysis_Code'))
    addpath(genpath('Gait_Analysis_Data'))
    addpath(genpath('Functions'))


    % Create a figure for the UI
    fig = uifigure('Name', 'Data Processing App', 'Position', [100, 100, 300, 200]);

    % Create a button for "Process Data"
    btnProcessData = uibutton(fig, 'push', 'Text', 'Process Data', ...
        'Position', [50, 120, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) processDataCallback());

    % Create a button for "Analyze Data"
    btnAnalyzeData = uibutton(fig, 'push', 'Text', 'Analyze Data', ...
        'Position', [50, 60, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) analyzeDataCallback());
end

% Callback function for Process Data button
function processDataCallback()
    % List of subject folders (you could replace this with dynamic folder listing)
    
    dataPath = fullfile(pwd, 'Data');

    % Get a list of folders within the 'Data' directory
    dirInfo = dir(dataPath);
    isFolder = [dirInfo.isdir];
    folderNames = {dirInfo(isFolder).name};

    % Filter out '.' and '..' which represent current and parent directories
    folderNames = folderNames(~ismember(folderNames, {'.', '..'}));
    
    % Display list dialog to select subject folders
    if isempty(folderNames)
        uialert(uifigure, 'No folders found in Data directory.', 'Folder Error');
    else
        [selection, ok] = listdlg('PromptString', 'Select Subject Folders:', ...
                                  'SelectionMode', 'multiple', ...
                                  'ListString', folderNames);

        % If the user clicked OK and made a selection
        if ok
            selectedFolders = fullfile(dataPath, folderNames(selection));
            disp('Selected folders for processing:');
            disp(selectedFolders);
            % Here, you would add the code to process the selected folders
        else
            disp('No folders selected.');
        end

        choice = questdlg('Is this treadmill or overground walking?', ...
            'Select Gait Type ', ...
            'Treadmill', 'Overground', 'Cancel', 'Treadmill');

    end

    % Process Data
    subjects = process(selectedFolders, choice);
    disp('Processing finished')


end

% Callback function for Analyze Data button
function analyzeDataCallback()
    disp('Running analysis script...');

    run("Gait_Analysis_Code\R01_GaitAnalysis.m")
    
    disp("Analysis Completed")
end
