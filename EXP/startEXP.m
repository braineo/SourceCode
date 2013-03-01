clear all
fprintf('Load EXPALLFixations, EXPALLFeatures...'); tic
load('../storage/EXPALLFixations.mat'); % EXPALLFixations
load('../storage/EXPALLFeatures.mat'); % ALLFeatures
fprintf([num2str(toc), ' seconds \n']);

NSS_tuned0r = {};
NSS_tuned1r = {};
NSS_tuned2r = {};
NSS_flatr = {};
weightr = {};

for trial=1:10
[trainingdata, T_pos, T_neg, testingdata] = makeSample(EXPALLFixations);
[weight,resnorm,residual,exitflag,output,lambda] = testKyokai(ALLFeatures, T_pos, T_neg);
[NSS_tuned0, NSS_tuned1, NSS_tuned2, NSS_flat] = testMakeSaliencymap(ALLFeatures, weight, testingdata);

weightr{length(weightr)+1} = weight;
NSS_tuned0r{length(NSS_tuned0r)+1} = NSS_tuned0;
NSS_tuned1r{length(NSS_tuned1r)+1} = NSS_tuned1;
NSS_tuned2r{length(NSS_tuned2r)+1} = NSS_tuned2;
NSS_flatr{length(NSS_flatr)+1} = NSS_flat;
end

savefile = '../storage/startEXP.mat'
save(savefile, 'NSS_tuned0r','NSS_tuned1r','NSS_tuned2r', 'NSS_flatr','weightr', '-v7.3');

