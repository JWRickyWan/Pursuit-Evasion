%function [xPath,graphVector]=graph_search(graphVector,idxStart,idxGoal)
%Implements the  @x   A* algorithm, as described by the pseudo-code in Algorithm 
%alg:astar.
function [xPath,graphVector]=graph_search(graphVector,idxStart,idxGoal)
pqOpen = priority_prepare();
graphVector(idxStart).g = 0;
pqOpen = priority_insert(pqOpen,idxStart,graphVector(idxStart).g);
idxClosed = [];
while ~isempty(pqOpen)
    [pqOpen,idxNBest,~] = priority_minExtract(pqOpen);
    [idxClosed] = [idxClosed;idxNBest];
    if isempty(pqOpen)
        pqOpen = [];
    end
    
    if idxNBest == idxGoal
        break
    end
    idxExpand = graph_getExpandList(graphVector,idxNBest,idxClosed);
    nNumber = length(idxExpand);
    for ineighbor = 1:nNumber
        [graphVector,pqOpen]=graph_expandElement(graphVector,idxNBest,idxExpand(ineighbor),idxGoal,pqOpen);
    end
    
end
xPath = graph_path(graphVector,idxStart,idxGoal);
    
% Set a maximum limit of iterations in the main  @x   A* loop on line 
%it:astar-main-loop of Algorithm  alg:astar. This will prevent the algorithm from
%remaining stuck on malformed graphs (e.g., graphs containing a node as a
%neighbor of itself), or if you make some mistake during development.
