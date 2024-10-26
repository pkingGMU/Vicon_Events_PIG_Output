function [found, found_idx, plate, plate_name, used_plates] = gen_frame_search(idx, found, direction, z1, z2, z3, z4, used_plates)
    % gen_frame_search Function to search for non-zero force plate data.
    % Input:
    %   - idx: current index to start searching
    %   - found: boolean indicating if a force plate was found
    %   - direction: 'forward' or 'backward' indicating search direction
    %   - z1, z2, z3, z4: force plate data arrays
    %   - used_plates: a logical array indicating which plates have been used (1 = used, 0 = not used)
    
    % Initialize variables
    count = 0;
    plate = [];
    plate_name = "";
    found_idx = 0;
    nonzero_idx = idx;

    while count < 50 && ~found
        if strcmp(direction, 'backward') && ...
                z1(nonzero_idx) == 0 && z2(nonzero_idx) == 0 && ...
                z3(nonzero_idx) == 0 && z4(nonzero_idx) == 0
            nonzero_idx = nonzero_idx - 1;
            count = count + 1;
        elseif strcmp(direction, 'forward') && ...
                z1(nonzero_idx) == 0 && z2(nonzero_idx) == 0 && ...
                z3(nonzero_idx) == 0 && z4(nonzero_idx) == 0
            nonzero_idx = nonzero_idx + 1;
            count = count + 1;
        else 
            found_idx = nonzero_idx;
            found = true;

            % Check which variable(s) triggered the else condition
            if z1(found_idx) ~= 0 && ~used_plates(1)
                disp(['z1 triggered the else condition at index: ', num2str(found_idx)]);
                plate = z1;
                plate_name = 'z1';
                used_plates(1) = true;  % Mark z1 as used
            elseif z2(found_idx) ~= 0 && ~used_plates(2)
                disp(['z2 triggered the else condition at index: ', num2str(found_idx)]);
                plate = z2;
                plate_name = 'z2';
                used_plates(2) = true;  % Mark z2 as used
            elseif z3(found_idx) ~= 0 && ~used_plates(3)
                disp(['z3 triggered the else condition at index: ', num2str(found_idx)]);
                plate = z3;
                plate_name = 'z3';
                used_plates(3) = true;  % Mark z3 as used
            elseif z4(found_idx) ~= 0 && ~used_plates(4)
                disp(['z4 triggered the else condition at index: ', num2str(found_idx)]);
                plate = z4;
                plate_name = 'z4';
                used_plates(4) = true;  % Mark z4 as used
            else
                found = false;
                break
                
            
            end
        end

        if ~found
            found_idx = idx;
        end
    end
end