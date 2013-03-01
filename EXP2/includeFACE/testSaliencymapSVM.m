function NSS_ = testSaliencymapSVM(TRI, W, B, ALLFeatures, faceFeatures, testingdata, fromfirst);

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
infos_base = zeros(M*N, 5);
for tm=1:M
    for tn=1:N
        infos_base(N*(tm-1)+tn, :) = [tn tm 1 0 0]; % imgidx X Y P(NEXT)までの距離 P(PREV)からの距離
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

th_near = get_distance(1.0)/minimize_scale;
NSS_ =[];

fprintf('%d testing datas\n', length(testingdata));
fprintf('Start testing... '); tic
for testidx=1:length(testingdata)
    %if(mod(testidx,fix(length(testingdata)/10))==0)
    %if(mod(testidx,20)==1)
        fprintf('%d, ', testidx);
    %end

    if(mod(testidx,fix(length(testingdata)/10))==0)
        fprintf('\n');
    end

    imgidx = testingdata{testidx}.imgidx;

    c1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{1}, fixsize, 'bilinear');
    c2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{2}, fixsize, 'bilinear');
    c3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{1}{3}, fixsize, 'bilinear');
    i1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{1}, fixsize, 'bilinear');
    i2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{2}, fixsize, 'bilinear');
    i3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{2}{3}, fixsize, 'bilinear');
    o1 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{1}, fixsize, 'bilinear');
    o2 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{2}, fixsize, 'bilinear');
    o3 = imresize(ALLFeatures{imgidx}.graphbase.scale_maps{3}{3}, fixsize, 'bilinear');
    face = faceFeatures{imgidx};
    
    v_c1 = reshape(c1, M*N, 1);
    v_c2 = reshape(c2, M*N, 1);
    v_c3 = reshape(c3, M*N, 1);
    v_i1 = reshape(i1, M*N, 1);
    v_i2 = reshape(i2, M*N, 1);
    v_i3 = reshape(i3, M*N, 1);
    v_o1 = reshape(o1, M*N, 1);
    v_o2 = reshape(o2, M*N, 1);
    v_o3 = reshape(o3, M*N, 1);
    v_face = reshape(face, M*N, 1);
    
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
        
        infos(:,4) = (t_px.*ones_-infos(:,1));
        infos(:,5) = (t_py.*ones_-infos(:,2));
        
        w_ = zeros(M*N, size(TRI.X, 1));
        for tm=1:M
            for tn=1:N
                w_(N*(tm-1)+tn, 1:size(TRI.X, 1)) = getWeight(TRI, infos(N*(tm-1)+tn,4), infos(N*(tm-1)+tn,5));
            end
        end
        tmp = W'*[v_c1 v_c2 v_c3 v_i1 v_i2 v_i3 v_o1 v_o2 v_o3 v_face]';
        t_s = sum(w_'.*tmp)'+w_*B';
        
        imshow(double(reshape(t_s(:,1), N, M))'./max(t_s(:,1)));
        hold on;
        plot(t_px, t_py, 'g+');
        plot(t_nx, t_ny, 'y+');
        
        [result, meanVec, stdVec] = convert4NSS_simple(t_s);
        nss_Tf = [nss_Tf result(N*(t_ny-1)+t_nx, 1)];
        
        clear tmp w_ result t_s
    end

    if(length(nss_Tf)>0)
        NSS_ =[NSS_ mean(nss_Tf)];
        fprintf('(%f),', mean(nss_Tf));
    else
        % fprintf('invlid_testidx: %d\n', testidx);
    end

    %break
end

%fclose(fid);
fprintf([num2str(toc), ' seconds \n']);