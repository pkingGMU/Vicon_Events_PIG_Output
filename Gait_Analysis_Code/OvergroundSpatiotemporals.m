function [spatiotemps] = OvergroundSpatiotemporals(frames,lheeAP,lheeML,rheeAP,rheeML,all_events,camrate,direction)
%TreadmillSpatiotemporals Calculates spatiotemporal parameters and returns
%an array of the structure:
% col 1: speed
% col 2: cadence
% col 3: left step length (m)
% col 4: right step length (m)
% col 5: left step width (m)
% col 6: right step width (m)
% col 7: left step time (s)
% col 8: right step time (s)
% col 9: left step time (as a percentage of gait cycle)
% col 10: right step time (as a percentage of gait cycle)
% col 11: left single support time (as a percentage of gait cycle)
% col 12: right single support time (as a percentage of gaity cycle)
% col 13: double support time (as a percentage of gait cycle)
% col 14: left stance time (as a percentage of gait cycle)
% col 15: right stance time (as a percentage of gait cycle)
% col 16: left swing time (as a percentage of gait cycle)
% col 17: right swing time (as a percentage of gait cycle)

% lheeAP = lheeAP(frames);
% lheeML = lheeML(frames);
% rheeAP = rheeAP(frames);
% rheeML = rheeML(frames);

% pull out rows for gait events for this cycle
% 1 = lhs, 2 = rto, 3 = rhs, 4 = rto
t=5;
% remove general events from events
all_events_nogen = all_events(all_events(:, 2) ~= 5, :);

hs_row = find(all_events_nogen(:,1)==frames(1,1));
hs_foot = all_events_nogen(hs_row,2);
hs = 1;

% next gait event is opposite foot off
opp_to =  find(frames == all_events_nogen(hs_row+1,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+1,1)));
opp_hs =  find(frames == all_events_nogen(hs_row+2,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+2,1)));
to = find(frames == all_events_nogen(hs_row+3,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+3,1)));

if hs_foot== 1 % if left heelstrike
    disp = direction*(lheeAP(end) - lheeAP(hs))/1000; % in m, -20 to make sure foot is still on belt
    lsteplength = abs(lheeAP(hs)-rheeAP(hs))/1000; % in m
    lstepwidth = abs(lheeML(hs)-rheeML(hs))/1000; % in m
    lsteptime_in_sec = (to-hs)/camrate; % in seconds
    lsteptime_as_pct = (to-hs)/(length(frames)-hs); % as % gait cycle)
    % lhs --> rto --> rhs --> lto
    % double supp is rto - lhs and lto - rhs
    % left single supp = rhs - rto; right single supp is until next_hs
    doublesupp = ((to-opp_hs)+ (opp_to-hs))/(length(frames)-hs); % as % gait cycle
    lsinglesupp = (opp_hs-opp_to)/(length(frames)-hs); % as % gait cycle
    rsinglesupp = 1-(doublesupp + lsinglesupp);
    lstance = (to-hs)/length(frames); %as % gait cycle
    lswing = 1-lstance; % as % gait cycle
    rsteplength = abs(rheeAP(opp_hs)-lheeAP(opp_hs))/1000;
    rstepwidth = abs(rheeML(opp_hs)-lheeML(opp_hs))/1000;
    rsteptime_in_sec = (length(frames)-opp_hs)/camrate;
    rsteptime_as_pct = (length(frames)-opp_hs)/length(frames);
    rstance = lswing;
    rswing= lstance;

else %if right heelstrike
    disp = direction*(rheeAP(end) - rheeAP(1))/1000;
    rsteplength = abs(rheeAP(hs)-lheeAP(hs))/1000; % in m
    rstepwidth = abs(rheeML(hs)-lheeML(hs))/1000; % in m
    rsteptime_in_sec = (to-hs)/camrate; % in seconds
    rsteptime_as_pct = (to-hs)/(length(frames)-hs); % as % gait cycle)
    % lhs --> rto --> rhs --> lto
    % double supp is rto - lhs and lto - rhs
    % left single supp = rhs - rto; right single supp is until next_hs
    doublesupp = ((to-opp_hs)+ (opp_to-hs))/(length(frames)-hs); % as % gait cycle
    rsinglesupp = (opp_hs-opp_to)/(length(frames)-hs); % as % gait cycle
    lsinglesupp = 1-(doublesupp + rsinglesupp);
    rstance = (to-hs)/length(frames); %as % gait cycle
    rswing = 1-rstance; % as % gait cycle
    lsteplength = abs(lheeAP(opp_hs)-rheeAP(opp_hs))/1000;
    lstepwidth = abs(lheeML(opp_hs)-rheeML(opp_hs))/1000;
    lsteptime_in_sec = (length(frames)-opp_hs)/camrate;
    lsteptime_as_pct = (length(frames)-opp_hs)/length(frames);
    lstance = rswing;
    lswing=rstance;
end
dt = (length(frames) - hs)/camrate; % in seconds
speed = disp/dt; %in m/s
cadence = (2/(length(frames)/camrate))*60; %time for gait cycle = max(frames)/120, 2 steps in that time

spatiotemps = [speed cadence lsteplength rsteplength lstepwidth rstepwidth...
    lsteptime_in_sec rsteptime_in_sec lsteptime_as_pct rsteptime_as_pct...
    lsinglesupp rsinglesupp doublesupp lstance rstance lswing rswing];
end