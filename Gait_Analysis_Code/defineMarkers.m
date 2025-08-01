% Originally written by Frankie Wade, Ph.D. Fall 2024
% Edited by Patrick King GMU 2025

function [varargout] = defineFootMarkers(text,data,APcol)
%defineFootMarkers Assigns variables to marker trajectory data in order of up to 12 options:
%   [LHeel_AP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP, RToe_ML] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP, RToe_ML, LToe_UP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP, RToe_ML, LToe_UP, RToe_UP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP, RToe_ML, LToe_UP, RToe_UP, LHeel_UP] = defineFootMarkers(text,data)
%   [LHeel_AP, LHeel_ML, RHeel_AP, RHeel_ML, LToe_AP, LToe_ML, RToe_AP, RToe_ML, LToe_UP, RToe_UP, LHeel_UP, RHeel_UP] = defineFootMarkers(text,data)

% rhee
for i = 1:length(text)
    nam = [':RHEE'];
    if length(text{i}) > 4
        if strcmp(text{i}(end-4:end),nam)==1
            if APcol == 1
                rhee_AP_col = i;
                rhee_ML_col = i+1;
                rhee_up_col = i+2;
            elseif APcol==2
                rhee_AP_col = i+1;
                rhee_ML_col = i;
                rhee_up_col = i+2;
            end
        end
    end
end
rhee_ap = data(:,rhee_AP_col);
rhee_ml = data(:,rhee_ML_col);
rhee_up = data(:,rhee_up_col);
% lhee
for i = 1:length(text)
    nam = [':LHEE'];
    if length(text{i}) > 4
        if strcmp(text{i}(end-4:end),nam)==1
            if APcol == 1
                lhee_AP_col = i;
                lhee_ML_col = i+1;
                lhee_up_col = i+2;
            elseif APcol==2
                lhee_AP_col = i+1;
                lhee_ML_col = i;
                lhee_up_col = i+2;
            end
        end
    end
end
lhee_ap = data(:,lhee_AP_col);
lhee_ml = data(:,lhee_ML_col);
lhee_up = data(:,lhee_up_col);

% rtoe
for i = 1:length(text)
    nam = [':RTOE'];
    if length(text{i}) > 4
        if strcmp(text{i}(end-4:end),nam)==1
            if APcol == 1
                rtoe_AP_col = i;
                rtoe_ML_col = i+1;
                rtoe_UP_col = i+2;
            elseif APcol==2
                rtoe_AP_col = i+1;
                rtoe_ML_col = i;
                rtoe_UP_col = i+2;
            end
        end
    end
end
rtoe_ap = data(:,rtoe_AP_col);
rtoe_ml = data(:,rtoe_ML_col);
rtoe_up = data(:,rote_UP_col);

% ltoe
for i = 1:length(text)
    nam = [':LTOE'];
    if length(text{i}) > 4
        if strcmp(text{i}(end-4:end),nam)==1
            if APcol == 1
                ltoe_AP_col = i;
                ltoe_ML_col = i+1;
                ltoe_UP_col = i+2;
            elseif APcol==2
                ltoe_AP_col = i+1;
                ltoe_ML_col = i;
                ltoe_UP_col = i+2;
            end
        end
    end
end
ltoe_ap = data(:,ltoe_AP_col);
ltoe_ml = data(:,ltoe_ML_col);
ltoe_up = data(:,ltoe_UP_col);

switch nargout
    case 1
        varargout{1} = lhee_ap;
    case 2
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
    case 3
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
    case 4
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
    case 5
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
    case 6
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
    case 7
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
    case 8
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
        varargout{8} = rtoe_ml;
    case 9
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
        varargout{8} = rtoe_ml;
        varargout{9} = ltoe_up;
    case 10
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
        varargout{8} = rtoe_ml;
        varargout{9} = ltoe_up;
        varargout{10} = rtoe_up;
    case 11
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
        varargout{8} = rtoe_ml;
        varargout{9} = ltoe_up;
        varargout{10} = rtoe_up;
        varargout{11} = lhee_up;
    case 12
        varargout{1} = lhee_ap;
        varargout{2} = lhee_ml;
        varargout{3} = rhee_ap;
        varargout{4} = rhee_ml;
        varargout{5} = ltoe_ap;
        varargout{6} = ltoe_ml;
        varargout{7} = rtoe_ap;
        varargout{8} = rtoe_ml;
        varargout{9} = ltoe_up;
        varargout{10} = rtoe_up;
        varargout{11} = lhee_up;
        varargout{12} = rhee_up;
end



end