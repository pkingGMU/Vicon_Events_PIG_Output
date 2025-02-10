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

function mos_process(selectedFolders, selection, choice, fr)


    root_data_dir = pwd; % select your primary data folder
    code_dir = fullfile(pwd, 'Functions', 'Margin_Of_Stability');
    addpath(genpath(code_dir));
    

    % Handle the response
    switch choice
        case 'Treadmill'
            % If treadmill - use SDSU code
            type = {'Treadmill'};
            data_dir = fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Treadmill');
            
    
        case 'Overground'
            % If overground - use UF code
            type = {'Overground'};
            data_dir = fullfile(pwd, 'Output', 'Gait_Events_Strikes', 'Overground');
            

        otherwise
            error('Operation canceled by the user.');
    end
    
    % one subject or all subjects? (Select subjects to run)
    % this is set up so every subject has its own folder
    d = dir(data_dir);
    fn = {d.name};
    % Filter out '.' and '..' which represent current and parent directories
    fn = fn(~ismember(fn, {'.', '..', '.DS_Store'}));
    


    sub_list_num = selection;
    
    % assign subject list number to folder name
    sub_folder = fn(sub_list_num);
    
    choice = questdlg('Which axis is anterioposterior for your lab?', ...
        'Select Axis ', ...
        'X', 'Y', 'Cancel', 'Y');
    
    % Handle the response
    %%% NEED
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
    
    sub_varNames = {'SubID','Trial','LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
    
    for i = 1:length(sub_varNames)-2
        jj{1,i} = 'double';
    end
    
    sub_varTypes =[{'string','string'} jj];
    sub_tab = table('Size',[0, length(sub_varTypes)],'VariableTypes',sub_varTypes,'VariableNames',sub_varNames);
    
    
    av_varNames = {'SubID','Trial','LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
    for i = 1:length(av_varNames)-2
        ll{1,i} = 'double';
    end
    av_varTypes =[{'string','string'} ll];
    
    av_tab = table('Size',[0, length(av_varTypes)],'VariableTypes',av_varTypes,'VariableNames',av_varNames);
    
    for each_subject = 1:length(sub_list_num)
        sub_name = sub_folder{each_subject};
        % Construct the path to the subject's folder
        
        subject_path = fullfile(data_dir, sub_folder{each_subject});
        %subject_path = [data_dir slash_dir sub_folder{each_subject}];
    
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
            %trial_file = [subject_path slash_dir trials{each_trial}];
            trial_file = fullfile(subject_path, trials{each_trial});
            % Load the trial data
    
            [active_data,active_text] = xlsread(trial_file); % rows are not the same between these two arrays so make sure you account for that in your indexing
    
    
            % define gait events
    
            % Find Gait Events & Extract Gait Event Data
            event_text_rows = find(strcmp(active_text,'Events')==1)+3: find(strcmp(active_text,'Devices')==1)-2;
            event_text = active_text(event_text_rows,2:3);
            event_data = active_data(event_text_rows - 1,4);

            %%% NEED
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
            %%% NEED
            model_text = active_text(modelrows+2,:);
            moddatstart = modelrows+4;
            allnan = find(isnan(active_data(:,1)));
            moddatend = allnan(find(allnan>moddatstart,1))-1;
            
            model_data = active_data(moddatstart:moddatend,:);
            sub_loc = find(strcmp(active_text(:,1),'Subject'));

            %%% NEED
            subID = string(active_text(sub_loc(1,1)+1,1));
    
    
            % For each gait cycle:
            for g = 1:length(gaitcycles)

                %%% NEED
                frames = gaitcycles{g};
                [rowMatch,~]=ismember(coordata(:,1),frames,'rows');
                traj_rows = find(rowMatch);
                [modrowMatch,~]=ismember(model_data(:,1),frames,'rows');
                mod_rows = find(modrowMatch);
                if strcmp(type{:},'Treadmill')==1
                    
                    mos(g,:)= MarginOfStability(subID,frames,camrate,model_text,model_data(mod_rows,:),coordata(mod_rows,:),coortext, all_events,APcol);
    
                    % col 1: LMoS_AP
                    % col 2; RMoS_AP
                    % col 3: LMoS_ML
                    % col 4: RMoS_ML
    
                elseif strcmp(type{:},'Overground')==1
    
                
    
                    mos(g,:)= MarginOfStability(subID,frames,camrate,model_text,model_data(mod_rows,:),coordata(mod_rows,:),coortext, all_events,APcol);
    
    
                end
    
            end
    
            % average across legs and save averages in a big subject
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
            
            mos = array2table(mos);
            mos.Properties.VariableNames = {'LMoS_AP_hs','RMoS_AP_hs','LMoS_ML_hs','RMoS_ML_hs','LMoS_AP_to','RMoS_AP_to','LMoS_ML_to','RMoS_ML_to'};
    
            temp = strsplit(trials{each_trial},'.');
            trial_nam = temp{1};
            sub_step_deets = cell2table({subID, trial_nam});
            sub_step_deets.Properties.VariableNames = {'SubID','Trial'};
    
            sub_tab2 = [sub_step_deets sub_mos];
            sub_tab = [sub_tab;sub_tab2];
    
            
    
            
  
    
            
    
    
            %MoS_Tab = [sub_step_deets sub_mos];

            
    
            gc_fn = append(subID, '_', trial_nam, '_EachGaitCycleData.xlsx');
            processed_data = fullfile(root_data_dir, 'Output', 'Margin Of Stability', type{1});
            
            if ~exist(processed_data, 'dir')
                mkdir(processed_data);  % Create the temporary folder if it doesn't exist
            end

            processed_data_file = fullfile(processed_data, gc_fn);
        
            
            writetable(mos, processed_data_file);
            clearvars -except av_tab sub_tab slash_dir root_data_dir APcol...
                code_dir core_dir data_dir each_subject each_trial sub_folder...
                sub_list_num sub_loc sub_varTypes subID subject_path trial_file...
                trial_list_num trials type sub_varNames av_varNames processed_data...
                trial_nam
    
        end % end trial loop
    
        

        
        
        sub_fn = append(subID,'_EachStep.xlsx');
        sub_fn = fullfile(processed_data, sub_fn);
        writetable(sub_tab,sub_fn);
    
    end % end subject loop

    cd(root_data_dir);


end



