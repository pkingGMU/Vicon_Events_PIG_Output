function [OBS_data] = obstacle_analysis(proc_table_struct, file, fr, trial_name, subject)
%% Program to process obstacle crossing data collected in the MOVE lab at the University of Arkansas.
% Written by Dr. Abigail Schmitt
% Edited by Patrick King GMU
%
% This version (3/5/24) processes obstacle crossing data from the "dowel",
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
%% **************Select Directory***********************************
% Read in the data from the selected trial
%[traj_num, trial_txt, trial_raw 
traj_num = proc_table_struct.(trial_name).trajectory_data_table;

traj_num = convertvars(traj_num, @iscell, 'string');
traj_num = convertvars(traj_num, @isstring, 'double');

model_num = proc_table_struct.(trial_name).model_data_table;

model_num = convertvars(model_num, @iscell, 'string');
model_num = convertvars(model_num, @isstring, 'double');



% *************************************************************************
% Separate out the arrays of interest

ltoez = traj_num.LTOE_Z;
ltoex = traj_num.LTOE_X;
ltoey = traj_num.LTOE_Y;
rtoez = traj_num.RTOE_Z;
rtoey = traj_num.RTOE_Y;
rtoex = traj_num.RTOE_X;
lheez = traj_num.LHEE_Z;
lheey = traj_num.LHEE_Y;
lheex = traj_num.LHEE_X;
rheez = traj_num.RHEE_Z;
rheey = traj_num.RHEE_Y;
rheex = traj_num.RHEE_X;

% MOS Inputs
COM_AP = (model_num.CentreOfMass_X)/1000;
COM_ML = (model_num.CentreOfMass_Y)/1000;
COM_UP = (model_num.CentreOfMass_Z)/1000;

rank_ap = (traj_num.RANK_X)/1000;
rank_ml = (traj_num.RANK_Y)/1000;
rank_up = (traj_num.RANK_Z)/1000;

lank_ap = (traj_num.LANK_X)/1000;
lank_ml = (traj_num.LANK_Y)/1000;
lank_up = (traj_num.LANK_Z)/1000;

rtoe_ap = (traj_num.RTOE_X)/1000;

ltoe_ap = (traj_num.LTOE_X)/1000;


try
    obs1y_pos = mean(traj_num.dowel1_Y);
    obs1z_pos = mean(traj_num.dowel1_Z);
catch

    try
        obs1y_pos = mean(traj_num.Obstacle1_Y);
        obs1z_pos = mean(traj_num.Obstacle1_Z);
    catch

        try
            obs1y_pos = mean(traj_num.OBS1_Y);
            obs1z_pos = mean(traj_num.OBS1_Z);
        catch
        end

    end


end





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

% back up to find the minimum z of the toe (for toe-offs)
lheez_ud_before = flipud(lheez(1:lheez_max_frame));  %flip array upside down to work "backwards"
nn=1;
for ll = 1:(length(lheez_ud_before)-1)
    if lheez_ud_before(ll,1) > lheez_ud_before((ll+1),1)
        lheez_ud_before_down(nn,:) = lheez_ud_before(ll+1);
        lheez_min_before = min(lheez_ud_before_down);
        nn = nn+1;
    else
        break
    end
end

% back up to find the minimum z of the toe (for toe-offs)
rheez_ud_before = flipud(rheez(1:rheez_max_frame));  %flip array upside down to work "backwards"
nn=1;
for ll = 1:(length(rheez_ud_before)-1)
    if rheez_ud_before(ll,1) > rheez_ud_before((ll+1),1)
        rheez_ud_before_down(nn,:) = rheez_ud_before(ll+1);
        rheez_min_before = min(rheez_ud_before_down);
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

lheez_min_before_frame = find(lheez==lheez_min_before);
rheez_min_before_frame = find(rheez==rheez_min_before);


l_eventsdata = [ltoez_min_frame,lheez_min_frame];
r_eventsdata = [rtoez_min_frame,rheez_min_frame];
if rtoez_min_frame > ltoez_min_frame
    Lead_foot = 'Left';
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
if strcmp(Lead_foot, 'Left') == 1
    Lead_toe_clearance = Lmin_toe_clearance;
    Trail_toe_clearance = Rmin_toe_clearance;
    Lead_heel_clearance = Lmin_heel_clearance;
    Trail_heel_clearance = Rmin_heel_clearance;
elseif strcmp(Lead_foot, 'Right') == 1
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
if strcmp(Lead_foot, 'Left') == 1
    approach_dist_trail = approach_dist_right;
    landing_dist_lead = landing_dist_left;
    approach_dist_lead = approach2_dist_left;
    landing_dist_trail = landing2_dist_right;
elseif strcmp(Lead_foot, 'Right') == 1
    approach_dist_trail = approach_dist_left;
    landing_dist_lead = landing_dist_right;
    approach_dist_lead = approach2_dist_right;
    landing_dist_trail = landing2_dist_left;
end


% *************************************************************************

trial = cellstr(trial_name);
subject = cellstr(subject);

disp(strcmp(Lead_foot, 'Left'))

if strcmp(Lead_foot, 'Left') == 1
    obs_start_frame = ltoez_min_frame;
    obs_end_frame = rheez_min_frame;
    
    hs_foot = 1;
    hs = ltoez_min_frame;
    to = lheez_min_frame;
    opp_hs = rtoez_min_frame;
    opp_to = rheez_min_frame;

    double_lead_before = lheez_min_before_frame;
    double_trail_before = rheez_min_before_frame;
    double_lead_after = lheez_min_frame;
    double_trail_after = rheez_min_frame;

elseif strcmp(Lead_foot, 'Right') == 1
    obs_start_frame = rtoez_min_frame;
    obs_end_frame = lheez_min_frame;
    
    hs_foot = 2;
    hs = rtoez_min_frame;
    to = rheez_min_frame;
    opp_hs = ltoez_min_frame;
    opp_to = lheez_min_frame;

    double_lead_before = rheez_min_before_frame;
    double_trail_before = lheez_min_before_frame;
    double_lead_after = rheez_min_frame;
    double_trail_after = lheez_min_frame;

end

lead_step_length = landing_dist_lead + approach_dist_trail;
trail_step_length = approach_dist_trail + landing_dist_lead;

disp(lheex(lheez_min_frame,1));
disp(ltoex(ltoez_min_frame, 1));
disp(rheex(rheez_min_frame,1));

%% Step Width
if strcmp(Lead_foot, 'Left') == 1
    lead_step_width = abs(lheex(lheez_min_frame,1) - rtoex(ltoez_min_frame, 1));
    trail_step_width = abs(rheex(rheez_min_frame,1) - ltoex(rtoez_min_frame, 1));
elseif strcmp(Lead_foot, 'Right') == 1
    trail_step_width = abs(lheex(lheez_min_frame,1) - rtoex(ltoez_min_frame, 1));
    lead_step_width = abs(rheex(rheez_min_frame,1) - ltoex(rtoez_min_frame, 1));
end


%% MOS

% create CoM vector and  Ankle vector
% at heelstrike
CoM_Vec_at_hs = [COM_AP(hs);COM_ML(hs);COM_UP(hs)];
RAnk_Vec_at_hs = [rank_ap(hs);rank_ml(hs);rank_up(hs)];
LAnk_Vec_at_hs = [lank_ap(hs);lank_ml(hs);lank_up(hs)];
% at opposite heelstrike
CoM_Vec_at_ohs = [COM_AP(opp_hs);COM_ML(opp_hs);COM_UP(opp_hs)];
RAnk_Vec_at_ohs = [rank_ap(opp_hs);rank_ml(opp_hs);rank_up(opp_hs)];
LAnk_Vec_at_ohs = [lank_ap(opp_hs);lank_ml(opp_hs);lank_up(opp_hs)];
% at toe off
CoM_Vec_at_to = [COM_AP(to);COM_ML(to);COM_UP(to)];
RAnk_Vec_at_to = [rank_ap(to);rank_ml(to);rank_up(to)];
LAnk_Vec_at_to = [lank_ap(to);lank_ml(to);lank_up(to)];
% at opposite toe off
CoM_Vec_at_oto = [COM_AP(opp_to);COM_ML(opp_to);COM_UP(opp_to)];
RAnk_Vec_at_oto = [rank_ap(opp_to);rank_ml(opp_to);rank_up(opp_to)];
LAnk_Vec_at_oto = [lank_ap(opp_to);lank_ml(opp_to);lank_up(opp_to)];

%% Double support

% Before Obstacle Lead
CoM_Vec_double_lead_before = [COM_AP(double_lead_before);COM_ML(double_lead_before);COM_UP(double_lead_before)];
RAnk_Vec_double_lead_before = [rank_ap(double_lead_before);rank_ml(double_lead_before);rank_up(double_lead_before)];
LAnk_Vec_double_lead_before = [lank_ap(double_lead_before);lank_ml(double_lead_before);lank_up(double_lead_before)];
% Before Obstacle Trail
CoM_Vec_double_trail_before = [COM_AP(double_trail_before);COM_ML(double_trail_before);COM_UP(double_trail_before)];
RAnk_Vec_double_trail_before = [rank_ap(double_trail_before);rank_ml(double_trail_before);rank_up(double_trail_before)];
LAnk_Vec_double_trail_before = [lank_ap(double_trail_before);lank_ml(double_trail_before);lank_up(double_trail_before)];
% After Obstacle Lead
CoM_Vec_double_lead_after = [COM_AP(double_lead_after);COM_ML(double_lead_after);COM_UP(double_lead_after)];
RAnk_Vec_double_lead_after = [rank_ap(double_lead_after);rank_ml(double_lead_after);rank_up(double_lead_after)];
LAnk_Vec_double_lead_after = [lank_ap(double_lead_after);lank_ml(double_lead_after);lank_up(double_lead_after)];
% After Obstacle Trail
CoM_Vec_double_trail_after = [COM_AP(double_trail_after);COM_ML(double_trail_after);COM_UP(double_trail_after)];
RAnk_Vec_double_trail_after = [rank_ap(double_trail_after);rank_ml(double_trail_after);rank_up(double_trail_after)];
LAnk_Vec_double_trail_after = [lank_ap(double_trail_after);lank_ml(double_trail_after);lank_up(double_trail_after)];

% calculate center of mass velocity
dt = 1/fr;

for i = 1:length(COM_AP)-1
    CoM_vel_AP(i+1,1) = (COM_AP(i+1)-COM_AP(i))/dt;
    CoM_vel_ML(i+1,1) = (COM_ML(i+1)-COM_ML(i))/dt;
end

if hs_foot == 1 % left heel strike/gc
    LBoS_AP_hs = ltoe_ap(hs);
    LBoS_ML_hs = lank_ml(hs);
    RBoS_AP_hs = rtoe_ap(opp_hs);
    RBoS_ML_hs = rank_ml(opp_hs);
    LBoS_AP_to = ltoe_ap(to);
    LBoS_ML_to = lank_ml(to);
    RBoS_AP_to = rtoe_ap(opp_to);
    RBoS_ML_to = rank_ml(opp_to);

    LBoS_AP_double_lead_before = ltoe_ap(double_lead_before);
    LBoS_ML_double_lead_before = lank_ml(double_lead_before);
    RBoS_AP_double_trail_before = rtoe_ap(double_trail_before);
    RBoS_ML_double_trail_before = rank_ml(double_trail_before);
    LBoS_AP_double_lead_after = ltoe_ap(double_lead_after);
    LBoS_ML_double_lead_after = lank_ml(double_lead_after);
    RBoS_AP_double_trail_after = rtoe_ap(double_trail_after);
    RBoS_ML_double_trail_after = rank_ml(double_trail_after);

    

    %acl_MoS(CoM_Vec,ank_vec, CoM, CoM_vel, BoS)

    % L_MoS_AP_hs = calc_MoS(CoM_Vec_at_hs,LAnk_Vec_at_hs,COM_AP(hs),CoM_vel_AP(hs),LBoS_AP_hs);
    % R_MoS_AP_hs = calc_MoS(CoM_Vec_at_ohs,RAnk_Vec_at_ohs,COM_AP(opp_hs),CoM_vel_AP(opp_hs),RBoS_AP_hs);
    % L_MoS_ML_hs = calc_MoS(CoM_Vec_at_hs,LAnk_Vec_at_hs,COM_ML(hs),CoM_vel_ML(hs),LBoS_ML_hs);
    % R_MoS_ML_hs = calc_MoS(CoM_Vec_at_ohs,RAnk_Vec_at_ohs,COM_ML(opp_hs),CoM_vel_ML(opp_hs),RBoS_ML_hs);
    % L_MoS_AP_to = calc_MoS(CoM_Vec_at_to,LAnk_Vec_at_to,COM_AP(to),CoM_vel_AP(to),LBoS_AP_to);
    % R_MoS_AP_to = calc_MoS(CoM_Vec_at_oto,RAnk_Vec_at_oto,COM_AP(opp_to),CoM_vel_AP(opp_to),RBoS_AP_to);
    % L_MoS_ML_to = calc_MoS(CoM_Vec_at_to,LAnk_Vec_at_to,COM_ML(to),CoM_vel_ML(to),LBoS_ML_to);
    % R_MoS_ML_to = calc_MoS(CoM_Vec_at_oto,RAnk_Vec_at_oto,COM_ML(opp_to),CoM_vel_ML(opp_to),RBoS_ML_to);

    L_MoS_AP_double_before = calc_MoS(CoM_Vec_double_lead_before,LAnk_Vec_double_lead_before,COM_AP(double_lead_before),CoM_vel_AP(double_lead_before),LBoS_AP_double_lead_before);
    R_MoS_AP_double_before = calc_MoS(CoM_Vec_double_trail_before,RAnk_Vec_double_trail_before,COM_AP(double_trail_before),CoM_vel_AP(double_trail_before),RBoS_AP_double_trail_before);
    L_MoS_ML_double_before = calc_MoS(CoM_Vec_double_lead_before,LAnk_Vec_double_lead_before,COM_ML(double_lead_before),CoM_vel_ML(double_lead_before),LBoS_ML_double_lead_before);
    R_MoS_ML_double_before = calc_MoS(CoM_Vec_double_trail_before,RAnk_Vec_double_trail_before,COM_ML(double_trail_before),CoM_vel_ML(double_trail_before),RBoS_ML_double_trail_before);
    L_MoS_AP_double_after = calc_MoS(CoM_Vec_double_lead_after,LAnk_Vec_double_lead_after,COM_AP(double_lead_after),CoM_vel_AP(double_lead_after),LBoS_AP_double_lead_after);
    R_MoS_AP_double_after = calc_MoS(CoM_Vec_double_trail_after,RAnk_Vec_double_trail_after,COM_AP(double_trail_after),CoM_vel_AP(double_trail_after),RBoS_AP_double_trail_after);
    L_MoS_ML_double_after = calc_MoS(CoM_Vec_double_lead_after,LAnk_Vec_double_lead_after,COM_ML(double_lead_after),CoM_vel_ML(double_lead_after),LBoS_ML_double_lead_after);
    R_MoS_ML_double_after = calc_MoS(CoM_Vec_double_trail_after,RAnk_Vec_double_trail_after,COM_ML(double_trail_after),CoM_vel_ML(double_trail_after),RBoS_ML_double_trail_after);

else % right leg heelstrike
   LBoS_AP_hs = ltoe_ap(opp_hs);
    LBoS_ML_hs = lank_ml(opp_hs);
    RBoS_AP_hs = rtoe_ap(hs);
    RBoS_ML_hs = rank_ml(hs);
    LBoS_AP_to = ltoe_ap(opp_to);
    LBoS_ML_to = lank_ml(opp_to);
    RBoS_AP_to = rtoe_ap(to);
    RBoS_ML_to = rank_ml(to);

    RBoS_AP_double_lead_before = rtoe_ap(double_lead_before);
    RBoS_ML_double_lead_before = rank_ml(double_lead_before);
    LBoS_AP_double_trail_before = ltoe_ap(double_trail_before);
    LBoS_ML_double_trail_before = lank_ml(double_trail_before);
    RBoS_AP_double_lead_after = rtoe_ap(double_lead_after);
    RBoS_ML_double_lead_after = rank_ml(double_lead_after);
    LBoS_AP_double_trail_after = ltoe_ap(double_trail_after);
    LBoS_ML_double_trail_after = lank_ml(double_trail_after);

    % L_MoS_AP_hs = calc_MoS(CoM_Vec_at_ohs,LAnk_Vec_at_ohs,COM_AP(opp_hs),CoM_vel_AP(opp_hs),LBoS_AP_hs);
    % R_MoS_AP_hs = calc_MoS(CoM_Vec_at_hs,RAnk_Vec_at_hs,COM_AP(hs),CoM_vel_AP(hs),RBoS_AP_hs);
    % L_MoS_ML_hs = calc_MoS(CoM_Vec_at_ohs,LAnk_Vec_at_ohs,COM_ML(opp_hs),CoM_vel_ML(opp_hs),LBoS_ML_hs);
    % R_MoS_ML_hs = calc_MoS(CoM_Vec_at_hs,RAnk_Vec_at_hs,COM_ML(hs),CoM_vel_ML(hs),RBoS_ML_hs);
    % L_MoS_AP_to = calc_MoS(CoM_Vec_at_oto,LAnk_Vec_at_oto,COM_AP(opp_to),CoM_vel_AP(opp_to),LBoS_AP_to);
    % R_MoS_AP_to = calc_MoS(CoM_Vec_at_to,RAnk_Vec_at_to,COM_AP(to),CoM_vel_AP(to),RBoS_AP_to);
    % L_MoS_ML_to = calc_MoS(CoM_Vec_at_oto,LAnk_Vec_at_oto,COM_ML(opp_to),CoM_vel_ML(opp_to),LBoS_ML_to);
    % R_MoS_ML_to = calc_MoS(CoM_Vec_at_to,RAnk_Vec_at_to,COM_ML(to),CoM_vel_ML(to),RBoS_ML_to);

    R_MoS_AP_double_before = calc_MoS(CoM_Vec_double_lead_before,RAnk_Vec_double_lead_before,COM_AP(double_lead_before),CoM_vel_AP(double_lead_before),RBoS_AP_double_lead_before);
    L_MoS_AP_double_before = calc_MoS(CoM_Vec_double_trail_before,LAnk_Vec_double_trail_before,COM_AP(double_trail_before),CoM_vel_AP(double_trail_before),LBoS_AP_double_trail_before);
    R_MoS_ML_double_before = calc_MoS(CoM_Vec_double_lead_before,RAnk_Vec_double_lead_before,COM_ML(double_lead_before),CoM_vel_ML(double_lead_before),RBoS_ML_double_lead_before);
    L_MoS_ML_double_before = calc_MoS(CoM_Vec_double_trail_before,LAnk_Vec_double_trail_before,COM_ML(double_trail_before),CoM_vel_ML(double_trail_before),LBoS_ML_double_trail_before);
    R_MoS_AP_double_after = calc_MoS(CoM_Vec_double_lead_after,RAnk_Vec_double_lead_after,COM_AP(double_lead_after),CoM_vel_AP(double_lead_after),RBoS_AP_double_lead_after);
    L_MoS_AP_double_after = calc_MoS(CoM_Vec_double_trail_after,LAnk_Vec_double_trail_after,COM_AP(double_trail_after),CoM_vel_AP(double_trail_after),LBoS_AP_double_trail_after);
    R_MoS_ML_double_after = calc_MoS(CoM_Vec_double_lead_after,RAnk_Vec_double_lead_after,COM_ML(double_lead_after),CoM_vel_ML(double_lead_after),RBoS_ML_double_lead_after);
    L_MoS_ML_double_after = calc_MoS(CoM_Vec_double_trail_after,LAnk_Vec_double_trail_after,COM_ML(double_trail_after),CoM_vel_ML(double_trail_after),LBoS_ML_double_trail_after);

end

% mos = [L_MoS_AP_hs R_MoS_AP_hs L_MoS_ML_hs R_MoS_ML_hs L_MoS_AP_to R_MoS_AP_to L_MoS_ML_to R_MoS_ML_to];
double_mos = [L_MoS_AP_double_before R_MoS_AP_double_before L_MoS_ML_double_before R_MoS_ML_double_before L_MoS_AP_double_after...
    R_MoS_AP_double_after L_MoS_ML_double_after R_MoS_ML_double_after];


% Combine all data
% OBS_data(1, :) = [trial Lead_foot approach_dist_trail landing_dist_lead...
%     approach_dist_lead landing_dist_trail...
%     Lead_toe_clearance Trail_toe_clearance...
%     Lead_heel_clearance Trail_heel_clearance obs1z_pos obs_start_frame obs_end_frame...
%     lead_step_length trail_step_length lead_step_width trail_step_width L_MoS_AP_hs...
%     R_MoS_AP_hs L_MoS_ML_hs R_MoS_ML_hs L_MoS_AP_to R_MoS_AP_to L_MoS_ML_to R_MoS_ML_to];

OBS_data(1, :) = [subject trial Lead_foot approach_dist_trail landing_dist_lead...
    approach_dist_lead landing_dist_trail...
    Lead_toe_clearance Trail_toe_clearance...
    Lead_heel_clearance Trail_heel_clearance obs1z_pos obs_start_frame obs_end_frame...
    lead_step_length trail_step_length lead_step_width trail_step_width ...
    L_MoS_AP_double_before R_MoS_AP_double_before L_MoS_ML_double_before ...
    R_MoS_ML_double_before L_MoS_AP_double_after...
    R_MoS_AP_double_after L_MoS_ML_double_after R_MoS_ML_double_after];

    


    % *************************************************************************

    clearvars -except SubID files filenum Files datapath fname pname name ...
        traj_num trial_txt trial_raw camrate OBS_data trial_type1...
        trial_type2 trial_type3 trial_type4 trial_type5 obstacle...
        obs1y_pos obs1z_pos  %Uncomment if dowel not in all trials for a subject

end

