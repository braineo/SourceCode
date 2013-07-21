%% MAVONA (All 10*6 dimentional)
dMatrix = zeros(15,15);
pMatrix = zeros(15,15);
statsMat = cell(15,15);
subsetSize = size(EXP_INDV_REGION_NOANGLE_ms6{1}.mInfo_tune,2);
X = zeros(subsetSize*15,10*6);
group = zeros(size(X,1),1);
tmp = zeros(subsetSize,10*6);
for subjecti = 1:15
        for i = 1:subsetSize
       
           tmp(i,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{i}.weight(:);

        end
        tmp = tmp/norm(tmp);
        X((subjecti-1)*subsetSize+1 : subjecti*subsetSize, :) = tmp;
        
        group((subjecti-1)*subsetSize+1:subjecti*subsetSize) = subjecti;
       
        %% PCA
%         [COEFF,SCORE,latent,tsquare] = princomp(X);
%         X = SCORE(:,1:10);
        %%
        
        
end
[COEFF,SCORE,latent,tsquare,explained] = princomp(X);
% [d,p,stats] = manova1(X,group);
% parallelcoords(X,'Group',group)
% savefile = sprintf('../Result/ACPR/ACPR_EXP2colorChannel');
% save(savefile,'dMatrix','pMatrix','statsMat','-v7.3');