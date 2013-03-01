 %show feature average map of the 400 experiment picture
%

% load('./storage/sevenFeatures.mat');
close all;
colorFeatNum = 2;
intensityFeatNum = 1;
orientationFeatNum = 4;
levelNum = 3;
dims = size(rawFeatureMaps{1,1}.color.maps.val{1,1}{1,2});
avr_feature_map = zeros(dims(1)*dims(2),...
                       (colorFeatNum+intensityFeatNum+orientationFeatNum)*levelNum...
                       );
for pic_num = 172:172
    i=0;
    rawFeat = rawFeatureMaps{1, pic_num};
    mapnames = fieldnames(rawFeat);
    for fmapi=1:length(mapnames)
    mapsobj = eval( [ 'rawFeat.' mapnames{fmapi} ';'] );
        for numtypes = 1:mapsobj.info.numtypes;
            for levels = 2:4;
                i=i+1;
                avr_feature_map(:,i) = ...
                avr_feature_map(:,i)+ mapsobj.maps.val{1,numtypes}{1,levels}(:);
            end
        end
    end
end
dim_show = [768,1366];
% dim_show = [270, 480];
dim_avr = [27, 48];
figure
for i = 1:6
    subplot(2, 3, i);
    imagesc(imresize(reshape(avr_feature_map(:,i), dim_avr),dim_show));
    title(featureNames(i),'FontSize', 28);
end
figure
for j= 1:3
    subplot(2,2,j);
    imagesc(imresize(reshape(avr_feature_map(:,i+j), dim_avr),dim_show));
    title(featureNames(i+j),'FontSize', 28);
end
figure
for k=1:12
    subplot(4,3,k);
    imagesc(imresize(reshape(avr_feature_map(:,i+j+k),dim_avr),dim_show));
    title(featureNames(i+j+k),'FontSize', 28);
end
    