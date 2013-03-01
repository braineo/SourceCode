clear all
stimfolder = '../Resource/final_resize/';
files=dir(fullfile(stimfolder,'*.jpg'));
[filenames{1:size(files,1)}] = deal(files.name);

minimize_scale = 4;
width = 1366;
height = 768;
M = round(height/minimize_scale);
N = round(width/minimize_scale);

gauss = @(omega, d) (1/(omega * sqrt(2 * pi))) * exp(-((d.^2) ./ (2*(omega.^2))));

fprintf('readCSV...\n'); tic
data = readCSV('../Resource/201111face.com/result.csv');
fprintf([num2str(toc), ' seconds \n']);

fprintf('Creating infos_base...\n'); tic
infos_base = zeros(M*N, 4);
for tm=1:M
    for tn=1:N
        infos_base(N*(tm-1)+tn, :) = [tn tm 0 0]; % imgidx X Y P(NEXT)�܂ł̋��� P(PREV)����̋��� �敪��?�
    end
end
ones_ = ones(size(infos_base, 1),1);
fprintf([num2str(toc), ' seconds \n']);

faceFeatures={};

for imgnum=1:400
    map = zeros(size(infos_base, 1),1);
    faces = data{imgnum};
    if(length(faces)>0)
        infomat_faces = {};
    
        for fi=1:length(faces)
            infomat = infos_base;
            face = faces{fi};
            face_x = str2double(face('x'))*double(N);
            face_y = str2double(face('y'))*double(M);
            face_w = str2double(face('w'))*double(N);
            face_h = str2double(face('h'))*double(M);
            face_size = sqrt(face_w*face_w/4+face_h*face_h/4);
            infomat(:,3) = ...
            sqrt(((face_x+0.5).*ones_-infomat(:,1)).*((face_x+0.5).*ones_-infomat(:,1))+...
                 ((face_y+0.5).*ones_-infomat(:,2)).*((face_y+0.5).*ones_-infomat(:,2)));
            % FWHM = sqrt(2*log(2)) * omega
            % infomat(:,4) = gauss(face_size/sqrt(2*log(2)), infomat(:,3));
            infomat(:,4) = gauss(face_size, infomat(:,3));
            infomat_faces{length(infomat_faces)+1} = infomat(:, 4);
            clear infomat
        end
        
        maps = [];
        for m=1:length(infomat_faces)
            t_map = infomat_faces{m};
            t_map = t_map./max(t_map);
            maps = [maps t_map];
            clear t_map
        end
        
        if(length(infomat_faces)>1)
            map = max(maps')';
        else
            map = maps;
        end
        map = map(:,1)./max(map(:,1));
        map = reshape(map(:,1), N, M)';

        img = imresize(imread(strcat(stimfolder, filenames{imgnum})), [M N], 'bilinear');
        imshow(heatmap_overlay(img, map));
        %imshow(map);
        %imshow(img);
        hold on;
        filename = sprintf('print/%s_faceoveray.jpg', filenames{imgnum});
        print('-djpeg', filename);
        filename = sprintf('print/%s_faceoveray.eps', filenames{imgnum});
        print('-depsc2', filename);
        close
        % break
        clear infomat_faces maps img
    else
        map = reshape(map(:,1), N, M)';
    end
    
    faceFeatures{imgnum} = map;
    %clear map
end


savefile = '../Output/storage/EXPfaceFeatures.mat';
save(savefile, 'faceFeatures', '-v7.3');