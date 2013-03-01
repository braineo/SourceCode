% load('.\storage\exallfications.mat')
stimfolder = 'C:\Users\yeb\Documents\MATLAB\final_resize';
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = files.name;

cmap = hsv(15);
for picnumber = 1:length(filenames)
    img = imread(fullfile(stimfolder,filenames{picnumber}));
    imshow(img);
    hold on;
    for n = 1:15
        fixationlocation=ExALLFixations{1,picnumber}{1,n}.medianXY; 
        plot(fixationlocation(:,1),fixationlocation(:,2),'*','color',cmap(n,:));
    end
    hold off;
    pause;
end