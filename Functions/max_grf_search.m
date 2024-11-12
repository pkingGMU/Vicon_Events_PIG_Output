function [heel_strikes, toe_offs] = max_grf_search(plate_data)
%MAX_GRF_SEARCH Summary of this function goes here
%   Detailed explanation goes here
% Testing
            GRF = abs(plate_data);
            
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
                % Check for Heel Strike (threshold = 80% of max GRF)
                if GRF(i) >= heel_strike_threshold && ~after_heel_strike
                    heel_strikes = [heel_strikes, i];  % Record the index of the heel strike
                    after_heel_strike = true;          % Set the flag to indicate we've detected a heel strike
                end
                
                % Check for Toe Off (threshold = 20% of max GRF)
                if GRF(i) <= toe_off_threshold && after_heel_strike
                    toe_offs = [toe_offs, i];  % Record the index of the toe off
                    after_heel_strike = false; % Reset flag after detecting a toe off
                end
            end
            
            % Display the results
            disp('Heel Strikes (threshold 75% of max GRF):');
            disp(heel_strikes);
            disp('Toe Offs (threshold 10% of max GRF):');
            disp(toe_offs);
end
