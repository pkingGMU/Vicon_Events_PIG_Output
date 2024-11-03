function [clean_foot_strikes] = gen_search(plate, plate_str)
%TREADMILL_GEN_SEARCH Summary of this function goes here
%   Detailed explanation goes here
    
    j = 1; % Initialize j to start from the first index
    idx_counter = 1; % Initialize index counter for struct events
    array_started = false; % Flag to indicate if an array is currently being populated
    temp_array = []; % Initialize temp_array
    clean_foot_strikes = {};
    
    while j <= length(plate)
        % Check if the current value exceeds the threshold
        if plate(j, 1) >= 25 || plate(j, 1) <= -25
            if ~array_started
                array_started = true; % Start a new array
                temp_array = [j]; % Initialize temp_array with the current index
            else
                temp_array = [temp_array, j]; % Continue adding to the existing array
            end
        else
            % If we hit a value that doesn't meet the condition
            if array_started
                % Store the completed array in the struct
                strike_counter = strcat("Strike", num2str(idx_counter));
                clean_foot_strikes.(strike_counter).data = temp_array;
                clean_foot_strikes.(strike_counter).start_idx = temp_array(1);
                clean_foot_strikes.(strike_counter).end_idx = temp_array(end);
                idx_counter = idx_counter + 1; % Increment the event counter
                
                % Reset for the next potential array
                array_started = false;
                temp_array = []; % Clear temp_array
            end
        end
        
        j = j + 1; % Move to the next index
    end
    
    % Check if there was an open array at the end of the loop
    if array_started
        strike_counter = strcat("Strike", num2str(idx_counter));
        clean_foot_strikes.(strike_counter).data = temp_array;
        clean_foot_strikes.(strike_counter).start_idx = temp_array(1);
        clean_foot_strikes.(strike_counter).end_idx = temp_array(end);
    end
    
    
    fprintf('Number of strikes for %s: %d\n', plate_str, idx_counter - 1);

end

