function [megaVect] = dff_aggregator(bigArray)

subMat = bigArray(:,5:end);
[m,n] = size(subMat);
megaVect = reshape(subMat, 1, (m*n));

h1 = cdfplot(megaVect)