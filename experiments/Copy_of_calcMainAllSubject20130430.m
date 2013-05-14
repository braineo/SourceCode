%% Main function of the project, calculating the weights
% return the result of training and NSS score for a single test subject
% parameter:
% opt_set: Setting up options
% saccadeData: saccade data of 15 subject view 400 pictures
% featureGBVS: GBVS saliency map
% faceFeature: Gaussian face feature
% subjectIndex: ID of test subject

% no random selection, use all saccades and all samples, no trail loop
function  [mInfo_tune, mNSS_tune, opt] = calcMainAllSubject20130430(opt_set, EXPALLFixations, featureGBVS, faceFeatures, sampleinfo, sampleinfoStat,subjecti)

load RandomSeed_20121220
opt = opt_set;
opt.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
M = opt.M;
N = opt.N;
tool = toolFunc(opt); % return distance on screen by angle? not really understand
%% initialize settings
positiveSampleSize = opt.posisize;
negativeSampleSize = zeros(1,6);

negativeSampleSize(1) = opt.posisize * opt.ngrate;
negRatio = negativeSampleSize(1)/sampleinfoStat{subjecti}.NegativeRegion(1);
for regioni = 2:6
    negativeSampleSize(regioni) = sampleinfoStat{subjecti}.NegativeRegion(regioni) * negRatio;
end
imgSize = size(sampleinfo{subjecti},2);
order_fromfirst = opt.n_order_fromfirst;

for triali = 1:opt.n_trial;
    fprintf('Start Calculation on Subject#%d, Trial#%d...\n',subjecti, triali);
    countNearAll = 0;
    countFarAll = 0;
    positiveSampleCount = zeros(1,6);
    negativeSampleCount = zeros(1,6);
    num_feat_A = 10; %total number of features
    sampleReadyFlag = zeros(1,12);
    if(opt.enable_angle)
        featurePixelValueNear = zeros(positiveSampleSize*opt.n_region, 3*num_feat_A*opt.n_region); % 3 directions, 10 features, n regions
        featurePixelValueFar = zeros(sum(negativeSampleSize),3*num_feat_A*opt.n_region);
    else
        featurePixelValueNear = zeros(positiveSampleSize*opt.n_region, num_feat_A*opt.n_region);
        featurePixelValueFar = zeros(sum(negativeSampleSize),num_feat_A*opt.n_region);
    end
    
    %% picture 1:370 training set, picture 371:400 test set
    % for every region, make a array storing all the sample then pick
    % randomly
            
    fprintf('Creating Feature Matrix...\n'); tic
    for regioni = 1:6
        allPositiveSampleInRegion = zeros(sampleinfoStat{subjecti}.PositiveRegion(regioni),8);
        allNegativeSampleInRegion = zeros(sampleinfoStat{subjecti}.NegativeRegion(regioni),8);
        posCount = 1;
        negCount = 1;
    for imgidx = 1:370
        
    if(ismember(imgidx, sampleinfoStat{subjecti}.EmptyCell))
        continue;
    elseif(isempty(sampleinfo{subjecti}{imgidx}{1}{regioni}))
        continue;
    else
        tmpPosSize = size(sampleinfo{subjecti}{imgidx}{1}{regioni},1);
        allPositiveSampleInRegion(posCount : posCount+tmpPosSize-1,:) = sampleinfo{subjecti}{imgidx}{1}{regioni};
        posCount = posCount + tmpPosSize;
        
        tmpNegSize = size(sampleinfo{subjecti}{imgidx}{2}{regioni},1);
        allNegativeSampleInRegion(negCount : negCount+tmpNegSize-1,:) = sampleinfo{subjecti}{imgidx}{2}{regioni};
        negCount = negCount + tmpNegSize;
    end
    end
    
    allPositiveSampleInRegion = allPositiveSampleInRegion(1:posCount-1,:);
    allNegativeSampleInRegion = allNegativeSampleInRegion(1:negCount-1,:);
    
    posSampleRandIdx = randperm(posCount-1);
    negSampleRandIdx = randperm(negCount-1);
    posSampleRandIdx = posSampleRandIdx(1:positiveSampleSize);
    negSampleRandIdx = negSampleRandIdx(1:negativeSampleSize(regioni));
    
    %% Postive Samples
    for i = posSampleRandIdx
        singleSample = allPositiveSampleInRegion(i,:);
        angleIndex = singleSample(8);
    
        sampleinfo{subjecti}{imgidx}{1}{regioni}(i,:)
        
        
        c1 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{1}{1}, [M N], 'bilinear');
        c2 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{1}{2}, [M N], 'bilinear');
        c3 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{1}{3}, [M N], 'bilinear');
        i1 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{2}{1}, [M N], 'bilinear');
        i2 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{2}{2}, [M N], 'bilinear');
        i3 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{2}{3}, [M N], 'bilinear');
        o1 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{3}{1}, [M N], 'bilinear');
        o2 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{3}{2}, [M N], 'bilinear');
        o3 = imresize(featureGBVS{singleSample(1)}.graphbase.scale_maps{3}{3}, [M N], 'bilinear');

        color = imresize(featureGBVS{singleSample(1)}.graphbase.top_level_feat_maps{1}, [M N], 'bilinear');
        intensity = imresize(featureGBVS{singleSample(1)}.graphbase.top_level_feat_maps{2}, [M N], 'bilinear');
        orientation = imresize(featureGBVS{singleSample(1)}.graphbase.top_level_feat_maps{3}, [M N], 'bilinear');
        face = imresize(faceFeatures{singleSample(1)}, [M N], 'bilinear');
        
        singleFeature = [c1(singleSample(3),singleSample(2)) c2(singleSample(3),singleSample(2)) c3(singleSample(3),singleSample(2))...
                                 i1(singleSample(3),singleSample(2)) i2(singleSample(3),singleSample(2)) i3(singleSample(3),singleSample(2))...
                                 o1(singleSample(3),singleSample(2)) o2(singleSample(3),singleSample(2)) o3(singleSample(3),singleSample(2)) face(singleSample(3),singleSample(2))];
                        if(opt.enable_angle)
                            featurePixelValueNear(countNearAll,num_feat_A*3*(regioni-1)+(angleIndex-1)*num_feat_A+1:num_feat_A*3*(regioni-1)+angleIndex*num_feat_A)=singleFeature(:);
                        else
                            featurePixelValueNear(countNearAll,num_feat_A*(regioni-1)+1:num_feat_A*regioni)=singleFeature(:);
                        end
        
        
      
            if(isempty(sampleinfo{subjecti}{imgidx}{1}{regioni}))
               continue;
            else
                
                for i = 1:size(sampleinfo{subjecti}{imgidx}{1}{regioni},1)
                    if(positiveSampleCount(regioni) >= positiveSampleSize)
                        sampleReadyFlag(regioni)=1;
                        break;
                    else
                        singleSample = sampleinfo{subjecti}{imgidx}{1}{regioni}(i,:);
                        positiveSampleCount(regioni) = positiveSampleCount(regioni) + 1;
                        countNearAll = countNearAll + 1;
                        angleIndex = singleSample(8);  
                        
                    end
                end
            end
        end
        %% Negative Samples
        for regioni = 1:6
            if(isempty(sampleinfo{subjecti}{imgidx}{2}{regioni}))
                
                 continue;
            else
                for i = 1:size(sampleinfo{subjecti}{imgidx}{2}{regioni},1)
                    if(negativeSampleCount(regioni) >= negativeSampleSize(regioni))
                        sampleReadyFlag(regioni+6)=1;
                        break;
                    else
                        singleSample = sampleinfo{subjecti}{imgidx}{2}{regioni}(i,:);
                        negativeSampleCount(regioni) = negativeSampleCount(regioni) + 1;
                        countFarAll = countFarAll + 1;
                        angleIndex = singleSample(8);  
                        singleFeature = [c1(singleSample(3),singleSample(2)) c2(singleSample(3),singleSample(2)) c3(singleSample(3),singleSample(2))...
                                 i1(singleSample(3),singleSample(2)) i2(singleSample(3),singleSample(2)) i3(singleSample(3),singleSample(2))...
                                 o1(singleSample(3),singleSample(2)) o2(singleSample(3),singleSample(2)) o3(singleSample(3),singleSample(2)) face(singleSample(3),singleSample(2))];
                        if(opt.enable_angle)
                            featurePixelValueFar(countFarAll,num_feat_A*3*(regioni-1)+(angleIndex-1)*num_feat_A+1:num_feat_A*3*(regioni-1)+angleIndex*num_feat_A)=singleFeature(:);
                        else
                            featurePixelValueFar(countFarAll,num_feat_A*(regioni-1)+1:num_feat_A*regioni)=singleFeature(:);
                        end
                    end
                end
            end
        end
    end
    if(sum(sampleReadyFlag) == 12)
        break;
    end
    end
    fprintf([num2str(toc), ' seconds \n']);
    
  
        %%  start to train
         
        featureMat = [featurePixelValueNear; featurePixelValueFar];
        
        labelMat = [ones(countNearAll, 1); zeros(countFarAll, 1)];
        
        fprintf('Training...\n'); tic
        info_tune = {};

        fprintf('|tune|');
        [m_,n_] = size(featureMat);
        [info_tune.weight,info_tune.resnorm,info_tune.residual,info_tune.exitflag,info_tune.output,info_tune.lambda]  =  lsqlin(featureMat, labelMat,-eye(n_,n_),zeros(n_,1));
        fprintf([num2str(toc), ' seconds \n']);

        clear featureMat labelMat

        if(order_fromfirst == 5) %% WTF?!?!
            order_fromfirst_ = 0;
        else
            order_fromfirst_ = order_fromfirst;
        end
        % generate test saccade samples, dirty code down here
        tmp = find(imgidx == imgIdxReorder);
        testSaccadeImageIndex = imgIdxReorder(tmp+1:end);
        testingsamles = getIndiviTestSamples(testSaccadeImageIndex, EXPALLFixations, opt, subjecti);
        thresholdLength  =  opt.thresholdLength;
        % dirty code up there
        NSS_tune = testSaliencymap(opt, featureGBVS, faceFeatures, thresholdLength, info_tune.weight, testingsamles, order_fromfirst_);
        mInfo_tune{triali} = info_tune;
        mNSS_tune{triali} = NSS_tune;
        clear info_tune
end

% opt.end_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
% time_stamp = datestr(now,'yyyymmddHHMMSS');
% savefile = sprintf('../Output/storage/EXP_%s_angle%dregion%dTestSub%d_%s.mat', ...
%                    opt.time_stamp, opt.enable_angle, opt.n_region, subjectIndex, time_stamp);
% save(savefile,'opt','mInfo_tune','-v7.3');