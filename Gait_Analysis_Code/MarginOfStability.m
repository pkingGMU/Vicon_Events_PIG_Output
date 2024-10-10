function [mos] = MarginOfStability(subID,frames,camrate,text,data,coordata,coortext, all_events,APcol);

%TreadmillMoS Calculates margin of stability (MoS)
%   Calculates anteriorposterior (AP) and mediolateral (ML) margins of stability at
%   heelstrike (hs) and toe-off (to). Exports an array of the structure: 
% [L_MoS_AP_hs, R_MoS_AP_hs, L_MoS_ML_hs, R_MoS_ML_hs, L_MoS_AP_to,
% R_MoS_AP_to, L_MoS_ML_to, R_MoS_ML_to]
% Base of Support Definition: Uses toe marker (placed according to PIG to define the base of support in
% the AP direction and the ankle marker to define the base of the support
% in the ML direction (less sensitive to foot angle)
% Limb length for pendulum calculation: Center of Mass to Ankle marker 
% Uses conventions as defined by Hof 2005; Curtze et al 2024. 

%
% text = model_text;
% data = model_data(mod_rows,:);

%% Define Markers from Trajectory Data
% Find CoM from model data
for i = 1:length(text)
    nam = append(subID,':CentreOfMass');

    if strcmp(text{i},nam)==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            ap = i+1;
            ml = i;
            up = i+2;

        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                        ap = i;
            ml = i+1;
            up = i+2;
            
       end
    end
end

            COM_AP = data(:,ap)/1000;
            COM_ML = data(:,ml)/1000;
            COM_UP = data(:,up)/1000;
% RANK
for i = 1:length(coortext)
    nam = [':RANK'];
    if length(coortext{i}) > 4
        if strcmp(coortext{i}(end-4:end),nam)==1
            if APcol == 1
                rank_AP_col = i;
                rank_ML_col = i+1;
                rank_up_col = i+2;
            elseif APcol==2
                rank_AP_col = i+1;
                rank_ML_col = i;
                rank_up_col = i+2;
            end
        end
    end
end
rank_ap = coordata(:,rank_AP_col)/1000;
rank_ml = coordata(:,rank_ML_col)/1000;
rank_up = coordata(:,rank_up_col)/1000;

% lank
for i = 1:length(coortext)
    nam = [':LANK'];
    if length(coortext{i}) > 4
        if strcmp(coortext{i}(end-4:end),nam)==1
            if APcol == 1
                lank_AP_col = i;
                lank_ML_col = i+1;
                lank_up_col = i+2;
            elseif APcol==2
                lank_AP_col = i+1;
                lank_ML_col = i;
                lank_up_col = i+2;
            end
        end
    end
end
lank_ap = coordata(:,lank_AP_col)/1000;
lank_ml = coordata(:,lank_ML_col)/1000;
lank_up = coordata(:,lank_up_col)/1000;

% rote
for i = 1:length(coortext)
    nam = [':RTOE'];
    if length(coortext{i}) > 4
        if strcmp(coortext{i}(end-4:end),nam)==1
            if APcol == 1
                rtoe_AP_col = i;
                rtoe_ML_col = i+1;
                rtoe_up_col = i+2;
            elseif APcol==2
                rtoe_AP_col = i+1;
                rtoe_ML_col = i;
                rtoe_up_col = i+2;
            end
        end
    end
end
rtoe_ap = coordata(:,rtoe_AP_col)/1000;
rtoe_ml = coordata(:,rtoe_ML_col)/1000;
rtoe_up = coordata(:,rtoe_up_col)/1000;

% ltoe
for i = 1:length(coortext)
    nam = [':LTOE'];
    if length(coortext{i}) > 4
        if strcmp(coortext{i}(end-4:end),nam)==1
            if APcol == 1
                ltoe_AP_col = i;
                ltoe_ML_col = i+1;
                ltoe_up_col = i+2;
            elseif APcol==2
                ltoe_AP_col = i+1;
                ltoe_ML_col = i;
                ltoe_up_col = i+2;
            end
        end
    end
end
ltoe_ap = coordata(:,ltoe_AP_col)/1000;
ltoe_ml = coordata(:,ltoe_ML_col)/1000;
ltoe_up = coordata(:,ltoe_up_col)/1000;

% Gait Events
hs_row = find(all_events(:,1)==frames(1,1));
hs_foot = all_events(hs_row,2);
hs = 1;

% next gait event is opposite foot off
opp_to =  find(frames == all_events(hs_row+1,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+1,1)));
opp_hs =  find(frames == all_events(hs_row+2,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+2,1)));
to = find(frames == all_events(hs_row+3,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+3,1)));


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

% calculate center of mass velocity
dt = 1/camrate;

for i = 1:length(COM_AP)-1
    CoM_vel_AP(i,1) = (COM_AP(i+1)-COM_AP(i))/dt;
    CoM_vel_ML(i,1) = (COM_ML(i+1)-COM_ML(i))/dt;
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

    %acl_MoS(CoM_Vec,ank_vec, CoM, CoM_vel, BoS)

    L_MoS_AP_hs = calc_MoS(CoM_Vec_at_hs,LAnk_Vec_at_hs,COM_AP(hs),CoM_vel_AP(hs),LBoS_AP_hs);
    R_MoS_AP_hs = calc_MoS(CoM_Vec_at_ohs,RAnk_Vec_at_ohs,COM_AP(opp_hs),CoM_vel_AP(opp_hs),RBoS_AP_hs);
    L_MoS_ML_hs = calc_MoS(CoM_Vec_at_hs,LAnk_Vec_at_hs,COM_ML(hs),CoM_vel_ML(hs),LBoS_ML_hs);
    R_MoS_ML_hs = calc_MoS(CoM_Vec_at_ohs,RAnk_Vec_at_ohs,COM_ML(opp_hs),CoM_vel_ML(opp_hs),RBoS_ML_hs);
    L_MoS_AP_to = calc_MoS(CoM_Vec_at_to,LAnk_Vec_at_to,COM_AP(to),CoM_vel_AP(to),LBoS_AP_to);
    R_MoS_AP_to = calc_MoS(CoM_Vec_at_oto,RAnk_Vec_at_oto,COM_AP(opp_to),CoM_vel_AP(opp_to),RBoS_AP_to);
    L_MoS_ML_to = calc_MoS(CoM_Vec_at_to,LAnk_Vec_at_to,COM_ML(to),CoM_vel_ML(to),LBoS_ML_to);
    R_MoS_ML_to = calc_MoS(CoM_Vec_at_oto,RAnk_Vec_at_oto,COM_ML(opp_to),CoM_vel_ML(opp_to),RBoS_ML_to);


else % right leg heelstrike
   LBoS_AP_hs = ltoe_ap(opp_hs);
    LBoS_ML_hs = lank_ml(opp_hs);
    RBoS_AP_hs = rtoe_ap(hs);
    RBoS_ML_hs = rank_ml(hs);
    LBoS_AP_to = ltoe_ap(opp_to);
    LBoS_ML_to = lank_ml(opp_to);
    RBoS_AP_to = rtoe_ap(to);
    RBoS_ML_to = rank_ml(to);

    L_MoS_AP_hs = calc_MoS(CoM_Vec_at_ohs,LAnk_Vec_at_ohs,COM_AP(opp_hs),CoM_vel_AP(opp_hs),LBoS_AP_hs);
    R_MoS_AP_hs = calc_MoS(CoM_Vec_at_hs,RAnk_Vec_at_hs,COM_AP(hs),CoM_vel_AP(hs),RBoS_AP_hs);
    L_MoS_ML_hs = calc_MoS(CoM_Vec_at_ohs,LAnk_Vec_at_ohs,COM_ML(opp_hs),CoM_vel_ML(opp_hs),LBoS_ML_hs);
    R_MoS_ML_hs = calc_MoS(CoM_Vec_at_hs,RAnk_Vec_at_hs,COM_ML(hs),CoM_vel_ML(hs),RBoS_ML_hs);
    L_MoS_AP_to = calc_MoS(CoM_Vec_at_oto,LAnk_Vec_at_oto,COM_AP(opp_to),CoM_vel_AP(opp_to),LBoS_AP_to);
    R_MoS_AP_to = calc_MoS(CoM_Vec_at_to,RAnk_Vec_at_to,COM_AP(to),CoM_vel_AP(to),RBoS_AP_to);
    L_MoS_ML_to = calc_MoS(CoM_Vec_at_oto,LAnk_Vec_at_oto,COM_ML(opp_to),CoM_vel_ML(opp_to),LBoS_ML_to);
    R_MoS_ML_to = calc_MoS(CoM_Vec_at_to,RAnk_Vec_at_to,COM_ML(to),CoM_vel_ML(to),RBoS_ML_to);

    
end

mos = [L_MoS_AP_hs R_MoS_AP_hs L_MoS_ML_hs R_MoS_ML_hs L_MoS_AP_to R_MoS_AP_to L_MoS_ML_to R_MoS_ML_to];

end


