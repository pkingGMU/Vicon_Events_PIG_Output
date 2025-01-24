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
    fig = uifigure('Name', 'Data Processing App', 'Position', [100, 100, 300, 300]);

    % Create a button for "Process Data"
    btnProcessData = uibutton(fig, 'push', 'Text', 'Process Data', ...
        'Position', [50, 180, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) processDataCallback(fig));

    % Create a button for "Analyze Data"
    btnAnalyzeData = uibutton(fig, 'push', 'Text', 'Analyze Data', ...
        'Position', [50, 120, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) analyzeDataCallback());
    
    % Create a button for "Obstacle Crossing"
    btnObstacleCrossing = uibutton(fig, 'push', 'Text', 'Obstacle Crossing Process', ...
        'Position', [50, 240, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) obstacleDataCallback(fig));

    % Create a text field for Frame Rate input
    lblFrameRate = uilabel(fig, 'Text', 'Frame Rate:', 'Position', [50, 80, 80, 22]);
    txtFrameRate = uieditfield(fig, 'numeric', 'Position', [130, 80, 100, 22]);
    txtFrameRate.Value = 120;  % Default value is 100

end

% Callback function for Process Data button
function processDataCallback(fig)
    % List of subject folders (you could replace this with dynamic folder listing)
    
    dataPath = fullfile(pwd, 'Gait_Preprocess', 'Data');

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

    

    % Get the frame rate input from the text box
    frameRate = fig.Children(1).Value;  % Access the text box for frame rate
    if isnan(frameRate)
        uialert(fig, 'Please enter a valid frame rate value.', 'Input Error');
        return;
    end

    method = 'process';

    % Process Data
    subjects = process(selectedFolders, choice, frameRate, method);
    disp('Processing finished')
end

% Callback function for Analyze Data button
function analyzeDataCallback()
    disp('Running analysis script...');
    cd("Gait_Analysis_Code")
    run("R01_GaitAnalysis.m")
    
    disp("Analysis Completed")
end

% Callback function for Obstacle crossing data button
function obstacleDataCallback(fig)
    % List of subject folders (you could replace this with dynamic folder listing)
    
    dataPath = fullfile(pwd, 'Gait_Obstacle', 'OBS_Data');

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

    

    % Get the frame rate input from the text box
    frameRate = fig.Children(1).Value;  % Access the text box for frame rate
    
    if isnan(frameRate)
        uialert(fig, 'Please enter a valid frame rate value.', 'Input Error');
        return;
    end

    method = 'obstacle';

    % Process Data
    subjects = process(selectedFolders, choice, frameRate, method);
    disp('Processing finished')
end
