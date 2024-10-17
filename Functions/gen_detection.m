function [cleanEventsStruct, gen_frames] = gen_detection(devices_data_table, gait_events_tables)
    % Input:
    % devices_data_table: Table containing the force plate data (z1, z2, z3, z4 columns).
    % gait_events_tables: Table containing the timing data (frames of interest in the first column and event types).
    
    % Sort gait_events_tables by cycle
    gait_events_tables = sortrows(gait_events_tables, 'Time (s)');

    % Get relevant columns
    frames = str2double(devices_data_table.Frame);  % Convert frames to numeric
    z1 = str2double(devices_data_table.("FP1Force_Fz"));    
    z2 = str2double(devices_data_table.("FP2Force_Fz"));      
    z3 = str2double(devices_data_table.("FP3Force_Fz")); 
    z4 = str2double(devices_data_table.("FP4Force_Fz"));  % Fourth force plate
    
    % Extract frames of interest from the fourth column of gait_events_tables
    targetFrames = round((gait_events_tables{:, 4} * 100), 0);  % Multiply by hundred since its in seconds
    eventType = gait_events_tables{:, 3};  

    % Filter the targetFrames for "Foot Strike" events only
    foot_strike_frames = targetFrames(strcmp(eventType, 'Foot Strike'));

    % Filter the targetFrames for "Foot Off" events only
    toe_off_frames = targetFrames(strcmp(eventType, 'Foot Off'));
    
    % Initialize a structure to store the clean events data
    cleanEventsStruct = struct();

    % Initialize a counter for event numbers
    eventCounter = 1;

    gen_frames = [];  % Initialize as an empty array 

    % Loop through each Foot Strike frame
    for i = 1:length(foot_strike_frames)
        
        % Find the index of the first occurrence of the frame in the devices data
        foot_strike_idx = find(frames == foot_strike_frames(i), 1, 'first');  % Numeric comparison

        try

            % Find the index of the first occurrence of the frame in the devices data
            toe_off_idx = find(frames == toe_off_frames(i+1), 1, 'first');  % Numeric comparison
        catch
            fprintf('Out of Cycles')
            break
        end
        
        %%% Searching for force plate indexes that are not zero within a
        %%% 100 frame tolerance
        % Initialize variables for searching
        found = false;
        foot_nonzero_idx = foot_strike_idx;
        count = 0;
        % Check all values +- 1/10 of a second
        while count < 100 && found == false

            if z1(foot_nonzero_idx) == 0 && z2(foot_nonzero_idx) == 0 && z3(foot_nonzero_idx) == 0 && z4(foot_nonzero_idx) == 0
                foot_nonzero_idx = foot_nonzero_idx + 1;
                count = count + 1;
            else 
                foot_strike_idx = foot_nonzero_idx;
                found = true;

                % Check which variable(s) triggered the else condition
                if z1(foot_nonzero_idx) ~= 0
                    disp(['z1 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z2(foot_nonzero_idx) ~= 0
                    disp(['z2 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z3(foot_nonzero_idx) ~= 0
                    disp(['z3 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z4(foot_nonzero_idx) ~= 0
                    disp(['z4 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
            end
            
        end

        foot_nonzero_idx = foot_strike_idx;
        count = 0;
        while count < 100 && found == false

            if z1(foot_nonzero_idx) == 0 && z2(foot_nonzero_idx) == 0 && z3(foot_nonzero_idx) == 0 && z4(foot_nonzero_idx) == 0
                foot_nonzero_idx = foot_nonzero_idx - 1;
                count = count + 1;
            else 
                foot_strike_idx = foot_nonzero_idx;
                found = true;

                % Check which variable(s) triggered the else condition
                if z1(foot_nonzero_idx) ~= 0
                    disp(['z1 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z2(foot_nonzero_idx) ~= 0
                    disp(['z2 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z3(foot_nonzero_idx) ~= 0
                    disp(['z3 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
                if z4(foot_nonzero_idx) ~= 0
                    disp(['z4 triggered the else condition at index: ', num2str(foot_nonzero_idx)]);
                end
            end
            
        end

        if found == false
            fprintf('No Force Plate data found \n')
            continue
        end

        %%% Searching for toe off frames
        % Initialize variables for searching
        found = false;
        toe_nonzero_idx = toe_off_idx;
        count = 0;
        % Check all values +- 1/10 of a second
        while count < 100 && found == false

            if z1(toe_nonzero_idx) == 0 && z2(toe_nonzero_idx) == 0 && z3(toe_nonzero_idx) == 0 && z4(toe_nonzero_idx) == 0
                toe_nonzero_idx = toe_nonzero_idx + 1;
                count = count + 1;
            else 
                toe_off_idx = toe_nonzero_idx;
                found = true;

                % Check which variable(s) triggered the else condition
                if z1(toe_nonzero_idx) ~= 0
                    disp(['z1 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z2(toe_nonzero_idx) ~= 0
                    disp(['z2 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z3(toe_nonzero_idx) ~= 0
                    disp(['z3 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z4(toe_nonzero_idx) ~= 0
                    disp(['z4 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                
                toe_off_idx = toe_nonzero_idx;
                found = true;
            end
            
        end

        toe_nonzero_idx = toe_off_idx;
        count = 0;
        while count < 100 && found == false

            if z1(toe_nonzero_idx) == 0 && z2(toe_nonzero_idx) == 0 && z3(toe_nonzero_idx) == 0 && z4(toe_nonzero_idx) == 0
                toe_nonzero_idx = toe_nonzero_idx - 1;
                count = count + 1;
            else 
                toe_off_idx = toe_nonzero_idx;
                found = true;

                % Check which variable(s) triggered the else condition
                if z1(toe_nonzero_idx) ~= 0
                    disp(['z1 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z2(toe_nonzero_idx) ~= 0
                    disp(['z2 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z3(toe_nonzero_idx) ~= 0
                    disp(['z3 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
                if z4(toe_nonzero_idx) ~= 0
                    disp(['z4 triggered the else condition at index: ', num2str(toe_nonzero_idx)]);
                end
            end
            
        end


        if found == false
            fprintf('No Force Plate data found \n')
            continue
        end
        
        
        

        % Ensure the frame index is valid
        if isempty(foot_strike_idx) || isempty(toe_off_idx)
            fprintf('No frames found')
            continue
            
        end

        % Display the z1, z2, z3, z4 values for the current frame
        fprintf('Frame %d: z1 = %.2f, z2 = %.2f, z3 = %.2f, z4 = %.2f\n', ...
                foot_strike_frames(i), z1(foot_strike_idx), z2(foot_strike_idx), z3(foot_strike_idx), z4(foot_strike_idx));


        % Initialize arrays to store data before and after the clean foot strike
        force_start_idx = foot_strike_idx + 1;
        force_end_idx = toe_off_idx - 1;

        % Expand the window upwards (before the foot strike)
        while force_start_idx > 1 && (z1(force_start_idx - 1) ~= 0 || z2(force_start_idx - 1) ~= 0 || z3(force_start_idx - 1) ~= 0 || z4(force_start_idx - 1) ~= 0)
            force_start_idx = force_start_idx - 1;
        end

        % Expand the window downwards (after the foot strike)
        while force_end_idx < length(frames) && any((z1(force_end_idx + 1) ~= 0 || z2(force_end_idx + 1) ~= 0 || z3(force_end_idx + 1) ~= 0 || z4(force_end_idx + 1) ~= 0))
            force_end_idx = force_end_idx + 1;
        end
        
        % Check for toe off lasting longer than 
        if toe_off_idx > force_end_idx
            fprintf('Foot Strike at frame %d is not clean because toe-off exceeds available force plate data\n', foot_strike_frames(i));
            continue
            % Skip to the next iteration if the toe-off goes beyond the data length
        end

        % Check for clean event: A single force plate is active at both foot strike and toe-off, and its paired plate has zero data in that window
        cleanFlag = false;  % Assume it's not clean unless proven otherwise
        relevantData = struct();  % Structure to store relevant data for clean events

         % Create a switch-case structure based on which force plate is active
        switch true
            case (z1(force_start_idx) ~= 0 && z1(force_end_idx) ~= 0 && all(z3(force_start_idx:force_end_idx) == 0))  % FP1 has data, FP2 has none
                cleanFlag = true;
                relevantData.z1 = devices_data_table(force_start_idx:force_end_idx, "FP1Force_Fz");
    
            case (z2(force_start_idx) ~= 0 && z2(force_end_idx) ~= 0 && all(z4(force_start_idx:force_end_idx) == 0))  % FP2 has data, FP1 has none
                cleanFlag = true;
                relevantData.z2 = devices_data_table(force_start_idx:force_end_idx, "FP2Force_Fz");
    
            case (z3(force_start_idx) ~= 0 && z3(force_end_idx) ~= 0 && all(z1(force_start_idx:force_end_idx) == 0))  % FP3 has data, FP4 has none
                cleanFlag = true;
                relevantData.z3 = devices_data_table(force_start_idx:force_end_idx, "FP3Force_Fz");
    
            case (z4(force_start_idx) ~= 0 && z4(force_end_idx) ~= 0 && all(z2(force_start_idx:force_end_idx) == 0))  % FP4 has data, FP3 has none
                cleanFlag = true;
                relevantData.z4 = devices_data_table(force_start_idx:force_end_idx, "FP4Force_Fz");
    
            otherwise
                % If none of the cases match, it's not a clean event
                fprintf('Foot Strike at frame %d is not clean due to overlapping paired force plate data\n', foot_strike_frames(i));
        end
        
        % If clean, store the event data
        if cleanFlag
            fprintf('Clean Foot Strike confirmed at frame %d (Toe-off at frame %d)\n', foot_strike_frames(i), toe_off_frames(i));
            gen_frames(end+1,1) = foot_strike_frames(i);
    
            % Store this clean data segment in the structure with a unique field name (event1, event2, etc.)
            eventFieldName = sprintf('event%d', eventCounter);
            cleanEventsStruct.(eventFieldName) = relevantData;
    
            % Increment event counter
            eventCounter = eventCounter + 1;
            
         end
     end
   


gen_frames = gen_frames / 100;  % Convert back from frames to seconds

% Display the clean events structure
disp('Clean force plate events found:');
disp(cleanEventsStruct);
            

end