function [cleanEventsStruct, gen_frames] = gen_detection(devices_data_table, gait_events_tables, fr)
    % Input:
    % devices_data_table: Table containing the force plate data (z1, z2, z3, z4 columns).
    % gait_events_tables: Table containing the timing data (frames of interest in the first column and event types).
    
    global r01

    frame_list = strtrim(split(r01.gui.user_frame.String, ','));
    plate_prefix = r01.gui.user_prefix_plates.String;
    grid = r01.data.force_plate_labels;
    [rows, cols] = size(grid);


    % Sort gait_events_tables by cycle
    gait_events_tables = sortrows(gait_events_tables, 'Time (s)');
    
    num_plates = sum(sum(~cellfun(@isempty, grid)));

    % Get relevant columns
    frames = str2double(devices_data_table.Frame);  % Convert frames to numeric
    z = cell(1, num_plates);  % Preallocate
    for i = 1:num_plates
        colName = sprintf('%s%dForce_Fz', plate_prefix, i);  % e.g., 'FP1Force_Fz'
        z{i} = str2double(devices_data_table.(colName));
    end

    %%% Find Clean Foot Strikes %%%
    clean_foot_strike = struct();
    for i = 1:num_plates
        plate_name = sprintf('z%d', i);
        clean_foot_strike.(plate_name) = gen_search(z{i}, plate_name);
    end

    %%% Match indexes from 
    
    % Extract frames of interest from the fourth column of gait_events_tables
    target_frames = round((gait_events_tables{:, 4} * fr), 0);  % Multiply by hundred since its in seconds
    event_type = gait_events_tables{:, 3};  

    % Filter the targetFrames for "Foot Strike" events only
    foot_strike_frames = target_frames(strcmp(event_type, 'Foot Strike'));

    % Filter the targetFrames for "Foot Off" events only
    toe_off_frames = target_frames(strcmp(event_type, 'Foot Off'));
    
    % Initialize a structure to store the clean events data
    cleanEventsStruct = struct();

    gen_frames = [];  % Initialize as an empty array 

    % Define relative offsets for 4-connected neighbors (orthogonal)
    neighbor_offsets = [ -1  0;  % up
                          1  0;  % down
                          0 -1;  % left
                          0  1]; % right

    force_data = devices_data_table;

    force_data = convertvars(force_data, @iscell, 'string');
    force_data = convertvars(force_data, @isstring, 'double');
    

    event_counter = 1;
    for r = 1:rows
        for c = 1:cols
            current_label = grid{r, c};
            if (isempty(current_label) | ~contains(frame_list, current_label, 'IgnoreCase',true))
                continue;  % Skip empty cells
            end
    
            fprintf("Checking plate (%d,%d): %s\n", r, c, current_label);

            current_data = abs(force_data.(current_label));
            clean = true;

            for k = 1:size(neighbor_offsets, 1)
                nr = r + neighbor_offsets(k, 1);
                nc = c + neighbor_offsets(k, 2);
    
                if nr >= 1 && nr <= rows && nc >= 1 && nc <= cols
                    neighbor_label = grid{nr, nc};
                    if isempty(neighbor_label)
                    
                        continue
                    end

                    fprintf("  Neighbor at (%d,%d): %s\n", nr, nc, neighbor_label);

                    neighbor_data = abs(force_data.(neighbor_label));
                    
                    overlap = intersect(current_data(current_data > 100),neighbor_data(neighbor_data > 100));

                    if ~isempty(overlap)
                        fprintf("    Overlap > 100 found: %s\n", mat2str(overlap));
                        clean = false;
                        continue
                    else 
                        clean = true
                        fprintf("Clean Foot Strike Found at given Force Plate")
                    end

                    
                        
                    
                end
            end

            if clean == true
                [max_z, max_z_idx] = max(current_data);
                target_frame = force_data.Frame(max_z_idx);

                [~, idx] = min(abs(foot_strike_frames - target_frame));  
                closest_val = foot_strike_frames(idx);
                

                gen_frames(end+1,1) = closest_val;
    
                event_counter = event_counter + 1;
            end

        end
    end

    gen_frames = gen_frames / fr;  % Convert back from frames to seconds


