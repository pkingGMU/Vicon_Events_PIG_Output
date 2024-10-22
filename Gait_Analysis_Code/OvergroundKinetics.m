function [peak_kinetics,varargout] = OvergroundKinetics(subID,frames,camrate,text,data,all_events,force_event,APcol)


%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

% only claculates for these events that have clean force data


%% ONLY FOR CLEAN FOOT STRIKES AS INDICATED BY GEN EVENTS

%NormalizedGRF - expressed as % bodyweight
%AnkleMoment
%HipMoment
%AnklePower
%HipPower
%RedistributionRatio
all_events_nogen = all_events(all_events(:, 2) ~= 5, :);
%Gait Events

%Gait Events
hs_row = find(all_events_nogen(:,1)==frames(1,1));
hs_foot = all_events_nogen(hs_row,2);
hs = 1;

% next gait event is opposite foot off
opp_to =  find(frames == all_events_nogen(hs_row+1,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+1,1)));
opp_hs =  find(frames == all_events_nogen(hs_row+2,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+2,1)));
to = find(frames == all_events_nogen(hs_row+3,1)); %find(frames == (all_events(find(all_events(:,1)==frames(1,1))+3,1)));

n_clean = length(force_event);

if n_clean ==1 % for one clean event
    if force_event == 1  % if left heelstrike is clean
        % AnkleMoment
        for i = 1:length(text)
            nam = ':LAnkleMoment' % pulls in N.mm/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    acol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    acol = i;
                end
            end
        end
        LAnkMom = data(:,acol)/1000; %Nm/kg
        RAnkMom(1:length(LAnkMom),1) = NaN;

        % HipMoment
        for i = 1:length(text)
            nam = ':LHipMoment' % pulls in N.mm/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    hcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    hcol = i;
                end
            end
        end
        LHipMom = data(:,hcol)/1000;
        RHipMom(1:length(LHipMom),1) = NaN;

        % AnklePower
        for i = 1:length(text)
            nam = ':LAnklePower' % pulls in W/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    apcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    apcol = i;
                end
            end
        end
        LAnkPow = data(:,apcol);
        RAnkPow(1:length(LAnkPow),1) = NaN;

        % Hip Power
        for i = 1:length(text)
            nam = ':LHipPower' % pulls in W/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    hpcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    hpcol = i;
                end
            end
        end
        LHipPow = data(:,hpcol);
        RHipPow(1:length(LHipPow),1) = NaN;

        % NormalisedGRF
        for i = 1:length(text)
            nam = ':LNormalisedGRF' % units undefined but needs something

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    apGRF = i;
                    mlGRF = i+1;
                    upGRF = i+2;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    apGRF = i+1;
                    mlGRF = i;
                    upGRF = i+2;
                end
            end
        end
        LaGRF = data(:,apGRF)/100; % spits out as a percentage of bodyweight, so divide by 100 to get as bodyweight decimal.
        % note treadmill spits out if walking forward that peak propulsion is
        % positive, whereas peak braking force is negative
        LupGRF = data(:,upGRF)/100;
        RaGRF(1:length(LaGRF),1) = NaN;
        RupGRF(1:length(LupGRF),1)= NaN;

        % find all positive data for step
        Lpos_ank_pow = LAnkPow(LAnkPow>0);
        Lpos_hip_pow = LHipPow(LHipPow>0);


    elseif force_event == 3 % if right heelstrike is clean
        % AnkleMoment
        for i = 1:length(text)
            nam = ':RAnkleMoment' % pulls in N.mm/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    acol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    acol = i;
                end
            end
        end
        RAnkMom = data(:,acol)/1000; %Nm/kg
        LAnkMom(1:length(RAnkMom),1) = NaN;

        % HipMoment
        for i = 1:length(text)
            nam = ':RHipMoment' % pulls in N.mm/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    hcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    hcol = i;
                end
            end
        end
        RHipMom = data(:,hcol)/1000;
        LHipMom(1:length(RHipMom),1) = NaN;

        % AnklePower
        for i = 1:length(text)
            nam = ':RAnklePower' % pulls in W/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    apcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    apcol = i;
                end
            end
        end
        RAnkPow = data(:,apcol);
        LAnkPow(1:length(RAnkPow),1) = NaN;

        % Hip Power
        for i = 1:length(text)
            nam = ':RHipPower' % pulls in W/kg

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    hpcol = i+1;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    hpcol = i;
                end
            end
        end
        RHipPow = data(:,hpcol);
        LHipPow(1:length(RHipPow),1) = NaN;

        % NormalisedGRF
        for i = 1:length(text)
            nam = ':RNormalisedGRF' % units undefined but needs something

            if contains(text{i},nam)==1
                if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                    apGRF = i;
                    mlGRF = i+1;
                    upGRF = i+2;
                elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                    apGRF = i+1;
                    mlGRF = i;
                    upGRF = i+2;
                end
            end
        end
        RaGRF = data(:,apGRF)/100; % spits out as a percentage of bodyweight, so divide by 100 to get as bodyweight decimal.
        % note treadmill spits out if walking forward that peak propulsion is
        % positive, whereas peak braking force is negative
        RupGRF = data(:,upGRF)/100;
        LaGRF(1:length(RaGRF),1) = NaN;
        LupGRF(1:length(RupGRF),1)= NaN;

        % find all positive data for step
        Rpos_ank_pow = RAnkPow(RAnkPow>0);
        Rpos_hip_pow = RHipPow(RHipPow>0);
    end


elseif n_clean ==2

    % AnkleMoment
    for i = 1:length(text)
        nam = ':LAnkleMoment' % pulls in N.mm/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                acol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                acol = i;
            end
        end
    end
    LAnkMom = data(:,acol)/1000; %Nm/kg

    % HipMoment
    for i = 1:length(text)
        nam = ':LHipMoment' % pulls in N.mm/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                hcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                hcol = i;
            end
        end
    end
    LHipMom = data(:,hcol)/1000;

    % AnklePower
    for i = 1:length(text)
        nam = ':LAnklePower' % pulls in W/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                apcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                apcol = i;
            end
        end
    end
    LAnkPow = data(:,apcol);

    % Hip Power
    for i = 1:length(text)
        nam = ':LHipPower' % pulls in W/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                hpcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                hpcol = i;
            end
        end
    end
    LHipPow = data(:,hpcol);

    % NormalisedGRF
    for i = 1:length(text)
        nam = ':LNormalisedGRF' % units undefined but needs something

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                apGRF = i;
                mlGRF = i+1;
                upGRF = i+2;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                apGRF = i+1;
                mlGRF = i;
                upGRF = i+2;
            end
        end
    end
    LaGRF = data(:,apGRF)/100; % spits out as a percentage of bodyweight, so divide by 100 to get as bodyweight decimal.
    % note treadmill spits out if walking forward that peak propulsion is
    % positive, whereas peak braking force is negative
    LupGRF = data(:,upGRF)/100;


    % find all positive data for step
    Lpos_ank_pow = LAnkPow(LAnkPow>0);
    Lpos_hip_pow = LHipPow(LHipPow>0);


    % AnkleMoment
    for i = 1:length(text)
        nam = ':RAnkleMoment' % pulls in N.mm/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                acol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                acol = i;
            end
        end
    end
    RAnkMom = data(:,acol)/1000; %Nm/kg

    % HipMoment
    for i = 1:length(text)
        nam = ':RHipMoment' % pulls in N.mm/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                hcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                hcol = i;
            end
        end
    end
    RHipMom = data(:,hcol)/1000;

    % AnklePower
    for i = 1:length(text)
        nam = ':RAnklePower' % pulls in W/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                apcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                apcol = i;
            end
        end
    end
    RAnkPow = data(:,apcol);

    % Hip Power
    for i = 1:length(text)
        nam = ':RHipPower' % pulls in W/kg

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                hpcol = i+1;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                hpcol = i;
            end
        end
    end
    RHipPow = data(:,hpcol);

    % NormalisedGRF
    for i = 1:length(text)
        nam = ':RNormalisedGRF' % units undefined but needs something

        if contains(text{i},nam)==1
            if APcol==1 % anteriorposterior axis is X, mediolateral axis is Y
                apGRF = i;
                mlGRF = i+1;
                upGRF = i+2;
            elseif APcol==2 % anteriorposterior is Y, mediolateral is X
                apGRF = i+1;
                mlGRF = i;
                upGRF = i+2;
            end
        end
    end
    RaGRF = data(:,apGRF)/100; % spits out as a percentage of bodyweight, so divide by 100 to get as bodyweight decimal.
    % note treadmill spits out if walking forward that peak propulsion is
    % positive, whereas peak braking force is negative
    RupGRF = data(:,upGRF)/100;


    % find all positive data for step
    Rpos_ank_pow = LAnkPow(LAnkPow>0);
    Rpos_hip_pow = LHipPow(LHipPow>0);
end


kinetic_array =[LAnkMom RAnkMom LAnkPow RAnkPow LHipMom RHipMom LHipPow RHipPow...
    LaGRF RaGRF LupGRF RupGRF];

%% calculate redistribution ratio


% integrate positive power to get work
dt = 1/camrate;
if exist('Lpos_ank_pow','var')==1
    Lpos_ank_work_step = trapz(dt,Lpos_ank_pow);
    Lpos_hip_work_step = trapz(dt,Lpos_hip_pow);

    RR_Lstep = 1 - (Lpos_ank_work_step - Lpos_hip_work_step)/(Lpos_ank_work_step + Lpos_hip_work_step);
end
if exist('Rpos_ank_pow','var')==1
    Rpos_ank_work_step = trapz(dt,Rpos_ank_pow);
    Rpos_hip_work_step = trapz(dt,Rpos_hip_pow);

    RR_Rstep = 1 - (Rpos_ank_work_step - Rpos_hip_work_step)/(Rpos_ank_work_step + Rpos_hip_work_step);
end

if exist('RR_Lstep','var')==1 && exist('RR_Rstep','var')==1
    LRR = RR_Lstep;
    RRR = RR_Rstep;
elseif exist('RR_Lstep','var')==1 && exist('RR_Rstep','var')==0
    LRR = RR_Lstep;
    RRR = NaN;
elseif exist('RR_Lstep','var')==0 && exist('RR_Rstep','var')==1
    LRR = NaN;
    RRR = RR_Rstep;
end


% figure()
% subplot(2,2,1) % make a 4x4 figure plotting ankle & hip moments and powers
% plot(LAnkMom)
% ylabel('Ankle Moment')
% subplot(2,2,2)
% plot(LAnkPow)
% ylabel('Ankle Power')
% subplot(2,2,3)
% plot(LHipMom)
% ylabel('Hip Moment')
% subplot(2,2,4)
% plot(LHipPow)
% ylabel('Hip Power')


late_stance = round((to-hs)/2);

%%Calculate Peaks

peak_LaGRF = max(LaGRF, [], 'omitnan');
peak_RaGRF = max(RaGRF, [], 'omitnan');
peak_LupGRF = max(LupGRF, [], 'omitnan');
peak_RupGRF = max(RupGRF, [], 'omitnan');
peak_LAnkMom = max(LAnkMom, [], 'omitnan');
peak_RAnkMom = max(RAnkMom, [], 'omitnan');
peak_LAnkPow = max(LAnkPow, [], 'omitnan');
peak_RAnkPow = max(RAnkPow, [], 'omitnan');
if hs_foot == 1
    peak_LHipMom = min(LHipMom(late_stance:end,1), [], 'omitnan'); % Negative sagittal moment in late half of gait cycle
    peak_RHipMom = min(RHipMom(1:opp_to,1), [], 'omitnan'); % Negative sagittal moment in late half of gait cycle
    peak_LHipPow = max(LHipPow(late_stance:end,1), [], 'omitnan'); %Positive power in late half of gait cycle
    peak_RHipPow = max(RHipPow(1:opp_to,1), [], 'omitnan'); %Positive power in late half of gait cycle
else
    peak_LHipMom = min(LHipMom(1:opp_to,1), [], 'omitnan');
    peak_RHipMom = min(RHipMom(late_stance:end,1), [], 'omitnan');
    peak_LHipPow = max(LHipPow(1:opp_to,1), [], 'omitnan');
    peak_RHipPow = max(RHipPow(late_stance:end,1), [], 'omitnan');
end


peak_kinetics = [LRR RRR peak_LaGRF peak_RaGRF peak_LupGRF peak_RupGRF...
    peak_LAnkMom peak_RAnkMom peak_LAnkPow peak_RAnkPow peak_LHipMom peak_RHipMom...
    peak_LHipPow peak_RHipPow];

if nargout > 1
    varargout{1} = peak_kinetics;
    varargout{2} = kinetic_array;
end
end