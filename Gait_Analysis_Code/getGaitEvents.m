function [varargout] = getGaitEvents(text,data,type,camrate)
%GetGaitEvents Send in text and data arrays from Vicon output, 
% sends out arrays with the frame number of each gait event:
% lhs = left foot strike
% lto = left foot off
% rhs = right foot contact
% rto = right foot off
% gen = clean force plate strike

%   Detailed explanation goes here


% define gait events
n_events = 0; n_lto = 0; n_lhs = 0; n_rto = 0; n_rhs = 0; n_gen = 0;
% categorize gait events: lhs = 1 rto = 2 rhs = 3 lto = 4, gen = 5;
% gen = clean foot strike for overground
for ii = 1:length(text)

    % Left Heel Strike
    if strcmp(text(ii,1),'Left')==1 && strcmp(text(ii,2),'Foot Strike')==1
        n_events = n_events + 1;
        n_lhs = n_lhs + 1;
        event_type{n_events,1} = {'Left hs'};
        event_type{n_events,2} = data(ii);
        lhs(n_lhs,1) = data(ii);
        lhs(n_lhs,2) = 1;
        % Left Toe Off
    elseif strcmp(text(ii,1),'Left')==1 && strcmp(text(ii,2),'Foot Off')==1
        n_events = n_events + 1;
        n_lto = n_lto + 1;
        event_type{n_events,1} = {'Left to'};
        event_type{n_events,2} = data(ii);
        lto(n_lto,1) = data(ii);
        lto(n_lto,2) = 4;
        % Right Toe off
    elseif strcmp(text(ii,1),'Right') == 1 && strcmp(text(ii,2),'Foot Off') == 1
        n_events = n_events + 1;
        n_rto = n_rto + 1;
        event_type{n_events,1} = {'Right to'};
        event_type{n_events,2} = data(ii);
        rto(n_rto,1) = data(ii);
        rto(n_rto,2) = 2;
        % Right Heel Strike
    elseif strcmp(text(ii,1),'Right')==1 && strcmp(text(ii,2),'Foot Strike')==1
        n_events = n_events + 1;
        n_rhs = n_rhs + 1;
        event_type{n_events,1} = {'Right hs'};
        event_type{n_events,2} = data(ii);
        rhs(n_rhs,1) = data(ii);
        rhs(n_rhs,2) = 3;

    elseif strcmp(text(ii,1), 'General') == 1 && strcmp(text(ii,2), 'Event') == 1
        n_events = n_events + 1;
        n_gen = n_gen + 1;
        event_type{n_events,1} = {'General'};
        event_type{n_events,2} = data(ii);
        gen(n_gen,1) = data(ii);
        gen(n_gen,2) = 5;
    end
end

% convert time to frame numbers % timetable look up

% sampling frequency: 1 frame is equal to 1/sampling frequency
%Identify the frame number of the event via time to frame conversion and
%organize events in ascending order. (Events are now in frames)

if ~any(~isnan(rhs(:,1)))==0
    rhs(:,1) = sort(round(rhs(:,1)*camrate));%right heel strike event times
end
if ~any(~isnan(lhs(:,1)))==0
    lhs(:,1) = sort(round(lhs(:,1)*camrate));%left heel strike event times
end
if ~any(~isnan(lto(:,1)))==0
    lto(:,1) = sort(round(lto(:,1)*camrate));%left toe off event times
end
if ~any(~isnan(rto(:,1)))==0
    rto(:,1) = sort(round(rto(:,1)*camrate));%right toe off event times
end
if strcmp(type{:},'Overground')==1
    try
        if ~any(~isnan(gen(:,1)))==0
            gen(:,1) = sort(round(gen(:,1)*camrate));% General event times
            

        end
    catch
         gen = zeros(n_rto, 2); % Set gen to a 1x1 array with a 0 in it
         gen(:, 2) = 5; % Set all values in column 2 to 5
         gen(:, 1) = Inf;
    end

    all_events = sortrows([rhs;rto;lhs;lto;gen],1);
else
    all_events = sortrows([rhs;rto;lhs;lto],1);
end

if nargout == 5
    varargout{1} = rhs;
    varargout{2} = rto;
    varargout{3} = lhs;
    varargout{4} = lto;
    varargout{5} = all_events;
elseif nargout == 6
    varargout{1} = rhs;
    varargout{2} = rto;
    varargout{3} = lhs;
    varargout{4} = lto;
    varargout{5} = gen;
    varargout{6} = all_events;
    
end

end