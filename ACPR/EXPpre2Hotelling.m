load('../Result/EXP20130613/EXP20130613_201306161433.mat');
cond1 = zeros(15,60);

for subjecti = 1:15
    cond1(subjecti,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';
end

for regioni = 1:6   
    cond1(:,regioni*10) = 0;
end

load('../Result/EXP20130617/EXP20130617_201307312210.mat');
dataBase = zeros(15,54);
cond2 = [];
for subjecti = 1:15   
    dataBase(subjecti,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';
end

for regioni = 1:6
    rangeL = (regioni-1)*9+1;
    rangeR = regioni*9;
    cond2 = [cond2, dataBase(:,rangeL:rangeR)];
    cond2 = [cond2, zeros(15,1)];
end

load('../Result/EXP20130627/EXP20130702_201307032012.mat');
cond3 = zeros(15,60);
for subjecti = 1:15
    cond3(subjecti,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';
end

% 
%     outputcsv = sprintf('cond3.csv');
%     fid = fopen(outputcsv, 'w');
%  vals_tune = mean(cond3,1);
% 
%     fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
%     fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', vals_tune);
%     fclose(fid);
dataBase = [cond1;cond2];
group = zeros(15*2,1);
group(1:15) = 1;
group(16:30) = 2;
feati = 3;

X = [];

for regioni = 1:6
    if(feati ~= 4);
        rangeL = (regioni-1)*10+1+3*(feati-1);
        rangeR = (regioni-1)*10+3+3*(feati-1);
        X = [X, dataBase(:,rangeL:rangeR)];
    else
        rangeL = regioni*10;
        X = [X, dataBase(:,rangeL)];
    end
end
for k=1:size(X,1)
    X(k,:) = X(k,:)/norm(X(k,:));
end
[d,p,stats] = manova1(X,group);