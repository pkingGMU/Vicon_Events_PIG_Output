function process_callback(fr)

    global r01
    
    

    possible_outcomes = ["Gait Events", "Gait Events & Clean Force Strikes", "R01 Analysis", ...
        "Obstacle Crossing Outcomes", "Margin Of Stability"];

    % Get list of outcome measures
    [outcome_selection, ~] = listdlg('PromptString', 'Select Outcome:', ...
                              'SelectionMode', 'single', ...
                              'ListString', possible_outcomes);

    outcome_selection = possible_outcomes(outcome_selection);

    selection_routing(outcome_selection, fr);

    
    disp("Finished!")

end

