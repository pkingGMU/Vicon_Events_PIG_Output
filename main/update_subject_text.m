% Callback function
function update_subject_text(src, ~)

    global r01

    % Get selected item
    selectedIdx = src.Value;
    selectedStr = src.String{selectedIdx};

    % Update the text field
    r01.gui.subject_panel_name.String = ['Selected: ' selectedStr];


    

    
end
