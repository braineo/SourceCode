function RetWeight = getWeight(TRI, dx, dy)

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
gauss = @(x1, y1) exp(-(x1*x1+y1*y1) ./ (2*(get_distance(4).^2)));

RetWeight = zeros(1, size(TRI.X, 1)); % size(TRI.X, 1): アンカー点の数

%dx = NextPt(1) - PrevPt(1);
%dy = NextPt(2) - PrevPt(2);
%dr = sqrt(dx, dy);
%da = atan2(dx, dy);

pL = pointLocation(TRI, [dx dy]);
% pL = pointLocation(TRI, [1 1]);
nB = neighbors(TRI, pL);

triangles = [pL nB];
if(length(triangles)==0)
    fprintf('(%f,%f)\n', dx, dy);
end
nearPts = TRI.Triangulation(triangles,:);
nearPts = reshape(nearPts, 1, size(nearPts, 1)*size(nearPts, 2));
nearPts = unique(nearPts);

for i=1:length(nearPts)
    RetWeight(nearPts(i)) = gauss(dx-TRI.X(nearPts(i),1), dy-TRI.X(nearPts(i),2));
end

RetWeight./sum(RetWeight);
