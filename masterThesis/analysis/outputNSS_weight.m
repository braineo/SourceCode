%{
clear all
loadfile_noangle = '../../storage/EXP_ms6_201112312351_noangle.mat'
loadfile_angle = '../../storage/EXP_ms6_201112290241_angle.mat'

load(loadfile_noangle); % 'EXP1_REGION_NOANGLE_ms6','info'
load(loadfile_angle); % 'EXP1_REGION_ANGLE_ms6','info'
%}
clear all
loadfile = '../../storage/EXP_ms6_201201031403.mat'
load(loadfile); % 'EXP1_REGION_NOANGLE_ms6','EXP1_REGION_ANGLE_ms6','info'

n_order_fromfirst = 1;
n_region_set = 6;

for n_region=n_region_set:n_region_set
    n_trial = info.opt_base.n_trial;
    m_weight1 = zeros(size(EXP1_REGION_NOANGLE_ms6{n_region}.mInfo_tune{1}{n_order_fromfirst}.weight, 1),1);
    for trial=1:n_trial
        m_weight1 = m_weight1 + EXP1_REGION_NOANGLE_ms6{n_region}.mInfo_tune{trial}{n_order_fromfirst}.weight;
    end
    m_weight1 = m_weight1./n_trial;
end

for n_region=n_region_set:n_region_set
    n_trial = info.opt_base.n_trial;
    m_weight2 = zeros(size(EXP1_REGION_ANGLE_ms6{n_region}.mInfo_tune{1}{n_order_fromfirst}.weight, 1),1);
    for trial=1:n_trial
        m_weight2 = m_weight2 + EXP1_REGION_ANGLE_ms6{n_region}.mInfo_tune{trial}{n_order_fromfirst}.weight;
    end
    m_weight2 = m_weight2./n_trial;
end

featlab = {'F', 'C1', 'C2', 'C3', 'I1', 'I2', 'I3', 'O1', 'O2', 'O3'};
num_feat = length(featlab);

%{
outputcsv = sprintf('outputNSS_C_vary_%d_noangle.csv', n_region_set);
fid = fopen(outputcsv, 'w');
for l=1:num_feat
    fprintf(fid, '\t%s', featlab{l});
end
fprintf(fid, '\n');
for r=1:n_region_set
    fprintf(fid, '''%d''', r);
    fprintf(fid, '\t%f', m_weight1(num_feat*(r-1)+num_feat,1));
    for f=1:num_feat-1
        fprintf(fid, '\t%f', m_weight1(num_feat*(r-1)+f,1));
    end
    if(r ~= n_region_set)
        fprintf(fid, '\n');
    end
end
fclose(fid);
%}

m_weight2_a = zeros(n_region_set*num_feat, 3);

for r=1:n_region_set
    for a=1:3
        for f=1:num_feat
            m_weight2_a(num_feat*(r-1)+f,a) = m_weight2(num_feat*(r-1)*3+num_feat*(a-1)+f,1);
        end
    end
end

