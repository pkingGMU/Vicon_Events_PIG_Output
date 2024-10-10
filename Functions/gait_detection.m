function [flhs,flto,frhs,frto] = gait_detection(trajectory)


    %% load motion data
    %frame = model_output(:,{Frame});
    frame_values = str2double(trajectory.("Frame"));
    frame_start = frame_values(1);
    FR=100; % frame rate, Hz
    %t=frame/FR; %time, sec
    %n=length(t);
    
    %% Markers
    % pelvis markers, meters
    %LASIS=(trajectory(:, {'02:LASI_X', '02:LASI_Y', '02:LASI_Z'}));
    %RASIS=(trajectory(:, {'02:RASI_X', '02:RASI_Y', '02:RASI_Z'}));
    %LPSIS=(trajectory(:, {'02:LPSI_X', '02:LPSI_Y', '02:LPSI_Z'}));
    y_LPSIS=str2double(trajectory.("LPSI_Y"));
    %RPSIS=(trajectory(:, {'02:RPSI_X', '02:RPSI_Y', '02:RPSI_Z'}));
    y_RPSIS=str2double(trajectory.("RPSI_Y"));
    %OPSIS=0.5*(RPSIS+LPSIS); %PSIS center(sacrum)
    y_OPSIS=0.5*(y_LPSIS+y_RPSIS); %PSIS y center(y sacrum)
    %CPSIS=mean([RPSIS;LPSIS],1);
    
    % foot markers
    %LHE=0.001*data(:,96:98);
    %x_LHE=0.001*data(:,96);
    y_LHE=str2double(trajectory.("LHEE_Y"));
    z_LHE=str2double(trajectory.("LHEE_Z"));
    
    %LTO=0.001*data(:,99:101);
    %x_LTO=0.001*data(:,99);
    y_LTO=str2double(trajectory.("LTOE_Y"));
    z_LTO=str2double(trajectory.("LTOE_Z"));
    
    %RHE=0.001*data(:,114:116);
    %x_RHE=0.001*data(:,114);
    y_RHE=str2double(trajectory.("RHEE_Y"));
    z_RHE=str2double(trajectory.("RHEE_Z"));
    
    %RTO=0.001*data(:,117:119);
    %x_RTO=0.001*data(:,117);
    y_RTO=str2double(trajectory.("RTOE_Y"));
    z_RTO=str2double(trajectory.("RTOE_Z"));
    
    z_lfocent= 0.5*(z_LHE+z_LTO); % z left foot centre
    z_rfocent= 0.5*(z_RHE+z_RTO); % z right foot centre
    
    
    
    %% load force data
    
    % LGRF=Fdata(:,3:5); 
    % LFx=LGRF(:,1); 
    % LFy=LGRF(:,2); 
    % LFz=LGRF(:,3);
    % 
    % RGRF=Fdata(:,12:14); 
    % RFx=RGRF(:,1); 
    % RFy=RGRF(:,2); 
    % RFz=RGRF(:,3);
    % 
    % LM=Fdata(:,6:8); 
    % LMx=LM(:,1); 
    % LMy=LM(:,2); 
    % LMz=LM(:,3);
    % 
    % RM=Fdata(:,15:17); 
    % RMx=LM(:,1); 
    % RMy=LM(:,2); 
    % RMz=LM(:,3);
    % 
    % for p= 1:length(LFz)
    % LCOPx(p)=-0.01*(LMy(p)/LFz(p)); LCOPy(p)=0.01*(LMx(p)/LFz(p));
    % RCOPx(p)=-0.01*(RMy(p)/RFz(p)); RCOPy(p)=0.01*(RMx(p)/RFz(p));
    % end
    % 
    % 
    % one_COP=0.1*Fdata(:,9:11); one_COPx=one_COP(:,1); one_COPy=one_COP(:,2);
    % two_COP=0.1*Fdata(:,18:20); two_COPx=two_COP(:,1); two_COPy=two_COP(:,2);
    % three_COP=0.1*Fdata(:,27:29); three_COPx=three_COP(:,1); three_COPy=three_COP(:,2);
    % 
    % G=[0 0 -9.81];
    
    %% Coordinate-Based Treadmill Algorithm_ EVENTS
    if y_RHE(1,1)<0 && y_LHE(1,1)<0
    
    disp('Top')

    % left heel-sacrum distance
    Lheel=y_LHE-y_OPSIS;
    % left toe-sacrum distance
    Ltoe=-1*(y_LTO-y_OPSIS); % inverted
    
    % right heel-sacrum distance
    Rheel=y_RHE-y_OPSIS;
    % right toe-sacrum distance
    Rtoe=-1*(y_RTO-y_OPSIS); % inverted
    
    %findpeaks/valleys left leg Events
    [Lpks,flhs]=findpeaks(Lheel); %[peaks, Frames] left heel strike
    figure; findpeaks(Lheel);
    xlabel('frame');
    ylabel('left heel strike');
    Lhstimes=(flhs-1)/FR; % left heel strike times
    
    [Lvlys,flto]=findpeaks(Ltoe); %[valleys, Frames] left toe off
    figure; findpeaks(Ltoe);
    xlabel('frame');
    ylabel('left toe off');
    Ltofftimes=(flto-1)/FR; % left toe off times
    
    %findpeaks- right leg Events
    [Rpks,frhs]=findpeaks(Rheel); %[peaks, Frames] right heel strike
    figure; findpeaks(Rheel);
    xlabel('frame');
    ylabel('right heel strike');
    Rhstimes=(frhs-1)/FR; % right heel strike times
    
    [Rvlys,frto]=findpeaks(Rtoe); %[valleys, Frames] right toe off
    figure; findpeaks(Rtoe);
    xlabel('frame');
    ylabel('right toe off');
    Rtofftimes=(frto-1)/FR; % right toe off times
    
    else
    
    disp('Bottom')

    % left heel-sacrum distance
    Lheel=-(y_LHE-y_OPSIS);
    % left toe-sacrum distance
    Ltoe=(y_LTO-y_OPSIS); % inverted
    
    % right heel-sacrum distance
    Rheel=-(y_RHE-y_OPSIS);
    % right toe-sacrum distance
    Rtoe=(y_RTO-y_OPSIS); % inverted
    
    %findpeaks/valleys left leg Events
    [Lpks,flhs]=findpeaks(Lheel); %[peaks, Frames] left heel strike
    figure; findpeaks(Lheel);
    xlabel('frame');
    ylabel('left heel strike');
    Lhstimes=(flhs-1)/FR; % left heel strike times
    
    [Lvlys,flto]=findpeaks(Ltoe); %[valleys, Frames] left toe off
    figure; findpeaks(Ltoe);
    xlabel('frame');
    ylabel('left toe off');
    Ltofftimes=(flto-1)/FR; % left toe off times
    
    %findpeaks- right leg Events
    [Rpks,frhs]=findpeaks(Rheel); %[peaks, Frames] right heel strike
    figure; findpeaks(Rheel);
    xlabel('frame');
    ylabel('right heel strike');
    Rhstimes=(frhs-1)/FR; % right heel strike times
    
    [Rvlys,frto]=findpeaks(Rtoe); %[valleys, Frames] right toe off
    figure; findpeaks(Rtoe);
    xlabel('frame');
    ylabel('right toe off');
    Rtofftimes=(frto-1)/FR; % right toe off times
    
    end

    flhs = (flhs + frame_start-1)/FR;
    flto = (flto + frame_start-1)/FR;
    frhs = (frhs + frame_start-1)/FR;
    frto = (frto + frame_start-1)/FR;




end

