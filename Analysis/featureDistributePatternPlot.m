function featureDistributePatternPlot(weightPattern,featName)

for feati = 1:length(featName)
    for regioni = 1:size(weightPattern{1},1)
        figure;
        maxValue = max(max(max(weightPattern{feati},[],3)));
        step = maxValue/100.0;
        range = 0:step:maxValue;        
        for subjecti = 1:size(weightPattern{1},2)
            tmp = reshape(weightPattern{feati}(regioni,subjecti,:),[1,size(weightPattern{1},3)]);
            %tmp=tmp(find(tmp));% remove all the zeros
            [N,X] = hist(tmp,range);
            hold all;
            plot(X, N);
        end        
    end
end