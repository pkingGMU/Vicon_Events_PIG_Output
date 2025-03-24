function update_ondeck
    
    global r01
    persistent ready_list
    persistent ready_list_full

    if isempty(ready_list)
        ready_list = {};
    end

    full_trial_list = r01.files.file_list;

    value_num = r01.gui.file_list_dropdown.Value;
    search_values = r01.files.selected_trials(value_num);
    ready_list_idx = find(ismember(full_trial_list(:,3), search_values) & ismember(full_trial_list(:, 2), r01.files.selected_subject));
    
    pulled_list = full_trial_list(ready_list_idx, :);

    for row = 1:height(pulled_list)
        if ~ismember(pulled_list(row, :), ready_list)
            
            ready_list = [ready_list pulled_list(row, 3)];
            ready_list_full = [ready_list_full; [pulled_list(row, :)]]

        end

    end

    r01.files.ready_to_process = ready_list_full;

    set(r01.gui.ondeck_dropdown, 'String', ready_list);

end

