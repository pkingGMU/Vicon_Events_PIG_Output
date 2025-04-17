function [files] = arrange_subjects(folder)
% Function that takes in a folder (Main Folder) and returns an arrary of all subject folders.  
    

    files = dir(folder);
    files = files([files.isdir] & ~ismember({files.name}, {'.', '..'}));
   
end

