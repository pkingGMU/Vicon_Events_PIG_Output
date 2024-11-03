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


    %%% Find Clean Foot Strikes %%%
    clean_foot_strike.z1 = gen_search(z1, 'z1');
    clean_foot_strike.z2 = gen_search(z2, 'z2');
    clean_foot_strike.z3 = gen_search(z3, 'z3');
    clean_foot_strike.z4 = gen_search(z4, 'z4');

    

    %%% Match indexes from 
    
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

    used_plates = [false,false,false,false];

    % Initialize arrays
    foot_strike_array = [];
    toe_off_array = [];

    fprintf('Reading Foot Strike/Toe Off Pairs\n');
    % Loop through each Foot Strike frame
    for i = 1:length(foot_strike_frames)

        
        
        % Find the index of the first occurrence of the frame in the devices data
        temp_foot_strike_idx = find(frames == foot_strike_frames(i), 1, 'first');  % Numeric comparison

        try

            % Find the index of the first occurrence of the frame in the devices data
            temp_toe_off_idx = find(frames == toe_off_frames(i+1), 1, 'first');  % Numeric comparison
        catch
            fprintf('Out of Pairs')
            fprintf('\n')
            break
        end

        foot_strike_array = [foot_strike_array, temp_foot_strike_idx];
        toe_off_array = [toe_off_array, temp_toe_off_idx];


    end





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
        for j = 1:length(current)
            
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
            heel_plate = clean_foot_strike.(plate_field_name).(current_strike_name).start_idx;
            toe_plate = clean_foot_strike.(plate_field_name).(current_strike_name).end_idx;

            %%% Determine the most fitting foot strike idx

            % Get the difference in values
            idx_differences = abs(foot_strike_array - heel_plate);

            % Find the min
            [~, closest_idx] = min(idx_differences);

            % Closest idx
            heel_close = foot_strike_array(closest_idx);
            toe_close = toe_off_array(closest_idx);

            disp(['Closest heel strike index: ', heel_close])


            if abs(heel_close - heel_plate) >= 75
                disp('Heel/Toe not all the way on the plate')
                continue
            end


            %%% Check for overlap
            % Check for clean event: A single force plate is active at both foot strike and toe-off, and its paired plate has zero data in that window
            cleanFlag = false;  % Assume it's not clean unless proven otherwise
            relevantData = struct();  % Structure to store relevant data for clean events
    
             % Create a switch-case structure based on which force plate is active
            switch plate_field_name
                case 'z1' 
                    
                    if z1(heel_plate) ~= 0 && z1(toe_plate) ~= 0 && all(z3(heel_plate:toe_plate) < 100 & z3(heel_plate:toe_plate) > -100)
                        cleanFlag = true;
                    end
                case 'z2'
                    if z2(heel_plate) ~= 0 && z2(toe_plate) ~= 0 && all(z3(heel_plate:toe_plate) < 100 & z3(heel_plate:toe_plate) > -100)
                        cleanFlag = true;
                    end

                case 'z3' 

                    if z3(heel_plate) ~= 0 && z3(toe_plate) ~= 0 && all(z2(heel_plate:toe_plate) < 100 & z2(heel_plate:toe_plate) > -100) && all(z4(heel_plate:toe_plate) < 100 & z4(heel_plate:toe_plate) > -100)
                        cleanFlag = true;
                    end

                case 'z4'

                    if z4(heel_plate) ~= 0 && z4(toe_plate) ~= 0 && all(z3(heel_plate:toe_plate) < 100 & z3(heel_plate:toe_plate) > -100)
                        cleanFlag = true;
                    end
        
          
        
                otherwise
                    % If none of the cases match, it's not a clean event
                    fprintf('Foot Strike at frame %d is not clean due to overlapping paired force plate data\n', foot_strike_frames(i));
            end

            if cleanFlag == false
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
        

    end

    gen_frames = gen_frames / 100;  % Convert back from frames to seconds



    

    


            

end