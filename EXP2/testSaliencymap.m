function [NSS_tuned1, NSS_tuned_all, NSS_flat] = testSaliencymap(ALLFeatures, kyokai, weight, weight_noborder, testingdata, fromfirst)

%weight
%weight_noborder
%fromfirst

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
NSS_tuned1 =[];
NSS_tuned_all =[];
NSS_flat =[];

fprintf('%d testing datas\n', length(testingdata));
fprintf('Start testing... '); tic
fprintf('\n');
for testidx=1:length(testingdata)
    if(mod(testidx,fix(length(testingdata)/10))==0)
        fprintf('*');
    end

    imgidx = testingdata{testidx}.imgidx;
    
    %if(imgidx ~= 324)
    %    continue
    %end

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

    nss_Tt1 = [];
    nss_Tta = [];
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
        %infos(find(infos(:,6)==-1),6) = 0;
        %imshow(double(reshape(infos(:,6), N, M))'./max(infos(:,6)));
        %hold on;
        %plot(t_px, t_py, 'g+');
        %plot(t_nx, t_ny, 'y+');
        
        kyokaiIdxMat = reshape(infos(:,6), N, M)';

        result_tuned1 = zeros(fixsize);
        result_tuned_all = zeros(fixsize);
        result_flat = zeros(fixsize);
        num_feat = 9;
        %num_feat = 6;
        for k=1:length(kyokai)
            %if(calNp ~= k)
            %    continue
            %end
            calIdx = find(kyokaiIdxMat(:,:)==k);
            
            result_tuned1(calIdx) = ...
            weight(num_feat*(k-1)+1).*c1(calIdx) + weight(num_feat*(k-1)+2).*c3(calIdx) + weight(num_feat*(k-1)+3).*c3(calIdx) + ...
            weight(num_feat*(k-1)+4).*i1(calIdx) + weight(num_feat*(k-1)+5).*i2(calIdx) + weight(num_feat*(k-1)+6).*i3(calIdx) + ...
            weight(num_feat*(k-1)+7).*o1(calIdx) + weight(num_feat*(k-1)+8).*o2(calIdx) + weight(num_feat*(k-1)+9).*o3(calIdx);
            result_tuned_all(calIdx) = ...
            weight_noborder(1).*c1(calIdx) + weight_noborder(2).*c3(calIdx) + weight_noborder(3).*c3(calIdx) + ...
            weight_noborder(4).*i1(calIdx) + weight_noborder(5).*i2(calIdx) + weight_noborder(6).*i3(calIdx) + ...
            weight_noborder(7).*o1(calIdx) + weight_noborder(8).*o2(calIdx) + weight_noborder(9).*o3(calIdx);
            
            %{
            result_tuned1(calIdx) = ...
            weight(num_feat*(k-1)+1).*c1(calIdx) + weight(num_feat*(k-1)+2).*c3(calIdx) + ...
            weight(num_feat*(k-1)+3).*i1(calIdx) + weight(num_feat*(k-1)+4).*i3(calIdx) + ...
            weight(num_feat*(k-1)+5).*o1(calIdx) + weight(num_feat*(k-1)+6).*o3(calIdx);
            result_tuned_all(calIdx) = ...
            weight_noborder(1).*c1(calIdx) + weight_noborder(2).*c3(calIdx) + ...
            weight_noborder(3).*i1(calIdx) + weight_noborder(4).*i3(calIdx) + ...
            weight_noborder(5).*o1(calIdx) + weight_noborder(6).*o3(calIdx);
            %}
            result_flat(calIdx) = (1/3).*color(calIdx) + (1/3).*intensity(calIdx) + (1/3).*orientation(calIdx);
        end

        %imshow(result_tuned1./max(max(result_tuned1)));
        %imshow(result_flat./max(max(result_flat)));
        %hold on;
        %plot(t_px, t_py, 'g+');
        %plot(t_nx, t_ny, 'y+');
        
        %[result_flat, meanVec_flat, stdVec_flat] = convert4NSS(result_flat, find(kyokaiIdxMat(:,:)>0));
        [result_tuned1, meanVec_tuned1, stdVec_tuned1] = convert4NSS(result_tuned1, find(kyokaiIdxMat(:,:)>0));
        [result_tuned_all, meanVec_tuned_all, stdVec_tuned_all] = convert4NSS(result_tuned_all, find(kyokaiIdxMat(:,:)>0));

        % TODO kyokai6以上？
        % 境界ぼかし

        %infos_near = infos(find(infos(:,4)<th1.*ones_),:);
        %sel_near = randperm(size(infos_near, 1));
        %nss_Tt1 = [nss_Tt1 result_tuned1(infos_near(sel_near(1), 2), infos_near(sel_near(1), 1))];
        %nss_Tf = [nss_Tf result_flat(infos_near(sel_near(1), 2), infos_near(sel_near(1), 1))];

        nss_Tt1 = [nss_Tt1 result_tuned1(t_ny, t_nx)];
        nss_Tta = [nss_Tta result_tuned_all(t_ny, t_nx)];
        %nss_Tf = [nss_Tf result_flat(t_ny, t_nx)];
        %fprintf('invlid: %d, val:%f\n', length(find(kyokaiIdxMat(:,:)==0)), result_tuned1(t_ny, t_nx));
        %break
        
        %{
        if(t_dis > 70 && (result_tuned1(t_ny, t_nx)-result_tuned_all(t_ny, t_nx))>0.5 && result_tuned1(t_ny, t_nx) > 0)
            fprintf('img:%d,sacorder:%d,dis:%f,val_proposed:%f,val_all:%f,P(%d,%d),N(%d,%d)\n', imgidx, i, t_dis, result_tuned1(t_ny, t_nx), result_tuned_all(t_ny, t_nx), t_px, t_py, t_nx, t_ny);
            
            imshow(result_tuned1./max(max(result_tuned1)));
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            filename = sprintf('%d_%d_1.eps', imgidx, i);
            print('-depsc2', filename);
            close
            imshow(result_tuned_all./max(max(result_tuned_all)));
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            filename = sprintf('%d_%d_2.eps', imgidx, i);
            print('-depsc2', filename);
            close
            
            imshow(c1);
            filename = sprintf('%d_c1.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(c2);
            filename = sprintf('%d_c2.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(c3);
            filename = sprintf('%d_c3.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(i1);
            filename = sprintf('%d_i1.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(i2);
            filename = sprintf('%d_i2.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(i3);
            filename = sprintf('%d_i3.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(o1);
            filename = sprintf('%d_o1.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(o2);
            filename = sprintf('%d_o2.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            imshow(o3);
            filename = sprintf('%d_o3.eps', imgidx);
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            print('-depsc2', filename);
            close
            
            imshow(double(reshape(infos(:,6), N, M))'./max(infos(:,6)));
            hold on;
            plot(t_px, t_py, 'g+');
            plot(t_nx, t_ny, 'y+');
            filename = sprintf('%d_kyokai.eps', imgidx);
            print('-depsc2', filename);
            close
        end
        %}
    end

    if(length(nss_Tt1)>0)
        NSS_tuned1 =[NSS_tuned1 mean(nss_Tt1)];
        NSS_tuned_all =[NSS_tuned_all mean(nss_Tta)];
        %NSS_flat =[NSS_flat mean(nss_Tf)];
    else
        % fprintf('invlid_testidx: %d\n', testidx);
    end

    %break
end

%fclose(fid);
fprintf([num2str(toc), ' seconds \n']);