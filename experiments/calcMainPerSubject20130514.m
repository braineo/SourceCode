%% Main function of the project, calculating the weights
% return the result of training and NSS score for a single test subject
% Random sampling algorithm: reservoir sampling
% parameter:
% opt_set: Setting up options
% saccadeData: saccade data of 15 subject view 400 pictures
% featureGBVS: GBVS saliency map
% faceFeature: Gaussian face feature
% subjectIndex: ID of test subject

% no random selection, use all saccades and all samples, no trail loop
function  [mInfo_tune, mNSS_tune, opt] = calcMainPerSubject20130514(opt_set, EXPALLFixations, featureGBVS, faceFeatures, sampleinfo, sampleinfoStat,subjecti)

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
        negativeSampleSize(regioni) = fix(sampleinfoStat{subjecti}.NegativeRegion(regioni) * negRatio);
    end

    order_fromfirst = opt.n_order_fromfirst;

    for triali = 1:opt.n_trial;
        fprintf('Start Calculation on Subject#%d, Trial#%d...\n',subjecti, triali);
        countNearAll = 0;
        countFarAll = 0;
        num_feat_A = 10; %total number of features
        if(opt.enable_angle)
            featurePixelValueNear = zeros(positiveSampleSize*opt.n_region, 3*num_feat_A*opt.n_region); % 3 directions, 10 features, n regions
            featurePixelValueFar = zeros(sum(negativeSampleSize),3*num_feat_A*opt.n_region);
        else
            featurePixelValueNear = zeros(positiveSampleSize*opt.n_region, num_feat_A*opt.n_region);
            featurePixelValueFar = zeros(sum(negativeSampleSize),num_feat_A*opt.n_region);
        end

        %% picture 1:370 training set, picture 371:400 test set

        fprintf('Randomly sampling...\n'); tic
        selectedPositiveSample = [];
        selectedNegativeSample = [];
        for regioni = 1:6
            selectedPositiveSampleInRegion = zeros(positiveSampleSize,8);
            selectedNegativeSampleInRegion = zeros(negativeSampleSize(regioni),8);
            posCount = 1;
            negCount = 1;

            posStat = [1,1]; %Marking searching status, [imgIndex, sampleIndex]
            negStat = [1,1];

            %% Random sampling positives samples
            while (posCount < positiveSampleSize)
                if(posStat(1) == 371)
                    break;
                end
                if(ismember(posStat(1), sampleinfoStat{subjecti}.EmptyCell))
                    posStat(1) = posStat(1) + 1;
                    continue;
                elseif(isempty(sampleinfo{subjecti}{posStat(1)}{1}{regioni}))
                    posStat(1) = posStat(1) + 1;
                    continue;
                else
                    selectedPositiveSampleInRegion(posCount,:) = sampleinfo{subjecti}{posStat(1)}{1}{regioni}(posStat(2),:);
                    posCount = posCount + 1;
                    if(posStat(2) == size(sampleinfo{subjecti}{posStat(1)}{1}{regioni},1))
                        posStat(1) = posStat(1) + 1;
                        posStat(2) = 1;
                    else
                        posStat(2) = posStat(2) + 1;
                    end
                end
                
            end

            while(1)
                if(posStat(1) == 371)
                    break;
                end
                if(ismember(posStat(1), sampleinfoStat{subjecti}.EmptyCell))
                    posStat(1) = posStat(1) + 1;
                    continue;
                elseif(isempty(sampleinfo{subjecti}{posStat(1)}{1}{regioni}))
                    posStat(1) = posStat(1) + 1;
                    continue;
                else
                randFactor = round((posCount - 1)*rand + 1);
                if(randFactor <= positiveSampleSize)
                    selectedPositiveSampleInRegion(randFactor,:) = sampleinfo{subjecti}{posStat(1)}{1}{regioni}(posStat(2),:);
                    posCount = posCount + 1;
                end
                end
                if(posStat(2) == size(sampleinfo{subjecti}{posStat(1)}{1}{regioni},1))
                    posStat(1) = posStat(1) + 1;
                    posStat(2) = 1;
                else
                    posStat(2) = posStat(2) + 1;
                end
                
            end

            %% Random sampling negative samples
            while (negCount < negativeSampleSize(regioni))
                if(negStat(1) == 371)
                    break;
                end
                if(ismember(negStat(1), sampleinfoStat{subjecti}.EmptyCell))
                    negStat(1) = negStat(1) + 1;
                    continue;
                elseif(isempty(sampleinfo{subjecti}{negStat(1)}{2}{regioni}))
                    negStat(1) = negStat(1) + 1;
                    continue;
                else
                    selectedNegativeSampleInRegion(negCount,:) = sampleinfo{subjecti}{negStat(1)}{2}{regioni}(negStat(2),:);
                    negCount = negCount + 1;
                    if(negStat(2) == size(sampleinfo{subjecti}{negStat(1)}{2}{regioni},1))
                        negStat(1) = negStat(1) + 1;
                        negStat(2) = 1;
                    else
                        negStat(2) = negStat(2) + 1;
                    end
                end
                
            end

            while(1)
                if(negStat(1) == 371)
                    break;
                end
                if(ismember(negStat(1), sampleinfoStat{subjecti}.EmptyCell))
                    negStat(1) = negStat(1) + 1;
                    continue;
                elseif(isempty(sampleinfo{subjecti}{negStat(1)}{2}{regioni}))
                    negStat(1) = negStat(1) + 1;
                    continue;
                else
                randFactor = round((negCount - 1)*rand + 1);
                if(randFactor <= negativeSampleSize(regioni))
                    selectedNegativeSampleInRegion(randFactor,:) = sampleinfo{subjecti}{negStat(1)}{2}{regioni}(negStat(2),:);
                    negCount = negCount + 1;
                end
                end
                if(negStat(2) == size(sampleinfo{subjecti}{negStat(1)}{2}{regioni},1))
                    negStat(1) = negStat(1) + 1;
                    negStat(2) = 1;
                else
                    negStat(2) = negStat(2) + 1;
                end
                
            end
            selectedPositiveSample = [selectedPositiveSample , selectedPositiveSampleInRegion];
            selectedNegativeSample = [selectedNegativeSample , selectedNegativeSampleInRegion];

        end
        fprintf([num2str(toc), ' seconds \n']);
        fprintf('Creating feature matrix...\n'); tic
        imgUsed = [selectedPositiveSample(:,1) ; selectedNegativeSample(:,1)];
        imgUsed = unique(imgUsed)';

        %% Postive Sample values
        for imgIdx = imgUsed
            c1 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{1}{1}, [M N], 'bilinear');
            c2 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{1}{2}, [M N], 'bilinear');
            c3 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{1}{3}, [M N], 'bilinear');
            i1 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{2}{1}, [M N], 'bilinear');
            i2 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{2}{2}, [M N], 'bilinear');
            i3 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{2}{3}, [M N], 'bilinear');
            o1 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{3}{1}, [M N], 'bilinear');
            o2 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{3}{2}, [M N], 'bilinear');
            o3 = imresize(featureGBVS{imgIdx}.graphbase.scale_maps{3}{3}, [M N], 'bilinear');

            color = imresize(featureGBVS{imgIdx}.graphbase.top_level_feat_maps{1}, [M N], 'bilinear');
            intensity = imresize(featureGBVS{imgIdx}.graphbase.top_level_feat_maps{2}, [M N], 'bilinear');
            orientation = imresize(featureGBVS{imgIdx}.graphbase.top_level_feat_maps{3}, [M N], 'bilinear');
            face = imresize(faceFeatures{imgIdx}, [M N], 'bilinear');

            posIdx = find(selectedPositiveSample(:,1) == imgIdx)';
            negIdx = find(selectedNegativeSample(:,1) == imgIdx)';

            for i = posIdx
                singleSample = selectedPositiveSample(i,:);
                angleIndex = singleSample(8);
                countNearAll = countNearAll + 1;

                singleFeature = [c1(singleSample(3),singleSample(2)) c2(singleSample(3),singleSample(2)) c3(singleSample(3),singleSample(2))...
                                 i1(singleSample(3),singleSample(2)) i2(singleSample(3),singleSample(2)) i3(singleSample(3),singleSample(2))...
                                 o1(singleSample(3),singleSample(2)) o2(singleSample(3),singleSample(2)) o3(singleSample(3),singleSample(2)) face(singleSample(3),singleSample(2))];
                if(opt.enable_angle)
                    featurePixelValueNear(countNearAll,num_feat_A*3*(regioni-1)+(angleIndex-1)*num_feat_A+1:num_feat_A*3*(regioni-1)+angleIndex*num_feat_A)=singleFeature(:);
                else
                    featurePixelValueNear(countNearAll,num_feat_A*(regioni-1)+1:num_feat_A*regioni)=singleFeature(:);
                end
            end

            %% Negative Samples
            for i = negIdx
                singleSample = selectedNegativeSample(i,:);
                angleIndex = singleSample(8);
                countFarAll = countFarAll + 1;

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

        testSaccadeImageIndex = 371:400;
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