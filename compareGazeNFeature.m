%% compare gaze point and feature maps


%% Load mat files
% load ('../Output/storage/EXPALLFixations.mat');
% load ('../Output/storage/sevenFeatures.mat');
featContribution = zeros(1,size(avr_feature_map,2));
%% define parameters
origDims = [768,1366];

%% get gaze maps
for picnumber = 1:400
    gazeMap = zeros(origDims);
    fixationlocation = [];
    for subject = 1:15
        fixationlocation=[fixationlocation; EXPALLFixations{1,picnumber}{1,subject}.medianXY];
    end
    fixationlocation = round(fixationlocation);
    fixationlocation(fixationlocation <= 0) = 1;
    fixationlocation(isnan(fixationlocation)) = 1;
    
%     tmp = fixationlocation(:,1);
%     fixationlocation(:,1)=fixationlocation(:,2);
%     fixationlocation(:,2)=tmp;
    tmp = fixationlocation(:,1);
    tmp(tmp > 1366) = 1366;
    fixationlocation(:,1) = tmp;
    tmp = fixationlocation(:,2);
    tmp(tmp > 768) = 768;
    fixationlocation(:,2) = tmp;
    for gazePointNum = 1:length(fixationlocation)
        gazeMap(fixationlocation(gazePointNum,2),fixationlocation(gazePointNum,1)) = ...
            gazeMap(fixationlocation(gazePointNum,2),fixationlocation(gazePointNum,1)) + 1;
    end
    
%% compare with feature maps
    for featNum = 1:size(avr_feature_map,2)
        featMap = imresize(reshape(avr_feature_map(:,featNum), dim_avr),origDims);
        tmp = gazeMap.*featMap;
        featContribution(featNum) = featContribution(featNum) + sum(tmp(:));
    end
end
