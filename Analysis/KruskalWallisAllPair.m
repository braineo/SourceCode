%% KruskalWallis test for each pair

examData = zeros(info.opt_base.n_trial,15);
testData = zeros(info.opt_base.n_trial,2);
featName = {'C1','C2','C3','I1','I2','I3','O1','O2','O3','F'};
count = 0;
featOrder = zeros(1,60);

for featnum = 1:10
    for regioni = 1:6
    featOrder(6*(featnum-1)+1:6*(featnum-1)+6) = ...
        featnum:10:60;
    end
end
for featurei = featOrder
    count = count + 1;
    for subjecti = 1:15
        for traili = 1:info.opt_base.n_trial
            examData(traili, subjecti) = ...
                EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{traili}.weight(featurei);
        end
    end
    
    for subjecti = 1:15
        for testPair = subjecti:15
            testData(:,1) = examData(:,subjecti);
            testData(:,2) = examData(:,testPair);
            p = kruskalwallis(testData,[],'off');
            if(p >= 0.05)
                plot(subjecti,testPair,'*');
            end
            hold on;
            if(p >= 0.05)
                plot(testPair,subjecti,'*');
            end
        end
    end
    set(gca, 'XTick', [1:15]);
    set(gca, 'YTick', [1:15]);


            regioni = num2str(ceil(featurei/10));
            if(~rem(featurei,10))
                featnum = 10;
            else 
                featnum = rem(featurei,10);
            end
                titleName = [featName{featnum},' region#',regioni];
                
                title(titleName);
                featnum = sprintf('%2d',count);
                fileName = sprintf('%s','../Output/storage/feature',featnum,num2str(i));
                print(fileName,'-dpdf');

        close all
   
end