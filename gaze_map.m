% load('.\storage\exallfications.mat');

gazeMap = zeros(1366,768);
max_x=0;
max_y=0;
for picnumber = 1:400
   
    fixationlocation = [];
    for subject = 1:15
        fixationlocation=[fixationlocation; EXPALLFixations{1,picnumber}{1,subject}.medianXY];
    end
    fixationlocation = round(fixationlocation);
    fixationlocation(fixationlocation <= 0) = 1;
    max_x =  max_x + sum(fixationlocation(:,1)>1366);
    max_y =  max_y + sum(fixationlocation(:,2)>768);
    fixationlocation(isnan(fixationlocation)) = 1;
    tmp = fixationlocation(:,1);
    tmp(tmp > 1366) = 1366;
    fixationlocation(:,1) = tmp;
    tmp = fixationlocation(:,2);
    tmp(tmp > 768) = 768;
    fixationlocation(:,2) = tmp;
    for gazePointNum = 1:length(fixationlocation)
        gazeMap(fixationlocation(gazePointNum,1),fixationlocation(gazePointNum,2)) = ...
            gazeMap(fixationlocation(gazePointNum,1),fixationlocation(gazePointNum,2)) + 1;
    end
end

imshow(gazeMap');