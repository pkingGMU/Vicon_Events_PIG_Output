function [found, found_idx, plate] = gen_frame_search(idx, found, direction, z1, z2, z3, z4)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        
        % Initialize variables
        count = 0;
        plate = '';
        found_idx = 0;
        nonzero_idx = idx;

        while count < 50 && found == false
            
            if strcmp(direction, 'backward') && z1(nonzero_idx) == 0 && z2(nonzero_idx) == 0 && z3(nonzero_idx) == 0 && z4(nonzero_idx) == 0
                nonzero_idx = nonzero_idx - 1;
                count = count + 1;
            elseif strcmp(direction, 'forward') && z1(nonzero_idx) == 0 && z2(nonzero_idx) == 0 && z3(nonzero_idx) == 0 && z4(nonzero_idx) == 0
                nonzero_idx = nonzero_idx + 1;
                count = count + 1;

            else 
                found_idx = nonzero_idx;
                found = true;

                % Check which variable(s) triggered the else condition
                if z1(found_idx) ~= 0
                    disp(['z1 triggered the else condition at index: ', num2str(found_idx)]);
                    plate = 'z1';
                end
                if z2(found_idx) ~= 0
                    disp(['z2 triggered the else condition at index: ', num2str(found_idx)]);
                    plate = 'z2';

                end
                if z3(found_idx) ~= 0
                    disp(['z3 triggered the else condition at index: ', num2str(found_idx)]);
                    plate = 'z3';
                end
                if z4(found_idx) ~= 0
                    disp(['z4 triggered the else condition at index: ', num2str(found_idx)]);
                    plate = 'z4';
                end
            end

            if found == false
                found_idx = idx;
            end

            
        end

        
end

