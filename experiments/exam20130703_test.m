% exam20130703
% use the result of exp20130613 to calculate NSS

load('../Result/exam20130703_NSS_score.mat');

x = zeros(14*15,1);
y = zeros(14*15,1);

for i = 1:15
    x(14*(i-1)+1:14*i) = mean(NSS_score{i}{i});
    count = 1;
    for j = 1:15
        if(i == j)
            continue;
        else
        y(14*(i-1)+count) = mean(NSS_score{i}{j});
        count = count + 1;
        end
    end
end