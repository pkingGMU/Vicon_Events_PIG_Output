%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UI APPLICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function app()
    
    clc
    close all hidden
    
    % Local imports
    addpath(genpath('Functions'))
    addpath(genpath('Functions/Gait_Events'))
    addpath(genpath('Functions/Gait_Events_Strikes'))
    addpath(genpath('Functions/Obstacle_Crossing'))
    addpath(genpath('Functions/R01_Analysis'))
    addpath(genpath('Gait_Analysis_Code'))
    addpath(genpath('Gait_Analysis_Data'))
    addpath(genpath('Gait_Obstacle'))
    addpath(genpath('Gait_Preprocess'))

    % Create a figure for the UI
    fig = uifigure('Name', 'Data Processing App', 'Position', [100, 100, 300, 300]);

    % Create a button for "Process Data"
    btnProcessData = uibutton(fig, 'push', 'Text', 'Start', ...
        'Position', [50, 180, 200, 40], ...
        'ButtonPushedFcn', @(btn,event) processDataCallback(fig));

    % Create a text field for Frame Rate input
    lblFrameRate = uilabel(fig, 'Text', 'Frame Rate:', 'Position', [50, 80, 80, 22]);
    txtFrameRate = uieditfield(fig, 'numeric', 'Position', [130, 80, 100, 22]);
    txtFrameRate.Value = 100;  % Default value is 100

end

% Callback function for Process Data button
function processDataCallback(fig)
    
    % Get the frame rate input from the text box
    frameRate = fig.Children(1).Value;  % Access the text box for frame rate
    if isnan(frameRate)
        uialert(fig, 'Please enter a valid frame rate value.', 'Input Error');
        return;
    end

    
    possible_outcomes = ["Gait Events", "Gait Events & Clean Force Strikes", "R01 Analysis", ...
        "Obstacle Crossing Outcomes", "Margin Of Stability"];
    
    % Get list of outcome measures
    [outcome_selection, ~] = listdlg('PromptString', 'Select Outcome:', ...
                              'SelectionMode', 'single', ...
                              'ListString', possible_outcomes);

    outcome_selection = possible_outcomes(outcome_selection);

    selection_routing(outcome_selection, frameRate);

    disp("Finished!")

end

