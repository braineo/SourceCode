clear all
loadfile = '../../storage/EXP_ms6_201201031403.mat'
load(loadfile); % 'EXP1_REGION_NOANGLE_ms6','EXP1_REGION_ANGLE_ms6','info'

time_stamp = datestr(now,'yyyymmddHHMM');
outputcsv = sprintf('outputNSS_c1_c6_%s.csv', time_stamp);
fid = fopen(outputcsv, 'w');

n_order_fromfirst_up = 5;
%n_region = 1;
n_region = 6;
fprintf(fid, 'n_region,%d\n', n_region);

fprintf(fid, 'noangle\n');

for n_order_fromfirst=1:n_order_fromfirst_up
    n_trial = info.opt_base.n_trial;
    vals_tune = [];
    for trial=1:n_trial
        vals_tune = [vals_tune mean(EXP1_REGION_NOANGLE_ms6{n_region}.mNSS_tune{trial}{n_order_fromfirst})];
    end
    fprintf(fid, '%d,%f,%f\n', n_order_fromfirst, mean(vals_tune), std(vals_tune));
end

fprintf(fid, 'angle\n');

for n_order_fromfirst=1:n_order_fromfirst_up
    n_trial = info.opt_base.n_trial;
    vals_tune = [];
    for trial=1:n_trial
        vals_tune = [vals_tune mean(EXP1_REGION_ANGLE_ms6{n_region}.mNSS_tune{trial}{n_order_fromfirst})];
    end
    fprintf(fid, '%d,%f,%f\n', n_order_fromfirst, mean(vals_tune), std(vals_tune));
end

fclose(fid);
