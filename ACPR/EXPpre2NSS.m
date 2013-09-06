load('../Output/storage/EXPALLFixations.mat'); % EXPALLFixations
load('../Output/storage/EXPALLFeatures.mat'); % ALLFeatures
load('../Output/storage/EXPfaceFeatures.mat'); % faceFeatures
load('../Result/EXP20130613/EXP20130613_201306161433.mat');
origin = zeros(15,60);
testSaccadeImageIndex = 301:400;
order_fromfirst_ = 1;
for subjecti = 1:15
    origin(subjecti,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';
end

for regioni = 1:6   
    origin(:,regioni*10) = 0;
end
orgNSS = cell(1,15);
for subjecti = 1:15
    opt = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.opt_ret;
   
        testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjecti);
        thresholdLength  =  opt.thresholdLength;
        weight = origin(subjecti,:)';
        orgNSS{subjecti} = testSaliencymap(opt, ALLFeatures, faceFeatures, thresholdLength, weight, testingsamles, order_fromfirst_);
end

load('../Result/EXP20130617/EXP20130617_201307312210.mat');

dataBase = zeros(15,54);
noFace = [];
for subjecti = 1:15   
    dataBase(subjecti,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';
end

for regioni = 1:6
    rangeL = (regioni-1)*9+1;
    rangeR = regioni*9;
    noFace = [noFace, dataBase(:,rangeL:rangeR)];
    noFace = [noFace, zeros(15,1)];
end

nofNSS = cell(1,15);
for subjecti = 1:15
    opt = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.opt_ret;
   
        testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjecti);
        thresholdLength  =  opt.thresholdLength;
        weight = noFace(subjecti,:)';
        nofNSS{subjecti} = testSaliencymap(opt, ALLFeatures, faceFeatures, thresholdLength, weight, testingsamles, order_fromfirst_);
end

A = zeros(15,1);
B = zeros(15,1);
for subjecti = 1:15
    A(subjecti) = mean(orgNSS{subjecti});
    B(subjecti) = mean(nofNSS{subjecti});
end

p = signrank(A,B);