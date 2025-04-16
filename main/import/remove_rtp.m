function remove_rtp
    
    global r01

    
    
    
    
    % Catch anytime someone hits the remove button but theres nothing in
    % the list

    try
        %ready_list_full = r01.files.ready_to_process;
        idx_to_remove = r01.gui.ondeck_dropdown.Value;

        %ready_list(:, idx_to_remove) = [];
    
        r01.files.ready_to_process(idx_to_remove, :) = [];

        if isempty(r01.files.ready_to_process)
            set(r01.gui.ondeck_dropdown, 'String', []);

            
        else
            
            if r01.gui.ondeck_dropdown.Value ~= 1
                r01.gui.ondeck_dropdown.Value = idx_to_remove - 1;
            end
            set(r01.gui.ondeck_dropdown, 'String', strcat(r01.files.ready_to_process(:, 2), ' |', r01.files.ready_to_process(:, 3)));
            
        end
    catch
        disp("No files added")

    end
    

end

