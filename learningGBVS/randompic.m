%% generate 100 ramdom dots images(100*100)
for i = 1:100
    image = rand([768 , 1366]);
    imshow(image);
    hold on;
    for j=1:30
        x_position = rand(1,2)*800;
        y_position = rand(1,2)*400;
        color = rand(1);
        rectangle('position',[x_position(1),y_position(1),y_position(2)*2,y_position(2)*2],'Curvature', [1 1],'faceColor',[rand(1) rand(1) rand(1)]);
    end
    filename = sprintf('../Output/ramdompics/%d.jpg', i);
    print('-djpeg', filename);
    close;
end
