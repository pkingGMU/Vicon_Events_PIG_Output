
%%*************************************************************************
%%Detect Events and Move Events To Ensure Continuous Kinetic Data for Clear Foot Strikes 
%%*************************************************************************
%Code to automatically detect events in overground normal walking trials based on marker data. 
%Code to import gait evets and re-define 'Foot Off' (frame - 1) and 'Foot Strike' (frame + 1) if necessary to re-import into Nexus 2.3 (Vicon) 
%
% Created 01/15/2017 by Matt Terza 
%
% Last Modified: 1/24/2017
%
%This code is meant to automaticallly detect gait events based on kinematic
%and marker data in lieu of force plate event detection. 
%
% Comands of interest:
%       ClearAllEvents
%       CreateAnEvent
%       GetEvent
%       GetModelOutput
%       GetSubjectName
%       GetTrialName
%       GetTrajectory
%
%**************************************************************************
%      
%**************************************************************************

%% ***** Clear all variables, close all windows, clear command window *****
clear all;
close all;
clc;

%%** Add Subfolders****************************************************
%%=========================================================================
%%ADD PATHS TO FOLDERS THAT CONTAIN RELEVANT PROGRAMS
%%=========================================================================
addpath('C:\Program Files (x86)\Vicon\Nexus2.12\SDK\Matlab')
addpath(genpath('S:\Biomech\Student\Terza\Matlab Files'))
mm=msgbox('Navigate to the MIND IN MOTION (U01 Grant) folder in the next pop-up box');
waitfor(mm)
mim_root = uigetdir(pwd,'Select project folder');

addpath(genpath([mim_root '\Matlab Codes'])) % adds relevant matlab folders


%%**********************Select Directory****************************

%Project Selection Dialogue

  

type=questdlg('Run which functionality?','Program Selection','Event Detect', 'Kinetic Mover','Both','Both');
kinetic2=0;
eventdet=0;
if strcmp(type,'Both')==1
    eventdet=1;
    kinetic2=1;
    
    type2=questdlg('Clear Existing Events?','Yes', 'Yes','No','No');
    clear_events=0;
    if strcmp(type2,'Yes')
        clear_events=1;
    end
elseif strcmp(type,'Event Detect')==1
    eventdet=1;
    kinetic2=0;
    
    type2=questdlg('Clear Existing Events?','Yes', 'Yes','No','No');
    clear_events=0;
    if strcmp(type2,'Yes')
        clear_events=1;
    end
elseif strcmp(type,'Kinetic Mover')==1
    eventdet=0;
    kinetic2=1;
end


%% *************  Connect to Vicon and Pull Trial Parameters **************
% Don't forget to set your Matlab path!

%   Connect to Vicon system:

[files]=uipickfiles('Type',{ '*.c3d',   'C3D Files'  });
filenum=length(files);
for gg=1:filenum
    clearvars -except files filenum vicon gg clear_events kinetic2 eventdet
    vicon = ViconNexus();
    [pname, name, ext]=fileparts(cell2mat(files(gg)));%breaks done the current file name into path filename(w/o extension) and the extension
    pname=strcat(pname,'\')%this adds a backslash to the file path so that the last text is seen as a folder
    fname=strcat(name,ext)%File name with the extension
    cd(pname);%This sets the current directory to the folder that the current file came from
    pathfilename=cell2mat(files(filenum)); %This variable contains a string of the whole file path and file name  
    vicon.OpenTrial(strcat(pname,name),30);
%     vicon.RunPipeline('PIG dynamic only','',30)
%   List of possible Vicon commands to work with:
% vicon.DisplayCommandList()
%   How to use the command:
% vicon.DisplayCommandHelp('CommandGoesHere')
%   To see what Inputs/Outputs are associated with a command use:
% help 'CommandGoesHere'

%   Import the subject name and trial number
SubjectName = vicon.GetSubjectNames;
TrialName = vicon.GetTrialName;
vicon.RunPipeline('PIG dynamic only','',30)

if eventdet==1
%Get Marker Trajectory Data
[rheex, rheey, rheez]=vicon.GetTrajectory(SubjectName{1},'RHEE');
[lheex, lheey, lheez]=vicon.GetTrajectory(SubjectName{1},'LHEE');
[rankx, ranky, rankz]=vicon.GetTrajectory(SubjectName{1},'RANK');
[lankx, lanky, lankz]=vicon.GetTrajectory(SubjectName{1},'LANK');
[rasisx, rasisy, rasisz]=vicon.GetTrajectory(SubjectName{1},'RASI');
[lasisx, lasisy, lasisz]=vicon.GetTrajectory(SubjectName{1},'LASI');
[rtoex, rtoey, rtoez]=vicon.GetTrajectory(SubjectName{1},'RTOE');
[ltoex, ltoey, ltoez]=vicon.GetTrajectory(SubjectName{1},'LTOE');

%Find Crop Frame
    [mag_start, crop_frame_start]=find(rheex~=0,1,'first');
    [mag_end, crop_frame_end]=find(rheex~=0,1,'last');
    
    %Filter
    filtermrkdata=1;%This variable only exists here right now
    if filtermrkdata==1
        %Filtering marker data
        tempcoordata1 = [rheex', rheey', rheez', lheex', lheey', lheez', rankx', ...
            ranky', rankz', lankx', lanky', lankz', rasisx', rasisy', rasisz',...
            lasisx', lasisy', lasisz', rtoex', rtoey', rtoez', ltoex', ltoey', ltoez'];
        tempcoordata=tempcoordata1(crop_frame_start:crop_frame_end,:);
        camrate=120;
        cutoff = 30; %indicates cutoff frequency
        [b,a] = butter(4, cutoff/(camrate/2), 'low'); %4th-order Butterworth low-pass filter
        coordata = filtfilt(b,a,tempcoordata); %redefines 'coordata' as filtered marker data
        rheex= coordata(:,1);
        rheey= coordata(:,2);
        rheez= rheez(crop_frame_start:crop_frame_end);%leaves these unfiltered because it makes the event placement more accurate
        lheex= coordata(:,4);
        lheey= coordata(:,5);
        lheez= lheez(crop_frame_start:crop_frame_end);%leaves these unfiltered because it makes the event placement more accurate
        rankx= coordata(:,7);
        ranky= coordata(:,8);
        rankz= coordata(:,9);
        lankx= coordata(:,10);
        lanky= coordata(:,11);
        lankz= coordata(:,12);
        rasisx= coordata(:,13);
        rasisy= coordata(:,14);
        rasisz=coordata(:,15);
        lasisx=coordata(:,16);
        lasisy=coordata(:,17);
        lasisz=coordata(:,18);
        rtoex= coordata(:,19);
        rtoey= coordata(:,20);
        rtoez= coordata(:,21);
        ltoex= coordata(:,22);
        ltoey= coordata(:,23);
        ltoez= coordata(:,24);
    end

% %Get Model Data
[lhip]=vicon.GetModelOutput(SubjectName{1},'LHipAngles');
lhipx=lhip(1,:)';
[rhip]=vicon.GetModelOutput(SubjectName{1},'RHipAngles');
rhipx=rhip(1,:)';
[lakj]=vicon.GetModelOutput(SubjectName{1},'LAnkleAngles');
lakjx=lakj(1,:)';
[rakj]=vicon.GetModelOutput(SubjectName{1},'RAnkleAngles');
rakjx=rakj(1,:)';

%Get Any Existing Events
%   Read in events from Nexus
[RightFS, Offset.RightFS]= vicon.GetEvents( SubjectName{1}, 'Right', 'Foot Strike' );
[RightFO, Offset.RightFO]= vicon.GetEvents( SubjectName{1}, 'Right', 'Foot Off' );
[LeftFS, Offset.LeftFS]= vicon.GetEvents( SubjectName{1}, 'Left', 'Foot Strike' );
[LeftFO, Offset.LeftFO]= vicon.GetEvents( SubjectName{1}, 'Left', 'Foot Off' );
[General, Offset.General]= vicon.GetEvents( SubjectName{1}, 'General', 'General' );

[Events.RightFS] = double(RightFS)+ceil(120*Offset.RightFS);
[Events.RightFO] = double(RightFO)+ceil(120*Offset.RightFO);
[Events.LeftFS]  = double(LeftFS)+ceil(120*Offset.LeftFS);
[Events.LeftFO]  = double(LeftFO)+ceil(120*Offset.LeftFO);
[Events.General] = double(General)+ceil(120*Offset.General);;
    

%Call Event Detection Sub Program
[rhs, rto, lhs, lto, gen]=Event_Detection_Overground_forVICON_VA(rheey,rheex, rheez,...
    lheex, lheey, lheez, rankx, ranky, rankz, lankx, lanky, lankz, rtoex, rtoey,...
    rtoez, ltoex, ltoey, ltoez, rasisx, rasisy, lasisx,lasisy, lakjx, rakjx, ...
    rhipx,  lhipx)

rhs=rhs+crop_frame_start-1;
lhs=lhs+crop_frame_start-1;
rto=rto+crop_frame_start-1;
lto=lto+crop_frame_start-1;


%Clear Events that May Already Exist
if clear_events==1
    vicon.ClearAllEvents
end

%Create New Events Based On Matlab Algorithm: 
%!!!!Need to determine if another event is already in the vicinity.
g=1;
%search window size for general events.
win=10;
if max(rhs)>0
    for j=1:length(rhs)
        vicon.CreateAnEvent(SubjectName{1},'Right','Foot Strike',rhs(j),0);
        for t=1:length(Events.General)
            if Events.General(t)>rhs(j)-win && Events.General(t)<rhs(j)+win
                gen(g)=rhs(j);
                g=g+1;
            end
        end    
    end
end
if max(lhs)>0
    for j=1:length(lhs)
        vicon.CreateAnEvent(SubjectName{1},'Left','Foot Strike',lhs(j),0);
        for t=1:length(Events.General)
            if Events.General(t)>lhs(j)-win && Events.General(t)<lhs(j)+win
                gen(g)=lhs(j);
                g=g+1;
            end
        end
    end
end
if max(rto)>0
    for j=1:length(rto)
        vicon.CreateAnEvent(SubjectName{1},'Right','Foot Off',rto(j),0);
        for t=1:length(Events.General)
            if Events.General(t)>rto(j)-win && Events.General(t)<rto(j)+win
                gen(g)=rto(j);
                g=g+1;
            end
        end
    end
end
if max(lto)>0
    for j=1:length(lto)
        vicon.CreateAnEvent(SubjectName{1},'Left','Foot Off',lto(j),0);
        for t=1:length(Events.General)
            if Events.General(t)>lto(j)-win && Events.General(t)<lto(j)+win
                gen(g)=lto(j);
                g=g+1;
            end
        end
    end
end

if max(gen)>0
    for j=1:length(gen)
        vicon.CreateAnEvent(SubjectName{1},'General','General',gen(j),0);
    end
end

vicon.SaveTrial(30)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%KINETIC EVENT MOVER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%In case the event detection was not run then it will create an empty gen
%event for the IF statement for entrance into the kinetic mover code
if exist('gen','var')==0
    [General, Offset.General]= vicon.GetEvents( SubjectName{1}, 'General', 'General' );
    [Events.General] = double(General)+ceil(120*Offset.General);
    gen=Events.General;
end

if kinetic2==1 && isempty(gen)==0 % if there are not general events don't bother running the kinetic mover
    if eventdet==0
        vicon.RunPipeline('PIG dynamic only','',30)
    end
%%Edit Event Location for Kinetic Data Based On Clear Force Strikes

%   List of possible Vicon commands to work with:
% vicon.DisplayCommandList()
%   How to use the command:
% vicon.DisplayCommandHelp('CommandGoesHere')
%   To see what Inputs/Outputs are associated with a command use:
% help 'CommandGoesHere'

%   Import the subject name and trial number

move_TO=0;
%Run this loop a max of (4) times in effort to move events to generate
%continuous model data.
for kk=1:4 
%Variable to check if events were changed by this iteration.
events_moved=0;%0 Starting value and will not change if no events are moved and will exit the loop at the end of this iteration even if kk does not equal 4.
    
%   Read in events from Nexus
[RightFS, Offset.RightFS]= vicon.GetEvents( SubjectName{1}, 'Right', 'Foot Strike' );
[RightFO, Offset.RightFO]= vicon.GetEvents( SubjectName{1}, 'Right', 'Foot Off' );
[LeftFS, Offset.LeftFS]= vicon.GetEvents( SubjectName{1}, 'Left', 'Foot Strike' );
[LeftFO, Offset.LeftFO]= vicon.GetEvents( SubjectName{1}, 'Left', 'Foot Off' );
[General, Offset.General]= vicon.GetEvents( SubjectName{1}, 'General', 'General' );

[Events.RightFS] = double(RightFS)+ceil(120*Offset.RightFS);
[Events.RightFO] = double(RightFO)+ceil(120*Offset.RightFO);
[Events.LeftFS]  = double(LeftFS)+ceil(120*Offset.LeftFS);
[Events.LeftFO]  = double(LeftFO)+ceil(120*Offset.LeftFO);
[Events.General] = double(General)+ceil(120*Offset.General);


%   Import data for the left & right ankle moments to check if data exists.
ModelOutput = {'RAnkleMoment', 'LAnkleMoment'};
for i = 1:length(ModelOutput) 
    [ModelData.Raw.(ModelOutput{i}), ModelData.Exists.(ModelOutput{i})] = vicon.GetModelOutput(SubjectName{1},ModelOutput{i});
end

%%  ****************   Plot Model Data to check for gaps   ****************
%   Ankle Moment Data (Left and Right)
figure(1)
subplot(2,1,1)
hold on
H = area(ModelData.Exists.LAnkleMoment*2000); set(H,'FaceColor',[1,0.8,0.8]);
plot(ModelData.Raw.LAnkleMoment(1,:), 'k'); title('Left Ankle Moment')
hold off
subplot(2,1,2)
hold on
H2 = area(ModelData.Exists.RAnkleMoment*2000); set(H2,'FaceColor',[0.8,1,0.8]);
plot(ModelData.Raw.RAnkleMoment(1,:), 'k'); title('Right Ankle Moment')
hold off

%%  ***************    Edit Events and Re-write to Nexus    ***************
%   Clear all old events - there isn't a command to clear them individually :(
vicon.ClearAllEvents
Clean_Event=0;%Initialize Clean Event Variable
%   Check to see if a 'Foot Off' coincides with Ankle Moment data
%   If not, move the 'Foot Off' event forward one frame. 
if kk==1 && move_TO==1
    new_Events.RightFO = (Events.RightFO - 1);
    new_Events.LeftFO = (Events.LeftFO - 1);
else
    for i = 1:length(Events.RightFO);
        %Check to see if the event to be moved corresponds to a general event
        %indicating a clean foot strike.
        for p=1:length(Events.General)
            if Events.RightFO(1,i)==Events.General(1,p)
                Clean_Event=1;
            end
        end
        if (ModelData.Exists.RAnkleMoment(1,(Events.RightFO(1,i))) ~=1) && Clean_Event==1
            new_Events.RightFO(1,i) = (Events.RightFO(1,i) - 1);
            events_moved=events_moved+1;
        else
            new_Events.RightFO(1,i) = (Events.RightFO(1,i));
        end
        Clean_Event=0;%Reset Clean Event Variable;
    end
end

for i = 1:length(Events.LeftFO);
        %Check to see if the event to be moved corresponds to a general event
        %indicating a clean foot strike.
        for p=1:length(Events.General)
            if Events.LeftFO(1,i)==Events.General(1,p)
                Clean_Event=1;
            end
        end
        if (ModelData.Exists.LAnkleMoment(1,(Events.LeftFO(1,i))) ~=1) && Clean_Event==1
            new_Events.LeftFO(1,i) = (Events.LeftFO(1,i) - 1);
            events_moved=events_moved+1;
        else
            new_Events.LeftFO(1,i) = (Events.LeftFO(1,i));
        end
        Clean_Event=0;%Reset Clean Event Variable;
end
new_R_FO_Events = (new_Events.RightFO)';
new_L_FO_Events = (new_Events.LeftFO)';

%   Create new Foot Off events
j = 1; 
for i = 1:length(new_R_FO_Events)
    vicon.CreateAnEvent( SubjectName{1}, 'Right', 'Foot Off', new_R_FO_Events(j,1), 0.0);
    j = j+1;
end

k = 1; 
for i = 1:length(new_L_FO_Events)
    vicon.CreateAnEvent( SubjectName{1}, 'Left', 'Foot Off', new_L_FO_Events(k,1), 0.0);
    k = k+1;
end


%   Check to see if a 'Foot Strike' coincides with Ankle Moment data
%   If not, move the 'Foot Strike' event forward one frame. 
for i = 1:length(Events.RightFS);
        %Check to see if the event to be moved corresponds to a general event
        %indicating a clean foot strike.
        for p=1:length(Events.General)
            if Events.RightFS(1,i)==Events.General(1,p)
                Clean_Event=1;
            end
        end    
        if (ModelData.Exists.RAnkleMoment(1,(Events.RightFS(1,i))) ~=1) && Clean_Event==1
            new_Events.RightFS(1,i) = (Events.RightFS(1,i) + 1);
            events_moved=events_moved+1;
        else
            new_Events.RightFS(1,i) = (Events.RightFS(1,i));
        end
    Clean_Event=0;%Reset Clean Event Variable;
end

for i = 1:length(Events.LeftFS);
        %Check to see if the event to be moved corresponds to a general event
        %indicating a clean foot strike.
        for p=1:length(Events.General)
            if Events.LeftFS(1,i)==Events.General(1,p)
                Clean_Event=1;
            end
        end    
        if (ModelData.Exists.LAnkleMoment(1,(Events.LeftFS(1,i))) ~=1) && Clean_Event==1
            new_Events.LeftFS(1,i) = (Events.LeftFS(1,i) + 1);
            events_moved=events_moved+1;
        else
            new_Events.LeftFS(1,i) = (Events.LeftFS(1,i));
        end
        Clean_Event=0;%Reset Clean Event Variable;
end

%**************************************************************************
% Do we need to include a test to make sure that one frame is enough?
%**************************************************************************

new_R_FS_Events = (new_Events.RightFS)';
new_L_FS_Events = (new_Events.LeftFS)';

%   Create new Foot Strike Events
m = 1; 
for i = 1:length(new_R_FS_Events)
    vicon.CreateAnEvent( SubjectName{1}, 'Right', 'Foot Strike', new_R_FS_Events(m,1), 0.0);
    m = m+1;
end

n = 1; 
for i = 1:length(new_L_FS_Events)
    vicon.CreateAnEvent( SubjectName{1}, 'Left', 'Foot Strike', new_L_FS_Events(n,1), 0.0);
    n = n+1;
end


%   Create new General Events (In the updated locations to match the new FO and FS events)
good_events = [new_R_FS_Events;new_L_FS_Events;new_R_FO_Events;new_L_FO_Events];
new_General_Events = sort([intersect(good_events, Events.General);intersect(good_events, (Events.General + 1));intersect(good_events, (Events.General - 1))]);

g = 1; 
for i = 1:length(new_General_Events)
    vicon.CreateAnEvent( SubjectName{1}, 'General', 'General', new_General_Events(g,1), 0.0);
    g = g+1;
end

%If no events were moved then exit the loop prematurely.
if events_moved==0
    break
end

r=1;
if kk==4
    display(strcat('For ', fname,' the events and/or labeling is super jacked up. Seriously who processed this?'))
    Errors{r}=fname;
    r=r+1;
end

%%Run Dynamic Plug In Gait to create new model outputs and then re-check
%%for continuity in the next iteration of the foor loop.
vicon.RunPipeline('PIG dynamic only','',30)
end

    vicon.SaveTrial(30)
%     vicon.RunPipeline('Filter Model and Export All','',30)
%     vicon.SaveTrial(30)
else
    %vicon.RunPipeline('Filter Model and Export All','',30)
    vicon.SaveTrial(30)
end
end




