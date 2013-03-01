%% Investigating Feature Contribution to Saliency
% This file is used to shows 7 features (color*2, intensity*1,
% orientation*4) times 3 levels = 21 raw feature maps
% 
%

%% Read picture library
%
stimfolder = '/Volumes/davinci/MATLAB/final_resize';
% stimfolder = './ramdompics';
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = files.name;
gray2rgb = @(Image) double(cat(3,Image,Image,Image))./255;

%% Parameters
rawFeatureMaps = {};
params = makeGBVSParams;
params.channels = 'CIO';
params.salmapmaxsize = 48;
   
%% Get feature maps

for i = 1: length(filenames)
    img = fullfile(stimfolder,filenames{i});
    fprintf('* %s\n', filenames{i});
    if ( strcmp(class(img),'char') == 1 ) img = imread(img); end
    if ( strcmp(class(img),'uint8') == 1 ) img = double(img)/255; end
    
    params = makeGBVSParams;
    params.channels = 'CIO';
    params.salmapmaxsize = 48;
    [grframe,param] = initGBVS(params,size(img));
    prevMotionInfo = [];
    is_color = (size(img,3) == 3);
    
    if(~is_color)
        fprintf('not color* %s\n', filenames{i});
        img = gray2rgb(img);
    end
    
    [out motionInfo] = getFeatureMaps( img , param, prevMotionInfo); 
    rawFeatureMaps{i} = out;
end
%% Get feature name
i=0;
featureNames=[];
mapnames = fieldnames(out);
for fmapi=1:length(mapnames)
    mapsobj = eval( [ 'out.' mapnames{fmapi} ';'] );
    for numtypes = 1:mapsobj.info.numtypes;
        for levels = 2:4;
            i=i+1;
            featureNames =[ featureNames,strcat(mapsobj.info.descriptions(numtypes),sprintf('-%d',levels))];
        end
    end
end
%% Save files
savefile = './storage/allRawFeatures.mat';
save(savefile, 'rawFeatureMaps','-v7.3');