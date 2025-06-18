function [cleanEventsStruct, gen_frames] = gen_detection(devices_data_table, gait_events_tables, fr)
    % Inputs:
    % devices_data_table: Table with force plate data (Force_Fz, CoP_Cx, CoP_Cy, Frame, etc)
    % gait_events_tables: Table with gait events including frame/time and event type
    % fr: sampling frequency (frames per second)
    
    global r01

    plate_prefix = r01.gui.user_prefix_plates.String;  
    grid = r01.data.force_plate_labels;
    [rows, cols] = size(grid);

     % Sort gait events by time 
    gait_events_tables = sortrows(gait_events_tables, 'Time (s)');
    event_frames = round(gait_events_tables{:, 4} * fr);  
    event_types = gait_events_tables{:, 3};
    event_feet = gait_events_tables{:,"Context"};

    % Separate heel strikes and toe offs
    heel_strikes_idx = find(strcmp(event_types, 'Foot Strike'));
    toe_offs_idx = find(strcmp(event_types, 'Foot Off'));

    % Convert force_data Frame to numeric for indexing
    force_data = devices_data_table;
    force_data = convertvars(force_data, @iscell, 'string');
    force_data = convertvars(force_data, @isstring, 'double');

    % Time thing
    time_vector = (0:height(force_data)-1)' / fr;

    % Identify all plate labels in a list for easy access
    plate_labels = {};
    num_plates = 0;
    for r = 1:rows
        for c = 1:cols
            if ~isempty(grid{r,c})
                num_plates = num_plates + 1;
                plate_labels{num_plates} = grid{r,c};
            end
        end
    end

    % Preload force Fz for all plates (as arrays for speed)
    force_Fz = zeros(height(force_data), num_plates);
    for i = 1:num_plates
        temp = abs(force_data.(plate_labels{i}));
        force_Fz(:, i) = temp - temp(1,1);
    end

    % Rough BW threshold using 95th percentile of combined force
    bw_thresh = prctile(abs(force_data.("CombinedForce_Fz")), 95);

    % Neighbor offsets 
    neighbor_offsets = [-1 0; 1 0; 0 -1; 0 1];

    % Initialize output variables
    gen_frames = [];
    cleanEventsStruct = struct( ...
        'frame', [], ...
        'time', [], ...
        'foot', [], ...
        'plate_label', [], ...
        'max_force', [], ...
        'mean_COP_velocity_mm_per_s', [], ...
        'clean', [], ...
        'start_idx', [], ...
        'end_idx', [], ...
        'displacement_x', [], ...
        'displacement_y', [], ...
        'propulsion', [], ...
        'breaking', [] ...
    );


    for i = 1:length(heel_strikes_idx) - 1
        hs_frame = event_frames(heel_strikes_idx(i));
        foot = event_feet(heel_strikes_idx(i));
        % Find the next toe off frame AFTER this heel strike
        to_frame = event_frames(toe_offs_idx(i+1));
        if isempty(to_frame)
            % No toe off after this heel strike — maybe last gait cycle, skip
            continue;
        end
        

        % Find the row index corresponding to hs_frame in force_data
        [~, hs_idx] = min(abs(force_data.Frame - hs_frame));
        [~, to_idx] = min(abs(force_data.Frame - to_frame));
        
        win_idx = hs_idx:to_idx;

        if to_frame > height(force_data) || hs_frame < 1
            % Out of range safety check
            continue;
        end

        % Extract force in window for all plates
        force_window = force_Fz(win_idx, :);

        % Binary contact detection above threshold
        contact_bool = force_window > (bw_thresh * 0.2);  % 20% BW threshold
        
        % Sum up how many time points each plate is "active"
        plate_contact_counts = sum(contact_bool, 1);  % [1 x num_plates]
        
        % Find plate index with the most "contact" samples
        [~, dom_plate_idx] = max(plate_contact_counts);
        % Find dominant plate with max force in window
        % [max_forces, ~] = max(force_window, [], 1);
        % [max_force, dom_plate_idx] = max(max_forces);

        % Skip if max force < half BW threshold
        % if max_force < bw_thresh
        %     continue;
        % end

        % Get dominant plate label & location in grid
        dom_plate_label = plate_labels{dom_plate_idx};
        [r_plate, c_plate] = find(strcmp(grid, dom_plate_label));

        
        current_data = abs(force_data.(dom_plate_label) - force_data.(dom_plate_label)(1));        [max_z, max_z_idx] = max(current_data);
        plate_force_window = current_data(hs_idx : to_idx);
        plate_force_window = plate_force_window(plate_force_window > 0);
        
        if isempty(plate_force_window) || plate_force_window(1) > 100 || plate_force_window(end) > 100
            continue
        end

        % Check neighbor overlap in the window
        clean = true;
        for k = 1:size(neighbor_offsets, 1)
            nr = r_plate + neighbor_offsets(k, 1);
            nc = c_plate + neighbor_offsets(k, 2);

            if nr >= 1 && nr <= rows && nc >= 1 && nc <= cols
                neighbor_label = grid{nr, nc};
                if isempty(neighbor_label)
                    continue;
                end

                neighbor_data = abs(force_data.(neighbor_label) - force_data.(neighbor_label)(1));
                neighbor_force_window = neighbor_data(max_z_idx-10 : max_z_idx+10);
        
                ratio = max(neighbor_force_window) / max(plate_force_window);
        
                if ratio > 0.75  
                    clean = false;
                    break
                end
            end
        end

        if ~clean
            continue;
        end

        % COP velocity check in window
        cop_x_label = strcat(erase(dom_plate_label, "Force_Fz"), "CoP_Cx");
        cop_y_label = strcat(erase(dom_plate_label, "Force_Fz"), "CoP_Cy");

        COPx_plate = force_data.(cop_x_label);
        COPy_plate = force_data.(cop_y_label);

        Fz_plate = force_data.(dom_plate_label);

        % Zero baseline offset
        COPx_plate = COPx_plate - COPx_plate(1);
        COPy_plate = COPy_plate - COPy_plate(1);

        Fz_plate = abs(Fz_plate - Fz_plate(1));

        COPx_win = COPx_plate(win_idx);
        COPy_win = COPy_plate(win_idx);
        time_win = time_vector(win_idx);

        Fz_plate = Fz_plate(win_idx);

        % Find indices where both COPx and COPy are non-zero
        valid_idx = ~((COPx_win == 0) & (COPy_win == 0));
        
        % Filter COP data
        COPx_valid = COPx_win(valid_idx);
        COPy_valid = COPy_win(valid_idx);
        time_valid = time_win(valid_idx);

        Fz_plate = Fz_plate(valid_idx);
        
        % Check for force shape
        % Fz_smooth = sgolayfilt(Fz_plate, 3, 11);
        % peaks = findpeaks(Fz_smooth);
        % if length(peaks) > 2 
        %     continue
        % end

        % Propulsion
        propulsion = max(Fz_plate);

        % Breaking
        breaking = min(Fz_plate);

        % Interpolate
        num_points = 100;
        time_norm = linspace(time_valid(1), time_valid(end), num_points);
        
        % Interpolate COPx and COPy to normalized time
        COPx_norm = interp1(time_valid, COPx_valid, time_norm, 'linear');
        COPy_norm = interp1(time_valid, COPy_valid, time_norm, 'linear');
        
        

        path_length = sum( sqrt( diff(COPx_norm).^2 + diff(COPy_norm).^2 ) );
        if path_length < 250
            continue
        end

        % Get displacement ranges
        range_x = max(COPx_norm) - min(COPx_norm);
        range_y = max(COPy_norm) - min(COPy_norm);
        
        % Avoid divide-by-zero
        if range_x == 0, range_x = eps; end
        if range_y == 0, range_y = eps; end
        
        % Normalize spatially to [0, 1]
        COPx_norm_spatial = (COPx_norm - min(COPx_norm)) / range_x;
        COPy_norm_spatial = (COPy_norm - min(COPy_norm)) / range_y;
                
        % Displacement calculation
        displacement_x = COPx_norm_spatial(end) - COPx_norm_spatial(1);
        displacement_y = COPy_norm_spatial(end) - COPy_norm_spatial(1);

        % Calculate velocity only on valid rows
        dx = diff(COPx_norm(10:end-10));
        dy = diff(COPy_norm(10:end-10));
        dt = diff(time_norm(10:end-10));
        dt(dt == 0) = eps;
        
        COP_velocity = sqrt(dx.^2 + dy.^2) ./ dt;
        mean_COP_velocity = mean(COP_velocity);

        COP_vel_thresh = 100; % mm/s threshold

        if mean(COP_velocity) > COP_vel_thresh
            continue; % skip noisy strike
        end

        % Passed all checks, store event info
        gen_frames(end+1,1) = hs_frame;
        cleanEventsStruct(end+1).frame = hs_frame;
        cleanEventsStruct(end).time = hs_frame / fr;
        cleanEventsStruct(end).plate_label = dom_plate_label;
        %cleanEventsStruct(end).max_force = max_force;
        cleanEventsStruct(end).mean_COP_velocity_mm_per_s = mean(COP_velocity);
        cleanEventsStruct(end).clean = true;
        cleanEventsStruct(end).start_idx = win_idx(1);
        cleanEventsStruct(end).end_idx = win_idx(end);
        cleanEventsStruct(end).displacement_x = abs(displacement_x);
        cleanEventsStruct(end).displacement_y = abs(displacement_y);
        cleanEventsStruct(end).propulsion = propulsion;
        cleanEventsStruct(end).breaking = breaking;
        cleanEventsStruct(end).foot = foot;
    end

    % Remove first empty element from cleanEventsStruct (due to initialization)
    if ~isempty(cleanEventsStruct) && isempty(cleanEventsStruct(1).frame)
        cleanEventsStruct(1) = [];
    end

    % Convert gen_frames to seconds
    gen_frames = gen_frames / fr;

end