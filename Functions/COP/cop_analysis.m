function cop_analysis(proc_table_struct, file, fr, trial_name, subject)

global r01

% Initialize an empty matrix to hold cop path and variables data
Lcopth_x_matrix = [];
Lcopth_y_matrix = [];
Rcopth_x_matrix = [];
Rcopth_y_matrix = [];
dcopx= []; dcopy= [];
sstime= [];
vcopx= []; vcopy= [];
PAPF= [];
COPx_rereg= []; COPy_rereg= [];
COPx_vel_rereg = []; COPy_vel_rereg = [];

%% load motion data

trajectory = proc_table_struct.(trial_name).trajectory_data_table;

trajectory = convertvars(trajectory, @iscell, 'string');
trajectory = convertvars(trajectory, @isstring, 'double');

frame_values = trajectory.("Frame");
frame_start = frame_values(1);

FR = fr;

xy = r01.project_xy;



if strcmp(xy, 'Y') == 1

    LASIS = trajectory(:, {'LASI_X', 'LASI_Y', 'LASI_Z'});
    RASIS = trajectory(:, {'RASI_X', 'RASI_Y', 'RASI_Z'});
    LPSIS= trajectory(:, {'LPSI_X', 'LPSI_Y', 'LPSI_Z'});
    y_LPSIS = trajectory.("LPSI_Y");
    RPSIS= trajectory(:, {'RPSI_X', 'RPSI_Y', 'RPSI_Z'});
    y_RPSIS = trajectory.("RPSI_Y"); 

    OPSIS=0.5*(table2array(RPSIS)+table2array(LPSIS)); 
    y_OPSIS=0.5*(y_LPSIS+y_RPSIS);

    LHE = trajectory(:, {'LHEE_X', 'LHEE_Y', 'LHEE_Z'});
    LTO = trajectory(:, {'LTOE_X', 'LTOE_Y', 'LTOE_Z'});
    
    y_LHE=trajectory.("LHEE_Y");
    z_LHE=trajectory.("LHEE_Z");
    
    y_LTO=trajectory.("LTOE_Y");
    z_LTO=trajectory.("LTOE_Z");
    
 
    y_RHE=trajectory.("RHEE_Y");
    z_RHE=trajectory.("RHEE_Z");
    
    y_RTO=trajectory.("RTOE_Y");
    z_RTO=trajectory.("RTOE_Z");

elseif strcmp(xy, 'X') == 1
    LASIS = trajectory(:, {'LASI_X', 'LASI_Y', 'LASI_Z'});
    RASIS = trajectory(:, {'RASI_X', 'RASI_Y', 'RASI_Z'});
    LPSIS= trajectory(:, {'LPSI_X', 'LPSI_Y', 'LPSI_Z'});
    y_LPSIS = (trajectory.("LPSI_X"));
    RPSIS= trajectory(:, {'RPSI_X', 'RPSI_Y', 'RPSI_Z'});
    y_RPSIS = (trajectory.("RPSI_X")); 

    OPSIS=0.5*(table2array(RPSIS)+table2array(LPSIS)); 
    y_OPSIS=0.5*(y_LPSIS+y_RPSIS);

    LHE = trajectory(:, {'LHEE_X', 'LHEE_Y', 'LHEE_Z'});
    LTO = trajectory(:, {'LTOE_X', 'LTOE_Y', 'LTOE_Z'});
    
    y_LHE=trajectory.("LHEE_X");
    z_LHE=trajectory.("LHEE_Z");
    
    y_LTO=trajectory.("LTOE_X");
    z_LTO=trajectory.("LTOE_Z");
    
 
    y_RHE=trajectory.("RHEE_X");
    z_RHE=trajectory.("RHEE_Z");
    
    y_RTO=trajectory.("RTOE_X");
    z_RTO=trajectory.("RTOE_Z");

end

z_lfocent= 0.5*(z_LHE+z_LTO); % z left foot centre
z_rfocent= 0.5*(z_RHE+z_RTO); % z right foot centre

%% Coordinate-Based Treadmill Algorithm_ EVENTS
if y_RHE(1,1)<0 || y_LHE(1,1)<0
  
% left heel-sacrum distance
Lheel=y_LHE-y_OPSIS;
% left toe-sacrum distance
Ltoe=-1*(y_LTO-y_OPSIS); % inverted

% right heel-sacrum distance
Rheel=y_RHE-y_OPSIS;
% right toe-sacrum distance
Rtoe=-1*(y_RTO-y_OPSIS); % inverted

else

% left heel-sacrum distance
Lheel=-(y_LHE-y_OPSIS);
% left toe-sacrum distance
Ltoe=(y_LTO-y_OPSIS); % inverted

% right heel-sacrum distance
Rheel=-(y_RHE-y_OPSIS);
% right toe-sacrum distance
Rtoe=(y_RTO-y_OPSIS); % inverted

end

%findpeaks/valleys left leg Events
[Lpks,flhs]=findpeaks(Lheel); %[peaks, Frames] left heel strike
Lhstimes=(flhs-1)/FR; % left heel strike times

[Lvlys,flto]=findpeaks(Ltoe); %[valleys, Frames] left toe off
Ltofftimes=(flto-1)/FR; % left toe off times

%findpeaks- right leg Events
[Rpks,frhs]=findpeaks(Rheel); %[peaks, Frames] right heel strike
Rhstimes=(frhs-1)/FR; % right heel strike times

[Rvlys,frto]=findpeaks(Rtoe); %[valleys, Frames] right toe off
Rtofftimes=(frto-1)/FR; % right toe off times

%% load force data

ForceData = proc_table_struct.(trial_name).devices_data_table;

ForceData = convertvars(ForceData, @iscell, 'string');
ForceData = convertvars(ForceData, @isstring, 'double');


temp = table();
i = 1;
num_plates = 0;
Forcedata = ForceData;


% Constants
n = height(trajectory);
index=10:10:10*n;
G=[0 0 -9.81];
filtered_COPx = {};
filtered_COPy = {};
filtered_Fy = {};
force_z = {};
force_y = {};
Fz_downsampled = {};
stance = {};
heelstrikes = {};

Fs= 1000;
Fc= 10;
order= 4;
[b, a] = butter(order, Fc / (Fs / 2), 'low');

i = 1;
plate = 1;
fCOPx_count = 1;
fCOPy_count = 1;
Fy_count = 1;
Fz_count = 1;
Fy_count = 1;
while i <= width(Forcedata)
    if i+2 > width(Forcedata)
        break
    end
    varName = string(Forcedata.Properties.VariableNames{i});

    col = table2array(Forcedata(:,i));
    
    if ~contains(varName, 'Combined') && (contains(varName, 'CoP_') || contains(varName, 'Force_Fy') || contains(varName, 'Force_Fz'))
        filtered = filtfilt(b,a, col);

        if contains(varName, 'CoP_Cx')
            filtered_COPx{fCOPx_count} = filtered;
            fCOPx_count = fCOPx_count +1;
            num_plates = num_plates + 1;

        elseif contains(varName, 'CoP_Cy')
            filtered_COPy{fCOPy_count} = filtered;
            fCOPy_count = fCOPy_count + 1;

        elseif contains(varName, 'Force_Fy')
            filtered_Fy{Fy_count} = filtered;
            

            if y_RHE(1,1) < 0 || y_LHE(1,1) < 0
                force_y{Fy_count} = -col;
            else
                force_y{Fy_count} = col;
            end

            Fy_count = Fy_count + 1;
        elseif contains(varName, 'Force_Fz')
            force_z{Fz_count} = -col;
            Fz_downsampled{Fz_count} = col(index, :);
            stance{Fz_count} = find(force_z{Fz_count} > 30);
            Fz_count = Fz_count + 1;
        end
    end
    i = i+1;
end


AP_GRF = {};
propulsive = {};
footcontact = {};
heelstrike = {};
toeoff = {};
frto_plate = {};
flto_plate = {};
frhs_plate = {};
flhs_plate = {};
LCOPx_fullst = {};
LCOPy_fullst = {};
LPAPF = {};
d_Lcopx = {};
d_Lcopy = {};
Lsstime = {};
v_Lcopx = {};
v_Lcopy = {};
Lstep_length = {};
Lstep_time = {};
Lstep_speed = {};
Lstep_width = {};
Ldstime = {};
RCOPx_fullst = {};
RCOPy_fullst = {};
RPAPF = {};
d_Rcopx = {};
d_Rcopy = {};
Rsstime = {};
v_Rcopx = {};
v_Rcopy = {};
Rstep_length = {};
Rstep_time = {};
Rstep_speed = {};
Rstep_width = {};
Rdstime = {};

for plate = 1:num_plates
    % Extract AP-GRF during the stance phase
    AP_GRF{plate} = force_y{plate}(stance{plate});
    propulsive{plate}= AP_GRF{plate} > 0; % Use only the positive values of AP-GRF (indicating propulsion)
    footcontact{plate} = 10 * find(abs(Fz_downsampled{plate}) > 30);
    %footcontact_test = round(stance{plate}); %alternative
    if ~isempty(footcontact{plate})
        heelstrike{plate} = footcontact{plate}(1);
        toeoff = footcontact{plate}(end);
        frto_plate{plate} = intersect(frto, footcontact{plate} / 10);
        frhs_plate{plate} = intersect(frhs, footcontact{plate} / 10);
        flto_plate{plate} = intersect(flto, footcontact{plate} / 10);
        flhs_plate{plate} = intersect(flhs, footcontact{plate} / 10);
    else
        heelstrike{plate} = [];
        toeoff{plate} = [];
        frto{plate} = [];
        frhs{plate} = [];
        flto{plate} = [];
        flhs{plate} = [];
    end

    if y_RHE(1,1) < 0 || y_LHE(1,1) < 0

        if ~isempty(heelstrike{plate}) && (y_LHE((heelstrike{plate})/10) > -2) && (y_LTO((heelstrike{plate})/10) < 2)
            LCOPx_fullst{plate} = filtered_COPx{plate}(stance{plate}); % COPx during stance time
            LCOPy_fullst{plate} = filtered_COPy{plate}(stance{plate});
            LPAPF{plate} = max(AP_GRF{plate}(propulsive{plate})); % Peak anterior propulsive force
            d_Lcopx{plate} = abs(filtered_COPx{plate}(10*frto_plate{plate}) - filtered_COPx{plate}(10*frhs_plate{plate})); % Left ML-COP displacement
            d_Lcopy{plate} = abs(filtered_COPy{plate}(10*frto_plate{plate}) - filtered_COPy{plate}(10*frhs_plate{plate})); % Left AP-COP displacement
            Lsstime{plate} = abs(frto_plate{plate} - frhs_plate{plate}) / FR; % Left single stance time
            v_Lcopx{plate} = d_Lcopx{plate} / Lsstime{plate}; % Left ML-COP velocity
            v_Lcopy{plate} = d_Lcopy{plate} / Lsstime{plate}; % Left AP-COP velocity
            Lstep_length{plate} = abs(y_LHE(heelstrike{plate} / 10) - y_RHE(frhs_plate{plate}));
            Lstep_time{plate}= abs((heelstrike{plate} / 10) - frhs_plate{plate}) / FR;
            Lstep_speed{plate}= Lstep_length{plate}/ Lstep_time{plate};
            Lstep_width{plate} = abs(x_LHE(heelstrike{plate} / 10) - x_RHE(frhs_plate{plate}));
            Ldstime{plate} = abs((heelstrike{plate} / 10) - frto_plate{plate}) / FR; % Left double stance time
        end

        if ~isempty(heelstrike{plate}) && (y_RHE((heelstrike{plate})/10) > -2) && (y_RTO((heelstrike{plate})/10) < 2)
            RCOPx_fullst{plate} = filtered_COPx{plate}(stance{plate}); % COPx during stance time
            RCOPy_fullst{plate} = filtered_COPy{plate}(stance{plate});
            RPAPF{plate} = max(AP_GRF{plate}(propulsive{plate})); % Peak anterior propulsive force
            d_Rcopx{plate} = abs(filtered_COPx{plate}(10*flto_plate{plate}) - filtered_COPx{plate}(10*flhs_plate{plate})); % Left ML-COP displacement
            d_Rcopy{plate} = abs(filtered_COPy{plate}(10*flto_plate{plate}) - filtered_COPy{plate}(10*flhs_plate{plate})); % Left AP-COP displacement
            Rsstime{plate} = abs(flto_plate{plate} - flhs_plate{plate}) / FR; % Left single stance time
            v_Rcopx{plate} = d_Rcopx{plate} / Lsstime{plate}; % Left ML-COP velocity
            v_Rcopy{plate} = d_Rcopy{plate} / Lsstime{plate}; % Left AP-COP velocity
            Rstep_length{plate} = abs(y_RHE(heelstrike{plate} / 10) - y_RHE(flhs_plate{plate}));
            Rstep_time{plate}= abs((heelstrike{plate} / 10) - flhs_plate{plate}) / FR;
            Rstep_speed{plate}= Rstep_length{plate}/ Lstep_time{plate};
            Rstep_width{plate} = abs(x_RHE(heelstrike{plate} / 10) - x_RHE(flhs_plate{plate}));
            Rdstime{plate} = abs((heelstrike{plate} / 10) - flto_plate{plate}) / FR; % Left double stance time
            
        end

    else

        if ~isempty(heelstrike{plate}) && (y_LHE((heelstrike{plate})/10) > -2) && (y_LTO((heelstrike{plate})/10) < 2)
            LCOPx_fullst{plate} = 400 - filtered_COPx{plate}(stance{plate}); % COPx during stance time
            LCOPy_fullst{plate} = 600 -filtered_COPy{plate}(stance{plate});
            LPAPF{plate} = max(AP_GRF{plate}(propulsive{plate})); % Peak anterior propulsive force
            d_Lcopx{plate} = abs(filtered_COPx{plate}(10*frto_plate{plate}) - filtered_COPx{plate}(10*frhs_plate{plate})); % Left ML-COP displacement
            d_Lcopy{plate} = abs(filtered_COPy{plate}(10*frto_plate{plate}) - filtered_COPy{plate}(10*frhs_plate{plate})); % Left AP-COP displacement
            Lsstime{plate} = abs(frto_plate{plate} - frhs_plate{plate}) / FR; % Left single stance time
            v_Lcopx{plate} = d_Lcopx{plate} / Lsstime{plate}; % Left ML-COP velocity
            v_Lcopy{plate} = d_Lcopy{plate} / Lsstime{plate}; % Left AP-COP velocity
            Lstep_length{plate} = abs(y_LHE(heelstrike{plate} / 10) - y_RHE(frhs_plate{plate}));
            Lstep_time{plate}= abs((heelstrike{plate} / 10) - frhs_plate{plate}) / FR;
            Lstep_speed{plate}= Lstep_length{plate}/ Lstep_time{plate};
            Lstep_width{plate} = abs(x_LHE(heelstrike{plate} / 10) - x_RHE(frhs_plate{plate}));
            Ldstime{plate} = abs((heelstrike{plate} / 10) - frto_plate{plate}) / FR; % Left double stance time
        end

        if ~isempty(heelstrike{plate}) && (y_RHE((heelstrike{plate})/10) > -2) && (y_RTO((heelstrike{plate})/10) < 2)
            RCOPx_fullst{plate} = 400 - filtered_COPx{plate}(stance{plate}); % COPx during stance time
            RCOPy_fullst{plate} = 600 -filtered_COPy{plate}(stance{plate});
            RPAPF{plate} = max(AP_GRF{plate}(propulsive{plate})); % Peak anterior propulsive force
            d_Rcopx{plate} = abs(filtered_COPx{plate}(10*flto_plate{plate}) - filtered_COPx{plate}(10*flhs_plate{plate})); % Left ML-COP displacement
            d_Rcopy{plate} = abs(filtered_COPy{plate}(10*flto_plate{plate}) - filtered_COPy{plate}(10*flhs_plate{plate})); % Left AP-COP displacement
            Rsstime{plate} = abs(flto_plate{plate} - flhs_plate{plate}) / FR; % Left single stance time
            v_Rcopx{plate} = d_Rcopx{plate} / Lsstime{plate}; % Left ML-COP velocity
            v_Rcopy{plate} = d_Rcopy{plate} / Lsstime{plate}; % Left AP-COP velocity
            Rstep_length{plate} = abs(y_RHE(heelstrike{plate} / 10) - y_RHE(flhs_plate{plate}));
            Rstep_time{plate}= abs((heelstrike{plate} / 10) - flhs_plate{plate}) / FR;
            Rstep_speed{plate}= Rstep_length{plate}/ Lstep_time{plate};
            Rstep_width{plate} = abs(x_RHE(heelstrike{plate} / 10) - x_RHE(flhs_plate{plate}));
            Rdstime{plate} = abs((heelstrike{plate} / 10) - flto_plate{plate}) / FR; % Left double stance time
            
        end

        

    end
end


% filtered_COP1x = filtfilt(b, a, COP1x); % Zero-phase filtering for no lag
% filtered_COP1y = filtfilt(b, a, COP1y);
% filtered_COP2x = filtfilt(b, a, COP2x);
% filtered_COP2y = filtfilt(b, a, COP2y);
% filtered_COP3x = filtfilt(b, a, COP3x);
% filtered_COP3y = filtfilt(b, a, COP3y);
% 
% F1z = -filtfilt(b, a, Forcedata(:,5));
% F2z = -filtfilt(b, a, Forcedata(:,14));
% % F3z = -filtfilt(b, a, Forcedata(:,23));
% F1yy = filtfilt(b, a, Forcedata(:,4));
% F2yy = filtfilt(b, a, Forcedata(:,13));
% % F3yy = filtfilt(b, a, Forcedata(:,22));
% 
% 
% index=10:10:10*n;
% F1z_downsampled= F1z(index,:);
% F2z_downsampled= F2z(index,:);
% % F3z_downsampled= F3z(index,:);
% 
% % M1_downsampled=Fdata(:,6:8); M1x_downsampled=M1_downsampled(:,1); M1y_downsampled=M1_downsampled(:,2); M1z_downsampled=M1_downsampled(:,3);
% % M2_downsampled=Fdata(:,15:17); M2x_downsampled=M2_downsampled(:,1); M2y_downsampled=M2_downsampled(:,2); M2z_downsampled=M2_downsampled(:,3);
% % 
% % one_COPx=filtered_COP1x(index,:);
% % one_COPy=filtered_COP1y(index,:);
% % two_COPx=filtered_COP2x(index,:);
% % two_COPy=filtered_COP2y(index,:);
% % three_COPx=filtered_COP3x(index,:);
% % three_COPy=filtered_COP3y(index,:);



% figure;
% plot(COP1x);
% hold on
% plot(filtered_COP1x);
% figure;
% plot(COP1y);
% hold on
% plot(filtered_COP1y);

%% COP Path
F1_footcontact = 10*find(abs(F1z_downsampled) > 30); %foot contact frames
% copth= Forcedata(one_fr_hs_tof,9:10); hs to toe-off
F1_heelstrike= F1_footcontact(1); %first frame of foot contact- force plate one

F2_footcontact = 10*find(abs(F2z_downsampled) > 30); %foot contact frames
% copth= Forcedata(two_fr_hs_tof,9:10); hs to toe-off
F2_heelstrike= F2_footcontact(1); %first frame of foot contact- force plate two

if y_RHE(1,1)<0 || y_LHE(1,1)<0
if y_LTO((F1_heelstrike)/10)>0

one_frto_indices=find(10*frto > F1_heelstrike, 1, 'first');
one_frto_first = 10*frto(one_frto_indices);
one_frhs_indices=find(10*frhs > F1_heelstrike, 1, 'first');
one_frhs_first = 10*frhs(one_frhs_indices);

left_copthsst_x = filtered_COP1x(one_frto_first:one_frhs_first); % Left ML cop path during single stance time
left_copthsst_y= filtered_COP1y(one_frto_first:one_frhs_first); % Left AP cop path during single stance time

two_flto_indices=find(10*flto > F2_heelstrike, 1, 'first');
two_flto_first = 10*flto(two_flto_indices);
two_flhs_indices=find(10*flhs > F2_heelstrike, 1, 'first');
two_flhs_first = 10*flhs(two_flhs_indices);

right_copthsst_x = filtered_COP2x(two_flto_first:two_flhs_first); % Right ML cop path during single stance time
right_copthsst_y = filtered_COP2y(two_flto_first:two_flhs_first)-603; % Right AP cop path during single stance time

else

one_flto_indices=find(10*flto > F1_heelstrike, 1, 'first');
one_flto_first = 10*flto(one_flto_indices);
one_flhs_indices=find(10*flhs > F1_heelstrike, 1, 'first');
one_flhs_first = 10*flhs(one_flhs_indices);

right_copthsst_x = filtered_COP1x(one_flto_first:one_flhs_first); % during single stance time
right_copthsst_y = filtered_COP1y(one_flto_first:one_flhs_first); % during single stance time

two_frto_indices=find(10*frto > F2_heelstrike, 1, 'first');
two_frto_first = 10*frto(two_frto_indices);
two_frhs_indices=find(10*frhs > F2_heelstrike, 1, 'first');
two_frhs_first = 10*frhs(two_frhs_indices);

left_copthsst_x = filtered_COP2x(two_frto_first:two_frhs_first); % during single stance time
left_copthsst_y = filtered_COP2y(two_frto_first:two_frhs_first)-603; % during single stance time

end
else
if y_LTO((F2_heelstrike)/10)>1.203

two_flto_indices=find(10*flto > F2_heelstrike, 1, 'first');
two_flto_first = 10*flto(two_flto_indices);
two_flhs_indices=find(10*flhs > F2_heelstrike, 1, 'first');
two_flhs_first = 10*flhs(two_flhs_indices);

right_copthsst_x = 400-(filtered_COP2x(two_flto_first:two_flhs_first)); % during single stance time
right_copthsst_y = 1203-(filtered_COP2y(two_flto_first:two_flhs_first));

one_frto_indices=find(10*frto > F1_heelstrike, 1, 'first');
one_frto_first = 10*frto(one_frto_indices);
one_frhs_indices=find(10*frhs > F1_heelstrike, 1, 'first');
one_frhs_first = 10*frhs(one_frhs_indices);

left_copthsst_x = 400-(filtered_COP1x(one_frto_first:one_frhs_first)); % during single stance time
left_copthsst_y = 600-(filtered_COP1y(one_frto_first:one_frhs_first)); % during single stance time

else

two_frto_indices=find(10*frto > F2_heelstrike, 1, 'first');
two_frto_first = 10*frto(two_frto_indices);
two_frhs_indices=find(10*frhs > F2_heelstrike, 1, 'first');
two_frhs_first = 10*frhs(two_frhs_indices);

left_copthsst_x = 400-(filtered_COP2x(two_frto_first:two_frhs_first)); % during single stance time
left_copthsst_y = 1203-(filtered_COP2y(two_frto_first:two_frhs_first)); % during single stance time

one_flto_indices=find(10*flto > F1_heelstrike, 1, 'first');
one_flto_first = 10*flto(one_flto_indices);
one_flhs_indices=find(10*flhs > F1_heelstrike, 1, 'first');
one_flhs_first = 10*flhs(one_flhs_indices);

right_copthsst_x = 400-(filtered_COP1x(one_flto_first:one_flhs_first)); % during single stance time
right_copthsst_y = 600-(filtered_COP1y(one_flto_first:one_flhs_first)); % during single stance time
end
end

%% 101 gait frames
nFrames = 101; % normalize to 101 frames

frameIndices_Lsst = linspace(1, length(left_copthsst_x), nFrames);
Lcopth_x = interp1(1:length(left_copthsst_x), left_copthsst_x, frameIndices_Lsst);
Lcopth_y = interp1(1:length(left_copthsst_y), left_copthsst_y, frameIndices_Lsst);
Lcopth_x= Lcopth_x';
Lcopth_y= Lcopth_y';

frameIndices_Rsst = linspace(1, length(right_copthsst_x), nFrames);
Rcopth_x = interp1(1:length(right_copthsst_x), right_copthsst_x, frameIndices_Rsst);
Rcopth_y = interp1(1:length(right_copthsst_y), right_copthsst_y, frameIndices_Rsst);
Rcopth_x= Rcopth_x';
Rcopth_y= Rcopth_y';

%% COP Displacement, mean velocity and single stance time
d_Lcopx_mat= left_copthsst_x(end)-left_copthsst_x(1); % Left ML-COP displacement
d_Lcopy_mat= left_copthsst_y(end)-left_copthsst_y(1); % Left AP-COP displacement
d_Rcopx_mat= right_copthsst_x(end)-right_copthsst_x(1); % Right ML-COP displacement
d_Rcopy_mat= right_copthsst_y(end)-right_copthsst_y(1); % Right AP-COP displacement

Lsstime_mat= (numel(left_copthsst_x))/Fs; % Left single stance time
Rsstime_mat= (numel(right_copthsst_x))/Fs; % Right single stance time

v_Lcopx_mat= d_Lcopx_mat/Lsstime_mat; % Left ML-COP velocity
v_Lcopy_mat= d_Lcopy_mat/Lsstime_mat; % Left AP-COP velocity
v_Rcopx_mat= d_Rcopx_mat/Rsstime_mat; % Right ML-COP velocity
v_Rcopy_mat= d_Rcopy_mat/Rsstime_mat; % Right AP-COP velocity

SD_Lcopx= std(left_copthsst_x);
SD_Lcopy= std(left_copthsst_y);
SD_Rcopx= std(right_copthsst_x);
SD_Rcopy= std(right_copthsst_y);

%% % Step 1: Peak Anterior Propulsive Force (PAPF)
stance_F1 = find(F1z > 30); % Indices where V-GRF > threshold
stance_F2 = find(F2z > 30); % Indices where V-GRF > threshold
%stance_F3 = find(F3z > 30); % Indices where V-GRF > threshold


if y_RHE(1,1) < 0 || y_LHE(1,1) < 0
    F1y= -F1yy;
    F2y= -F2yy;
%     F3y= -F3yy;
else
    F1y= F1yy;
    F2y= F2yy;
%     F3y= F3yy;
end

% Step 3: Extract AP-GRF during the stance phase
AP_GRF1 = F1y(stance_F1);
AP_GRF2 = F2y(stance_F2);
%AP_GRF3 = F3y(stance_F3);

propulsive_F1 = AP_GRF1 > 0; % Use only the positive values of AP-GRF (indicating propulsion)
PAPF1_mat = max(AP_GRF1(propulsive_F1)); % Peak anterior propulsive force
propulsive_F2 = AP_GRF2 > 0; 
PAPF2_mat = max(AP_GRF2(propulsive_F2));
% propulsive_F3 = AP_GRF3 > 0;
% PAPF3_mat = max(AP_GRF3(propulsive_F3));

%% reregistering cop trajectories
delta_t= 1/Fs;

if y_RHE(1,1)<0 || y_LHE(1,1)<0
    if y_LTO((F1_heelstrike)/10)>0
    LCOPx_fullst= filtered_COP1x(stance_F1); % copx during stance time
    LCOPy_fullst= filtered_COP1y(stance_F1); % copy during stance time
    RCOPx_fullst= filtered_COP2x(stance_F2);
    RCOPy_fullst= filtered_COP2y(stance_F2)-603;
    else
    RCOPx_fullst= filtered_COP1x(stance_F1); % copx during stance time
    RCOPy_fullst= filtered_COP1y(stance_F1); % copy during stance time
    LCOPx_fullst= filtered_COP2x(stance_F2);
    LCOPy_fullst= filtered_COP2y(stance_F2)-603;
    end
else
    if y_LTO((F2_heelstrike)/10)>1.203
    RCOPx_fullst= 400-filtered_COP2x(stance_F2);
    RCOPy_fullst= 1205-filtered_COP2y(stance_F2);
    LCOPx_fullst= 400-filtered_COP1x(stance_F1);
    LCOPy_fullst= 600-filtered_COP1y(stance_F1);
    else
    LCOPx_fullst= 400-filtered_COP2x(stance_F2);
    LCOPy_fullst= 1205-filtered_COP2y(stance_F2);
    RCOPx_fullst= 400-filtered_COP1x(stance_F1);
    RCOPy_fullst= 600-filtered_COP1y(stance_F1);  
    end
end

% Step 1: Translate COP data
% For each force plate, translate COP data so that heel strike becomes the origin
LCOPx_translated = LCOPx_fullst - LCOPx_fullst(1);
LCOPy_translated = LCOPy_fullst - LCOPy_fullst(1);
RCOPx_translated = RCOPx_fullst - RCOPx_fullst(1);
RCOPy_translated = RCOPy_fullst - RCOPy_fullst(1);

% Combine translated COP data for PCA
LCOP_translated = [LCOPx_translated, LCOPy_translated];
RCOP_translated = [RCOPx_translated, RCOPy_translated];

% Step 2: Apply PCA to Align to Principal Axes
[coeff1, ~, ~] = pca(LCOP_translated); % coeff1 contains PC1 and PC2 as columns
LCOP_pca = LCOP_translated * coeff1; % Align data to principal axes
footlength = (1000*sqrt(sum((LHE(30,:) - LTO(30,:)).^2)));
LCOP_nlf= (LCOP_pca/footlength)*100;
LCOPx_nlf = -LCOP_nlf(:, 2);
LCOPy_nlf = LCOP_nlf(:, 1);

% Output PCA-Aligned Data
LCOPx_pca = -LCOP_pca(:, 2); % New x-coordinates (aligned with PC2)
LCOPy_pca = LCOP_pca(:, 1); % New y-coordinates (aligned with PC1)

LCOPx_vel = zeros(size(LCOPx_pca)); % Pre-allocate with the same size
LCOPy_vel = zeros(size(LCOPy_pca));

LCOPx_vel(1) = (LCOPx_pca(2) - LCOPx_pca(1)) / delta_t;
LCOPy_vel(1) = (LCOPy_pca(2) - LCOPy_pca(1)) / delta_t;

for i = 2:length(LCOPx_pca)-1
    LCOPx_vel(i) = (LCOPx_pca(i+1) - LCOPx_pca(i-1)) / (2 * delta_t);
    LCOPy_vel(i) = (LCOPy_pca(i+1) - LCOPy_pca(i-1)) / (2 * delta_t);
end

LCOPx_vel(end) = (LCOPx_pca(end) - LCOPx_pca(end-1)) / delta_t;
LCOPy_vel(end) = (LCOPy_pca(end) - LCOPy_pca(end-1)) / delta_t;

% Step 3: Normalize to 100% stance phase (101 frames)
LframeIndices = linspace(1, length(LCOPx_pca), nFrames);

LCOPx_normalized = (interp1(1:length(LCOPx_nlf), LCOPx_nlf, LframeIndices))';
LCOPy_normalized = (interp1(1:length(LCOPy_nlf), LCOPy_nlf, LframeIndices))';
LCOPx_vel_normalized = (interp1(1:length(LCOPx_vel), LCOPx_vel, LframeIndices))'; 
LCOPy_vel_normalized = (interp1(1:length(LCOPy_vel), LCOPy_vel, LframeIndices))';

% Step 2: Apply PCA to Align to Principal Axes
[coeff2, ~, ~] = pca(RCOP_translated); % coeff2 contains PC1 and PC2 as columns
RCOP_pca = RCOP_translated * coeff2; % Align data to principal axes
RCOP_nlf= (RCOP_pca/footlength)*100;
RCOPx_nlf = RCOP_nlf(:, 2);
RCOPy_nlf = RCOP_nlf(:, 1);

% Output PCA-Aligned Data
RCOPx_pca = RCOP_pca(:, 2); % New x-coordinates (aligned with PC2)
RCOPy_pca = RCOP_pca(:, 1); % New y-coordinates (aligned with PC1)

RCOPx_vel = zeros(size(RCOPx_pca)); % Pre-allocate with the same size
RCOPy_vel = zeros(size(RCOPy_pca));

RCOPx_vel(1) = (RCOPx_pca(2) - RCOPx_pca(1)) / delta_t;
RCOPy_vel(1) = (RCOPy_pca(2) - RCOPy_pca(1)) / delta_t;

for i = 2:length(RCOPx_pca)-1
    RCOPx_vel(i) = (RCOPx_pca(i+1) - RCOPx_pca(i-1)) / (2 * delta_t);
    RCOPy_vel(i) = (RCOPy_pca(i+1) - RCOPy_pca(i-1)) / (2 * delta_t);
end

RCOPx_vel(end) = (RCOPx_pca(end) - RCOPx_pca(end-1)) / delta_t;
RCOPy_vel(end) = (RCOPy_pca(end) - RCOPy_pca(end-1)) / delta_t;

% Step 3: Normalize to 100% stance phase (101 frames)
RframeIndices = linspace(1, length(RCOPx_pca), nFrames);

RCOPx_normalized = (interp1(1:length(RCOPx_nlf), RCOPx_nlf, RframeIndices))';
RCOPy_normalized = (interp1(1:length(RCOPy_nlf), RCOPy_nlf, RframeIndices))';
RCOPx_vel_normalized = (interp1(1:length(RCOPx_vel), RCOPx_vel, RframeIndices))'; 
RCOPy_vel_normalized = (interp1(1:length(RCOPy_vel), RCOPy_vel, RframeIndices))';

%% Append data to matrices
    Lcopth_x_matrix = [Lcopth_x_matrix, Lcopth_x];
    Lcopth_y_matrix = [Lcopth_y_matrix, Lcopth_y];
    Rcopth_x_matrix = [Rcopth_x_matrix, Rcopth_x];
    Rcopth_y_matrix = [Rcopth_y_matrix, Rcopth_y];
dcopx= [dcopx, d_Lcopx_mat, d_Rcopx_mat];
dcopy= [dcopy, d_Lcopy_mat, d_Rcopy_mat];
sstime= [sstime, Lsstime_mat, Rsstime_mat];
vcopx= [vcopx, v_Lcopx_mat, v_Rcopx_mat];
vcopy= [vcopy, v_Lcopy_mat, v_Rcopy_mat];
    PAPF= [PAPF, PAPF1_mat, PAPF2_mat];
    COPx_rereg= [COPx_rereg, LCOPx_normalized, RCOPx_normalized];
    COPy_rereg= [COPy_rereg, LCOPy_normalized, RCOPy_normalized];
COPx_vel_rereg = [COPx_vel_rereg, LCOPx_vel_normalized, RCOPx_vel_normalized];
COPy_vel_rereg = [COPy_vel_rereg, LCOPy_vel_normalized, RCOPy_vel_normalized];

    % Store file name in cell array
    [~, file_name, ~] = fileparts(filename);
    file_names{u} = file_name;

   

%% Plot Results: COPx and COPy vs Frames
frames = 1:nFrames; % Frame indices

% COPx vs Frames
figure;
subplot(1,2,1);
hold on;
plot(frames, COPx_rereg, 'b', 'DisplayName', 'Force Plate 1'); % Force Plate 1
grid on;
title('COPx vs Frames');
xlabel('Frames');
ylabel('COPx (Lateral)');
legend show;

% COPy vs Frames
subplot(1,2,2);
hold on;
plot(frames, COPy_rereg, 'b', 'DisplayName', 'Force Plate 1'); % Force Plate 1
grid on;
title('COPy vs Frames');
xlabel('Frames');
ylabel('COPy (Anterior)');
legend show;

% velocity of COPx vs Frames
figure;
subplot(1,2,1);
hold on;
plot(frames, COPx_vel_rereg, 'b', 'DisplayName', 'Force Plate 1'); % Force Plate 1
grid on;
title('V_COPx vs Frames');
xlabel('Frames');
ylabel('V_COPx (Lateral)');
legend show;

% velocity of COPy vs Frames
subplot(1,2,2);
hold on;
plot(frames, COPx_vel_rereg, 'b', 'DisplayName', 'Force Plate 1'); % Force Plate 1
grid on;
title('V_COPy vs Frames');
xlabel('Frames');
ylabel('V_COPy (Anterior)');
legend show;
%% tables
% Insert file names as row headers
Lcopth_x_matrix = [string(file_names); num2cell(Lcopth_x_matrix)]';
Lcopth_y_matrix = [string(file_names); num2cell(Lcopth_y_matrix)]';
Rcopth_x_matrix = [string(file_names); num2cell(Rcopth_x_matrix)]';
Rcopth_y_matrix = [string(file_names); num2cell(Rcopth_y_matrix)]';

file_name_row = reshape(repmat(file_names, 2, 1), 1, []); % Repeat each file name twice and reshape to match the required size
dcopx = [file_name_row; num2cell(dcopx)]'; % Append the file_name_row as the first row in dcopx
dcopy = [file_name_row; num2cell(dcopy)]';
sstime = [file_name_row; num2cell(sstime)]';
vcopx = [file_name_row; num2cell(vcopx)]';
vcopy = [file_name_row; num2cell(vcopy)]';
PAPF = [file_name_row; num2cell(PAPF)]';
COPx_rereg = [file_name_row; num2cell(COPx_rereg)]';
COPy_rereg = [file_name_row; num2cell(COPy_rereg)]';
COPx_vel_rereg = [file_name_row; num2cell(COPx_vel_rereg)]';
COPy_vel_rereg = [file_name_row; num2cell(COPy_vel_rereg)]';

% Define headers
headers = {'Participant', 'Task', 'dcopx', 'dcopy', 'sstime', 'vcopx', 'vcopy', 'CodeCondition', 'PAPF'};
% Extract the first column of d_copx as strings
first_column_words = string(dcopx(:, 1));
% Initialize Participant column
Participant = regexp(first_column_words, '(?<=Over|DT)\d+', 'match', 'once'); % Extract numbers after Over or DT
Participant = str2double(Participant); % Convert to numeric (NaN for non-matching entries)
% Initialize CodeCondition
CodeCondition = zeros(size(first_column_words));
% Apply conditions
CodeCondition(contains(first_column_words, 'v', 'IgnoreCase', true)) = -0.5; % If the word contains 'v'
CodeCondition(contains(first_column_words, 'T', 'IgnoreCase', true)) = 0.5;  % If the word contains 't'
Participant= num2cell(Participant);
CodeCondition= num2cell(CodeCondition);
dcopx(:,1)= cellstr(dcopx(:,1));
% Combine headers and data, including Participant and CodeCondition
cop_variables_headers = [headers; Participant, dcopx(:,1), dcopx(:,2:end), dcopy(:,2:end), sstime(:,2:end), vcopx(:,2:end), vcopy(:,2:end), CodeCondition, PAPF(:,2:end)];

% Save matrices and their names
save('Lcopth_x_data.mat', 'Lcopth_x_matrix');
save('Lcopth_y_data.mat', 'Lcopth_y_matrix');
save('Rcopth_x_data.mat', 'Rcopth_x_matrix');
save('Rcopth_y_data.mat', 'Rcopth_y_matrix');
save('cop_variables.mat', 'cop_variables_headers');
save('copx_reregistered.mat', 'COPx_rereg');
save('copy_reregistered.mat', 'COPy_rereg');
save('copx_vel_reregistered.mat', 'COPx_vel_rereg');
save('copy_vel_reregistered.mat', 'COPy_vel_rereg');

% Write to Excel file
writematrix(Lcopth_x_matrix, 'copth_data.xlsx', 'Sheet', 'Lcopth_x');
writematrix(Lcopth_y_matrix, 'copth_data.xlsx', 'Sheet', 'Lcopth_y');
writematrix(Rcopth_x_matrix, 'copth_data.xlsx', 'Sheet', 'Rcopth_x');
writematrix(Rcopth_y_matrix, 'copth_data.xlsx', 'Sheet', 'Rcopth_y');
writecell(cop_variables_headers, 'cop_variables.xlsx');
writecell(COPx_rereg, 'COP_reregistered.xlsx', 'Sheet', 'COPx');
writecell(COPy_rereg, 'COP_reregistered.xlsx', 'Sheet', 'COPy');
writecell(COPx_vel_rereg, 'COP_vel_reregistered.xlsx', 'Sheet', 'COPx');
writecell(COPy_vel_rereg, 'COP_vel_reregistered.xlsx', 'Sheet', 'COPy');
           

end