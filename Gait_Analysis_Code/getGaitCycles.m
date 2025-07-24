function [gaitcycles] = getGaitCycles(data,all_events,lhs,rhs)
%getGaitCycles Reads in frames for marker coordinate data and gait events
% spits out a cell array with start and end of each gait cycle based on
% which foot is the first heelstrike in the data

gaitcycles = {};

found = false;
i = 1;
while found == false

     if all_events(i,2) == 1
               startleg = 1; % left
               numcycles = length(lhs)-1;
               found = true;
           elseif all_events(i,2) == 3
               startleg = 2; % right
               numcycles = length(rhs)-1;
               found = true;
     end
    
     all_events = all_events(i+4:end, :);
     i = i + 4;

end

if startleg == 1 % left

    startframe = find(data(:,1) == lhs(1),1,'first');

    for ii = 1:numcycles
        endframe = find(data(:,1) == lhs(ii+1),1,'first')-1;
        for jj = startframe:endframe
            gaitcycles{ii}(jj-startframe+1,1) = data(jj,1); %
        end
        startframe = jj+1;
    end
else
    startframe = find(data(:,1) == rhs(1),1,'first');

    for ii = 1:numcycles
        endframe = find(data(:,1) == rhs(ii+1),1,'first')-1;
        for jj = startframe:endframe
            gaitcycles{ii}(jj-startframe+1,1) = data(jj,1); %
        end
        startframe = jj+1;
    end

end