
clear all

fprintf('Load EXPALLFixations, EXPALLFeatures...'); tic
load('C:\hg\Master\code\matlab\storage\EXPALLFixations.mat'); % EXPALLFixations
load('C:\hg\Master\code\matlab\storage\EXPALLFeatures.mat'); % ALLFeatures
load('C:\hg\Master\code\matlab\storage\EXPfaceFeatures.mat'); % faceFeatures
fprintf([num2str(toc), ' seconds \n']);

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

n=0;
n_c=0;
nv=0;
nv_c=0;
fixes=[];


sigma = round(get_distance(1)/minimize_scale);
gw = sigma*8;
gh = gw;
gfilter = zeros(gh+1, gw+1);
gcx = gw/2+1;
gcy = gh/2+1;
for tj=1:gh+1
  for ti=1:gw+1
    %gfilter(tj, ti) = 1/(2*pi*sigma^2)*exp(-(((double(gcx-ti))^2+(double(gcy-tj)^2))/(2*sigma^2)));
    gfilter(tj, ti) = exp(-(((double(gcx-ti))^2+(double(gcy-tj)^2))/(2*sigma^2)));
  end
end

t_mat = zeros(2*M, 2*N);
t_mat_g = zeros(2*M, 2*N);

for imgidx=1:400
    for subidx=1:length(EXPALLFixations{imgidx})
        fix_length = size(EXPALLFixations{imgidx}{subidx}.medianXY, 1);
        if(fix_length < 2)
            continue
        end
        n = n + (fix_length-1);
        n_c = n_c + 1;

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
                % valid_flag = 0;
            end

            if(valid_flag)
                nv = nv + 1;
                nv_c = nv_c + 1;
                
                t_dx = t_nx - t_px;
                t_dy = t_ny - t_py;
                
                t_x = round(N+t_dx);
                t_y = round(M+t_dy);
                
                for tj=max(1, t_y-gh/2):min(2*M, t_y+gh/2)
                  for ti=max(1, t_x-gw/2):min(2*N, t_x+gw/2)
                    t_mat_g(tj, ti) = t_mat_g(tj, ti) + gfilter(gcy-(t_y-tj),gcx-(t_x-ti));
                  end
                end
                
                t_mat(t_y, t_x) = t_mat(t_y, t_x) + 1;
            end
            
        end
        
        fixes = [fixes fix_length-1];
    end
end

t_mat = t_mat/max(max(t_mat));
t_mat_g = t_mat_g/max(max(t_mat_g));

%t_mat = uint8(t_mat*255);
%t_mat_g = uint8(t_mat_g*255);
%colormap(gray); % カラーマップを白黒にする
pcolor(t_mat);
colorbar; % カラーバーを表示
axis ij; % 左上が最小になるように変更



% c_dis = [2 5 8 12 16 20 24 28 33 38];
c_dis = [2 5 8 12 16 21 26 32 38 45 52];
c_ang = [0 45 90 135 180 225 270 315;22.5 67.5 112.5 157.5 200.5 247.5 292.5 337.5];
A=[0 0];
for i=1:size(c_dis, 2)
    for j=1:size(c_ang, 2)
        c_dr = get_distance(c_dis(i))/minimize_scale;
        c_da = c_ang(mod((i+1),size(c_ang, 1))+1, j)/180*pi;
        % A=[A; [M-c_dr*sin(c_da) N+c_dr*cos(c_da)]];
        A=[A; [round(c_dr*sin(c_da)) round(c_dr*cos(c_da))]];
    end
end
% scatter(A(:,1),A(:,2))

dt = DelaunayTri(A(:,1),A(:,2));
triplot(dt); 
axis equal
grid on
SI = pointLocation(dt,[1 1])

neighbors(dt, SI)
dt.Triangulation(SI,:)

trimesh(TRI,x,y);
T = tsearch(x,y,TRI,1,1);

subplot(1,2,1),...
trimesh(TRI,x,y,zeros(size(x))); view(2),...
%axis([0 1 0 1]); hold on; 
plot(x,y,'o');
set(gca,'box','on');