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

function r01_process(selection, choice, fr)

   

    global r01

    gait_exists = 0;
    gait_force_exists = 0;

    % Check GUI flags
    if strcmp(r01.gui.trial_panel_gait_check.String, 'Gait Events: Run')
        gait_exists = 1;
    elseif strcmp(r01.gui.trial_panel_gait_force_check.String, 'Gait Events & Force: Run')
        gait_force_exists = 1;
    else
        disp('Cannot run because gait events need to be detected by either Gait or Gait Force');
        add2log(0,"Cannot run because gait events need to be detected by either Gait or Gait Force", 1,0,0,0,0,1);

        return;
    end

    % Directory setup
    root_data_dir = pwd;
    code_dir = fullfile(pwd, 'Functions', 'R01_Analysis');
    addpath(genpath(code_dir));

    % Set data_dir based on user choice and gait detection status
    switch choice
        case 'Treadmill'
            type = {'Treadmill'};
            if gait_force_exists
                data_dir = fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Treadmill');
            elseif gait_exists
                data_dir = fullfile(pwd, 'Output', 'Gait_Events', 'Treadmill');
            end
        case 'Overground'
            type = {'Overground'};
            if gait_force_exists
                data_dir = fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Overground');
            elseif gait_exists
                data_dir = fullfile(pwd, 'Output', 'Gait_Events', 'Overground');
            end
        otherwise
            error('Operation canceled by the user.');
    end

    % Unique list of subjects
    subject_names = unique(selection(:, 2));
    
    choice = r01.project_xy;
    
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
    nRows = length(subject_names);
    
    sub_varNames = {'SubID','Trial','Speed','Cadence','L_StepLength','R_StepLength',...
        'L_StepWidth','R_StepWidth','L_StepTime_pct','R_StepTime_pct','L_SingleSupport','R_SingleSupport',...
        'DoubleSupport','L_StanceTime','R_StanceTime','L_SwingTime','R_SwingTime',...
        'L_Plantarflexion_stance','R_Plantarflexion_stance','L_Dorsiflexion_stance','R_Dorsiflexion_stance','L_KneeFlexion_stance','R_KneeFlexion_stance',...
        'L_HipFlexion_stance','R_HipFlexion_stance','L_Plantarflexion_swing','R_Plantarflexion_swing','L_Dorsiflexion_swing','R_Dorsiflexion_swing',...
        'L_KneeFlexion_swing','R_KneeFlexion_swing','L_HipFlexion_swing','R_HipFlexion_swing',...
        'L_RR','R_RR','L_aGRF','R_aGRF','L_vGRF','R_vGRF','L_AnkleMoment','R_AnkleMoment','L_AnklePower','R_AnklePower',...
        'L_HipMoment','R_HipMoment','L_HipPower','R_HipPower','LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
    
    for i = 1:length(sub_varNames)-2
        jj{1,i} = 'double';
    end
    
    sub_varTypes =[{'string','string'} jj];
    sub_tab_total = table('Size',[0, length(sub_varTypes)],'VariableTypes',sub_varTypes,'VariableNames',sub_varNames);
    
    av_varNames = {'SubID','Trial','Speed','Cadence','StepLength','StepWidth','StepTime','SingleSupport','DoubleSupport',...
        'StanceTime', 'SwingTime','Plantarflexion_stance','Dorsiflexion_stance','KneeFlexion_stance','HipFlexion_stance',...
        'Plantarflexion_swing','Dorsiflexion_swing','KneeFlexion_swing','HipFlexion_swing','RR','aGRF','vGRF','AnkleMoment',...
        'AnklePower','HipMoment','HipPower','LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
    for i = 1:length(av_varNames)-2
        ll{1,i} = 'double';
    end
    av_varTypes =[{'string','string'} ll];
    
    av_tab = table('Size',[0, length(av_varTypes)],'VariableTypes',av_varTypes,'VariableNames',av_varNames);
    
    for each_subject = 1:height(subject_names)

        sub_tab = table('Size',[0, length(sub_varTypes)],'VariableTypes',sub_varTypes,'VariableNames',sub_varNames);


        sub_name = subject_names{each_subject};
        % Construct the path to the subject's folder
        
        subject_path = fullfile(data_dir, sub_name);
        
        % Check if the folder exists before navigating to it
        % if isfolder(subject_path)
        %     % Navigate to that subject folder
        %     cd(subject_path);
        % else
        %     warning(['Folder does not exist: ', subject_path]);
        %     %continue;  % Skip to the next subject if the folder doesn't exist
        % end
    
        % what trials do you want to analyze? (Select trials)
        % f = dir("*.xlsx");
        % fn = {f.name};
        fn_idx = find(ismember(selection(:,2), sub_name));
    
        fn = selection(fn_idx, 3);
    
        % [trial_list_num,tf] = listdlg('PromptString',{'Select trials to analyze for subject' sub_name},...
        %     'SelectionMode','multiple','ListString',fn);
    
        % Check if the user selected any trials
        % if tf == 0
        %     warning(['No trials selected for subject ', subject_names{each_subject}, '. Skipping to next subject.']);
        %     continue;
        % end
    
    
        % assign trial list number to trial name
        trials = fn;

        
    
        % Loop through each selected trial
        for each_trial = 1:height(trials)
            clear active_data active_text coordataline coordatalineend event_data event_text event_text_rows frame_number 
            % Construct the full path to the file
            %trial_file = [subject_path slash_dir trials{each_trial}];
            

            % Load the trial data
            try

                trial_file = fullfile(subject_path, strcat(regexprep(trials{each_trial}, ' ', '_'), '_events.xlsx'));
            
                mem_dir = dir(trial_file);
                file_size = mem_dir.bytes / (1024^2);
                limit = 200;
    
                if file_size > 150
                    clear active_data active_text
                    disp("File To Big")
                    continue
                end
            % [active_data,active_text] = xlsread(trial_file); % rows are not the same between these two arrays so make sure you account for that in your indexing
            [active_data,active_text, ~] = xlsread(trial_file); % rows are not the same between these two arrays so make sure you account for that in your indexing
            catch
                clear active_data active_text
                disp("File not Found")
                continue
            end
            
            
         
    
            % Find Gait Events & Extract Gait Event Data
            event_text_rows = find(strcmp(active_text,'Events')==1)+3: find(strcmp(active_text,'Devices')==1)-2;
            event_text = active_text(event_text_rows,2:3);
            event_data = active_data(event_text_rows - 1,4);
            camrate = active_data(strcmp(active_text(:,1),'Events')==1,1); % in frames per second
    
            if strcmp(type{:},'Treadmill')==1
                [rhs, ~, lhs, ~, all_events]= getGaitEvents(event_text, event_data,type,camrate);
            elseif strcmp(type{:},'Overground')==1
                [rhs,~,lhs,~,gen,all_events]= getGaitEvents(event_text, event_data,type,camrate);
            end

            event_col = all_events(:,2);
            patterns = {[1 2 3 4], [3 4 1 2]};
      
            is_match = false;

            for i = 1:length(patterns)
                pattern = patterns{i};
                len = length(pattern);
                
                % Repeat pattern to match length of col
                repeated = repmat(pattern(:), ceil(length(event_col)/len), 1);
                repeated = repeated(1:length(event_col));
                
                % Check if column matches the pattern
                if isequal(event_col(:), repeated)
                    is_match = true;
                    disp(['Matches pattern: ', mat2str(pattern)]);
                    break;
                end
            end
            
            if ~is_match
                disp('No matching pattern found.');
                continue
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

            try
            
            gaitcycles = getGaitCycles(frame_number,all_events,lhs,rhs);

            catch
                continue
            end

            if isempty(gaitcycles)
                disp(strcat('Need more than 1 gait cycle', sub_name));
                add2log(0,strcat('Need more than 1 gait cycle', sub_name), 1,0,0,0,0,1);
                continue
            end
    
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

            if isempty(modelrows)
                disp("Failed finding Model Outputs")
                continue
            end

            model_text = active_text(modelrows+2,:);
            moddatstart = modelrows+4;
            allnan = find(isnan(active_data(:,1)));
            moddatend = allnan(find(allnan>moddatstart,1))-1;
            model_data = active_data(moddatstart:moddatend,:);
            %sub_loc = find(strcmp(active_text(:,1),'Subject'));
            subID = sub_name;
            % subID = string(active_text(sub_loc(1,1)+1,1));
            clear active_data
            clear active_text
            
    
    
            % For each gait cycle:
            for g = 1:length(gaitcycles)

                try
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
                    
                    %%% UNCOMMENT HERE FOR KINETICS
        
                    % kinetics(g,:) = TreadmillKinetics(subID,frames,camrate,model_text,model_data(mod_rows,:),all_events,APcol);

                    try
                        kinetics(g,:)= TreadmillKinetics(subID,frames,camrate,model_text,model_data(mod_rows,:),all_events,APcol);
                    catch
                        disp("Missing kinetic info")
                        kinetics(g,:) = NaN(1,14);
                    end
                    % col 1 = redistribution ratio (0 = all about ankle, 2 = all about hip)
                    % % col 2 & 3 = peak anterior ground reaction forces (L&R) in % bodyweight
                    % col 4 & 5 = peak vertical ground reaction forces (L&R) in % bodyweight
                    % col 6 & 7 = peak plantarflexion ankle moment (L&R) in Nm/kg
                    % col 8 & 9 = peak plantarflexion ankle power (L&R) in W/kg
                    % col 10 & 11 = peak hip  moment (L&R) in last 50% gait cycle in
                    % Nm/kg
                    % col 12 & 13 =  peak hip power (L&R) in last 50% gait cycle in W/kg
                    mos(g,:)= MarginOfStability(subID,frames,camrate,model_text,model_data(mod_rows,:),coordata(mod_rows,:),coortext, all_events,APcol);
    
                    % col 1: LMoS_AP
                    % col 2; RMoS_AP
                    % col 3: LMoS_ML
                    % col 4: RMoS_ML
    
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
    
                    mos(g,:)= MarginOfStability(subID,frames,camrate,model_text,model_data(mod_rows,:),coordata(mod_rows,:),coortext, all_events,APcol);
                    
                    
    
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
                            try
                                [kinetics] = OvergroundKinetics(subID,frames,camrate,model_text,model_data(mod_rows,:),all_events,force_event,APcol);
                            catch
                                disp("Missing kinetic info")
                                kinetics(g,:) = NaN(1,14);
                            end
                        else
                            kinetics(g,:) = NaN(1,14);
                        end
                    else
                        kinetics(g,:) = NaN(1,14);
                    end
                end

                catch

                    disp("gait cycle failed")
                    continue

                end
    
            end

            try
    
            % average across legs and save averages in a big subject
            [sub_LRsteps,sub_avs] = averages(spatiotemps,jointAngs,kinetics);
            av_LMoS_AP_hs = mean(mos(:,1));
            av_RMoS_AP_hs = mean(mos(:,2));
            av_LMoS_ML_hs = mean(mos(:,3));
            av_RMoS_ML_hs = mean(mos(:,4));
            av_LMoS_AP_to = mean(mos(:,5));
            av_RMoS_AP_to = mean(mos(:,6));
            av_LMoS_ML_to = mean(mos(:,7));
            av_RMoS_ML_to = mean(mos(:,8));
            %mos = [L_MoS_AP_hs R_MoS_AP_hs L_MoS_ML_hs R_MoS_ML_hs L_MoS_AP_to R_MoS_AP_to L_MoS_ML_to R_MoS_ML_to];
    
            sub_mos = array2table([av_LMoS_AP_hs av_RMoS_AP_hs av_LMoS_ML_hs av_RMoS_ML_hs av_LMoS_AP_to av_RMoS_AP_to av_LMoS_ML_to av_RMoS_ML_to]);
            sub_mos.Properties.VariableNames = {'LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
            
            % Check if missing a row of kinetics
            if height(kinetics) ~= height(spatiotemps)
                kinetics(height(kinetics) + 1, :) = 0;
            end


            % save all step data in a trial table
            sub_full_gc = array2table([spatiotemps jointAngs kinetics mos]);
            LR_names = {'Speed','Cadence','L_StepLength','R_StepLength',...
                'L_StepWidth','R_StepWidth','L_StepTime_s','R_StepTime_s','L_StepTime_pct','R_StepTime_pct','L_SingleSupport','R_SingleSupport',...
                'DoubleSupport','L_StanceTime','R_StanceTime','L_SwingTime','R_SwingTime',...
                'L_Plantarflexion_stance','R_Plantarflexion_stance','L_Dorsiflexion_stance','R_Dorsiflexion_stance','L_KneeFlexion_stance','R_KneeFlexion_stance',...
                'L_HipFlexion_stance','R_HipFlexion_stance','L_Plantarflexion_swing','R_Plantarflexion_swing','L_Dorsiflexion_swing','R_Dorsiflexion_swing',...
                'L_KneeFlexion_swing','R_KneeFlexion_swing','L_HipFlexion_swing','R_HipFlexion_swing',...
                'L_RR','R_RR','L_aGRF','R_aGRF','L_vGRF','R_vGRF','L_AnkleMoment','R_AnkleMoment','L_AnklePower','R_AnklePower',...
                'L_HipMoment','R_HipMoment','L_HipPower','R_HipPower', 'LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
            sub_full_gc.Properties.VariableNames = LR_names;
            sub_step_tab1 = array2table(sub_LRsteps);
            sub_step_tab1.Properties.VariableNames = sub_varNames(3:end-8);
    
            temp = strsplit(trials{each_trial},'.');
            trial_nam = temp{1};
            sub_step_deets = cell2table({subID, trial_nam});
            sub_step_deets.Properties.VariableNames = {'SubID','Trial'};
    
            sub_tab2 = [sub_step_deets sub_step_tab1 sub_mos];
            sub_tab = [sub_tab;sub_tab2];
            sub_tab_total = [sub_tab_total;sub_tab2];
    
            av_tab1 = array2table(sub_avs);
            av_tab1.Properties.VariableNames = av_varNames(3:end-8);
    
            av_tab2 = [sub_step_deets av_tab1 sub_mos];
            av_tab = [av_tab;av_tab2];
    
            
    
    
            %MoS_Tab = [sub_step_deets sub_mos];
    
            gc_fn = append(subID, '_', trial_nam, '_EachGaitCycleData.xlsx');
            processed_data = fullfile(root_data_dir, 'Output', 'R01_Analysis', type{1}, subID, trial_nam);
            
            if ~exist(processed_data, 'dir')
                mkdir(processed_data);  % Create the temporary folder if it doesn't exist
            end

            processed_data_file = fullfile(processed_data, gc_fn);
        
            
            writetable(sub_full_gc, processed_data_file);
            clearvars -except av_tab sub_tab sub_tab_total slash_dir root_data_dir APcol...
                code_dir core_dir data_dir each_subject each_trial subject_names...
                sub_list_num sub_loc sub_varTypes subID subject_path trial_file...
                trial_list_num trials type sub_varNames av_varNames processed_data...
                trial_nam sub_name selection 
            catch
                disp("Trial Failed")
            end
    
        end % end trial loop
    
        % save averages across legs per trial in a subject table
        sub_fn = append(subID,'_EachStep.xlsx');
        subject_names_output = fullfile(root_data_dir, 'Output', 'R01_Analysis', type{1}, subID, sub_fn);
        writetable(sub_tab,subject_names_output);

        clearvars sub_tab
        clear active_data active_text coordate coordataline coordatalineend coortext event_data event_text event_text_rows frame_number 

    
    end % end subject loop

    clear active_data active_text coordate coordataline coordatalineend coortext event_data event_text event_text_rows frame_number 
    
    % add each subject & trial averages to a big table
    
    processed_data_dir = fullfile(root_data_dir, 'Output', 'R01_Analysis');

    if ~exist(processed_data_dir, 'dir')
        mkdir(processed_data_dir);  % Create the temporary folder if it doesn't exist
    end
    sub_total_fn = append('Total','_EachStep.xlsx');
    sub_total_folder_output = fullfile(root_data_dir, 'Output', 'R01_Analysis', type{1}, sub_total_fn);
    writetable(sub_tab_total,sub_total_folder_output);

    
    
    
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




    cd(root_data_dir);

    


end



