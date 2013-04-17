%% Main function of the project, calculating the weights for each subject
% return the result of training and NSS score for a single test subject
% parameter:
% opt_set: Setting up options
% saccadeData: saccade data of 15 subject view 400 pictures
% featureGBVS: GBVS saliency map
% faceFeature: Gaussian face feature
% subjectIndex: ID of test subject

function  [mInfo_tune, mNSS_tune, opt] = calcMainPerSubject(opt_set, saccadeData, featureGBVS, faceFeatures, subjectIndex)

load RandomSeed_2012122
opt = opt_set;
opt.start_time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
M = opt.M;
N = opt.N;
tool = toolFunc(opt); % return distance on screen by angle? not really understand

for order_fromfirst=1:opt.n_order_fromfirst % to nth saccade
    [thresholdLength, thresholdAngle, n_samples_each_region] = getThresholdLength(order_fromfirst, saccadeData, opt);
    opt.thresholdLength{order_fromfirst} = thresholdLength;
    opt.thresholdAngle{order_fromfirst} = thresholdAngle;
    opt.n_samples_each_region{order_fromfirst} = n_samples_each_region;
    clear thresholdLength thresholdAngle n_samples_each_region
end

for trial=1:opt.n_trial %times of experienment
    regionStatisticsNear = zeros(1,opt.n_region);
    regionStatisticsFar = zeros(1,opt.n_region);
    fprintf('XXXXXXXXXXXXXXX trial: %d\n', trial);
    
    rand_param = sum(RandomSeed{trial}); % set up rand generator state
    opt.rand_param{trial} = rand_param;
    
    [sample_saccade, testingsamles] = getIndiTTsamples(rand_param, saccadeData, opt, subjectIndex);
    
    fprintf('Creating infos_base...\n'); tic
    infos_base = zeros(M*N, 8);
    for tm=1:M
        for tn=1:N
            infos_base(N*(tm-1)+tn, :) = [0 tn tm 0 0 0 0 0];
            % 1. imgidx, 2.X, 3. Y, 4. distance to P(NEXT), 5. distance to P(PREV),
            % 6. Region number,
            % 7. Angle(degree) based on P(PREV),
            % 8. Angle(index) (horizontal:1, up:2, down:3)
        end
    end
    
    allOnesMat = ones(size(infos_base, 1),1);
    fprintf([num2str(toc), ' seconds \n']);
    
     for order_fromfirst=1:opt.n_order_fromfirst %order_fromfirst: take consider from the 1st to nth saccade

        rand('state',rand_param*trial*order_fromfirst);

        fprintf('---------------- order_fromfirst: %d\n', order_fromfirst);

        thresholdLength = opt.thresholdLength{order_fromfirst};

        sampleSaccadeOrderSelected = sample_saccade(find(sample_saccade(:,2)<=order_fromfirst&sample_saccade(:,8)==1),:);
        sample_order1_perm = randperm(size(sampleSaccadeOrderSelected, 1));
        sampleSaccadeOrderSelected = sampleSaccadeOrderSelected(sample_order1_perm, :);% random reordered
        
        %---------------
        num_near_all = 0;
        num_far_all = 0;
        c_near = 0;
        c_far = 0;
        
        num_feat_A = 10; %total number of features
        infomat_near_distance = zeros(opt.posisize*1.1,1);
        if(opt.enable_angle)
            featurePixelValueNear = zeros(opt.posisize*1.1,3*num_feat_A*size(thresholdLength,2)); % 3 directions, 10 features, n regions
            featurePixelValueFar = zeros(opt.posisize*opt.ngrate*1.1,3*num_feat_A*size(thresholdLength,2));
        else
            featurePixelValueNear = zeros(opt.posisize*1.1,num_feat_A*size(thresholdLength,2));
            featurePixelValueFar = zeros(opt.posisize*opt.ngrate*1.1,num_feat_A*size(thresholdLength,2));
        end

        rate = 1;
        positiveSamples = tool.get_distance(1)*tool.get_distance(1)*1.05*pi*size(sampleSaccadeOrderSelected, 1);
        if(positiveSamples > opt.posisize)
            rate = positiveSamples/opt.posisize;
        end
        
        rate

        fprintf('Prepare Training...\n'); tic
        for imgidx=1:400
            if(mod(imgidx,10)==0)
                fprintf('%d, ', imgidx);
            end
            if(mod(imgidx,100)==0)
                fprintf('\n');
            end
            sampleIndexSelected = sampleSaccadeOrderSelected(find(sampleSaccadeOrderSelected(:,1)==imgidx),:);
            if(size(sample_imgidx, 1)==0)
                clear sample_imgidx
                continue
            end
% resize feature maps
            c1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{1}, [M N], 'bilinear');
            c2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{2}, [M N], 'bilinear');
            c3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{3}, [M N], 'bilinear');
            i1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{1}, [M N], 'bilinear');
            i2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{2}, [M N], 'bilinear');
            i3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{3}, [M N], 'bilinear');
            o1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{1}, [M N], 'bilinear');
            o2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{2}, [M N], 'bilinear');
            o3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{3}, [M N], 'bilinear');

            color = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{1}, [M N], 'bilinear');
            intensity = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{2}, [M N], 'bilinear');
            orientation = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{3}, [M N], 'bilinear');
            face = imresize(faceFeatures{imgidx}, [M N], 'bilinear');
           
            for i=1:size(sampleIndexSelected,1)
                %% Fill in infomat
                infomat = infos_base;
                infomat(:,1) = imgidx;
                t_px = sampleIndexSelected(i, 3);
                t_py = sampleIndexSelected(i, 4);
                t_nx = sampleIndexSelected(i, 5);
                t_ny = sampleIndexSelected(i, 6);
                % 1. imgidx, 2.X, 3. Y, 
                % 4. distance to P(NEXT), 5. distance to P(PREV),
                % 6. Region number,
                % 7. Angle(degree) based on P(PREV),
                % 8. Angle(index) (horizontal:1, up:2, down:3)
                infomat(:,4) = ...
                    sqrt(((t_nx+0.5).*allOnesMat-infomat(:,2)).*((t_nx+0.5).*allOnesMat-infomat(:,2))+...
                         ((t_ny+0.5).*allOnesMat-infomat(:,3)).*((t_ny+0.5).*allOnesMat-infomat(:,3)));
                infomat(:,5) = ...
                    sqrt(((t_px+0.5).*allOnesMat-infomat(:,2)).*((t_px+0.5).*allOnesMat-infomat(:,2))+...
                         ((t_py+0.5).*allOnesMat-infomat(:,3)).*((t_py+0.5).*allOnesMat-infomat(:,3)));

                for k=1:size(thresholdLength,2)
                    infomat(find(infomat(:,5)<thresholdLength(1,k)&infomat(:,6)==0),6) = k;
                end

                if(opt.enable_angle)
                    infomat(:,7) = ...
                        atan2(-(infomat(:,3)-(t_py+0.5).*ones_), abs(infomat(:,2)-(t_px+0.5).*ones_));

                    infomat(find(infomat(:,7)>-pi/4&infomat(:,7)<pi/4),8) = 1; %direction: horizontal
                    infomat(find(infomat(:,7)>=pi/4),8) = 2; %direction: up
                    infomat(find(infomat(:,7)<=-pi/4),8) = 3; %direction: down
                end
                
                for k=1:size(thresholdLength,2)
                    infomatRegionedNear{k} = [infomatRegionedNear{k}; infomat(find(infomat(:,4)<opt.th_near & infomat(:,6) == k),:)];
                    infomatRegionedFar{k} = [infomatRegionedNear{k}; infomat(find(infomat(:,4)>opt.th_far & infomat(:,6) == k),:)];
                end
            end
        end
     end
end