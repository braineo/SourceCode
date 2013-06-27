%% Output the result of individualDiff_angle0_region6 to CSV
% Output 15 files for 15 subjects

clear vals_tune


regioni = 6;
time_stamp = datestr(now,'yyyymmddHHMM');
percent = [30,50,70,90];
for subjecti = 1:1
    for trial = 1:4
    outputcsv = sprintf('samplePercent%d.csv',percent(trial));
    fid = fopen(outputcsv, 'w');

    n_order_fromfirst_up = 1;
   

    vals_tune = zeros(info.opt_base.n_trial, size(EXP_INDV_REGION_NOANGLE_ms6{1}.mInfo_tune{1}.weight,1));
        n_trial = info.opt_base.n_trial;
        
            vals_tune = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{trial}.weight';
    

    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
    fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', vals_tune);
    fclose(fid);
     end
end

