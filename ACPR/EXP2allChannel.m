%% Hotelling T2 test for 15C2 combinations of pairs (all channel 10*6 dimentional)
dMatrix = zeros(15,15);
pMatrix = zeros(15,15);
statsMat = cell(15,15);
subsetSize = size(EXP_INDV_REGION_NOANGLE_ms6{1}.mInfo_tune,2);
left = zeros(subsetSize,10*6);
right = zeros(subsetSize,10*6);
for subjectLeft = 1:15
    for subjectRight = subjectLeft+1:15
        for i = 1:subsetSize
            
            for regioni = 1:6
                rangeL = (regioni-1)*10+1;
                rangeR = (regioni-1)*10+10;
                left(i,:) = EXP_INDV_REGION_NOANGLE_ms6{subjectLeft}.mInfo_tune{i}.weight(:);
                right(i,:) = EXP_INDV_REGION_NOANGLE_ms6{subjectRight}.mInfo_tune{i}.weight(:);
                
            end
        end
        left = left/norm(left);
        right = right/norm(right);
        X = [left;right];
        group = zeros(size(X,1),1);
        group(1:size(left,1)) = subjectLeft;
        group(1+size(left,1):end) = subjectRight;
        %% PCA
%         [COEFF,SCORE,latent,tsquare] = princomp(X);
%         X = SCORE(:,1:12);
        %%
        [d,p,stats] = manova1(X,group);
        dMatrix(subjectLeft,subjectRight) = d;
        pMatrix(subjectLeft,subjectRight) = p;
        statsMat{subjectLeft,subjectRight} = stats;
    end
end

% savefile = sprintf('../Result/ACPR/ACPR_EXP2colorChannel');
% save(savefile,'dMatrix','pMatrix','statsMat','-v7.3');