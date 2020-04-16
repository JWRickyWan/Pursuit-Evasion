%function [idxExpand]=graph_getExpandList(graphVector,idxNBest,idxClosed)
%Finds the neighbors of element  @x   idxNBest that are not in  @x   idxClosed
%(line  it:expansion in Algorithm  alg:astar).
function [idxExpand]=graph_getExpandList(graphVector,idxNBest,idxClosed)
idxExpand = [];
ListLength = length(graphVector(idxNBest).neighbors);
for iElement =1:ListLength
    if ~ismember(graphVector(idxNBest).neighbors(iElement),idxClosed)
        [idxExpand] = [idxExpand;graphVector(idxNBest).neighbors(iElement)];
    end
end
idxExpand(idxExpand==idxNBest)=[];

%Ensure that the vector  @x   idxBest is not included in the list of neighbors
%(i.e., avoid self-loop edges in the graph).
