function [OBS_data] = Obstacle_Crossing_P(proc_table_struct, subject, fr, trial_name)
%% Program to process obstacle crossing data collected in the MOVE lab at the University of Arkansas.
% Written by Dr. Abigail Schmitt
%
% This version (3/2/2023) processes obstacle crossing data from the "dowel",
%   "rope", and "branch" conditions. 
%   Exported data files MUST contain Trajectories (heel & toe for both feet & obstacle markers).
%
%
% Output variables:
%       Toe Clearance: Lead foot and Trail foot
%       Heel Clearance: Lead foot and Trail foot
%           This is the vertical distance between the obstacle and the
%           respective marker during the crossing step directly over the obstacle
%       Approach distance: Trail foot
%           This is the horizontal distance between the obstacle and the
%           toe marker of the trailing foot preceding the crossing step.
%       Approach distance: Lead foot
%           This is the horizontal distance between the obstacle and the
%           toe marker of the leading foot at toe-off of the crossing step.
%       Landing distance: Lead foot
%           This is the horizontal distance between the obstacle and the
%           heel marker of the leading foot following the crossing step.
%       Landing distance: Trail foot
%           This is the horizontal distance between the obstacle and the
%           heel marker of the trailing foot at foot-strike of the crossing step.
%
%% **************Select Directory******************************************
% Import Data Set
% Set Directory and use prompt to choose exported files for analysis

proc_table_struct = proc_table_struct;

%%% Get Subject Name %%%
% Easy naming convention
% Regex to get subject name
subject = char(subject);
parts = strsplit(subject, 'Data');
subject_name = parts{2};
subject_name = regexprep(subject_name, '[\\/]', '');
% Display subject for debugging
subject =  'sub' + string(subject_name);
subject = regexprep(subject, ' ', '_');

% Read in the data from the selected trial
%[trial_num, trial_txt, trial_raw 
trial_num = proc_table_struct.(trial_name).trajectory_data_table;

trial_num = convertvars(trial_num, @iscell, 'string');
trial_num = convertvars(trial_num, @isstring, 'double');



% *************************************************************************
% Separate out the arrays of interest

ltoez = trial_num.LTOE_Z;
ltoey = trial_num.LTOE_Y;
rtoez = trial_num.RTOE_Z;
rtoey = trial_num.RTOE_Y;
lheez = trial_num.LHEE_Z;
lheey = trial_num.LHEE_Y;
rheez = trial_num.RHEE_Z;
rheey = trial_num.RHEE_Y;

obs1y_pos = mean(trial_num.dowel1_Y);
obs1z_pos = mean(trial_num.dowel1_Z);


% *************************************************************************

% Identify the events
% Find the general location of crossing (max z for toe and heel)
[ltoez_max,ltoez_max_frame] = max(ltoez);
[rtoez_max,rtoez_max_frame] = max(rtoez);
[lheez_max,lheez_max_frame] = max(lheez);
[rheez_max,rheez_max_frame] = max(rheez);

% back up to find the minimum z of the toe (for toe-offs)
ltoez_ud = flipud(ltoez(1:ltoez_max_frame));  %flip array upside down to work "backwards"
nn=1;
for ll = 1:(length(ltoez_ud)-1)
    if ltoez_ud(ll,1) > ltoez_ud((ll+1),1)
        ltoez_down(nn,:) = ltoez_ud(ll+1);
        ltoez_min = min(ltoez_down);
        nn = nn+1;
    else
        break
    end
end

rtoez_ud = flipud(rtoez(1:rtoez_max_frame));  %flip array upside down to work "backwards"
nn=1;
for ll = 1:(length(rtoez_ud)-1)
    if rtoez_ud(ll,1) > rtoez_ud((ll+1),1)
        rtoez_down(nn,:) = rtoez_ud(ll+1);
        rtoez_min = min(rtoez_down);
        nn = nn+1;
    else
        break
    end
end

% move forward to find the minimum z of the heel (for footstrikes)
nn=1;
for ll = lheez_max_frame:(length(lheez)-1)
    if lheez(ll,1) > lheez((ll+1),1)
        lheez_down(nn,:) = lheez(ll+1);
        lheez_min = min(lheez_down);
        nn = nn+1;
    else
        break
    end
end

nn=1;
for ll = rheez_max_frame:(length(rheez)-1)
    if rheez(ll,1) > rheez((ll+1),1)
        rheez_down(nn,:) = rheez(ll+1);
        rheez_min = min(rheez_down);
        nn = nn+1;
    else
        break
    end
end

ltoez_min_frame = find(ltoez==ltoez_min);  % Toe-off of left foot
rtoez_min_frame = find(rtoez==rtoez_min);  % Toe-off of right foot
lheez_min_frame = find(lheez==lheez_min);  % Foot-strike of left foot
rheez_min_frame = find(rheez==rheez_min);  % Foot-strike of right foot

l_eventsdata = [ltoez_min_frame,lheez_min_frame];
r_eventsdata = [rtoez_min_frame,rheez_min_frame];
if rtoez_min_frame > ltoez_min_frame
    Lead_foot = 'Left ';
else ltoez_min_frame > rtoez_min_frame;
    Lead_foot = 'Right';
end

% *************************************************************************

% Trajectories (during the crossing phase only)
ltoezcycles(:,1) = ltoez(ltoez_min_frame:lheez_min_frame,1);
rtoezcycles(:,1) = rtoez(rtoez_min_frame:rheez_min_frame,1);
ltoeycycles(:,1) = ltoey(ltoez_min_frame:lheez_min_frame,1);
rtoeycycles(:,1) = rtoey(rtoez_min_frame:rheez_min_frame,1);
lheezcycles(:,1) = lheez(ltoez_min_frame:lheez_min_frame,1);
rheezcycles(:,1) = rheez(rtoez_min_frame:rheez_min_frame,1);
lheeycycles(:,1) = lheey(ltoez_min_frame:lheez_min_frame,1);
rheeycycles(:,1) = rheey(rtoez_min_frame:rheez_min_frame,1);


% *************************************************************************
% Add in Toe & Heel Clearance when marker y = obs1 Y  (difference between Z positions)

% Pull toe clearance from each limb and organize (limited to the period
% when the toe marker is over the obstacle - w/in 25mm either way)
nn=1;
for mm = 1:length (ltoeycycles)
    if (ltoeycycles(mm,1) < (obs1y_pos+25)) && (ltoeycycles(mm,1) > (obs1y_pos-25))
        ltoe_over_obs(nn,:) = (ltoezcycles(mm,1));
        Lmin_toe_clearance = min(ltoe_over_obs)-obs1z_pos;
        nn = nn+1;
    end
end
nn=1;
for mm = 1:length (rtoeycycles)
    if (rtoeycycles(mm,1) < (obs1y_pos+25)) && (rtoeycycles(mm,1) > (obs1y_pos-25))
        rtoe_over_obs(nn,:) = (rtoezcycles(mm,1));
        Rmin_toe_clearance = min(rtoe_over_obs)-obs1z_pos;
        nn = nn+1;
    end
end
nn=1;
for mm = 1:length (lheeycycles)
    if (lheeycycles(mm,1) < (obs1y_pos+25)) && (lheeycycles(mm,1) > (obs1y_pos-25))
        lhee_over_obs(nn,:) = (lheezcycles(mm,1));
        Lmin_heel_clearance = min(lhee_over_obs)-obs1z_pos;
        nn = nn+1;
    end
end
nn=1;
for mm = 1:length (rheeycycles)
    if (rheeycycles(mm,1) < (obs1y_pos+25)) && (rheeycycles(mm,1) > (obs1y_pos-25))
        rhee_over_obs(nn,:) = (rheezcycles(mm,1));
        Rmin_heel_clearance = min(rhee_over_obs)-obs1z_pos;
        nn = nn+1;
    end
end

% Re-assign to "Lead" and "Trail"
if Lead_foot == 'Left '
    Lead_toe_clearance = Lmin_toe_clearance;
    Trail_toe_clearance = Rmin_toe_clearance;
    Lead_heel_clearance = Lmin_heel_clearance;
    Trail_heel_clearance = Rmin_heel_clearance;
else Lead_foot == 'Right';
    Lead_toe_clearance = Rmin_toe_clearance;
    Trail_toe_clearance = Lmin_toe_clearance;
    Lead_heel_clearance = Rmin_heel_clearance;
    Trail_heel_clearance = Lmin_heel_clearance;
end

% *********************************************************************
% Find horizontal clearance measures

% Find approach distance (trail limb)
% find frame of toe crossings (both lead and trail- defined later)
ltoez_frame = find(ltoez==ltoe_over_obs(1,1));  % frame of left crossing
rtoez_frame = find(rtoez==rtoe_over_obs(1,1));  % frame of right crossing
% pull Y data from toe crossing frame for OPPOSITE toe
approach_dist_frame_right = rtoey(ltoez_frame,1);
approach_dist_frame_left = ltoey(rtoez_frame,1);
% subtract Y obs position from Y toe position == approach distance
approach_dist_left = abs(abs(approach_dist_frame_left)-abs(obs1y_pos));
approach_dist_right = abs(abs(approach_dist_frame_right)-abs(obs1y_pos));

% Find approach distance (lead limb)     **** NEEDS TO BE CHECKED ****
approach2_dist_frame_right = rtoey(rtoez_min_frame,1);
if approach2_dist_frame_right > 0.001
    approach2_dist_right = abs(abs(approach2_dist_frame_right)-abs(obs1y_pos));
else
    approach2_dist_right = abs(abs(approach2_dist_frame_right)+abs(obs1y_pos));  % ADD instead of subtract if crossing origin
end

approach2_dist_frame_left = ltoey(ltoez_min_frame,1);
if approach2_dist_frame_left > 0.001
    approach2_dist_left = abs(abs(approach2_dist_frame_left)-abs(obs1y_pos));
else
    approach2_dist_left = abs(abs(approach2_dist_frame_left)+abs(obs1y_pos));    % ADD instead of subtract if crossing origin
end

% Find Landing distance (lead limb)
% pull y heel position from lead foot
landing_dist_frame_right = rheey(ltoez_frame,1);
landing_dist_frame_left = lheey(rtoez_frame,1);
% subtract Y heel from Y obs position == landing distance
landing_dist_left = abs(abs(landing_dist_frame_left)-abs(obs1y_pos));
landing_dist_right = abs(abs(landing_dist_frame_right)-abs(obs1y_pos));
% (-25mm for rope)

% Find landing distance (trail limb)     **** NEEDS TO BE CHECKED ****
landing2_dist_frame_right = rheey(rheez_min_frame,1);
if landing2_dist_frame_right > 0.001
    landing2_dist_right = abs(abs(landing2_dist_frame_right)-abs(obs1y_pos));
else
    landing2_dist_right = abs(abs(landing2_dist_frame_right)+abs(obs1y_pos)); % ADD instead of subtract if crossing origin
end

landing2_dist_frame_left = lheey(lheez_min_frame,1);
if landing2_dist_frame_left > 0.001
    landing2_dist_left = abs(abs(landing2_dist_frame_left)-abs(obs1y_pos));
else
    landing2_dist_left = abs(abs(landing2_dist_frame_left)+abs(obs1y_pos)); % ADD instead of subtract if crossing origin
end


% Rename to Lead and Trail from Left and Right
if Lead_foot == 'Left '
    approach_dist_trail = approach_dist_right;
    landing_dist_lead = landing_dist_left;
    approach_dist_lead = approach2_dist_left;
    landing_dist_trail = landing2_dist_right;
else Lead_foot == 'Right';
    approach_dist_trail = approach_dist_left;
    landing_dist_lead = landing_dist_right;
    approach_dist_lead = approach2_dist_right;
    landing_dist_trail = landing2_dist_left;
end


% *************************************************************************

trial = cellstr(trial_name);

% Combine all data
OBS_data(1, :) = [trial Lead_foot approach_dist_trail landing_dist_lead...
    approach_dist_lead landing_dist_trail...
    Lead_toe_clearance Trail_toe_clearance...
    Lead_heel_clearance Trail_heel_clearance obs1z_pos];

    


    % *************************************************************************

    clearvars -except SubID files filenum Files datapath fname pname name ...
        trial_num trial_txt trial_raw camrate OBS_data trial_type1...
        trial_type2 trial_type3 trial_type4 trial_type5 obstacle...
        obs1y_pos obs1z_pos  %Uncomment if dowel not in all trials for a subject


    % *************************************************************************







% % SubID = trial_txt(4,1);
% Subject = char(SubID);
% 
% % ***************** Export data to an Excel sheet ***********************
% % Name the excel sheet: (with file path)
% fname2 = [pname,'/','OBS_Outputs','.xlsx'];
% headers = {'Trial','Lead Foot','Obstacle_approach_dist_trail','Obstacle_landing_dist_lead',...
%     'Obstacle_approach_dist_lead','Obstacle_landing_dist_trail',...
%     'Lead_toe_clearance','Trail_toe_clearance','Lead_heel_clearance','Trail_heel_clearance',...
%     'Obstacle Height'};
% Sheeta = string(SubID);
% 
% % Convert OBS_data to a table
% OBS_table = cell2table(OBS_data, 'VariableNames', headers);
% 
% % Change directory to ou;tput
% cd ..
% cd("OBS_Outputs/")
% 
% 
% writetable(OBS_table, fname2, 'Sheet', Sheeta, 'WriteRowNames', false);
% 
% % % Sheet = strcat(Sheeta,trial_type1);
% % xlswrite(fname2,headers,Sheeta);
% % xlswrite(fname2,OBS_data,Sheeta,'A2');
% 
% % *************************************************************************
% 
% disp('Hooray. One down.')

end

