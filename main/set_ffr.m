function set_ffr(~, ~)
    
    global r01
    
    val_str = get(r01.gui.FFr_box, "String");
    val_num = str2double(val_str);
    
    if isnan(val_num) || val_num <= 0
        msgbox("Please enter a valid positive number for frame rate.", "Invalid Input", "warn");
    else
        r01.project_ffr = val_num;
        disp(['Frame rate set to ', num2str(val_num), ' fps.']);
        add2log(1, ['Frame Rate: ', num2str(val_num), ' fps.'], 1,1,1,1,0,1);
        disp(r01.project_ffr);
    end

end

