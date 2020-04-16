%function [h]=graph_heuristic(graphVector,idxX,idxGoal)
%Computes the heuristic  @x   h given by the Euclidean distance between the nodes
%with indexes  @x   idxX and  @x   idxGoal.
function [h]=graph_heuristic(graphVector,idxX,idxGoal)
position = graphVector(idxX).x;
goal = graphVector(idxGoal).x;
[h] = norm(goal-position);
