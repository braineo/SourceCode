%% Sample statistic for 1st saccade

sampleinfoStat=cell(1,15);

for subjecti = 1:15
    positiveSampleNumberAll = 0;
    negativeSampleNumberAll = 0;
    positiveSampleNumberRegion = zeros(1,6);
    negativeSampleNumberRegion = zeros(1,6);
    emptyImage = [];
    for imgi = 1:size(sampleinfo{subjecti},2)
        if(isempty(sampleinfo{subjecti}{imgi}))
            emptyImage = [emptyImage, imgi];
            continue;
        else
        for regioni = 1:3
            tmpPos = size(sampleinfo{subjecti}{imgi}{1}{regioni},1);
            tmpNeg = size(sampleinfo{subjecti}{imgi}{2}{regioni},1);
            positiveSampleNumberAll = positiveSampleNumberAll + tmpPos;
            negativeSampleNumberAll = negativeSampleNumberAll + tmpNeg;            
            positiveSampleNumberRegion(regioni) = ...
                positiveSampleNumberRegion(regioni) + tmpPos;
            negativeSampleNumberRegion(regioni) = ...
                negativeSampleNumberRegion(regioni) + tmpNeg;
        end
        end
    end
    sampleinfoStat{subjecti}.PositiveAll = positiveSampleNumberAll;
    sampleinfoStat{subjecti}.NegativeAll = negativeSampleNumberAll;
    sampleinfoStat{subjecti}.PositiveRegion = positiveSampleNumberRegion;
    sampleinfoStat{subjecti}.NegativeRegion = negativeSampleNumberRegion;
    sampleinfoStat{subjecti}.EmptyCell = emptyImage;
end

savefile = sprintf('../Output/storage/sampleStat1st_3region.mat');
save(savefile,'sampleinfoStat','-v7.3');