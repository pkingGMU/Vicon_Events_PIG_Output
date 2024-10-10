function [sub_LRsteps,sub_avs] = averages(spatiotemps,jointAngs,kinetics)
%Averages Calculates average values for spatiotemporals, joint angles, and
%kinetics. See readme for full details of output. 

% average across legs and save averages in a big subject
        av_speed = mean(spatiotemps(:,1),'omitnan');
        av_cadence = mean(spatiotemps(:,2),'omitnan');
        av_Lsteplength = mean(spatiotemps(:,3),'omitnan');
        av_Rsteplength = mean(spatiotemps(:,4),'omitnan');
        av_steplength = mean([spatiotemps(:,3);spatiotemps(:,4)],'omitnan');
        av_Lstepwidth = mean(spatiotemps(:,5),'omitnan');
        av_Rstepwidth = mean(spatiotemps(:,6),'omitnan');
        av_stepwidth = mean([spatiotemps(:,5);spatiotemps(:,6)],'omitnan');
        av_Lsteptime_s = mean(spatiotemps(:,7),'omitnan');
        av_Rsteptime_s = mean(spatiotemps(:,8),'omitnan');
        av_steptime_s = mean([spatiotemps(:,7);spatiotemps(:,8)],'omitnan');
        av_Lsteptime_pct = mean(spatiotemps(:,9),'omitnan');
        av_Rsteptime_pct = mean(spatiotemps(:,10),'omitnan');
        av_steptime_pct = mean([spatiotemps(:,9);spatiotemps(:,10)],'omitnan');
        av_Lsinglesupp = mean(spatiotemps(:,11),'omitnan');
        av_Rsinglesupp = mean(spatiotemps(:,12),'omitnan');
        av_singlesupp = mean([spatiotemps(:,11);spatiotemps(:,12)],'omitnan');
        av_doublesupp = mean(spatiotemps(:,13),'omitnan');
        av_Lstancetime_pct = mean(spatiotemps(:,14),'omitnan');
        av_Rstancetime_pct = mean(spatiotemps(:,15),'omitnan');
        av_stancetime_pct = mean([spatiotemps(:,14);spatiotemps(:,15)],'omitnan');
        av_Lswingtime_pct = mean(spatiotemps(:,16),'omitnan');
        av_Rswingtime_pct = mean(spatiotemps(:,17),'omitnan');
        av_swingtime_pct = mean([spatiotemps(:,16);spatiotemps(:,17)],'omitnan');

        av_Lpf_stance = mean(jointAngs(:,1),'omitnan');
        av_Rpf_stance = mean(jointAngs(:,2),'omitnan');
        av_pf_stance = mean([jointAngs(:,1); jointAngs(:,2)],'omitnan');
        av_Ldf_stance = mean(jointAngs(:,3),'omitnan');
        av_Rdf_stance = mean(jointAngs(:,4),'omitnan');
        av_df_stance = mean([jointAngs(:,3); jointAngs(:,4)],'omitnan');
        av_Lkneeflex_stance = mean(jointAngs(:,5),'omitnan');
        av_Rkneeflex_stance = mean(jointAngs(:,6),'omitnan');
        av_kneeflex_stance = mean([jointAngs(:,5); jointAngs(:,6)],'omitnan');
        av_Lhipflex_stance = mean(jointAngs(:,7),'omitnan');
        av_Rhipflex_stance = mean(jointAngs(:,8),'omitnan');
        av_hipflex_stance = mean([jointAngs(:,7); jointAngs(:,8)],'omitnan');
        av_Lpf_swing = mean(jointAngs(:,9),'omitnan');
        av_Rpf_swing = mean(jointAngs(:,10),'omitnan');
        av_pf_swing = mean([jointAngs(:,9); jointAngs(:,10)],'omitnan');
        av_Ldf_swing = mean(jointAngs(:,11),'omitnan');
        av_Rdf_swing = mean(jointAngs(:,12),'omitnan');
        av_df_swing = mean([jointAngs(:,11); jointAngs(:,12)],'omitnan');
        av_Lkneeflex_swing = mean(jointAngs(:,13),'omitnan');
        av_Rkneeflex_swing = mean(jointAngs(:,14),'omitnan');
        av_kneeflex_swing = mean([jointAngs(:,13); jointAngs(:,14)],'omitnan');
        av_Lhipflex_swing = mean(jointAngs(:,15),'omitnan');
        av_Rhipflex_swing = mean(jointAngs(:,16),'omitnan');
        av_hipflex_swing = mean([jointAngs(:,15); jointAngs(:,16)],'omitnan');

        av_LRR = mean(kinetics(:,1),'omitnan');
        av_RRR = mean(kinetics(:,2),'omitnan');
        av_RR = mean([kinetics(:,1);kinetics(:,2)],'omitnan');
        av_LaGRF = mean(kinetics(:,3),'omitnan');
        av_RaGRF = mean(kinetics(:,4),'omitnan');
        av_aGRF = mean([kinetics(:,3); kinetics(:,4)],'omitnan');
        av_LvGRF = mean(kinetics(:,5),'omitnan');
        av_RvGRF = mean(kinetics(:,6),'omitnan');
        av_vGRF = mean([kinetics(:,6); kinetics(:,5)],'omitnan');
        av_LAnkMom = mean(kinetics(:,7),'omitnan');
        av_RAnkMom = mean(kinetics(:,8),'omitnan');
        av_AnkMom = mean([kinetics(:,8); kinetics(:,7)],'omitnan');
        av_LAnkPow = mean(kinetics(:,9),'omitnan');
        av_RAnkPow = mean(kinetics(:,10),'omitnan');
        av_AnkPow = mean([kinetics(:,10); kinetics(:,9)],'omitnan');
        av_LHipMom = mean(kinetics(:,11),'omitnan');
        av_RHipMom = mean(kinetics(:,12),'omitnan');
        av_HipMom = mean([kinetics(:,12); kinetics(:,11)],'omitnan');
        av_LHipPow = mean(kinetics(:,13),'omitnan');
        av_RHipPow = mean(kinetics(:,14),'omitnan');
        av_HipPow = mean([kinetics(:,14); kinetics(:,13)],'omitnan');
        
        sub_LRsteps = [av_speed av_cadence av_Lsteplength av_Rsteplength av_Lstepwidth av_Rstepwidth...
            av_Lsteptime_pct av_Rsteptime_pct av_Lsinglesupp av_Rsinglesupp av_doublesupp...
            av_Lstancetime_pct av_Rstancetime_pct av_Lswingtime_pct av_Rswingtime_pct...
            av_Lpf_stance av_Rpf_stance av_Ldf_stance av_Rdf_stance av_Lkneeflex_stance av_Rkneeflex_stance...
            av_Lhipflex_stance av_Rhipflex_stance av_Lpf_swing av_Rpf_swing av_Ldf_swing  av_Rdf_swing...
            av_Lkneeflex_swing av_Rkneeflex_swing av_Lhipflex_swing av_Rhipflex_swing...
            av_LRR av_RRR av_LaGRF av_RaGRF av_LvGRF av_RvGRF av_LAnkMom av_RAnkMom av_LAnkPow av_RAnkPow...
            av_LHipMom av_RHipMom av_LHipPow av_RHipPow];

        sub_avs = [av_speed av_cadence av_steplength av_stepwidth av_steptime_pct av_singlesupp av_doublesupp...
            av_stancetime_pct av_swingtime_pct av_pf_stance av_df_stance av_kneeflex_stance av_hipflex_stance...
            av_pf_swing av_df_swing av_kneeflex_swing av_hipflex_swing av_RR av_aGRF av_vGRF av_AnkMom av_AnkPow...
            av_HipMom av_HipPow];




end