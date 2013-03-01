%% findSevenFeatures
% It is a function similar to findIttiFeature2 (created by Mr. Kubota)
% The difference is that I save 7 features (color*2, intensity*1, orientation*4)
% separately.

function [features, salData] = findSevenFeatures(img, dims)

% ----------------------------------------------------------------------
% Matlab tools for "Learning to Predict Where Humans Look" ICCV 2009
% Tilke Judd, Kristen Ehinger, Fredo Durand, Antonio Torralba
% 
% Copyright (c) 2010 Tilke Judd
% Distributed under the MIT License
% See MITlicense.txt file in the distribution folder.
% 
% Contact: Tilke Judd at <tjudd@csail.mit.edu>
% ----------------------------------------------------------------------

%% Determind parameters
% DESCRIPTIVE TEXT

fprintf('Finding Itti&Koch channels...'); tic;
% features=zeros(dims(1)*dims(2), 28);

img = initializeImage(img);
params = defaultSaliencyParams(img.size, 'dyadic'); %'dyadic' - pyramids with downsampling by a factor of 2 (default)
params.levelParams.maxDelta = 3;
params.levelParams.maxLevel = 6;

%% Generate feature maps
[salmap, salData] = makeSaliencyMap(img, params);
i=1;

%% Color

for featureNumColor=1:size(salData(1).FM, 1)
    for levelNumber=1:size(salData(1).FM, 2)
%         colorFMStr = imresize(...
%         salData(1).FM(featureNumColor, levelNumber).data,  dims, 'bicubic');
        colorFMStr = salData(1).FM(featureNumColor, levelNumber).data;
        features(:,i)=colorFMStr(:);
        i=i+1;
    end
 end


%% Intensity

for featureNumIntens=1:size(salData(2).FM, 1)
    for levelNumber=1:size(salData(2).FM, 2)
%         intensityFMStr = imresize(...
%         salData(2).FM(featureNumIntens, levelNumber).data,  dims, 'bicubic');
       intensityFMStr = salData(2).FM(featureNumIntens, levelNumber).data;
        features(:,i)=intensityFMStr(:);
        i=i+1;
    end
end
%% Orientation

for featureNumOrien=1:size(salData(3).FM, 1)
    for levelNumber=1:size(salData(3).FM, 2)
%         orientationFMStr = imresize(...
%         salData(3).FM(featureNumOrien, levelNumber).data,  dims, 'bicubic');
        orientationFMStr = salData(3).FM(featureNumOrien, levelNumber).data;
        features(:,i)=orientationFMStr(:);
        i=i+1;
    end
end
