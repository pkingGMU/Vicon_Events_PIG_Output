% Callback function
function update_subject_text(src, ~)

    global r01

    % Get selected item
    selectedIdx = src.Value;
    selectedStr = src.String{selectedIdx};

    % Update the text field
    r01.gui.subject_panel_name.String = ['Selected: ' selectedStr];

    % Catch when the list is empty
    try

        value_num = r01.gui.subject_list_dropdown.Value;
        subject = r01.files.subjects(value_num);
        
        r01.files.selected_subject = subject;
    
        full_trial_list = r01.files.file_list;
    
        trial_list_idx = find(ismember(full_trial_list(:,2), subject));
    
        trial_list = full_trial_list(trial_list_idx, :);
    
        r01.files.selected_trials = trial_list;
    
        r01.gui.file_list_dropdown.Value = 1;
    
    
        set(r01.gui.file_list_dropdown, 'String', trial_list(:, 3))
        
    catch

        disp('List empty')
    end


    

    
end
