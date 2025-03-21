function update_trial_list
    global r01

    value_num = r01.gui.subject_list_dropdown.Value;
    subject = r01.files.subjects(value_num);
    
    r01.files.selected_subject = subject;

    full_trial_list = r01.files.file_list;

    trial_list_idx = find(ismember(full_trial_list(:,2), subject));

    trial_list = full_trial_list(trial_list_idx, 3);

    r01.files.selected_trials = trial_list;

    r01.gui.file_list_dropdown.Value = 1;


    set(r01.gui.file_list_dropdown, 'String', trial_list)

end

