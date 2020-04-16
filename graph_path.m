%function [xPath]=graph_path(graphVector,idxStart,idxGoal)
%This function follows the backpointers from the node with index  @x   idxGoal in
% @x   graphVector to the one with index  @x   idxStart node, and returns the 
%coordinates (not indexes) of the sequence of traversed elements.
function [xPath]=graph_path(graphVector,idxStart,idxGoal)
xPath = [];
nextnode = graphVector(idxGoal).backpointer;
while nextnode~=idxStart
    [xPath] = [graphVector(nextnode).x,xPath];
    nextnode = graphVector(nextnode).backpointer;
end
xPath =[graphVector(idxStart).x,xPath];
xPath = [xPath,graphVector(idxGoal).x];