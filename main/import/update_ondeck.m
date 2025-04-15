function update_ondeck
    
    global r01

    % trial_list = r01.gui.file_list_dropdown.String;
    trial_list = r01.files.selected_trials;

    value_num = r01.gui.file_list_dropdown.Value;

    % Catch if list is empty %

    try
        
        if height(r01.files.ready_to_process) < 1
            r01.files.ready_to_process = trial_list(value_num, :);
        elseif ismember(trial_list(value_num, 1), r01.files.ready_to_process(:, 1))
            disp('Exists')
        elseif height(r01.files.ready_to_process) >= 1
            r01.files.ready_to_process(end+1, :) = trial_list(value_num, :);
        end

    
        
    
        set(r01.gui.ondeck_dropdown, 'String', r01.files.ready_to_process(:, 3));

    catch
        disp('List empty')
    
    end
end

