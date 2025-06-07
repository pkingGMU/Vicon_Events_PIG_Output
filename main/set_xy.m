function set_xy(~, ~)
    
    global r01
    
    val_str = get(r01.gui.XY_box, "String");

    r01.project_xy = val_str;
    add2log(1, ['XY: ', val_str], 1,1,1,1,0,1);
    disp(r01.project_xy);
    
end
