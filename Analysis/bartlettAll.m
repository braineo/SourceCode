%% Bartlett's test

examData = zeros(info.opt_base.n_trial,15);
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
            vartestn(examData);
            regioni = num2str(ceil(featurei/10));
            if(~rem(featurei,10))
                featnum = 10;
            else 
                featnum = rem(featurei,10);
            end
                titleName = [featName{featnum},' region#',regioni];
            
            hfig = get(0,'children');
            for i = 1:length(hfig)
                figure(hfig(i))
                
                title(titleName);
                featnum = sprintf('%2d',count);
                fileName = sprintf('%s','../Output/storage/feature',featnum,num2str(i));
                print(hfig(i),fileName,'-dpdf');
            end
        close all
   
end