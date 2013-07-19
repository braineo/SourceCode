%% ACPR EXP 1
% calculate NSS for individual model and generic model

load('../Output/storage/EXPALLFeatures.mat'); % ALLFeatures
load('../Output/storage/EXPALLFixations.mat'); % EXPALLFixations
load('../Output/storage/EXPfaceFeatures.mat'); % faceFeatures

load('../Result/EXP20130613/EXP20130613_201306161433.mat');
individualNSS = zeros(1,15);
for subjectNG = 1:15
    opt = EXP_INDV_REGION_NOANGLE_ms6{subjectNG}.opt_ret;
    info_tune = EXP_INDV_REGION_NOANGLE_ms6{subjectNG}.mInfo_tune{1};
    order_fromfirst_ = 1;
    testSaccadeImageIndex = 1:100;
    testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjectNG);
    thresholdLength  =  opt.thresholdLength;
        % dirty code up there
    NSS_tune = testSaliencymap(opt, ALLFeatures, faceFeatures, thresholdLength, info_tune.weight, testingsamles, order_fromfirst_);
    individualNSS(subjectNG) = mean(NSS_tune);
end

load('../Result/ACPR/ACPR_EXP1_201307152257.mat');
genericNSS = zeros(1,15);
for subjectNG = 1:15
    opt = EXP_INDV_REGION_NOANGLE_ms6{subjectNG}.opt_ret;
    info_tune = EXP_INDV_REGION_NOANGLE_ms6{subjectNG}.mInfo_tune{1};
    order_fromfirst_ = 1;
    testSaccadeImageIndex = 1:100;
    testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjectNG);
    thresholdLength  =  opt.thresholdLength;
        % dirty code up there
    NSS_tune = testSaliencymap(opt, ALLFeatures, faceFeatures, thresholdLength, info_tune.weight, testingsamles, order_fromfirst_);
    genericNSS(subjectNG) = mean(NSS_tune);
end