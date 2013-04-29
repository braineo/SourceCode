%% Output exp result to csv

clear vals_tune

regioni = 6;
time_stamp = datestr(now,'yyyymmddHHMM');
subjecti = 1;
    outputcsv = sprintf('allSample_alltestSubject#%d.csv',subjecti);
%     outputcsv = sprintf('allSample_alltestSubjectNSS.csv');
    fid = fopen(outputcsv, 'w');

    
    vals_tune = EXP_INDV_REGION_NOANGLE_ms6{subjecti}{6}.mInfo_tune{1}.weight';
%     vals_tune = EXP_INDV_REGION_NOANGLE_ms6{6}.mInfo_tune{1}.weight';
%     vals_tune = EXP_INDV_REGION_NOANGLE_ms6{6}.mNSS_tune{1}';
 
    fprintf(fid, ',C1,C2,C3,I1,I2,I3,O1,O2,O3,F\n');
%     fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', mean(vals_tune),std(vals_tune));
    fprintf(fid, ',%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\n', vals_tune);
    fclose(fid);


