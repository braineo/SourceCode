%% Output the result of individualDiff_angle0_region6 to CSV
% Output 15 files for 15 subjects

clear vals_tune
% loadfile = '../Output/storage/EXP_INDV_angle0_region6_201304180005.mat'
% load(loadfile);

regioni = 6;
time_stamp = datestr(now,'yyyymmddHHMM');
for subjecti = 7:7
    outputcsv = sprintf('testSubject_%d.csv',subjecti);
    fid = fopen(outputcsv, 'w');

    n_order_fromfirst_up = 1;
    n_region = 6;
    fprintf(fid, 'n_region,%d\n', n_region);

    vals_tune = zeros(info.opt_base.n_trial, size(EXP_INDV_REGION_NOANGLE_ms6{1}.mInfo_tune{1}.weight,1));
        n_trial = info.opt_base.n_trial;
        for trial = 1:n_trial
            vals_tune(trial,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{trial}.weight';
        end

    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3\n');
    fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f\n', vals_tune);
    fclose(fid);
end

