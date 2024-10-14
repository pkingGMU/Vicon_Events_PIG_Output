% Gait Analysis Code for R01 Prelim Data

% calculates:
% Speed (m/s)
% Step length (averaged across both legs) (heel to heel)  
% Step width (averaged across both legs) (heel to heel) 
% Plantarflexion @ toe-off (averaged across both legs) from PIG  
% Peak aGRF in last 50% of stance phase 
% Redistribution ratio (ratio of +ve ankle and hip work, 0 is fully about ankle 2 is fully about hip)

% Some important notes:
% code is written so subjects are stored in one root folder with each
% subject having their own sub-folder.
% Plug-in-gait output should be as a ".xlsx" file

% code is set up so you can batch process either overground walking or treadmill walking
% if you want to switch between, this requires re-running the code.


% SDSU LAB: X = ML, Y = AP, Z = UP
% written by Frankie Wade, Ph.D. Fall 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear all
clc

% Select operating system for file path slash direction
choice = questdlg('Are you using a Mac or Windows system?', ...
    'Select Operating System', ...
    'Mac', 'Windows', 'Cancel', 'Mac');

% Handle the response
switch choice
    case 'Mac'
        slash_dir = '/';
    case 'Windows'
        slash_dir = '\';
    otherwise
        error('Operation canceled by the user.');
end


% Set file paths
% add core code to path
waitfor(msgbox("Select your main project folder (i.e., where your code and data subfolders are kept)."));

core_dir = uigetdir;
addpath(core_dir);
addpath([core_dir slash_dir 'Code']);

% add data directory
waitfor(msgbox("Select your main data folder."));

root_data_dir = uigetdir; % select your primary data folder

cd(root_data_dir);



% If the user cancels uigetdir, it returns 0
if root_data_dir == 0
    error('Operation canceled by the user.');
end

waitfor(msgbox("Select the primary code folder (i.e., where your code is kept)"));
code_dir = uigetdir;
addpath(genpath(code_dir));



% Ask if you are doing overground or treadmill analysis
choice = questdlg('Is this treadmill or overground walking?', ...
    'Select Gait Type ', ...
    'Treadmill', 'Overground', 'Cancel', 'Treadmill');

% Handle the response
switch choice
    case 'Treadmill'
        % If treadmill - use SDSU code
        type = {'Treadmill'};


        waitfor(msgbox("Select your treadmill data folder."));

        data_dir = uigetdir; % select your primary data folder

        cd(data_dir);

    case 'Overground'
        % If overground - use UF code
        type = {'Overground'};
         waitfor(msgbox("Select your overground data folder."));
        data_dir = uigetdir; % select your primary data folder

        cd(data_dir);
    otherwise
        error('Operation canceled by the user.');
end


% Select subjects to analyze

% one subject or all subjects? (Select subjects to run)
% this is set up so every subject has its own folder
d = dir();
fn = {d.name};
[sub_list_num,tf] = listdlg('PromptString',{'Select subjects to analyze'},...
    'SelectionMode','multiple','ListString',fn);

% Check if the user selected any subjects
if tf == 0
    error('No subjects selected. Operation canceled.');
end

% assign subject list number to folder name
sub_folder = fn(sub_list_num);

choice = questdlg('Which axis is anterioposterior for your lab?', ...
    'Select Axis ', ...
    'X', 'Y', 'Cancel', 'Y');

% Handle the response
switch choice
    case 'X'
        % If AP direction is along x
        APcol = 1;
    case 'Y'
        % If AP direction is along y
        APcol = 2;
    otherwise
        error('Operation canceled by the user.');
end

% Preallocate final tables:
nRows = length(sub_list_num);

sub_varNames = {'SubID','Trial','Speed','Cadence','L_StepLength','R_StepLength',...
    'L_StepWidth','R_StepWidth','L_StepTime_pct','R_StepTime_pct','L_SingleSupport','R_SingleSupport',...
    'DoubleSupport','L_StanceTime','R_StanceTime','L_SwingTime','R_SwingTime',...
    'L_Plantarflexion_stance','R_Plantarflexion_stance','L_Dorsiflexion_stance','R_Dorsiflexion_stance','L_KneeFlexion_stance','R_KneeFlexion_stance',...
    'L_HipFlexion_stance','R_HipFlexion_stance','L_Plantarflexion_swing','R_Plantarflexion_swing','L_Dorsiflexion_swing','R_Dorsiflexion_swing',...
    'L_KneeFlexion_swing','R_KneeFlexion_swing','L_HipFlexion_swing','R_HipFlexion_swing',...
    'L_RR','R_RR','L_aGRF','R_aGRF','L_vGRF','R_vGRF','L_AnkleMoment','R_AnkleMoment','L_AnklePower','R_AnklePower',...
    'L_HipMoment','R_HipMoment','L_HipPower','R_HipPower'};
for i = 1:length(sub_varNames)-2
    jj{1,i} = 'double';
end

sub_varTypes =[{'string','string'} jj];
sub_tab = table('Size',[nRows, length(sub_varTypes)],'VariableTypes',sub_varTypes,'VariableNames',sub_varNames);


av_varNames = {'SubID','Trial','Speed','Cadence','StepLength','StepWidth','StepTime','SingleSupport','DoubleSupport',...
    'StanceTime', 'SwingTime','Plantarflexion_stance','Dorsiflexion_stance','KneeFlexion_stance','HipFlexion_stance',...
    'Plantarflexion_swing','Dorsiflexion_swing','KneeFlexion_swing','HipFlexion_swing','RR','aGRF','vGRF','AnkleMoment',...
    'AnklePower','HipMoment','HipPower'};
for i = 1:length(av_varNames)-2
    ll{1,i} = 'double';
end
av_varTypes =[{'string','string'} ll];

av_tab = table('Size',[nRows, length(av_varTypes)],'VariableTypes',av_varTypes,'VariableNames',av_varNames);

for each_subject = 1:length(sub_list_num)
    sub_name = sub_folder{each_subject};
    % Construct the path to the subject's folder
    subject_path = [data_dir slash_dir sub_folder{each_subject}];

    % Check if the folder exists before navigating to it
    if isfolder(subject_path)
        % Navigate to that subject folder
        cd(subject_path);
    else
        warning(['Folder does not exist: ', subject_path]);
        %continue;  % Skip to the next subject if the folder doesn't exist
    end

    % what trials do you want to analyze? (Select trials)
    f = dir("*.xlsx");
    fn = {f.name};
    [trial_list_num,tf] = listdlg('PromptString',{'Select trials to analyze for subject' sub_name},...
        'SelectionMode','multiple','ListString',fn);

    % Check if the user selected any trials
    if tf == 0
        warning(['No trials selected for subject ', sub_folder{each_subject}, '. Skipping to next subject.']);
        %continue;
    end


    % assign trial list number to trial name
    trials = fn(trial_list_num);

    % Loop through each selected trial
    for each_trial = 1:length(trials)
        % Construct the full path to the file
        trial_file = [subject_path slash_dir trials{each_trial}];

        % Load the trial data

        [active_data,active_text] = xlsread(trial_file); % rows are not the same between these two arrays so make sure you account for that in your indexing


        % define gait events

        % Find Gait Events & Extract Gait Event Data
        event_text_rows = find(strcmp(active_text,'Events')==1)+3: find(strcmp(active_text,'Devices')==1)-2;
        event_text = active_text(event_text_rows,2:3);
        event_data = active_data(event_text_rows - 1,4);
        camrate = active_data(strcmp(active_text(:,1),'Events')==1,1); % in frames per second

        if strcmp(type{:},'Treadmill')==1
            [rhs, rto, lhs, lto, all_events]= getGaitEvents(event_text, event_data,type,camrate);
        elseif strcmp(type{:},'Overground')==1
            [rhs,rto,lhs,lto,gen,all_events]= getGaitEvents(event_text, event_data,type,camrate);
        end

        % Define Gait Cycles & extract trajectory data for those rose: lhs = 1 rto = 2 rhs = 3 lto = 4
        % find marker coordinate data
        coordataline = find(strcmp(active_text(:,1),'Trajectories'))+4;%Start line for marker data
        coordatalineend = find(isnan(active_data(coordataline:end,1))==1,1,'first')+coordataline-2;%End line for marker data
        if isempty(coordatalineend)==1% This is to check to make sure this isn't the last data section
            coordatalineend=length(active_data(:,1));
        end
        coordata=active_data(coordataline:coordatalineend,:);%Select coordinate data
        coortext = active_text(coordataline - 2,:);
        frame_number=coordata(:,1);

        gaitcycles = getGaitCycles(frame_number,all_events,lhs,rhs);

        % extract marker coordinates for relevant foot markers
        [lheeAP, lheeML, rheeAP, rheeML, LToe_AP] = defineFootMarkers(coortext,coordata,APcol);

        % Define direction of travel

        %if toe marker is more positive than heel
        if strcmp(type{1},'Treadmill')==1
            if LToe_AP(1,1)>lheeAP(1,1)
                direction = -1;
            else
                direction = 1;
            end
        else
            if LToe_AP(1,1)>lheeAP(1,1)
                direction = 1;
            else
                direction = -1;
            end
        end



        % extract Dynamic Plug in Gait Model Outputs
        modelrows = find(strcmp(active_text(:,1),'Model Outputs'));
        model_text = active_text(modelrows+2,:);
        moddatstart = modelrows+4;
        allnan = find(isnan(active_data(:,1)));
        moddatend = allnan(find(allnan>moddatstart,1))-1;
        model_data = active_data(moddatstart:moddatend,:);
        sub_loc = find(strcmp(active_text(:,1),'Subject'));
        subID = string(active_text(sub_loc(1,1)+1,1));


        % For each gait cycle:
        for g = 1:length(gaitcycles)
            frames = gaitcycles{g};
            [rowMatch,~]=ismember(coordata(:,1),frames,'rows');
            traj_rows = find(rowMatch);
            [modrowMatch,~]=ismember(model_data(:,1),frames,'rows');
            mod_rows = find(modrowMatch);
            if strcmp(type{:},'Treadmill')==1
                spatiotemps(g,:) = TreadmillSpatiotemporals(frames,lheeAP(traj_rows),lheeML(traj_rows),rheeAP(traj_rows),rheeML(traj_rows),all_events,camrate,direction);
                % spatiotemporals structure:
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

                jointAngs(g,:) = TreadmillJointAngs(subID,frames,model_text,model_data(mod_rows,:),all_events,APcol,direction);
                % NEEDS OPPOSITE LIMB SPITTING OUT DURING ITS STANCE

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
                % col 12: Right peak dorsiflexion during swing (+ve)
                % col 13: Left peak knee flexion during swing (+ve)
                % col 14: Right peak knee flexion during swing (+ve)
                % col 15: Left peak hip flexion during swing (+ve)
                % col 16: Right peak hip flexion during swing (+ve)

                kinetics(g,:) = TreadmillKinetics(subID,frames,camrate,model_text,model_data(mod_rows,:),all_events,APcol);
                % col 1 = redistribution ratio (0 = all about ankle, 2 = all about hip)
                % % col 2 & 3 = peak anterior ground reaction forces (L&R) in % bodyweight
                % col 4 & 5 = peak vertical ground reaction forces (L&R) in % bodyweight
                % col 6 & 7 = peak plantarflexion ankle moment (L&R) in Nm/kg
                % col 8 & 9 = peak plantarflexion ankle power (L&R) in W/kg
                % col 10 & 11 = peak hip  moment (L&R) in last 50% gait cycle in
                % Nm/kg
                % col 12 & 13 =  peak hip power (L&R) in last 50% gait cycle in W/kg

            elseif strcmp(type{:},'Overground')==1
                
                spatiotemps(g,:) = OvergroundSpatiotemporals(frames,lheeAP(traj_rows),lheeML(traj_rows),rheeAP(traj_rows),rheeML(traj_rows),all_events,camrate,direction);
                % spatiotemporals structure:
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

                jointAngs(g,:) = OvergroundJointAngs(subID,frames,model_text,model_data(mod_rows,:),all_events,APcol,direction);

                if gen(:,1)~=0
                    all_events_nogen = all_events(all_events(:, 2) ~= 5, :);

                    % Find if a general event matches any frames for this gait cycle

                    [isMatch] = ismember(frames,gen(:,1)); %returns array where gen matches frames
                    if any(isMatch) ==1
                        matchingIndices = find(isMatch); %
                        % create an array of force events within this gait
                        % cycle that can be used to pull force plate data
                        for ev = 1:length(matchingIndices)
                            ev_frame=frames(matchingIndices(ev));
                            force_event(ev,1) = all_events_nogen(find(all_events_nogen(:,1)==ev_frame),2);
                        end

                        [kinetics] = OvergroundKinetics(subID,frames,camrate,model_text,model_data(mod_rows,:),all_events,force_event,APcol);

                    else
                        kinetics(g,:) = NaN(1,14);
                    end
                else
                    kinetics(g,:) = NaN(1,14);
                end
            end

            %%% MoS - Added by Patrick
            mos(g,:) = MarginOfStability(subID, frames, camrate, model_text,model_data(mod_rows, :), coordata, coortext, all_events, APcol);

        end
        
        %%% Mos Table - Added by Patrick
        mos_table = array2table(mos);
        mos_vars = {'L_MoS_AP_hs', 'R_MoS_AP_hs', 'L_MoS_ML_hs', 'R_MoS_ML_hs', 'L_MoS_AP_to', 'R_MoS_AP_to', 'L_MoS_ML_to', 'R_MoS_ML_to'};
        mos_table.Properties.VariableNames = mos_vars;
        

        % average across legs and save averages in a big subject
        [sub_LRsteps,sub_avs] = averages(spatiotemps,jointAngs,kinetics);

        % save all step data in a trial table
        sub_full_gc = array2table([spatiotemps jointAngs kinetics]);
        LR_names = {'Speed','Cadence','L_StepLength','R_StepLength',...
            'L_StepWidth','R_StepWidth','L_StepTime_s','R_StepTime_s','L_StepTime_pct','R_StepTime_pct','L_SingleSupport','R_SingleSupport',...
            'DoubleSupport','L_StanceTime','R_StanceTime','L_SwingTime','R_SwingTime',...
            'L_Plantarflexion_stance','R_Plantarflexion_stance','L_Dorsiflexion_stance','R_Dorsiflexion_stance','L_KneeFlexion_stance','R_KneeFlexion_stance',...
            'L_HipFlexion_stance','R_HipFlexion_stance','L_Plantarflexion_swing','R_Plantarflexion_swing','L_Dorsiflexion_swing','R_Dorsiflexion_swing',...
            'L_KneeFlexion_swing','R_KneeFlexion_swing','L_HipFlexion_swing','R_HipFlexion_swing',...
            'L_RR','R_RR','L_aGRF','R_aGRF','L_vGRF','R_vGRF','L_AnkleMoment','R_AnkleMoment','L_AnklePower','R_AnklePower',...
            'L_HipMoment','R_HipMoment','L_HipPower','R_HipPower'};

        sub_full_gc.Properties.VariableNames = LR_names;
        sub_step_tab1 = array2table(sub_LRsteps);
        sub_step_tab1.Properties.VariableNames = sub_varNames(3:end);

        temp = strsplit(trials{each_trial},'.');
        trial_nam = temp{1};
        sub_step_deets = cell2table({subID, trial_nam});
        sub_step_deets.Properties.VariableNames = {'SubID','Trial'};

        sub_tab2 = [sub_step_deets sub_step_tab1];
        sub_tab = [sub_tab;sub_tab2];

        av_tab1 = array2table(sub_avs);
        av_tab1.Properties.VariableNames = av_varNames(3:end);

        av_tab2 = [sub_step_deets av_tab1];
        av_tab = [av_tab;av_tab2];

        gc_fn = append(subID, '_', trial_nam, '_EachGaitCycleData.xlsx');
        processed_data = append(root_data_dir,slash_dir,'Processed Data',slash_dir,type{1});
        cd(processed_data)
        writetable(sub_full_gc,gc_fn);
        clearvars -except av_tab sub_tab slash_dir root_data_dir APcol...
            code_dir core_dir data_dir each_subject each_trial sub_folder...
            sub_list_num sub_loc sub_varTypes subID subject_path trial_file...
            trial_list_num trials type sub_varNames av_varNames processed_data...
            trial_nam mos

    end % end trial loop

    % save averages across legs per trial in a subject table
    cd(processed_data)
    sub_fn = append(subID,'_EachStep.xlsx');
    writetable(sub_tab,sub_fn);

end % end subject loop

% add each subject & trial averages to a big table
processed_data_dir= append(root_data_dir,slash_dir,'Processed Data');

% look to see if processed data output already exists
cd(processed_data_dir)
p_files = dir("*.xlsx");

% if it does, ask if you want to add to it or overwrite it

if strcmp(type{1},'Treadmill')==1
    if exist('Treadmill_All_Subjects.xlsx','file')==2
        ow = questdlg("Do you want to overwrite the data in Treadmill_All_Subjects.xlsx?",'Overwrite?','No');
        switch ow
            case 'Yes'
                check = questdlg("Are you sure you want to overwrite the data in Treadmill_All_Subjects.xlsx?","Check overwrite.","No");
                switch check
                    case 'Yes'
                        writetable(av_tab,'Treadmill_All_Subjects.xlsx')
                    case No
                        ad = questdlg("Do you want to add to the data in Treadmill_All_Subjects.xlsx?",'Overwrite?','Yes');
                        switch ad
                            case 'Yes'
                                old = readtable("Treadmill_All_Subjects.xlsx");
                                new = [old;av_tab];
                                writetable(new,'Treadmill_All_Subjects.xlsx')
                            case 'No'
                                warning('User canceled saving data')
                        end
                end

            case 'No'
                ad = questdlg("Do you want to add to the data in Treadmill_All_Subjects.xlsx?",'Overwrite?','Yes');
                switch ad
                    case 'Yes'
                        old = readtable("Treadmill_All_Subjects.xlsx");
                        new = [old;av_tab];
                        writetable(new,'Treadmill_All_Subjects.xlsx')
                    case 'No'
                        warning('User canceled saving data')
                end

        end
    else
        writetable(av_tab,'Treadmill_All_Subjects.xlsx')
    end
elseif strcmp(type{1},'Overground')==1
    if exist('Overground_All_Subjects.xlsx','file')==2

        ow = questdlg("Do you want to overwrite the data in Overground_All_Subjects.xlsx?",'Overwrite?','No');
        switch ow
            case 'Yes'
                check = questdlg("Are you sure you want to overwrite the data in Overground_All_Subjects.xlsx?","Check overwrite.","No");
                switch check
                    case 'Yes'
                        writetable(av_tab,'Overground_All_Subjects.xlsx')
                    case 'No'
                        ad = questdlg("Do you want to add to the data in Overground_All_Subjects.xlsx?",'Overwrite?','Yes');
                        switch ad
                            case 'Yes'
                                old = readtable("Overground_All_Subjects.xlsx");
                                new = [old;av_tab];
                                writetable(new,'Overground_All_Subjects.xlsx')
                            case 'No'
                                warning('User canceled saving data')
                        end
                end

            case 'No'
                ad = questdlg("Do you want to add to the data in Overground_All_Subjects.xlsx?",'Overwrite?','Yes');
                switch ad
                    case 'Yes'
                        old = readtable("Overground_All_Subjects.xlsx");
                        new = [old;av_tab];
                        writetable(new,'Overground_All_Subjects.xlsx')
                    case 'No'
                        warning('User canceled saving data')
                end

        end


    end

else
    writetable(av_tab,'Overground_All_Subjects.xlsx')
end




