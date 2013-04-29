%% all sample for training
% Divide into 6 regions
% Angle disabled

clear all
info = {};
info.time_stamp = datestr(now,'yyyymmddHHMM');
info.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');

%% ----------------- TEMPLATE -----------------------------
fprintf('Load EXPALLFixations, EXPALLFeatures...'); tic
load('../Output/storage/EXPALLFixations.mat'); % EXPALLFixations
load('../Output/storage/EXPALLFeatures.mat'); % ALLFeatures
load('../Output/storage/EXPfaceFeatures.mat'); % faceFeatures
fprintf([num2str(toc), ' seconds \n']);

opt = {};
opt.time_stamp = info.time_stamp;
opt.IMGS = './final_resize';
opt.minimize_scale = 6;
opt.width = 1366;
opt.height = 768;
opt.M = round(opt.height/opt.minimize_scale);
opt.N = round(opt.width/opt.minimize_scale);
M = opt.M;
N = opt.N;
tool = toolFunc(opt);

opt.th_near = tool.get_distance(1.0);
opt.th_far = tool.get_distance(4.0);
opt.u_sigma = tool.get_distance(1.0);

opt.rand_param = {};
%opt.discard_short_saccade = tool.get_distance(2);
opt.discard_short_saccade = -1;

opt.thresholdLength = {};
opt.thresholdAngle = {};
opt.thresholdAngleInit = {5, 8, 11, 14, 20, 57};
%opt.thresholdAngleInit = {6, 9, 12, 16, 22, 80};

opt_base = opt;
clear opt
%% ----------------- TEMPLATE -----------------------------

%% ----------------- SETTING -----------------------------
opt = opt_base;
opt.posisize = 50000;
opt.ngrate = 20;
opt.n_trial = 20;
opt.n_order_fromfirst = 1;
opt.thresholdLengthType = 's_uni'; %
opt.allAreTrainingSample = 1; %take all saccades to generate training samlple
opt_base = opt;
clear opt
%% ----------------- SETTING -----------------------------

info.opt_base = opt_base;


    for regioni = 6:6
    opt = opt_base;
    opt.n_region = regioni;
    opt.enable_angle = 0;
    fprintf('========================================================= angle: %d region: %d\n', opt.enable_angle, opt.n_region);
    RET = {};
    [RET.mInfo_tune, RET.mNSS_tune, RET.opt_ret] = calcMainAllSubject20130430(opt, EXPALLFixations, ALLFeatures, faceFeatures);
    EXP_INDV_REGION_NOANGLE_ms6{regioni} = RET;
    clear opt RET
    end


info.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS')
savefile = sprintf('../Output/storage/EXP20130430_angle0_region6_%s.mat', info.time_stamp);
save(savefile,'EXP_INDV_REGION_NOANGLE_ms6','info','-v7.3');