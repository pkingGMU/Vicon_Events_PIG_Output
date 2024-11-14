function [clean_foot_strikes] = treadmill_gen_search(hs_array, to_array, event_name)
%TREADMILL_GEN_SEARCH Summary of this function goes here
%   Detailed explanation goes here
    
    idx_counter = 1;
    
    for event = 1:length(hs_array)

        % Store the completed array in the struct
        strike_counter = strcat("Strike", num2str(idx_counter));

        switch event_name
            case 'left'

                try
                    clean_foot_strikes.(strike_counter).end_idx = int32(to_array(event+1));
                catch
                    disp('Out of pairs')
                    continue
                end

                clean_foot_strikes.(strike_counter).start_idx = int32(hs_array(event));
                
                    

            case 'right'
                try
                    clean_foot_strikes.(strike_counter).end_idx = int32(to_array(event+1));
                catch
                    disp('Out of pairs')
                    continue
                end

                clean_foot_strikes.(strike_counter).start_idx = int32(hs_array(event));
                

        end

        idx_counter = idx_counter + 1; % Increment the event counter

    end

   
            
    

end

