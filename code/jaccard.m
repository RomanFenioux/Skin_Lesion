function [ j ] = jaccard( segIm, grndTruth )
%JACCARD(I,J) Computes the jaccard index between binary images of same size

    j= nnz(segIm & grndTruth)/(nnz(segIm | grndTruth));

end