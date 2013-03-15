clear vals_tune
% loadfile = '../Output/storage/individualDifference/indiviTest01_201303042329.mat'
% load(loadfile);

for regioni = 6:6
time_stamp = datestr(now,'yyyymmddHHMM');
outputcsv = sprintf('individualTest_%s_region%d.csv', time_stamp,regioni);
fid = fopen(outputcsv, 'w');

n_order_fromfirst_up = 1;
%n_region = 1;
n_region = 10;
fprintf(fid, 'n_region,%d\n', n_region);

fprintf(fid, 'mean,std\n');
vals_tune = zeros(15*info.opt_base.n_trial,size(EXP1_REGION_NOANGLE_ms6{1}{regioni}.mInfo_tune{1}{1}.weight,1));
for subjecti = 1:15
    for n_order_fromfirst=1:n_order_fromfirst_up
        n_trial = info.opt_base.n_trial;     
        for trial=1:n_trial
            vals_tune((subjecti-1)*10+trial,:) = EXP1_REGION_NOANGLE_ms6{subjecti}{regioni}.mInfo_tune{trial}{n_order_fromfirst}.weight';
        end
    end
end
fprintf(fid, '%f,%f\n', mean(vals_tune)', std(vals_tune)');
fclose(fid);
end