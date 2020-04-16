%function [graphVector]=grid2graph(grid)
%The function should return a  graphVector structure described by the inputs. See
%Figure  fig:grid2graph for an example of the expected inputs and outputs.
function [graphVector]=grid2graph(grid)

%total number of nodes in the graph
NNodes=sum(grid.F(:));
%initialize stucture
graphVector=repmat(struct('neighbors',[],'neighborsCost',[],'x',[]),NNodes,1);

%grid size
szGrid=size(grid.F);

%this array keeps, for each non-false element of grid.F, the
%corresponding index in graphVector
idxMap=zeros(size(grid.F));
idxMap(grid.F)=1:NNodes;

%fill in the x and neighbors fields
for iXCoord=1:szGrid(2)
    for iYCoord=1:szGrid(1)
        if grid.F(iYCoord,iXCoord)
            idxGraph=idxMap(iYCoord,iXCoord);
            graphVector(idxGraph).x=[grid.xx(iXCoord);grid.yy(iYCoord)];
            idxNeighborsF=grid2graph_computeNeighbors(iYCoord,iXCoord,grid.F);
            graphVector(idxGraph).neighbors=idxMap(sub2ind(szGrid,idxNeighborsF(1,:),idxNeighborsF(2,:)));
        end
    end
end

%fill in the neighborcost field
%Note: we cannot do this in the previous loop because we need to have all
%the x fields populated first

for iNode=1:NNodes
    graphVector(iNode).neighborsCost=...
        sqrt(euclideanDistMatrix(graphVector(iNode).x,...
        [graphVector(graphVector(iNode).neighbors).x]));
end


