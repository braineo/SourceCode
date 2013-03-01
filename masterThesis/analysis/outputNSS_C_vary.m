clear all
loadfile_noangle = '../../storage/EXP_ms6_201112312351_noangle.mat'
loadfile_angle = '../../storage/EXP_ms6_201112290241_angle.mat'

load(loadfile_noangle); % 'EXP1_REGION_NOANGLE_ms6','info'
load(loadfile_angle); % 'EXP1_REGION_ANGLE_ms6','info'

time_stamp = datestr(now,'yyyymmddHHMM');
outputcsv = sprintf('outputNSS_C_vary_%s.csv', time_stamp);
fid = fopen(outputcsv, 'w');

n_order_fromfirst = 1;

fprintf(fid, 'noangle\n');

for n_region=1:10
    n_trial = info.opt_base.n_trial;
    vals_tune = [];
    for trial=1:n_trial
        vals_tune = [vals_tune mean(EXP1_REGION_NOANGLE_ms6{n_region}.mNSS_tune{trial}{n_order_fromfirst})];
    end
    fprintf(fid, '%d,%f,%f\n', n_region, mean(vals_tune), std(vals_tune));
end

fprintf(fid, 'angle\n');

for n_region=1:10
    n_trial = info.opt_base.n_trial;
    vals_tune = [];
    for trial=1:n_trial
        vals_tune = [vals_tune mean(EXP1_REGION_ANGLE_ms6{n_region}.mNSS_tune{trial}{n_order_fromfirst})];
    end
    fprintf(fid, '%d,%f,%f\n', n_region, mean(vals_tune), std(vals_tune));
end

fclose(fid);
