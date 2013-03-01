function [SALIENCYMAP, meanVec, stdVec] = convert4NSS_simple(SALIENCYMAP)
meanVec=mean(SALIENCYMAP(:), 1);
SALIENCYMAP=SALIENCYMAP-repmat(meanVec, size(SALIENCYMAP));
stdVec=std(SALIENCYMAP(:));
z=find(stdVec==0);
if length(z)>0
    display('Alert: DIVIDE by 0 in the Whiten call!');
end
SALIENCYMAP=SALIENCYMAP./repmat(stdVec, size(SALIENCYMAP));
