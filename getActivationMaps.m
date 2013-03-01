%% Investigating Feature Contribution to Saliency
% This file is used to get feature saliency maps
% 
%

%% Read picture library
%
stimfolder = '../Resource/final_resize';
% stimfolder = '../Resource/ramdompics';
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = files.name;
gray2rgb = @(Image) double(cat(3,Image,Image,Image))./255;

%% Parameters
saltFeatureMaps = {};
params = makeGBVSParams;
params.channels = 'CIO';
params.salmapmaxsize = 48;
   
%% Get feature maps

for filenamei = 1: length(filenames)
    img = fullfile(stimfolder,filenames{filenamei});
    fprintf('* %s\n', filenames{filenamei});
    if ( strcmp(class(img),'char') == 1 ) img = imread(img); end
    if ( strcmp(class(img),'uint8') == 1 ) img = double(img)/255; end
    
    params = makeGBVSParams;
    params.channels = 'CIO';
    params.salmapmaxsize = 48;
    [grframe,param] = initGBVS(params,size(img));
    prevMotionInfo = [];
    is_color = (size(img,3) == 3);
    
    if(~is_color)
        fprintf('not color* %s\n', filenames{filenamei});
        img = gray2rgb(img);
    end
    
    [rawfeatmaps motionInfo] = getFeatureMaps( img , param, prevMotionInfo); 
%     rawFeatureMaps{filenamei} = out;
    mapnames = fieldnames(rawfeatmaps);
    mapweights = zeros(1,length(mapnames));
    map_types = {};
    allmaps = {};
    i = 0;
    mymessage(param,'computing activation maps...\n');
    for fmapi=1:length(mapnames)
        mapsobj = eval( [ 'rawfeatmaps.' mapnames{fmapi} ';'] );
        numtypes = mapsobj.info.numtypes;
        mapweights(fmapi) = mapsobj.info.weight;
        map_types{fmapi} = mapsobj.description;
        for typei = 1 : numtypes
            if ( param.activationType == 1 )
                for lev = param.levels                
                    mymessage(param,'making a graph-based activation (%s) feature map.\n',mapnames{fmapi});
                    i = i + 1;
                    [allmaps{i}.map,tmp] = graphsalapply( mapsobj.maps.val{typei}{lev} , ...
                        grframe, param.sigma_frac_act , 1 , 2 , param.tol );
                    allmaps{i}.maptype = [ fmapi typei lev ];
                end
            else
                for centerLevel = param.ittiCenterLevels
                    for deltaLevel = param.ittiDeltaLevels
                        mymessage(param,'making a itti-style activation (%s) feature map using center-surround subtraction.\n',mapnames{fmapi});
                        i = i + 1;                    
                        center_ = mapsobj.maps.origval{typei}{centerLevel};
                        sz_ = size(center_);
                        surround_ = imresize( mapsobj.maps.origval{typei}{centerLevel+deltaLevel}, sz_ , 'bicubic' );                    
                        allmaps{i}.map = (center_ - surround_).^2;
                        allmaps{i}.maptype = [ fmapi centerLevel deltaLevel ];
                    end
                end
            end
        end
    end
    saltFeatureMaps{filenamei} = allmaps;
end
%%
savefile = '../Output/storage/saltFeatureMaps.mat';
save(savefile, 'saltFeatureMaps','-v7.3');