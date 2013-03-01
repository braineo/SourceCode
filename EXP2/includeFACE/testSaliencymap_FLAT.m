function NSS_flat = testSaliencymap_FLAT(ALLFeatures, faceFeatures, testingdata, fromfirst)

minimize_scale = 6;
width = 1366;
height = 768;
M = round(height/minimize_scale);
N = round(width/minimize_scale);
% ------------------
%�f�B�X�v���C�ƖڂƂ̋���(m)
set_length_d2e = 1.33;
%�𑜓x(pixel)�Ƃ���ɑΉ��������(m)
set_kaizodo = 768.0;
set_nagasa = 0.802;
get_angle = @(d) (atan(d*set_nagasa/set_kaizodo/set_length_d2e)*180.0/pi);
get_distance = @(a) (tan(a*pi/180.0)*set_length_d2e*set_kaizodo/set_nagasa);
% ------------------

% Inputs
IMGS = 'C:\hg\Master\data\exp\EXP201109\images\final_resize'; %Change this to the path on your local computer
imagefiles = dir(fullfile(IMGS, '*.jpg'));
numImgs = length(imagefiles);
fixsize = [M N];

%outputcsv = 'result.csv';
%fid = fopen(outputcsv, 'w');

fprintf('Creating infos_base...\n'); tic
infos_base = zeros(M*N, 6);
for tm=1:M
    for tn=1:N
        infos_base(N*(tm-1)+tn, :) = [tn tm 1 0 0 0]; % imgidx X Y P(NEXT)�܂ł̋��� P(PREV)����̋��� �敪�ԍ�
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

th_near = get_distance(1.0)/minimize_scale;
NSS_flat =[];

fprintf('%d testing datas\n', length(testingdata));
fprintf('Start testing... '); tic
pre_imgidx = 0;
for testidx=1:length(testingdata)
    if(mod(testidx,fix(length(testingdata)/10))==0)
        fprintf('*');
    end

    imgidx = testingdata{testidx}.imgidx;

    if(pre_imgidx ~= imgidx)
        c1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{1}, fixsize, 'bilinear');
        c2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{2}, fixsize, 'bilinear');
        c3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{3}, fixsize, 'bilinear');
        i1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{1}, fixsize, 'bilinear');
        i2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{2}, fixsize, 'bilinear');
        i3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{3}, fixsize, 'bilinear');
        o1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{1}, fixsize, 'bilinear');
        o2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{2}, fixsize, 'bilinear');
        o3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{3}, fixsize, 'bilinear');
        color = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{1}, fixsize, 'bilinear');
        intensity = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{2}, fixsize, 'bilinear');
        orientation = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{3}, fixsize, 'bilinear');
        face = imresize(faceFeatures{imgidx}, fixsize, 'bilinear');
        pre_imgidx = imgidx;
    end

    nss_Tf = [];
    for i=1:size(testingdata{testidx}.sacinfo)
        if((fromfirst>0)&&(i > fromfirst))
            break
        end
        
        if(testingdata{testidx}.sacinfo(i, 6) == 0)
            continue
        end
        
        t_px = round(testingdata{testidx}.sacinfo(i, 1)+0.5);
        t_py = round(testingdata{testidx}.sacinfo(i, 2)+0.5);
        t_nx = round(testingdata{testidx}.sacinfo(i, 3)+0.5);
        t_ny = round(testingdata{testidx}.sacinfo(i, 4)+0.5);

        t_dis = testingdata{testidx}.sacinfo(i, 5);
        
        infos = infos_base;
        infos(:,3) = imgidx.*ones_;
        
        % ���S����̋������v�Z
        infos(:,4) = sqrt((t_nx.*ones_-infos(:,1)).*(t_nx.*ones_-infos(:,1))+(t_ny.*ones_-infos(:,2)).*(t_ny.*ones_-infos(:,2)));
        infos(:,5) = sqrt((t_px.*ones_-infos(:,1)).*(t_px.*ones_-infos(:,1))+(t_py.*ones_-infos(:,2)).*(t_py.*ones_-infos(:,2)));
        
        calNp = 0;
        
        infos(:,6) = 1;
        
        kyokaiIdxMat = reshape(infos(:,6), N, M)';

        result_flat = zeros(fixsize);
        
        calIdx = find(kyokaiIdxMat(:,:)==1);
        result_flat(calIdx) = color(calIdx) + intensity(calIdx) + orientation(calIdx) + face(calIdx);
        
        [result_flat, meanVec_flat, stdVec_flat] = convert4NSS(result_flat, find(kyokaiIdxMat(:,:)>0));

        nss_Tf = [nss_Tf result_flat(t_ny, t_nx)];
    end

    if(length(nss_Tf)>0)
        NSS_flat =[NSS_flat mean(nss_Tf)];
    end
end

%fclose(fid);
fprintf([num2str(toc), ' seconds \n']);