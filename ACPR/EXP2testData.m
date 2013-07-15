testData = zeros(150,60);
groupData = zeros(150,1);
for subjecti = 1:15
    for imgseti = 1:10
        testData((subjecti-1)*10+imgseti,:) = ...
            EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{imgseti}.weight';
        groupData((subjecti-1)*10+imgseti) = subjecti;
    end
end