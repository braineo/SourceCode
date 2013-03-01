stimfolder = 'C:\Users\yeb\Documents\MATLAB\final_resize';
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = files.name;
dims = [256, 455];
gray2rgb = @(Image) double(cat(3,Image,Image,Image))./255;

ExALLFeatures2 = {};
FEATURES = zeros(dims(1)*dims(2), 7);
h = fspecial('laplacian');
%% Initialize
summap =zeros(768,1366,3);
for i = 1: length(filenames)
    fn = fullfile(stimfolder,filenames{i});
    fprintf('* %s\n', filenames{i});
    img = imread(fn);
    
    is_color = (size(img,3) == 3);
    
    if(~is_color)
        fprintf('not color* %s\n', filenames{i});
        img = gray2rgb(img);
    end
    img = imfilter(img,h,'replicate'); 
    summap = summap + double(abs(img));
end
maxval = max(max(max(summap)))
minval = min(min(min(summap)))
summap = (summap-minval) /  (maxval-minval)