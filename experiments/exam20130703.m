% exam20130703
% use the result of exp20130613 to calculate NSS
% 
%

fprintf('Loading Fixations, GVBS Features, and Models...'); tic
load('../Output/storage/EXPALLFixations.mat'); % EXPALLFixations
load('../Output/storage/EXPALLFeatures.mat'); % ALLFeatures
load('../Output/storage/EXPfaceFeatures.mat'); % faceFeatures
load('../Result/EXP20130613/EXP20130613_201306161433.mat');
load('../Resource/sampleInfo/sampleInfoSaccade1.mat');
fprintf([num2str(toc), ' seconds \n']);

opt = Info;
order_fromfirst_ = opt.n_order_fromfirst;
NSS_score = cell(15,1);
opt.enable_angle=0;

for subjecti = 1:15
    testSaccadeImageIndex = 400:400;
    testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjecti);
    thresholdLength  =  opt.thresholdLength{opt.n_order_fromfirst};
    for compareSubjecti = 1:15
        fprintf('Fixation: %d, Model: %d \n',subjecti, compareSubjecti);
        info_tune = EXP_INDV_REGION_NOANGLE_ms6{compareSubjecti}.mInfo_tune{1};
        NSS_score{subjecti}{compareSubjecti} = testSaliencymap(opt, ...
                                                          ALLFeatures, faceFeatures, thresholdLength, info_tune.weight, testingsamles, order_fromfirst_);
    end
end
