function [flhs,flto,frhs,frto, frame_start, FR, failed] = gait_detection(trajectory, model_output, devices_table, choice, fr)

    failed = false;
    %% load motion data
    %frame = model_output(:,{Frame});
    frame_values = str2double(trajectory.("Frame"));
    frame_start = frame_values(1);

    switch choice
            case 'Treadmill'
                FR = 120; % frame rate, Hz
            case 'Overground'
                FR = 100; % frame rate, Hz

    end

    FR = fr;
    
    switch choice
        case 'Overground'
            %% Markers
            % pelvis markers, meters
            %LASIS=(trajectory(:, {'02:LASI_X', '02:LASI_Y', '02:LASI_Z'}));
            %RASIS=(trajectory(:, {'02:RASI_X', '02:RASI_Y', '02:RASI_Z'}));
            %LPSIS=(trajectory(:, {'02:LPSI_X', '02:LPSI_Y', '02:LPSI_Z'}));
            y_LPSIS=str2double(trajectory.("LPSI_Y"));
            %RPSIS=(trajectory(:, {'02:RPSI_X', '02:RPSI_Y', '02:RPSI_Z'}));
            y_RPSIS=str2double(trajectory.("RPSI_Y"));
            %OPSIS=0.5*(RPSIS+LPSIS); %PSIS center(sacrum)
            y_OPSIS=0.5*(y_LPSIS+y_RPSIS); %PSIS y center(y sacrum)
            %CPSIS=mean([RPSIS;LPSIS],1);
            
            % foot markers
            %LHE=0.001*data(:,96:98);
            %x_LHE=0.001*data(:,96);
            y_LHE=str2double(trajectory.("LHEE_Y"));
            z_LHE=str2double(trajectory.("LHEE_Z"));
            
            %LTO=0.001*data(:,99:101);
            %x_LTO=0.001*data(:,99);
            y_LTO=str2double(trajectory.("LTOE_Y"));
            z_LTO=str2double(trajectory.("LTOE_Z"));
            
            %RHE=0.001*data(:,114:116);
            %x_RHE=0.001*data(:,114);
            y_RHE=str2double(trajectory.("RHEE_Y"));
            z_RHE=str2double(trajectory.("RHEE_Z"));
            
            %RTO=0.001*data(:,117:119);
            %x_RTO=0.001*data(:,117);
            y_RTO=str2double(trajectory.("RTOE_Y"));
            z_RTO=str2double(trajectory.("RTOE_Z"));
            
            z_lfocent= 0.5*(z_LHE+z_LTO); % z left foot centre
            z_rfocent= 0.5*(z_RHE+z_RTO); % z right foot centre
            
            
            %% Coordinate-Based Treadmill Algorithm_ EVENTS
            if y_RHE(1,1)<0 && y_LHE(1,1)<0
            
            disp('Top')
        
            % left heel-sacrum distance
            Lheel=y_LHE-y_OPSIS;
            % left toe-sacrum distance
            Ltoe=-1*(y_LTO-y_OPSIS); % inverted
            
            % right heel-sacrum distance
            Rheel=y_RHE-y_OPSIS;
            % right toe-sacrum distance
            Rtoe=-1*(y_RTO-y_OPSIS); % inverted
            
            %findpeaks/valleys left leg Events
            [Lpks,flhs]=findpeaks(Lheel); %[peaks, Frames] left heel strike
            % figure; findpeaks(Lheel);
            % xlabel('frame');
            % ylabel('left heel strike');
            % Lhstimes=(flhs-1)/FR; % left heel strike times
            
            [Lvlys,flto]=findpeaks(Ltoe); %[valleys, Frames] left toe off
            % figure; findpeaks(Ltoe);
            % xlabel('frame');
            % ylabel('left toe off');
            % Ltofftimes=(flto-1)/FR; % left toe off times
            
            %findpeaks- right leg Events
            [Rpks,frhs]=findpeaks(Rheel); %[peaks, Frames] right heel strike
            % figure; findpeaks(Rheel);
            % xlabel('frame');
            % ylabel('right heel strike');
            % Rhstimes=(frhs-1)/FR; % right heel strike times
            
            [Rvlys,frto]=findpeaks(Rtoe); %[valleys, Frames] right toe off
            % figure; findpeaks(Rtoe);
            % xlabel('frame');
            % ylabel('right toe off');
            % Rtofftimes=(frto-1)/FR; % right toe off times
            
            else
            
            disp('Bottom')
        
            % left heel-sacrum distance
            Lheel=-(y_LHE-y_OPSIS);
            % left toe-sacrum distance
            Ltoe=(y_LTO-y_OPSIS); % inverted
            
            % right heel-sacrum distance
            Rheel=-(y_RHE-y_OPSIS);
            % right toe-sacrum distance
            Rtoe=(y_RTO-y_OPSIS); % inverted
            
            %findpeaks/valleys left leg Events
            [Lpks,flhs]=findpeaks(Lheel); %[peaks, Frames] left heel strike
            % figure; findpeaks(Lheel);
            % xlabel('frame');
            % ylabel('left heel strike');
            % Lhstimes=(flhs-1)/FR; % left heel strike times
            
            [Lvlys,flto]=findpeaks(Ltoe); %[valleys, Frames] left toe off
            % figure; findpeaks(Ltoe);
            % xlabel('frame');
            % ylabel('left toe off');
            % Ltofftimes=(flto-1)/FR; % left toe off times
            
            % findpeaks- right leg Events
            [Rpks,frhs]=findpeaks(Rheel); %[peaks, Frames] right heel strike
            % figure; findpeaks(Rheel);
            % xlabel('frame');
            % ylabel('right heel strike');
            % Rhstimes=(frhs-1)/FR; % right heel strike times
            
            [Rvlys,frto]=findpeaks(Rtoe); %[valleys, Frames] right toe off
            % figure; findpeaks(Rtoe);
            % xlabel('frame');
            % ylabel('right toe off');
            % Rtofftimes=(frto-1)/FR; % right toe off times
            % 
            end
        case 'Treadmill'

            l_force_plate = str2double(devices_table.("LeftPlateForce_Fz")); 
            r_force_plate = str2double(devices_table.("RightPlateForce_Fz")); 

            % [~, rhs] = findpeaks(r_force_plate);
            % [~, lhs] = findpeaks(l_force_plate);

            [flhs, flto] = max_grf_search(l_force_plate);
            [frhs, frto] = max_grf_search(r_force_plate);

    end
            

    %%% After detecting events, ensure first event is a heel strike
    % Left leg: if the first event in the left leg is not a heel strike, rearrange
    % if flhs(1) > flto(1)  % First event is a toe-off
    %     disp('Rearranging left leg events to start with heel strike');
    %     flto = flto(2:end);  % Skip first toe-off
    %     toe_off_cut = 1;
    % end
    % 
    % % Right leg: if the first event in the right leg is not a heel strike, rearrange
    % if toe_off_cut ~= 1
    %     if frhs(1) > frto(1)  % First event is a toe-off
    %         disp('Rearranging right leg events to start with heel strike');
    %         frto = frto(2:end);  % Skip first toe-off
    %     end
    % end

    % Combine all events into a single array with identifiers for event type and side
    
    % Combine all events into a single array with identifiers for event type and side
    events = [
        num2cell(flhs(:)), repmat({"flhs"}, numel(flhs), 1);
        num2cell(flto(:)), repmat({"flto"}, numel(flto), 1);
        num2cell(frhs(:)), repmat({"frhs"}, numel(frhs), 1);
        num2cell(frto(:)), repmat({"frto"}, numel(frto), 1)
    ];
    
    % Extract the first column (event times) and convert to numeric array
    event_times = cell2mat(events(:,1));  % Convert the first column to numeric array

    % Sort the event times and get the sorted indices
    [~, sorted_indices] = sort(event_times);

    % Reorder the entire events cell array based on the sorted indices
    events = events(sorted_indices, :);

    
    
    % Initialize arrays to store the corrected sequence
    new_flhs = [];
    new_flto = [];
    new_frhs = [];
    new_frto = [];



    % New logic for patterns

    % i = 1;
    % while i <=size(events, 1) - 3
    % 
    %     % Gait pattern 1 hs, opposite to, opposite hs, to
    %     if strcmp(events{i, 2}, 'flhs') && strcmp(events{i+1, 2}, 'frto') && strcmp(events{i+2, 2}, 'frhs') && strcmp(events{i+3, 2}, 'flto')
    %         new_flhs(end+1) = events{i, 1};
    %         new_frto(end+1) = events{i+1, 1};
    %         new_frhs(end+1) = events{i+2, 1};
    %         new_flto(end+1) = events{i+3, 1};
    %         i = i + 4;  % Move to the next set of events
    %     % Gait pattern 2 to, opposite hs, opposite to, hs
    %     elseif strcmp(events{i, 2}, 'frhs') && strcmp(events{i+1, 2}, 'frto') && strcmp(events{i+2, 2}, 'flhs') && strcmp(events{i+3, 2}, 'flto')
    %         new_frhs(end+1) = events{i, 1};
    %         new_frto(end+1) = events{i+1, 1};
    %         new_flhs(end+1) = events{i+2, 1};
    %         new_flto(end+1) = events{i+3, 1};
    %         i = i + 4;  % Move to the next set of events
    %         else
    %         i = i + 1;  % Skip this event if it doesn't fit the pattern
    %     end
    % end

    % Iterate through the sorted events and enforce the sequence
    i = 1;
    while i <= size(events, 1) - 3
        % Check for foot strike first (either left or right)
        if strcmp(events{i, 2}, 'flhs') || strcmp(events{i, 2}, 'frhs')
            % Check for opposite toe-off, opposite heel strike, and same toe-off
            if strcmp(events{i+1, 2}, 'frto') && strcmp(events{i+2, 2}, 'frhs') && strcmp(events{i+3, 2}, 'flto') || ...
               strcmp(events{i+1, 2}, 'flto') && strcmp(events{i+2, 2}, 'flhs') && strcmp(events{i+3, 2}, 'frto') 
               
                % Add the correct sequence to the new arrays
                if strcmp(events{i, 2}, 'flhs')
                    new_flhs(end+1) = events{i, 1};  % Left heel strike
                    new_frto(end+1) = events{i+1, 1};  % Right toe off
                    new_frhs(end+1) = events{i+2, 1};  % Right heel strike
                    new_flto(end+1) = events{i+3, 1};  % Left toe off
                else
                    new_frhs(end+1) = events{i, 1};  % Right heel strike
                    new_flto(end+1) = events{i+1, 1};  % Left toe off
                    new_flhs(end+1) = events{i+2, 1};  % Left heel strike
                    new_frto(end+1) = events{i+3, 1};  % Right toe off
                end
                
                % Move to the next set of events
                i = i + 4;
            else
                % Sequence is incorrect, move to the next event
                i = i + 1;
            end
        else
            % If the first event is not a heel strike, move to the next event
            i = i + 1;
        end
    end

    % Update the original arrays with the validated sequence
    flhs = new_flhs;
    flto = new_flto;
    frhs = new_frhs;
    frto = new_frto;

    if isempty(flhs)
        disp('Gait_Detection order is not correct')
        failed = true;
    end

    
    % Ensure equal number of elements in each array
    min_len = min([length(flhs), length(flto), length(frhs), length(frto)]);
    flhs = flhs(1:min_len);
    flto = flto(1:min_len);
    frhs = frhs(1:min_len);
    frto = frto(1:min_len);
    
    % Calculate to time
    flhs = str2double(devices_table{flhs, 1}') /FR;
    flto = str2double(devices_table{flto, 1}') /FR;
    frhs = str2double(devices_table{frhs, 1}') /FR;
    frto = str2double(devices_table{frto, 1}') /FR;


    % flhs = (flhs + frame_start-1)/FR;
    % flto = (flto + frame_start-1)/FR;
    % frhs = (frhs + frame_start-1)/FR;
    % frto = (frto + frame_start-1)/FR;

    


end

