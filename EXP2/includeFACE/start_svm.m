
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

gauss = @(sig, d) (1/(sig * sqrt(2 * pi))) * exp(-((d.^2) ./ (2*(sig.^2))));

th_near = get_distance(1.0)/minimize_scale;
th_far = get_distance(4.0)/minimize_scale;


smv_t0 = 100;
svm_lamda = 0.01;
svm_skip = 100;

posisize = 200000;
ngrate = 2;

% ------------------

c_dis = [2 5 8 12 16 21 26 32 38 45 52];
c_ang = [0 45 90 135 180 225 270 315;22.5 67.5 112.5 157.5 200.5 247.5 292.5 337.5];
A=[0 0];
for i=1:size(c_dis, 2)
    for j=1:size(c_ang, 2)
        c_dr = get_distance(c_dis(i))/minimize_scale;
        c_da = c_ang(mod((i+1),size(c_ang, 1))+1, j)/180*pi;
        A=[A; [round(c_dr*sin(c_da)) round(c_dr*cos(c_da))]];
    end
end
% scatter(A(:,1),A(:,2))
TRI = DelaunayTri(A(:,1),A(:,2));

% ------------------

mNSS = {};
mTesting = {};
mW = {};

for trial=1:1

fprintf('XXXXXXXXXXXXXXX trial: %d\n', trial);

mNSS{trial} = {};
mTesting{trial} = {};
mW{trial} = {};

fprintf('Selecting training & testingsamles ...'); tic

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

            clear t_px t_py t_nx t_ny t_dis
        end

        if(training_flag == 0)
            testingsamles{length(testingsamles) + 1} = testing;
        end

        clear testing fix_length sacinfo_c
    end
end
sample_saccade = sample_saccade(1:c_sample_saccade,:);
fprintf([num2str(toc), ' seconds \n']);

fprintf('trainingsample: %d, testingsample: %d\n', c_sample_saccade, length(testingsamles));

fprintf('Creating infos_base...\n'); tic
infos_base = zeros(M*N, 7);
for tm=1:M
    for tn=1:N
        infos_base(N*(tm-1)+tn, :) = [0 tn tm 0 0 0 0]; % imgidx X Y 
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

for order_fromfirst=1:1
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
    
    num_feat = 10;
    
    infomat_near = zeros(posisize,num_feat+3);
    infomat_far = zeros(posisize*ngrate,num_feat+3);
    
    rate = 1;
    psamples = 100*size(sample_order1, 1);
    if(psamples > posisize)
        rate = psamples/posisize;
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
        
        color = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{1}, [M N], 'bilinear');
        intensity = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{2}, [M N], 'bilinear');
        orientation = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{3}, [M N], 'bilinear');
        face = faceFeatures{imgidx};
        
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
            infomat(:,6) = t_nx - t_px;
            infomat(:,7) = t_ny - t_py;

            t_infomat_near = infomat(find(infomat(:,4)<th_near),:);
            t_infomat_far = infomat(find(infomat(:,4)>th_far),:);
            num_near_all = num_near_all + size(t_infomat_near, 1);
            num_far_all = num_far_all + size(t_infomat_far, 1);
            
            t_infomat_near_sel = randperm(size(t_infomat_near,1));
            t_infomat_far_sel = randperm(size(t_infomat_far,1));
            
            t_infomat_near_sel = t_infomat_near_sel(1:round(size(t_infomat_near,1)/rate));
            t_infomat_far_sel = t_infomat_far_sel(1:size(t_infomat_near_sel,2)*ngrate);

            for j=1:size(t_infomat_near_sel,2)
                ji=t_infomat_near_sel(j);
                c_near = c_near+1;
                item = t_infomat_near(ji,:)';
                
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) face(item(3),item(2))...
                item(6) item(7) 1];
                infomat_near(c_near,:)=item_main(:);
                clear item item_main
            end

            for j=1:size(t_infomat_far_sel,2)
                ji=t_infomat_far_sel(j);
                c_far = c_far + 1;
                item = t_infomat_far(ji,:)';
                
                item_main = [c1(item(3),item(2)) c2(item(3),item(2)) c3(item(3),item(2))...
                i1(item(3),item(2)) i2(item(3),item(2)) i3(item(3),item(2))...
                o1(item(3),item(2)) o2(item(3),item(2)) o3(item(3),item(2)) face(item(3),item(2))...
                item(6) item(7) -1];
                infomat_far(c_far,:)=item_main(:);
                clear item item_main
            end

            clear t_px t_py t_nx t_ny infomat t_infomat_near t_infomat_far t_infomat_near_sel t_infomat_far_sel
        end
        
        clear sample_imgidx c1 c2 c3 i1 i2 i3 o1 o2 o3 color intensity orientation face
    end
    fprintf([num2str(toc), ' seconds \n']);
    fprintf('all: num_near:%d num_far:%d\n', num_near_all, num_far_all);
    fprintf('use: num_near:%d num_far:%d\n', c_near, c_far);

    fprintf('learning...\n');

    infomat_near = infomat_near(1:c_near,:);
    infomat_far = infomat_far(1:c_far,:);
    infomat_final = [infomat_near;infomat_far];
    clear infomat_near infomat_far;

    infomat_final_sel = randperm(size(infomat_final,1));
    infomat_final = infomat_final(infomat_final_sel, :);
    
    t_W=zeros(10, size(TRI.X, 1));
    t_b=zeros(1, size(TRI.X, 1));
    svm_t = 0;
    svm_count = svm_skip;
    for i=1:size(infomat_final, 1)
        
        item = infomat_final(i,:);
        
        t_Coding = getWeight(TRI, item(11), item(12)) / (svm_lamda*(svm_t + smv_t0));
        t_H = 1 - item(13) * (t_Coding * t_W' * item(1:10)' + t_Coding * t_b');
        
        if(t_H > 0)
            t_W = t_W + item(13) * item(1:10)'* t_Coding;
            t_b = t_b + item(13) * getWeight(TRI, item(11), item(12)) / (svm_lamda*(svm_t + smv_t0));
        end
        
        svm_count = svm_count - 1;
        
        if(svm_count <= 0)
            t_W = t_W .* (1-svm_skip/(svm_t + smv_t0));
            svm_count = svm_skip;
        end
        
        svm_t = svm_t + 1;
        
        clear item
        
        if(mod(i,1000)==1)
            fprintf('%d, ', i);
        end

        if(mod(i,10000)==0)
            fprintf('\n');
            break
        end
    end
    fprintf([num2str(toc), ' seconds \n']);
    clear infomat_final infomat_final_sel;

    NSS = testSaliencymapSVM(TRI, t_W, t_b, ALLFeatures, faceFeatures, testingsamles, order_fromfirst);
    mNSS{trial}{order_fromfirst} = NSS;
    mTesting{trial}{order_fromfirst} = testingsamles;
    mW{trial}{order_fromfirst} = t_W;

    

end
end

savefile = '../../storage/EXP_SVM.mat'
save(savefile,'mNSS','mTesting','-v7.3');

