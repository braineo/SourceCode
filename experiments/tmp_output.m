%% Output exp result to csv

clear vals_tune

regioni = 6;
time_stamp = datestr(now,'yyyymmddHHMM');
for subjecti = 1:1
    outputcsv = sprintf('testSubject#%d.csv',subjecti);
%     outputcsv = sprintf('allSample_alltestSubjectNSS.csv');
    fid = fopen(outputcsv, 'w');

    
%     vals_tune = EXP_INDV_REGION_NOANGLE_ms6{subjecti}{6}.mInfo_tune{1}.weight';
%     vals_tune = EXP_INDV_REGION_NOANGLE_ms6{6}.mInfo_tune{1}.weight';
%     vals_tune = EXP_INDV_REGION_NOANGLE_ms6{6}.mNSS_tune{1}';
 vals_tune = EXP_INDV_REGION_NOANGLE_ms6{subjecti}.mInfo_tune{1}.weight';

    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
%     fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', mean(vals_tune),std(vals_tune));
    fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', vals_tune);
    fclose(fid);
end

