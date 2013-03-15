%% This file is to show Activation maps

load('../Output/storage/saltFeatureMaps.mat');

close all;
dims = size(saltFeatureMaps{1}{1}.map);
avrActFeatureMap = zeros(dims(1)*dims(2),...
                    length(saltFeatureMaps{1}));
%% load and calculate average map
for pic_sum = 172:172
    i=0;
    actFeat = saltFeatureMaps{pic_sum};
    for fmapi = 1:length(actFeat)
        i = i+1;
        avrActFeatureMap(:,i) = actFeat{fmapi}.map(:)+...
        avrActFeatureMap(:,i);
    end
end

dim_show = [768,1366];
% dim_show = [270, 480];
dim_avr = [27, 48];
figure
for i = 1:6
    subplot(2, 3, i);
    imagesc(imresize(reshape(avrActFeatureMap(:,i), dim_avr),dim_show));
    title(featureNames(i),'FontSize', 28);
end
figure
for j= 1:3
    subplot(2,2,j);
    imagesc(imresize(reshape(avrActFeatureMap(:,i+j), dim_avr),dim_show));
    title(featureNames(i+j),'FontSize', 28);
end
figure
for k=1:12
    subplot(4,3,k);
    imagesc(imresize(reshape(avrActFeatureMap(:,i+j+k),dim_avr),dim_show));
    title(featureNames(i+j+k),'FontSize', 28);
end