%% feature distributions of 15 subjects
% this file is to read the weights of the features and plot their pattern

close all;
clear all;
loadfile = '../Output/storage/individualDifference/indiviDiff_20130329_angle0_region6_trial50_tsample800/individualDiff_angle0_region6_201303290256.mat';
load(loadfile);
outputCSV = 0;

%% reform data
n_region = 6;
featName = {'C1','C2','C3','I1','I2','I3','O1','O2','O3','F'};
weightPattern = cell([1,10]);
for feati = 1:10 % 10 features C1,C2,C3,I1,I2,I3,O1,O2,O3,F
    weights = zeros(n_region, length(EXP1_REGION_NOANGLE_ms6),...
        length(EXP1_REGION_NOANGLE_ms6{1}{n_region}.mInfo_tune));
    for regioni = 1:n_region
        for subjecti = 1:length(EXP1_REGION_NOANGLE_ms6)
            for triali = 1:length(EXP1_REGION_NOANGLE_ms6{subjecti}{n_region}.mInfo_tune)
                weights(regioni, subjecti, triali) = ...
                    EXP1_REGION_NOANGLE_ms6{subjecti}{n_region}.mInfo_tune{triali}{1}.weight((regioni-1)*10+feati);
            end
        end
    end
    if(outputCSV)
        outputfile = sprintf('featDistribute_%s.csv',featName{feati});
        fid = fopen(outputfile, 'w');
        fprintf(fid, 'feature distribution of %s in region 1 - %d\n', featName{feati}, n_region);
        for regionprint = 1:regioni
            fprintf(fid, 'Region_%d\n',regionprint);
            fmtstring = repmat('%f,', 1, triali);
            for subprint = 1:subjecti
                fprintf(fid, ['Subject#%d,',fmtstring,'\n'],subprint,weights(regionprint,subprint,:));
            end
        end
    else
        weightPattern{feati} = weights;
    end
end
featureDistributePatternPlot(weightPattern,featName);
%% Output mat file
savefile = sprintf('../Output/storage/weightPattern.mat');
save(savefile, 'weightPattern','-v7.3');
