
clear all

fprintf('Load EXPALLFixations, EXPALLFeatures...'); tic
load('C:\hg\Master\code\matlab\storage\EXPALLFixations.mat'); % EXPALLFixations
load('C:\hg\Master\code\matlab\storage\EXPALLFeatures.mat'); % ALLFeatures
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


weight_tune = {};
weight_tuneA = {};
weight_tuneB = {};
weight_tuneC = {};
weight_all = {};
mNSS_tuned1 = {};
mNSS_tunedA = {};
mNSS_tunedB = {};
mNSS_tunedC = {};
mNSS_tuned_all = {};
mNSS_flat = {};

mTesting = {};

for trial=1:8

fprintf('XXXXXXXXXXXXXXX trial: %d\n', trial);

weight_tune{trial} = {};
weight_tuneA{trial} = {};
weight_tuneB{trial} = {};
weight_tuneC{trial} = {};
weight_all{trial} = {};
mNSS_tuned1{trial} = {};
mNSS_tunedA{trial} = {};
mNSS_tunedB{trial} = {};
mNSS_tunedC{trial} = {};
mNSS_tuned_all{trial} = {};
mNSS_flat{trial} = {};

mTesting{trial} = {};

fprintf('Selecting training & testingsamles ...'); tic
outputcsv = 'saccade.csv';
fid = fopen(outputcsv, 'w');

sample_saccade = zeros(100000,8);
testingsamles = {};
c_sample_saccade=0;
for imgidx=1:400
    for subidx=1:length(EXPALLFixations{imgidx})
        fix_length = size(EXPALLFixations{imgidx}{subidx}.medianXY, 1);
        if(fix_length < 2)
            continue
        end
        
        training_flag = 0;
        
        if(rand >.5)
            training_flag = 1;
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
                valid_flag = 0;
            end
            
            if(training_flag == 1)
                c_sample_saccade = c_sample_saccade + 1;
                sample_saccade(c_sample_saccade,:) = [imgidx i-1 t_px t_py t_nx t_ny t_dis valid_flag];
            end
            
            testing.sacinfo(i-1, :) = [t_px t_py t_nx t_ny t_dis valid_flag];

            fprintf(fid, '%f,%d,%d,%f\n', valid_flag, imgidx, i-1, get_angle(t_dis*minimize_scale));
            clear t_px t_py t_nx t_ny t_dis
        end

        if(training_flag == 0)
            testingsamles{length(testingsamles) + 1} = testing;
        end

        clear testing fix_length sacinfo_c
    end
end
sample_saccade = sample_saccade(1:c_sample_saccade,:);

fclose(fid);
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

for order_fromfirst=1:4
%order_fromfirst: 最初から何回目までのサッケードを考えるか

fprintf('---------------- order_fromfirst: %d\n', order_fromfirst);

    sample_order1 = sample_saccade(find(sample_saccade(:,2)<=order_fromfirst&sample_saccade(:,8)==1),:);
    sample_order1_perm = randperm(size(sample_order1, 1));
    sample_order1 = sample_order1(sample_order1_perm, :);

    %---------------

    num_near_all = 0;
    num_far_all = 0;
    c_near = 0;
    c_far = 0;

    c_far_A = 0;
    c_far_B = 0;
    %c_far_C = 0;


    %num_feat = 6;
    num_feat = 9;

    infomat_near = zeros(200000,num_feat*size(kyokai,2));
    infomat_far = zeros(2000000,num_feat*size(kyokai,2));
    
    %infomat_far_A = zeros(3000000,num_feat*size(kyokai,2));
    %infomat_far_B = zeros(4000000,num_feat*size(kyokai,2));
    %infomat_far_C = zeros(1000000,num_feat*size(kyokai,2));
    
    infomat_near_noborder = zeros(200000,num_feat);
    infomat_far_noborder = zeros(2000000,num_feat);

    rate = 1;
    psamples = 100*size(sample_order1, 1);
    if(psamples > 200000)
        rate = psamples/200000;
    end
    
    rate

    fprintf('Prepare Training...'); tic
    for imgidx=1:400
        fprintf('%d, ', imgidx);
        if(mod(imgidx,15)==1)
            fprintf('\n');
        end
        sample_imgidx = sample_order1(find(sample_order1(:,1)==imgidx),:);
        if(size(sample_imgidx, 1)==0)
            clear sample_imgidx
            continue
        end
        
        c1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{1}, [M N], 'bilinear');
        c2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{2}, [M N], 'bilinear');
        c3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{3}, [M N], 'bilinear');
        i1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{1}, [M N], 'bilinear');
        i2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{2}, [M N], 'bilinear');
        i3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{3}, [M N], 'bilinear');
        o1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{1}, [M N], 'bilinear');
        o2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{2}, [M N], 'bilinear');
        o3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{3}, [M N], 'bilinear');
        
        for i=1:size(sample_imgidx,1)
            infomat = infos_base;
            infomat(:,1) = imgidx;
            t_px = sample_imgidx(i, 3);
            t_py = sample_imgidx(i, 4);
            t_nx = sample_imgidx(i, 5);
            t_ny = sample_imgidx(i, 6);
            
            infomat(:,4) = ...
            sqrt(((t_nx+0.5).*ones_-infomat(:,2)).*((t_nx+0.5).*ones_-infomat(:,2))+...
                 ((t_ny+0.5).*ones_-infomat(:,3)).*((t_ny+0.5).*ones_-infomat(:,3)));
            infomat(:,5) = ...
            sqrt(((t_px+0.5).*ones_-infomat(:,2)).*((t_px+0.5).*ones_-infomat(:,2))+...
                 ((t_py+0.5).*ones_-infomat(:,3)).*((t_py+0.5).*ones_-infomat(:,3)));

            for k=1:size(kyokai,2)
                infomat(find(infomat(:,5)<kyokai(1,k)&infomat(:,6)==0),6) = k;
            end

            t_infomat_near = infomat(find(infomat(:,4)<th_near&infomat(:,6)~=0),:);
            t_infomat_far = infomat(find(infomat(:,4)>th_far&infomat(:,6)~=0),:);
            num_near_all = num_near_all + size(t_infomat_near, 1);
            num_far_all = num_far_all + size(t_infomat_far, 1);
            
            t_infomat_near_sel = randperm(size(t_infomat_near,1));
            t_infomat_far_sel = randperm(size(t_infomat_far,1));
            
            t_infomat_near_sel = t_infomat_near_sel(1:round(size(t_infomat_near,1)/rate));
            
            t_infomat_far_sel_A = t_infomat_far_sel(1:round(size(t_infomat_near_sel,2)*15));
            t_infomat_far_sel_B = t_infomat_far_sel(1:round(size(t_infomat_near_sel,2)*20));
            %t_infomat_far_sel_C = t_infomat_far_sel;

            t_infomat_far_sel = t_infomat_far_sel(1:size(t_infomat_near_sel,2)*10);

            for j=1:size(t_infomat_near_sel,2)
                ji=t_infomat_near_sel(j);
                c_near = c_near+1;
                item = t_infomat_near(ji,:)';
                kyokai_idx = item(6);
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                %{
                item_main = [c1(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o3(item(3),item(2)) ];
                %}
                %item_main = [ o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                infomat_near(c_near,num_feat*(kyokai_idx-1)+1:num_feat*kyokai_idx)=item_main(:);
                infomat_near_noborder(c_near,1:num_feat)=item_main(:);
                clear item item_main
            end

            for j=1:size(t_infomat_far_sel,2)
                ji=t_infomat_far_sel(j);
                c_far = c_far + 1;
                item = t_infomat_far(ji,:)';
                kyokai_idx = item(6);
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                %{
                item_main = [c1(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o3(item(3),item(2)) ];
                %}
                %item_main = [ o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                infomat_far(c_far,num_feat*(kyokai_idx-1)+1:num_feat*kyokai_idx)=item_main(:);
                infomat_far_noborder(c_far,1:num_feat)=item_main(:);
                clear item item_main
            end

            %{
            for j=1:size(t_infomat_far_sel_A,2)
                ji=t_infomat_far_sel_A(j);
                c_far_A = c_far_A + 1;
                item = t_infomat_far(ji,:)';
                kyokai_idx = item(6);
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                infomat_far_A(c_far_A,num_feat*(kyokai_idx-1)+1:num_feat*kyokai_idx)=item_main(:);
                clear item item_main
            end

            for j=1:size(t_infomat_far_sel_B,2)
                ji=t_infomat_far_sel_B(j);
                c_far_B = c_far_B + 1;
                item = t_infomat_far(ji,:)';
                kyokai_idx = item(6);
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) ];
                infomat_far_B(c_far_B,num_feat*(kyokai_idx-1)+1:num_feat*kyokai_idx)=item_main(:);
                clear item item_main
            end
            %}

            clear t_px t_py t_nx t_ny infomat t_infomat_near t_infomat_far t_infomat_near_sel t_infomat_far_sel
        end
        
        clear sample_imgidx c1 c2 c3 i1 i2 i3 o1 o2 o3
        %clear sample_imgidx c1 c3 i1 i3 o1 o3
        %clear sample_imgidx o1 o2 o3
    end
    fprintf([num2str(toc), ' seconds \n']);
    fprintf('all: num_near:%d num_far:%d\n', num_near_all, num_far_all);
    fprintf('use: num_near:%d num_far:%d num_far_A:%d num_far_B:%d\n', c_near, c_far, c_far_A, c_far_B);

    infomat_near = infomat_near(1:c_near,:);
    infomat_far = infomat_far(1:c_far,:);
    %{
    infomat_far_A = infomat_far_A(1:c_far_A,:);
    infomat_far_B = infomat_far_B(1:c_far_B,:);
    %infomat_far_C = infomat_far_C(1:c_far_C,:);
    %}
    
    infomat_near_noborder = infomat_near_noborder(1:c_near,:);
    infomat_far_noborder = infomat_far_noborder(1:c_far,:);

    featall = [infomat_near; infomat_far];
    %{
    featall_A = [infomat_near; infomat_far_A];
    featall_B = [infomat_near; infomat_far_B];
    %featall_C = [infomat_near; infomat_far_C];
    %}
    featall_noborder = [infomat_near_noborder; infomat_far_noborder];
    %labelall = [50*(c_far/c_near).*ones(c_near, 1); zeros(c_far, 1)];
    labelall = [ones(c_near, 1); zeros(c_far, 1)];
    %{
    labelall_A = [ones(c_near, 1); zeros(c_far_A, 1)];
    labelall_B = [ones(c_near, 1); zeros(c_far_B, 1)];
    %}
    %labelall_C = [ones(c_near, 1); zeros(c_far_C, 1)];
    
    %clear infomat_near infomat_far infomat_far_A infomat_far_B infomat_near_noborder infomat_far_noborder;
    clear infomat_near infomat_far infomat_near_noborder infomat_far_noborder;

    fprintf('Training...'); tic
    fprintf('|1|');
    [x_,resnorm_,residual_,exitflag_,output_,lambda_]  =  lsqnonneg(featall, labelall);
    %{
    fprintf('|A|');
    [xA_,resnormA_,residualA_,exitflagA_,outputA_,lambdaA_]  =  lsqnonneg(featall_A, labelall_A);
    fprintf('|B|');
    [xB_,resnormB_,residualB_,exitflagB_,outputB_,lambdaB_]  =  lsqnonneg(featall_B, labelall_B);
    fprintf('|C|');
    %[xC_,resnormC_,residualC_,exitflagC_,outputC_,lambdaC_]  =  lsqnonneg(featall_C, labelall_C);
    %}
    fprintf('|N|');
    x_noborder=[];
    [x_noborder,resnorm_noborder,residual_noborder,exitflag_noborder,output_noborder,lambda_noborder]  =  lsqnonneg(featall_noborder, labelall);
    fprintf([num2str(toc), ' seconds \n']);
    
    clear featall featall_A featall_B labelall labelall_A labelall_B featall_noborder;

    [NSS_tuned1, NSS_tuned_all, NSS_flat] = testSaliencymap(ALLFeatures, kyokai, x_, x_noborder, testingsamles, order_fromfirst);
    %{
    [NSS_tunedA, NSS_tuned_all, NSS_flat] = testSaliencymap(ALLFeatures, kyokai, xA_, x_noborder, testingsamles, order_fromfirst);
    [NSS_tunedB, NSS_tuned_all, NSS_flat] = testSaliencymap(ALLFeatures, kyokai, xB_, x_noborder, testingsamles, order_fromfirst);
    %[NSS_tunedC, NSS_tuned_all, NSS_flat] = testSaliencymap(ALLFeatures, kyokai, xC_, x_noborder, testingsamles, order_fromfirst);
    %}

    weight_tune{trial}{order_fromfirst} = x_;
    weight_all{trial}{order_fromfirst} = x_noborder;
    mNSS_tuned1{trial}{order_fromfirst} = NSS_tuned1;
    mNSS_tuned_all{trial}{order_fromfirst} = NSS_tuned_all;
    mNSS_flat{trial}{order_fromfirst} = NSS_flat;
    
    %{
    weight_tuneA{trial}{order_fromfirst} = xA_;
    mNSS_tunedA{trial}{order_fromfirst} = NSS_tunedA;
    weight_tuneB{trial}{order_fromfirst} = xB_;
    mNSS_tunedB{trial}{order_fromfirst} = NSS_tunedB;
    %weight_tuneC{trial}{order_fromfirst} = xC_;
    %mNSS_tunedC{trial}{order_fromfirst} = NSS_tunedC;
    %}

    mTesting{trial}{order_fromfirst} = testingsamles;

end
end

savefile = '../storage/EXP2_test201111011.mat'
%save(savefile, 'weight_tune','weight_all','mNSS_tuned1','mNSS_tunedA','mNSS_tunedB','mNSS_tunedC','mNSS_tuned_all','mNSS_flat','-v7.3');
%save(savefile, 'weight_tune','weight_tuneA','weight_tuneB','weight_all','mNSS_tuned1','mNSS_tunedA','mNSS_tunedB','mNSS_tunedC','mNSS_tuned_all','-v7.3');
save(savefile, 'weight_tune','weight_all','mNSS_tuned1','mNSS_tuned_all','mTesting','-v7.3');

