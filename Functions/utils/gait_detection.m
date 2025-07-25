function [flhs,flto,frhs,frto, frame_start, FR, failed] = gait_detection(trajectory, ~, ~, choice, fr)
    
    global r01

    failed = false;
    %% load motion data
    %frame = model_output(:,{Frame});
    frame_values = str2double(trajectory.("Frame"));
    frame_start = frame_values(1);

    FR = fr;
    
    [b, a] = butter(4, 1/(FR/2)); % 4th order Butterworth at 6 Hz
    

    xy = r01.project_xy;

    

    if strcmp(xy, 'Y') == 1
        LPSIS=str2double(trajectory.("LPSI_Y"));
            
        RPSIS=str2double(trajectory.("RPSI_Y"));
       
        OPSIS=0.5*(LPSIS+RPSIS); %PSIS y center(y sacrum)
       
        LHE=str2double(trajectory.("LHEE_Y"));
        z_LHE=str2double(trajectory.("LHEE_Z"));
        
        LTO=str2double(trajectory.("LTOE_Y"));
        z_LTO=str2double(trajectory.("LTOE_Z"));
        
     
        RHE=str2double(trajectory.("RHEE_Y"));
        z_RHE=str2double(trajectory.("RHEE_Z"));
        
        RTO=str2double(trajectory.("RTOE_Y"));
        z_RTO=str2double(trajectory.("RTOE_Z"));

    elseif strcmp(xy, 'X') == 1
        LPSIS=str2double(trajectory.("LPSI_X"));
            
        RPSIS=str2double(trajectory.("RPSI_X"));
       
        OPSIS=0.5*(LPSIS+RPSIS); %PSIS y center(y sacrum)
       
        LHE=str2double(trajectory.("LHEE_X"));
        z_LHE=str2double(trajectory.("LHEE_Z"));
        
        LTO=str2double(trajectory.("LTOE_X"));
        z_LTO=str2double(trajectory.("LTOE_Z"));
        
     
        RHE=str2double(trajectory.("RHEE_X"));
        z_RHE=str2double(trajectory.("RHEE_Z"));
        
        RTO=str2double(trajectory.("RTOE_X"));
        z_RTO=str2double(trajectory.("RTOE_Z"));
    
    end

        


    
    
    %% Markers

    if strcmp(choice, 'Treadmill')

         % left heel-sacrum distance
    Lheel=filtfilt(b, a, LHE-OPSIS);
    % left toe-sacrum distance
    Ltoe=filtfilt(b, a, -1*(LTO-OPSIS)); % inverted
    
    % right heel-sacrum distance
    Rheel=filtfilt(b, a, RHE-OPSIS);
    % right toe-sacrum distance
    Rtoe=filtfilt(b, a, -1*(RTO-OPSIS)); % inverted

    
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

    
    if RHE(1,1)<0 && LHE(1,1)<0
    
    disp('Top')

    % left heel-sacrum distance
    Lheel=LHE-OPSIS;
    % left toe-sacrum distance
    Ltoe=-1*(LTO-OPSIS); % inverted
    
    % right heel-sacrum distance
    Rheel=RHE-OPSIS;
    % right toe-sacrum distance
    Rtoe=-1*(RTO-OPSIS); % inverted

    
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
    Lheel=-(LHE-OPSIS);
    % left toe-sacrum distance
    Ltoe=(LTO-OPSIS); % inverted
    
    % right heel-sacrum distance
    Rheel=-(RHE-OPSIS);
    % right toe-sacrum distance
    Rtoe=(RTO-OPSIS); % inverted
    
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
    % 
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


    end

    end

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

    
    
    % Initialize new event arrays
    new_flhs = [];
    new_frto = [];
    new_frhs = [];
    new_flto = [];
    
    % Decide on pattern direction
    pattern = '';
    i = 1;
    while i <= size(events, 1) - 3
        if strcmp(pattern, '')
            % Detect initial valid pattern
            if strcmp(events{i,2}, 'flhs') && ...
               strcmp(events{i+1,2}, 'frto') && ...
               strcmp(events{i+2,2}, 'frhs') && ...
               strcmp(events{i+3,2}, 'flto')
                pattern = 'left-first';
            elseif strcmp(events{i,2}, 'frhs') && ...
                   strcmp(events{i+1,2}, 'flto') && ...
                   strcmp(events{i+2,2}, 'flhs') && ...
                   strcmp(events{i+3,2}, 'frto')
                pattern = 'right-first';
            else
                i = i + 1;
                continue;
            end
        end
    
        % Follow the detected pattern
        if strcmp(pattern, 'left-first') && ...
           strcmp(events{i,2}, 'flhs') && ...
           strcmp(events{i+1,2}, 'frto') && ...
           strcmp(events{i+2,2}, 'frhs') && ...
           strcmp(events{i+3,2}, 'flto')
    
            new_flhs(end+1) = events{i,1};
            new_frto(end+1) = events{i+1,1};
            new_frhs(end+1) = events{i+2,1};
            new_flto(end+1) = events{i+3,1};
            i = i + 4;
    
        elseif strcmp(pattern, 'right-first') && ...
               strcmp(events{i,2}, 'frhs') && ...
               strcmp(events{i+1,2}, 'flto') && ...
               strcmp(events{i+2,2}, 'flhs') && ...
               strcmp(events{i+3,2}, 'frto')
    
            new_frhs(end+1) = events{i,1};
            new_flto(end+1) = events{i+1,1};
            new_flhs(end+1) = events{i+2,1};
            new_frto(end+1) = events{i+3,1};
            i = i + 4;
    
        else
            % If the pattern doesn't match, skip to next event
            i = i + 1;
        end
    end




    % % Iterate through the sorted events and enforce the sequence
    % i = 1;
    % while i <= size(events, 1) - 3
    %     % Check for foot strike first (either left or right)
    %     if strcmp(events{i, 2}, 'flhs') || strcmp(events{i, 2}, 'frhs')
    %         % Check for opposite toe-off, opposite heel strike, and same toe-off
    %         if strcmp(events{i+1, 2}, 'frto') && strcmp(events{i+2, 2}, 'frhs') && strcmp(events{i+3, 2}, 'flto') || ...
    %            strcmp(events{i+1, 2}, 'flto') && strcmp(events{i+2, 2}, 'flhs') && strcmp(events{i+3, 2}, 'frto') 
    % 
    %             % Add the correct sequence to the new arrays
    %             if strcmp(events{i, 2}, 'flhs')
    %                 new_flhs(end+1) = events{i, 1};  % Left heel strike
    %                 new_frto(end+1) = events{i+1, 1};  % Right toe off
    %                 new_frhs(end+1) = events{i+2, 1};  % Right heel strike
    %                 new_flto(end+1) = events{i+3, 1};  % Left toe off
    %             else
    %                 new_frhs(end+1) = events{i, 1};  % Right heel strike
    %                 new_flto(end+1) = events{i+1, 1};  % Left toe off
    %                 new_flhs(end+1) = events{i+2, 1};  % Left heel strike
    %                 new_frto(end+1) = events{i+3, 1};  % Right toe off
    %             end
    % 
    %             % Move to the next set of events
    %             i = i + 4;
    %         else
    %             % Sequence is incorrect, move to the next event
    %             i = i + 1;
    %         end
    %     else
    %         % If the first event is not a heel strike, move to the next event
    %         i = i + 1;
    %     end
    % end

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
    % t_flhs = str2double(devices_table{flhs, 1}') /FR;
    % t_flto = str2double(devices_table{flto, 1}') /FR;
    % t_frhs = str2double(devices_table{frhs, 1}') /FR;
    % t_frto = str2double(devices_table{frto, 1}') /FR;


    flhs = (flhs + frame_start-1)/FR;
    flto = (flto + frame_start-1)/FR;
    frhs = (frhs + frame_start-1)/FR;
    frto = (frto + frame_start-1)/FR;

    


end

