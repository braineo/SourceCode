
clear all

fprintf('Load EXPALLFixations, EXPALLFeatures...'); tic
load('C:\hg\Master\code\matlab\storage\EXPALLFixations.mat'); % EXPALLFixations
load('C:\hg\Master\code\matlab\storage\EXPALLFeatures.mat'); % ALLFeatures
load('C:\hg\Master\code\matlab\storage\EXPfaceFeatures.mat'); % faceFeatures
fprintf([num2str(toc), ' seconds \n']);

rand('state',sum(100*clock));

minimize_scale = 4;
width = 1366;
height = 768;
M = round(height/minimize_scale);
N = round(width/minimize_scale);
% ------------------
%ディスプレイと目との距離(m)
set_length_d2e = 1.33;
%解像度(pixel)とそれに対応する実寸(m)
set_kaizodo = 768.0;
set_nagasa = 0.802;
get_angle = @(d) (atan(d*set_nagasa/set_kaizodo/set_length_d2e)*180.0/pi);
get_distance = @(a) (tan(a*pi/180.0)*set_length_d2e*set_kaizodo/set_nagasa);
% ------------------

kyokai = [get_distance(6) get_distance(9) get_distance(12) get_distance(16) get_distance(22) get_distance(80)];
kyokai = kyokai/minimize_scale;

fprintf('Selecting training & testingsamles ...'); tic

testingsamles = {};
c_sample_saccade=0;
for imgidx=1:400
    for subidx=1:length(EXPALLFixations{imgidx})
        fix_length = size(EXPALLFixations{imgidx}{subidx}.medianXY, 1);
        if(fix_length < 2)
            continue
        end

        testing = {};
        testing.imgidx = imgidx;
        testing.sacinfo = zeros(fix_length-1, 6);

        for i=2:fix_length
            valid_flag = 1;
        
            if(EXPALLFixations{imgidx}{subidx}.medianXY(i, 1) < 0 || EXPALLFixations{imgidx}{subidx}.medianXY(i, 2) < 0 || ...
               EXPALLFixations{imgidx}{subidx}.medianXY(i, 1) >= width || EXPALLFixations{imgidx}{subidx}.medianXY(i, 2) >= height)
                valid_flag = 0;
            end
            t_px = EXPALLFixations{imgidx}{subidx}.medianXY(i-1, 1)/minimize_scale;
            t_py = EXPALLFixations{imgidx}{subidx}.medianXY(i-1, 2)/minimize_scale;
            t_nx = EXPALLFixations{imgidx}{subidx}.medianXY(i, 1)/minimize_scale;
            t_ny = EXPALLFixations{imgidx}{subidx}.medianXY(i, 2)/minimize_scale;
            t_dis = norm([t_px-t_nx t_py-t_ny]);

            if(t_dis<get_distance(2)/minimize_scale)
                %valid_flag = 0;
            end
            
            testing.sacinfo(i-1, :) = [t_px t_py t_nx t_ny t_dis valid_flag];
            clear t_px t_py t_nx t_ny t_dis
        end

        testingsamles{length(testingsamles) + 1} = testing;
        clear testing fix_length sacinfo_c
    end
end
fprintf([num2str(toc), ' seconds \n']);

fprintf('trainingsample: %d, testingsample: %d\n', c_sample_saccade, length(testingsamles));

fprintf('Creating infos_base...\n'); tic
infos_base = zeros(M*N, 6);
for tm=1:M
    for tn=1:N
        infos_base(N*(tm-1)+tn, :) = [0 tn tm 0 0 0]; % imgidx X Y P(NEXT)までの距離 P(PREV)からの距離 区分番号
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

th_near = get_distance(1.0)/minimize_scale;
th_far = get_distance(4.0)/minimize_scale;

NSS_flat = {};

for order_fromfirst=1:5
%order_fromfirst: 最初から何回目までのサッケードを考えるか
fprintf('---------------- order_fromfirst: %d\n', order_fromfirst);
    NSS_flat{order_fromfirst} = testSaliencymapFlat(ALLFeatures, faceFeatures, kyokai, testingsamles, order_fromfirst);
end
fprintf('order_fromfirst,mean\n');
for order_fromfirst=1:5
    fprintf('%d,%f\n',order_fromfirst, mean(NSS_flat{order_fromfirst}));
end