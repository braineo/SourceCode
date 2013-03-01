
datafolder = './of/';

EXPALLFixations = {};
for imgidx = 1:400
    Fixations = {};
    EXPALLFixations{imgidx} = Fixations;
end

for imgidx = 1:400
    for subject = 0:14
        datafile = sprintf('%s%02d%03d.csv', datafolder, subject, imgidx);
        eyedata = load(datafile);
        [data,Fix,Sac] = getFixations(eyedata);
        EXPALLFixations{imgidx}{length(EXPALLFixations{imgidx})+1}=Fix;
    end
end

savefile = './storage/EXPALLFixations.mat'
save(savefile, 'EXPALLFixations', '-v7.3');
