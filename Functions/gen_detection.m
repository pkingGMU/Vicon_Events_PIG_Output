function [cleanEventsStruct, gen_frames] = gen_detection(devices_data_table, gait_events_tables)
    % Input:
    % devices_data_table: Table containing the force plate data (z1, z2, z3, z4 columns).
    % gait_events_tables: Table containing the timing data (frames of interest in the first column and event types).
    
    % Get relevant columns
    frames = str2double(devices_data_table.Frame);  % Convert frames to numeric
    z1 = str2double(devices_data_table.("FP4Force_Fz"));    
    z2 = str2double(devices_data_table.("FP3Force_Fz"));      
    z3 = str2double(devices_data_table.("FP2Force_Fz")); 
    z4 = str2double(devices_data_table.("FP1Force_Fz"));  % Fourth force plate
    
    % Extract frames of interest from the fourth column of gait_events_tables
    targetFrames = gait_events_tables{:, 4} * 100;  % Multiply by hundred since its in seconds
    eventType = gait_events_tables{:, 3};  

    % Filter the targetFrames for "Foot Strike" events only
    footStrikeFrames = targetFrames(strcmp(eventType, 'Foot Strike'));
    
    % Initialize a structure to store the clean events data
    cleanEventsStruct = struct();

    % Initialize a counter for event numbers
    eventCounter = 1;

    gen_frames = [];  % Initialize as an empty array 

    % Loop through each Foot Strike frame
    for i = 1:length(footStrikeFrames)
        % Find the index of the first occurrence of the frame in the devices data
        frameIdx = find(frames == footStrikeFrames(i), 1, 'first');  % Numeric comparison

        % Ensure the frame index is valid
        if ~isempty(frameIdx)
            % Display the z1, z2, z3, z4 values for the current frame
            fprintf('Frame %d: z1 = %.2f, z2 = %.2f, z3 = %.2f, z4 = %.2f\n', ...
                    footStrikeFrames(i), z1(frameIdx), z2(frameIdx), z3(frameIdx), z4(frameIdx));

            % Condition for clean event: Only one Z value is non-zero, others are zero
            if (~(z1(frameIdx) == 0) && (z2(frameIdx) == 0) && (z3(frameIdx) == 0) && (z4(frameIdx) == 0)) || ...
               ((z1(frameIdx) == 0) && ~(z2(frameIdx) == 0) && (z3(frameIdx) == 0) && (z4(frameIdx) == 0)) || ...
               ((z1(frameIdx) == 0) && (z2(frameIdx) == 0) && ~(z3(frameIdx) == 0) && (z4(frameIdx) == 0)) || ...
               ((z1(frameIdx) == 0) && (z2(frameIdx) == 0) && (z3(frameIdx) == 0) && ~(z4(frameIdx) == 0))

                % Mark this as a potential clean event
                fprintf('Potential clean Foot Strike detected at frame %d\n', footStrikeFrames(i));

                % Initialize arrays to store data before and after the clean foot strike
                startIdx = frameIdx;
                endIdx = frameIdx;

                % Expand the window upwards (before the foot strike)
                while startIdx > 1 && (z1(startIdx - 1) ~= 0 || z2(startIdx - 1) ~= 0 || z3(startIdx - 1) ~= 0 || z4(startIdx - 1) ~= 0)
                    startIdx = startIdx - 1;
                end

                % Expand the window downwards (after the foot strike)
                while endIdx < length(frames) && (z1(endIdx + 1) ~= 0 || z2(endIdx + 1) ~= 0 || z3(endIdx + 1) ~= 0 || z4(endIdx + 1) ~= 0)
                    endIdx = endIdx + 1;
                end

                % Now, check for overlap in the expanded window
                % Ensure there is no overlap with non-zero values from other force plates
                cleanFlag = true;  % Assume it's clean unless proven otherwise
                for j = startIdx:endIdx
                    % If any force plate has non-zero values where others don't, mark as not clean
                    if (~(z1(j) == 0) && (z2(j) ~= 0 || z3(j) ~= 0 || z4(j) ~= 0)) || ...
                       ((z1(j) ~= 0) && (z2(j) == 0 && z3(j) ~= 0 || z4(j) ~= 0)) || ...
                       ((z1(j) == 0) && (z2(j) ~= 0 && z3(j) == 0 && z4(j) ~= 0)) || ...
                       ((z1(j) == 0) && (z2(j) == 0 && z3(j) ~= 0 && z4(j) ~= 0))
                        cleanFlag = false;
                        break;
                    end
                end

                % If clean, store the event data
                if cleanFlag
                    fprintf('Clean Foot Strike confirmed at frame %d\n', footStrikeFrames(i));
                    
                    gen_frames(end+1,1) = footStrikeFrames(i);

                    % Capture the full clean segment (from startIdx to endIdx)
                    cleanDataSegment = devices_data_table(startIdx:endIdx, :);
                    
                    % Extract data for the relevant force plate (assuming z1, z2, z3, z4 are the columns)
                    relevantData = struct();
                    if z1(frameIdx) ~= 0
                        relevantData.z1 = cleanDataSegment.FP4Force_Fz;  % Store data from z1 column
                    end
                    if z2(frameIdx) ~= 0
                        relevantData.z2 = cleanDataSegment.FP3Force_Fz;  % Store data from z2 column
                    end
                    if z3(frameIdx) ~= 0
                        relevantData.z3 = cleanDataSegment.FP2Force_Fz;  % Store data from z3 column
                    end
                    if z4(frameIdx) ~= 0
                        relevantData.z4 = cleanDataSegment.FP1Force_Fz;  % Store data from z4 column
                    end

                    % Store this clean data segment in the structure with a unique field name (event1, event2, etc.)
                    eventFieldName = sprintf('event%d', eventCounter);
                    cleanEventsStruct.(eventFieldName) = relevantData;

                    % Increment event counter
                    eventCounter = eventCounter + 1;
                else
                    fprintf('Foot Strike at frame %d is not clean due to overlap\n', footStrikeFrames(i));
                end
            end
        end
    end

    gen_frames = gen_frames / 100;  % Convert back from frames to seconds

    % Display the clean events structure
    disp('Clean force plate events found:');
    disp(cleanEventsStruct);
end
