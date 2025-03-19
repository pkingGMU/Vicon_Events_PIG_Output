%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% UI APPLICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function app()
    
    clc
    close all hidden;
    clear global r01

    %%% Main global variable struct %%%
    global r01

    r01.intern.name = 'GMU SMART Lab';
    r01.intern.version = 0.01;
    versiontxt = num2str(r01.intern.version,'%3.2f');
    r01.intern.versiontxt = ['V',versiontxt(1:3),'.',versiontxt(4:end)];
    r01.intern.version_datestr = '2025-03-19';
    
    file = which('app.m');
    
    if isempty(file)
        errormessage('Can''t find R01 Installation. Change to R01 install directory');
        return;
    end
    
    % Local Import
    r01.intern.install_dir = fileparts(file);
    addpath(genpath(r01.intern.install_dir));

    r01preset;

    %%% TODO BATCH

    r01.intern.batchmode = 0;
    r01logo;

    % Allow for loading
    pause(1);
    delete(r01.gui.fig_logo);

    r01gui;

    add2log(0,['>>>> ',datestr(now,31), ' Session started'],1,1);



    % Create a figure for the UI
    %fig = uifigure('Name', 'Data Processing App', 'Position', [100, 100, 300, 300]);

    % Create a button for "Process Data"
%     btnProcessData = uibutton(fig, 'push', 'Text', 'Start', ...
%         'Position', [50, 180, 200, 40], ...
%         'ButtonPushedFcn', @(btn,event) processDataCallback(fig));
% 
%     % Create a text field for Frame Rate input
%     lblFrameRate = uilabel(fig, 'Text', 'Frame Rate:', 'Position', [50, 80, 80, 22]);
%     txtFrameRate = uieditfield(fig, 'numeric', 'Position', [130, 80, 100, 22]);
%     txtFrameRate.Value = 100;  % Default value is 100
% 
% end
% 
% % Callback function for Process Data button
% function processDataCallback(fig)
% 
%     % Get the frame rate input from the text box
%     frameRate = fig.Children(1).Value;  % Access the text box for frame rate
%     if isnan(frameRate)
%         uialert(fig, 'Please enter a valid frame rate value.', 'Input Error');
%         return;
%     end
% 
% 
%     possible_outcomes = ["Gait Events", "Gait Events & Clean Force Strikes", "R01 Analysis", ...
%         "Obstacle Crossing Outcomes", "Margin Of Stability"];
% 
%     % Get list of outcome measures
%     [outcome_selection, ~] = listdlg('PromptString', 'Select Outcome:', ...
%                               'SelectionMode', 'single', ...
%                               'ListString', possible_outcomes);
% 
%     outcome_selection = possible_outcomes(outcome_selection);
% 
%     selection_routing(outcome_selection, frameRate);
% 
%     disp("Finished!")
% 
% end

