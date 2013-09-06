%% MAVONA (Compare of any combination of feature)
% init
dMatrix = zeros(1,15);
pMatrix = cell(1,15);
statsMat = cell(1,15);
comboMat = cell(1,15);
subsetSize = size(EXP_INDV_REGION_NOANGLE_ms6{1}.mInfo_tune,2);
featureType = [1,2,3,4];
dataBase = zeros(15*subsetSize,60);
group = zeros(15*subsetSize,1);
% making database
i = 1;
for subjecti = 1:15
    for subseti = 1:subsetSize
        dataBase(i,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{subseti}.weight';
        group(i) = subjecti;
        i = i + 1;
    end
end

j = 1;
for comboNum = 1:4
    combo = combntns(featureType, comboNum);
    for i = 1:size(combo,1)
        X = [];
        for feati = combo(i,:)
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
        end
        for k=1:size(X,1)
            X(k,:) = X(k,:)/norm(X(k,:));
        end
        [d,p,stats] = manova1(X,group);
        dMatrix(j) = d;
        pMatrix{j} = p;
        statsMat{j} = stats;
        comboMat{j} = combo(i,:);
        j = j + 1;
    end
end
% for i = 1:15
%     manovacluster(statsMat{i},'average');
%     hfig = get(0,'children');
%     for j = 1:length(hfig)
%         figure(hfig(j))
%     fileName = sprintf('%s','../Output/storage/MANOVA',num2str(i));
%     print(hfig(j),fileName,'-deps');
%     end
% end

% savefile = sprintf('../Result/ACPR/ACPR_EXP2comboMANOVA');
% save(savefile,'dMatrix','pMatrix','statsMat','-v7.3');