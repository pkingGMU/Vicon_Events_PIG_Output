function [clean_foot_strikes] = treadmill_gen_search(plate, plate_str)
%TREADMILL_GEN_SEARCH Summary of this function goes here
%   Detailed explanation goes here

    idx_counter = 1; % Initialize index counter for struct events

    GRF = abs(plate);
            
    max_GRF = max(GRF);
    
    % Set thresholds for heel strikes and toe offs
    heel_strike_threshold = 0.75 * max_GRF;  % 80% of max GRF
    toe_off_threshold = 0.10 * max_GRF;     % 20% of max GRF
    
    % Initialize lists for heel strikes and toe offs
    heel_strikes = [];
    toe_offs = [];
    
    % Flag to track the state (after a heel strike)
    after_heel_strike = false;
    
    % Iterate over the GRF data to detect heel strikes and toe offs
    for i = 2:length(GRF)
        
        finished = false;

        % Check for Heel Strike (threshold = 80% of max GRF)
        if GRF(i) >= heel_strike_threshold && ~after_heel_strike
            heel_strikes = [heel_strikes, i];  % Record the index of the heel strike
            after_heel_strike = true; % Set the flag to indicate we've detected a heel strike
        end
        
        % Check for Toe Off (threshold = 20% of max GRF)
        if GRF(i) <= toe_off_threshold && after_heel_strike
            toe_offs = [toe_offs, i];  % Record the index of the toe off
            after_heel_strike = false; % Reset flag after detecting a toe off
            finished = true;
        end

        if finished == false
            continue
        end 

        % Store the completed array in the struct
        strike_counter = strcat("Strike", num2str(idx_counter));
        % clean_foot_strikes.(strike_counter).data = temp_array;
        clean_foot_strikes.(strike_counter).start_idx = heel_strikes(i);
        clean_foot_strikes.(strike_counter).end_idx = toe_offs(i);
        idx_counter = idx_counter + 1; % Increment the event counter
    end
            
    % % Set thresholds for heel strikes and toe offs
    % heel_strike_threshold = 0.85 * max_GRF;  % 80% of max GRF
    % toe_off_threshold = 0.10 * max_GRF;     % 20% of max GRF
    % 
    % j = 2; % Initialize j to start from the first index
    % idx_counter = 1; % Initialize index counter for struct events
    % array_started = false; % Flag to indicate if an array is currently being populated
    % temp_array = []; % Initialize temp_array
    % clean_foot_strikes = {};
    % 
    % while j <= length(plate)
    %     % Check if the current value exceeds the threshold
    %     if plate(j, 1) >= heel_strike_threshold 
    %         if ~array_started
    %             array_started = true; % Start a new array
    %             temp_array = [j]; % Initialize temp_array with the current index
    %         else
    %             temp_array = [temp_array, j]; % Continue adding to the existing array
    %         end
    %     else
    %         % If we hit a value that doesn't meet the condition
    %         if array_started
    %             % Store the completed array in the struct
    %             strike_counter = strcat("Strike", num2str(idx_counter));
    %             clean_foot_strikes.(strike_counter).data = temp_array;
    %             clean_foot_strikes.(strike_counter).start_idx = temp_array(1);
    %             clean_foot_strikes.(strike_counter).end_idx = temp_array(end);
    %             idx_counter = idx_counter + 1; % Increment the event counter
    % 
    %             % Reset for the next potential array
    %             array_started = false;
    %             temp_array = []; % Clear temp_array
    %         end
    %     end
    % 
    %     j = j + 1; % Move to the next index
    % end
    % 
    % % Check if there was an open array at the end of the loop
    % if array_started
    %     strike_counter = strcat("Strike", num2str(idx_counter));
    %     clean_foot_strikes.(strike_counter).data = temp_array;
    %     clean_foot_strikes.(strike_counter).start_idx = temp_array(1);
    %     clean_foot_strikes.(strike_counter).end_idx = temp_array(end);
    % end
    % 
    % 
    % fprintf('Number of strikes for %s: %d\n', plate_str, idx_counter - 1);

end

