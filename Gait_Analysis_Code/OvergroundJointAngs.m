% Originally written by Frankie Wade, Ph.D. Fall 2024
% Edited by Patrick King GMU 2025

function [varargout] = OvergroundJointAngs(subID,frames,text,data,all_events,APcol,direction)
%TreadmillJointAngs Spits out array of peak joint angles with optional array of joint angles across the gait cycle. 
%   [jointAngs] = TreadmillJointAngs(subID,frames,text,data,all_events,APcol)
% [jointAngs, jointAngs_Array] = TreadmillJointAngs(subID,frames,text,data,all_events,APcol)
% col 1: Left peak plantarflexion during stance (-ve)
% col 2: Right peak plantarflexion during stance (-ve)
% col 3: Left peak dorsiflexion during stance (+ve)
% col 4: Right peak dorsiflexion during stance (+ve)
% col 5: Left peak knee flexion during stance (+ve)
% col 6: Right peak knee flexion during stance (+ve)
% col 7: Left peak hip flexion during stance (+ve)
% col 8: Right peak hip flexion during stance (+ve)
% col 9: Left peak plantarflexion during swing (-ve)
% col 10: Right peak plantarflexion during swing (-ve)
% col 11: Left peak dorsiflexion during swing (+ve)
% col 12: Right peak dorsiflexion during swint (+ve)
% col 13: Left peak knee flexion during swing (+ve)
% col 14: Right peak knee flexion during swing (+ve)
% col 15: Left peak hip flexion during swing (+ve)
% col 16: Right peak hip flexion during swing (+ve)

% text = model_text;
% data = model_data(frames,:);

% Ankle Angles
for i = 1:length(text)
    nam = append(subID, ':LAnkleAngles');

    if contains(text{i},':LAnkleAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            pfc = i+1;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            pfc = i;
        end
    end
end
LAnk_PF = data(:,pfc);

for i = 1:length(text)
    nam = append(subID, ':RAnkleAngles');

    if contains(text{i},':RAnkleAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            pfc = i+1;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            pfc = i;
        end
    end
end
RAnk_PF = data(:,pfc);


% Hip Angles
for i = 1:length(text)
    nam = append(subID, ':LHipAngles');

    if contains(text{i},':LHipAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            hipc = i+1;
            hipad = i;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            hipc = i;
            hipad = i+1;
        end
    end
end
LHip_Flex = data(:,hipc);
LHip_Abd = data(:,hipad);

for i = 1:length(text)
    nam = append(subID, ':RHipAngles');

    if contains(text{i}, ':RHipAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            hipc = i+1;
            hipad = i;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            hipc = i;
            hipad = i+1;
        end
    end
end
RHip_Flex = data(:,hipc);
RHip_Abd = data(:,hipad);

% Knee Angles
for i = 1:length(text)
    nam = append(subID, ':LKneeAngles');

    if contains(text{i},':LKneeAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            kneec = i+1;
            kneead = i;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            kneec = i;
            kneead = i+1;
        end
    end
end
LKnee_Flex = data(:,kneec);
LKnee_Abd = data(:,kneead);

for i = 1:length(text)
    nam = append(subID, ':RKneeAngles');

    if contains(text{i},':RKneeAngles')==1
        if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
            kneec = i+1;
            kneead = i;
        elseif APcol==2 % anteriorposterior is Y, mediolateral is X
            kneec = i;
            kneead = i+1;
        end
    end
end
RKnee_Flex = data(:,kneec);
RKnee_Abd = data(:,kneead);

jointAngs_array = [LAnk_PF RAnk_PF LKnee_Flex RKnee_Flex LKnee_Abd RKnee_Abd LHip_Flex RHip_Flex LHip_Abd RHip_Abd];

%Find peaks
% Gait Events
all_events_nogen = all_events(all_events(:, 2) ~= 5, :);
hs_row = find(all_events_nogen(:,1)==frames(1,1));
hs_foot = all_events_nogen(hs_row,2);
hs = 1;

% next gait event is opposite foot off
opp_to =  find(frames == all_events_nogen(hs_row+1,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+1,1)));
opp_hs =  find(frames == all_events_nogen(hs_row+2,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+2,1)));
to = find(frames == all_events_nogen(hs_row+3,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+3,1)));


% stance phase = hs : to;
% swing = to : end

if hs_foot ==1 % if left is in stance at start of gait cycle:

PeakLPF = min(LAnk_PF(hs:to,1));
PeakLDF = max(LAnk_PF(hs:to,1));
PeakLHipFlex = max(LHip_Flex(hs:to,1));
PeakLKneeFlex = max(LKnee_Flex(hs:to,1));

% right will be in stance between opp_hs and end
PeakRPF = min(RAnk_PF(opp_hs:end,1));
PeakRDF = max(RAnk_PF(opp_hs:end,1));
PeakRHipFlex = max(RHip_Flex(opp_hs:end,1));
PeakRKneeFlex = max(RKnee_Flex(opp_hs:end,1));

%right in swing between opp_to and opp_hs
PeakRPf_swing = min(RAnk_PF(opp_to:opp_hs,1));
PeakRDf_swing = max(RAnk_PF(opp_to:opp_hs,1));
PeakRHipFlex_swing = max(RHip_Flex(opp_to:opp_hs,1));
PeakRKneeFlex_swing = max(RKnee_Flex(opp_to:opp_hs,1));

%left in swing between to and end
PeakLPf_swing = min(LAnk_PF(to:end,1));
PeakLDf_swing = max(LAnk_PF(to:end,1));
PeakLHipFlex_swing = max(LHip_Flex(to:end,1));
PeakLKneeFlex_swing = max(LKnee_Flex(to:end,1));

else
PeakRPF = min(RAnk_PF(hs:to,1));
PeakRDF = max(RAnk_PF(hs:to,1));
PeakRHipFlex = max(RHip_Flex(hs:to,1));
PeakRKneeFlex = max(RKnee_Flex(hs:to,1));

% left will be in stance between opp_hs and end
PeakLPF = min(LAnk_PF(opp_hs:end,1));
PeakLDF = max(LAnk_PF(opp_hs:end,1));
PeakLHipFlex = max(LHip_Flex(opp_hs:end,1));
PeakLKneeFlex = max(LKnee_Flex(opp_hs:end,1));

% left will be in stance opp_hs
PeakLPf_swing = min(LAnk_PF(opp_to:opp_hs,1));
PeakLDf_swing = max(LAnk_PF(opp_to:opp_hs,1));
PeakLHipFlex_swing = max(LHip_Flex(opp_to:opp_hs,1));
PeakLKneeFlex_swing = max(LHip_Flex(opp_to:opp_hs,1));

%right in swing between to and end
PeakRPf_swing = min(RAnk_PF(to:end,1));
PeakRDf_swing = max(RAnk_PF(to:end,1));
PeakRHipFlex_swing = max(RHip_Flex(to:end,1));
PeakRKneeFlex_swing = max(RKnee_Flex(to:end,1));
end

jointAngs = [PeakLPF PeakRPF PeakLDF PeakRDF PeakLKneeFlex PeakRKneeFlex...
    PeakLHipFlex PeakRHipFlex PeakLPf_swing PeakRPf_swing PeakLDf_swing PeakRDf_swing...
    PeakLKneeFlex_swing PeakRKneeFlex_swing PeakLHipFlex_swing PeakRHipFlex_swing]; 
    
if nargout>1
    varargout{1} = jointAngs;
    varargout{2} = jointAngs_array;
else
    varargout{1} = jointAngs;
end

end