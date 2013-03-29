function featureDistributePatternPlot(weightPattern,featName)

for feati = 1:length(featName)
    for regioni = 1:size(weightPattern{1},1)
        figure;
        maxValue = max(max(max(weightPattern{feati}(regioni,:,:),[],3)));
        step = maxValue/10.0;
        range = 0:step:maxValue;
        titleName = sprintf('feature:%s,region:%d',featName{feati},regioni);
        title(titleName);
        for subjecti = 1:size(weightPattern{1},2)
            tmp = reshape(weightPattern{feati}(regioni,subjecti,:),[1,size(weightPattern{1},3)]);
            %tmp=tmp(find(tmp));% remove all the zeros
            [N,X] = hist(tmp,range);
            xlim([0 maxValue]);
            ylim([-1,inf]);
            hold on;
            [XX, NN] = smoothLine(X,N);
            notationString = sprintf('Subject#%d',subjecti);
            cc = hsv(15);
            plot(XX, NN,'LineWidth',1.5,'DisplayName',notationString, 'color',cc(subjecti,:));
            xlabel('Weight');
            ylabel('Frequency');
            legend('-DynamicLegend');
        end
        print('-djpeg',[titleName,'.jpg'],'-r300');
        close;
    end
end