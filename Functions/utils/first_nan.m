function [rowEnd] = first_nan(row)
%Find the first nan in a row of labels
% 
    % Convert a single row to an array

    row = table2array(row);
    
    % cellfun is a fancy built in function to to search through an array
    % In this case we are trying to find the index of the first empty cell
    emptyCellIndex = find(cellfun(@(x) isempty(x), row), 1);

    % If emptyCellIndex is empty its just the size of the table
    if isempty(emptyCellIndex)
        emptyCellIndex = length(row) + 1;
    end
    
    % Our row end is the first empty cell minus 1
    rowEnd = emptyCellIndex - 1;

end