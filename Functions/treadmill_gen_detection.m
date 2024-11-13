function [cleanEventsStruct, gen_frames] = treadmill_gen_detection(devices_data_table, gait_events_tables, lhs, lto, rhs, rto)
    % Input:
    % devices_data_table: Table containing the force plate data (z1, z2, z3, z4 columns).
    % gait_events_tables: Table containing the timing data (frames of interest in the first column and event types).
    
    z1 = str2double(devices_data_table.("LeftPlateForce_Fz"));    
    z2 = str2double(devices_data_table.("RightPlateForce_Fz"));      

    lhs = lhs * 120;
    lto = lto * 120;
    rhs = rhs * 120;
    rto = rto * 120;

    clean_foot_strike.left = treadmill_gen_search(lhs, lto, 'left');
    clean_foot_strike.right = treadmill_gen_search(rhs, rto, 'right');
    frames = str2double(devices_data_table.Frame);  % Convert frames to numeric

    % Initialize a structure to store the clean events data
    cleanEventsStruct = struct();

    % Initialize a counter for event numbers
    eventCounter = 1;

    gen_frames = [];  % Initialize as an empty array 

    % Loop through each plate

    
    % Get the field names from the struct clean_foot_strikes (ex.
    % z1,z2,z3,z4)
    plate_field_names = fieldnames(clean_foot_strike);

    

    % Loop thorugh each plate
    for i = 1:length(plate_field_names)
        
        % Assign name to current plate
        plate_field_name = plate_field_names{i};
        
        % Extract the data from the current plate
        current = clean_foot_strike.(plate_field_name);
        

        % Prevents operating on empty cells
        if iscell(current)
            continue
        end
        

        % Get the field names for the current plate
        strike_field_names = fieldnames(current);

        
        % Loop through each strike
        for j = 1:length(strike_field_names)
            
            % Get the name of the current stirke
            current_strike_name = strike_field_names{j};
            
            % Extract the necessary data
            current_strike = current.(current_strike_name);

            % Display the contents of the current field
            if ~isempty(current)  % Check if 'data' is non-empty
                disp(['Start of ', plate_field_name, ' ', current_strike_name ':']);
                disp([clean_foot_strike.(plate_field_name).(current_strike_name).start_idx]);  % Display the data
                fprintf('\n')
            else
                disp([field_name, ' is empty.']);
            end

            % Assign values
            heel_plate_frame = clean_foot_strike.(plate_field_name).(current_strike_name).start_idx;
            toe_plate_frame = clean_foot_strike.(plate_field_name).(current_strike_name).end_idx;

            heel_plate= find(frames == heel_plate_frame, 1, "first");
            toe_plate = find(frames == toe_plate_frame, 1, "first");

            toe_plate_comparison = round(toe_plate * .9);

            %%% Determine the most fitting foot strike idx

            % Get the difference in values
            % idx_differences = abs(foot_strike_array - heel_plate);
            % 
            % % Find the min
            % [~, closest_idx] = min(idx_differences);
            % 
            % % Closest idx
            % heel_close = foot_strike_array(closest_idx);
            % toe_close = toe_off_array(closest_idx);
            % 
            % disp(['Closest heel strike index: ', num2str(heel_close)])
            % 
            % 
            % if abs(heel_close - heel_plate) >= 75 || abs (toe_close - toe_plate) >= 75
            %     disp('Heel/Toe not all the way on the plate')
            %     continue
            % end


            %%% Check for overlap
            % Check for clean event: A single force plate is active at both foot strike and toe-off, and its paired plate has zero data in that window
            cleanFlag = false;  % Assume it's not clean unless proven otherwise
            relevantData = struct();  % Structure to store relevant data for clean events
    
             % Create a switch-case structure based on which force plate is active
            switch plate_field_name
                case 'left' 
                    
                    if z1(heel_plate) ~= 0 && z1(toe_plate) ~= 0 && all(z2(heel_plate:toe_plate_comparison) < 200 & z2(heel_plate:toe_plate_comparison) > -200)
                        cleanFlag = true;
                    end
                case 'right'
                    if z2(heel_plate) ~= 0 && z2(toe_plate) ~= 0 && all(z1(heel_plate:toe_plate_comparison) < 100 & z1(heel_plate:toe_plate_comparison) > -100)
                        cleanFlag = true;
                    end

                
        
          
        
                otherwise
                    % If none of the cases match, it's not a clean event
                    fprintf('Foot Strike at frame %d is not clean due to overlapping paired force plate data\n', heel_plate_frame);
            end

            if cleanFlag == false
                     fprintf('Foot Strike at frame %d is not clean due to overlapping paired force plate data\n', heel_plate_frame);

            end

             % If clean, store the event data
            if cleanFlag
                fprintf('Clean Foot Strike confirmed at frame %d (Toe-off at frame %d)\n', heel_plate_frame, toe_plate_frame);
                gen_frames(end+1,1) = heel_plate_frame;
        
                % Store this clean data segment in the structure with a unique field name (event1, event2, etc.)
                eventFieldName = sprintf('event%d', eventCounter);
                cleanEventsStruct.(eventFieldName) = relevantData;
        
                % Increment event counter
                eventCounter = eventCounter + 1;
                
            end


        end
        

    end

    gen_frames = gen_frames / 120;  % Convert back from frames to seconds



    

    


            

end