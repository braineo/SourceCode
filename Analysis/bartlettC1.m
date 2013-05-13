%% Color, Scale1, Bartlett's test for 15 subjects in region 1

colorScale1 = zeros(info.opt_base.n_trial,15);

for subjecti = 1:15
    for traili = 1:info.opt_base.n_trial
    colorScale1(traili, subjecti) = ...
        EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{traili}.weight(20);
    end
end

