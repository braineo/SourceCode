a=zeros([256,  455]);
figure
for n = 1:2:5
    a=a+(reshape(tmp(:,n), [256,  455]));
end
imagesc(a);
a=zeros([256,  455]);
figure
for n = 2:2:6
    a=a+(reshape(tmp(:,n), [256,  455]));
end
imagesc(a);
a=zeros([256,  455]);
figure
for n = 1:6
    a=a+(reshape(tmp(:,n), [256,  455]));
end
imagesc(a);