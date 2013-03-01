function NSS_ = testSaliencymapGBVS(ALLFeatures, faceFeatures, kyokai, testingdata, fromfirst)

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
        infos_base(N*(tm-1)+tn, :) = [tn tm 1 0 0 0]; % imgidx X Y P(NEXT)までの距離 P(PREV)からの距離 区分番号
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

th_near = get_distance(1.0)/minimize_scale;
NSS_ =[];

fprintf('%d testing datas\n', length(testingdata));
fprintf('Start testing... '); tic
for testidx=1:length(testingdata)
    if(mod(testidx,fix(length(testingdata)/10))==0)
        fprintf('*');
    end

    imgidx = testingdata{testidx}.imgidx;

    % ittikoch
    % graphbase
    color = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{1}, fixsize, 'bilinear');
    intensity = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{2}, fixsize, 'bilinear');
    orientation = imresize(ALLFeatures{imgidx}.graphbase.top_level_feat_maps{3}, fixsize, 'bilinear');
    face = faceFeatures{imgidx};

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
        %fprintf('IMG(%d),P(%f,%f),N(%f,%f)\n', imgidx, t_px, t_py, t_nx, t_ny);

        t_dis = testingdata{testidx}.sacinfo(i, 5);
        
        infos = infos_base;
        infos(:,3) = imgidx.*ones_;
        
        % 中心からの距離を計算
        infos(:,4) = sqrt((t_nx.*ones_-infos(:,1)).*(t_nx.*ones_-infos(:,1))+(t_ny.*ones_-infos(:,2)).*(t_ny.*ones_-infos(:,2)));
        infos(:,5) = sqrt((t_px.*ones_-infos(:,1)).*(t_px.*ones_-infos(:,1))+(t_py.*ones_-infos(:,2)).*(t_py.*ones_-infos(:,2)));
        
        calNp = 0;
        
        for k=1:size(kyokai, 2)
            if(t_dis < kyokai(1, k))
                calNp = k;
                break
            end
        end
        
        %infos(find(infos(:,5)<(get_distance(2)/minimize_scale)),6) = -1;
        for k=1:size(kyokai, 2)
            infos(find(infos(:,5)<kyokai(k)&infos(:,6)==0),6) = k;
        end
        kyokaiIdxMat = reshape(infos(:,6), N, M)';

        result = zeros(fixsize);
        num_feat = 9;
        %num_feat = 6;
        for k=1:length(kyokai)
            %if(calNp ~= k)
            %    continue
            %end
            calIdx = find(kyokaiIdxMat(:,:)==k);
            result(calIdx) = color(calIdx) + intensity(calIdx) + orientation(calIdx);
        end
        
        [result, meanVec, stdVec] = convert4NSS(result, find(kyokaiIdxMat(:,:)>0));

        nss_Tf = [nss_Tf result(t_ny, t_nx)];
    end

    if(length(nss_Tf)>0)
        NSS_ =[NSS_ mean(nss_Tf)];
    else
        % fprintf('invlid_testidx: %d\n', testidx);
    end

    %break
end

%fclose(fid);
fprintf([num2str(toc), ' seconds \n']);