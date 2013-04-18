%% Output the result of individualDiff_angle0_region6 to CSV
% Output 15 files for 15 subjects

clear vals_tune
% loadfile = '../Output/storage/EXP_INDV_angle0_region6_201304180005.mat'
% load(loadfile);

regioni = 6;
time_stamp = datestr(now,'yyyymmddHHMM');
for subjecti = 1:15
    outputcsv = sprintf('individualTest_%s_region_%d_subject_%d.csv', time_stamp,regioni,subjecti);
    fid = fopen(outputcsv, 'w');

    n_order_fromfirst_up = 1;
    n_region = 6;
    fprintf(fid, 'n_region,%d\n', n_region);

    vals_tune = zeros(info.opt_base.n_trial, size(EXP_INDV_REGION_NOANGLE_ms6{1}{regioni}.mInfo_tune{1}{1}.weight,1));
    for n_order_fromfirst = 1:n_order_fromfirst_up
        n_trial = info.opt_base.n_trial;
        for trial = 1:n_trial
            vals_tune(trial,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}{regioni}.mInfo_tune{trial}{n_order_fromfirst}.weight';
        end
    end
    
    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
    fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', mean(vals_tune));
    fclose(fid);
end

%% Output Average and standard deviation for all individual weights
for outputi = 1:2
    if outputi == 1
        outputType = 'average';
    else
        outputType = 'deviation';
    end

    outputcsv = sprintf('individualTest_%s_region_%d_%s.csv', time_stamp,regioni, outputType);
    fid = fopen(outputcsv, 'w');

    n_order_fromfirst_up = 1;
    n_region = 6;
    fprintf(fid, 'n_region,%d\n', n_region);
    if outputi == 1
        fprintf(fid, 'mean\n');
    else
        fprintf(fid, 'std\n');
    end

    vals_tune = zeros(15*info.opt_base.n_trial,size(EXP_INDV_REGION_NOANGLE_ms6{1}{regioni}.mInfo_tune{1}{1}.weight,1));
    for subjecti = 1:15
        for n_order_fromfirst=1:n_order_fromfirst_up
            n_trial = info.opt_base.n_trial;
            for trial=1:n_trial
                vals_tune((subjecti-1)*n_trial+trial,:) = EXP_INDV_REGION_NOANGLE_ms6{subjecti}{regioni}.mInfo_tune{trial}{n_order_fromfirst}.weight';
            end
        end
    end
    % fprintf(fid, '%f, %f\n', mean(vals_tune), std(vals_tune));
    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
    if outputi == 1
        fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', mean(vals_tune));
    else
        fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', std(vals_tune));
    end
    fclose(fid);
end