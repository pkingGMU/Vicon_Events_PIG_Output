function [save_gesture] = save_gesture_events(full_data_table)
% Find in the loaded table if there are gesture events to save them later
    
        device_i = 1;
        save_row = 1;
        gesture_i = true;
        
        save_gesture = table();

        while gesture_i

              if strcmp(full_data_table.Var1{device_i}, 'Devices') 
                  gesture_i = false;
                  break
              end

              if ~strcmp(full_data_table.Var3(device_i), 'Gesture')
                  device_i = device_i + 1;
                  continue
              end

              save_gesture(save_row, :) = full_data_table(device_i, {'Var1', 'Var2', 'Var3', 'Var4', 'Var5'});
              device_i = device_i + 1;
              save_row = save_row + 1;

        end

end

