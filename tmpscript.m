for j=1:400
    for i = 1:21
        subplot(3,7,i)
hold on;
        imagesc(saltFeatureMaps{j}{i}.map);
    end
end