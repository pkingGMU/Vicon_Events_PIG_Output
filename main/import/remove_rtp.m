function remove_rtp
    
    global r01

    ready_list_full = r01.files.ready_to_process;

    idx_to_remove = r01.gui.ondeck_dropdown.Value;

    ready_list_full(idx_to_remove, :) = [];

    r01.files.ready_to_process = ready_list_full;

    set(r01.gui.ondeck_dropdown, 'String', ready_list_full(:,3));

end

