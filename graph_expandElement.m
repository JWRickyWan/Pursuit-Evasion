%function [graphVector,pqOpen]=graph_expandElement(graphVector,idxNBest,idxX,idxGoal,pqOpen)
%This function expands the vertex with index  @x   idxX (which is a neighbor of
%the one with index  @x   idxNBest) and returns the updated versions of  @x  
%graphVector and  @x   pqOpen.
function [graphVector,pqOpen]=graph_expandElement(graphVector,idxNBest,idxX,idxGoal,pqOpen)
ncost=graphVector(idxNBest).neighborsCost(graphVector(idxNBest).neighbors==idxX);
if ~priority_isMember(pqOpen,idxX)
    graphVector(idxX).g = graphVector(idxNBest).g + ncost;
    graphVector(idxX).backpointer = idxNBest;
    f_x = graphVector(idxX).g + graph_heuristic(graphVector,idxX,idxGoal);
    pqOpen = priority_insert(pqOpen,idxX,f_x);
elseif graphVector(idxNBest).g+ncost<graphVector(idxX).g
    graphVector(idxX).g = graphVector(idxNBest).g + ncost;
    graphVector(idxX).backpointer = idxNBest;
end

%This function corresponds to lines  it:expansion-start-- it:expansion-end in
%Algorithm  alg:astar.
