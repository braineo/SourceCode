%% smooth all pictures in a directry
filefolder = './ramdampic';
files=dir(fullfile(filefolder,'*.jpg'));
[filenames{1:size(files,1)}] = files.name;
cd ramdompics
h = fspecial('gaussian',[50 50],10);
for i=1:length(filenames)
    img = imread(filenames{1,i});
    img = imfilter(img,h,'replicate');
    %imshow(img)
    imwrite(img, filenames{1,i});
end