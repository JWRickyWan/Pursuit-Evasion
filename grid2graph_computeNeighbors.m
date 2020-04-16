%function grid2graph_computeNeighbors(iXx,iYy,flag,szGrid)
%Computes indexes (in flag) of a given location in flag(iRow,iCol).
function [idxNeighborsExist]=grid2graph_computeNeighbors(iRow,iCol,flag)

szGrid=size(flag);

if any([iRow iCol]>szGrid)
    error('Specified index for flag is out of bound')
end

%offsets for 8-connected neighborhood (clockwise order, starting from
%northwest).
idxNeighborsOffsetsTop=[-1 0 1; ones(1,3)];
idxNeighborsOffsetsRight=[1;0];
idxNeighborsOffsetsBottom=[1 0 -1; -ones(1,3)];
idxNeighborsOffsetsLeft=[-1;0];
idxNeighborsOffsets=[idxNeighborsOffsetsTop idxNeighborsOffsetsRight ...
    idxNeighborsOffsetsBottom idxNeighborsOffsetsLeft];
NNeighbors=size(idxNeighborsOffsets,2);
assert(NNeighbors==8);

%index of potential neighbors
idxNeighbors=idxNeighborsOffsets+[iRow;iCol]*ones(1,NNeighbors);
%keep only potential neighbors that are not out of bound
flagNeighborsValid=all(idxNeighbors>0 & idxNeighbors<=(szGrid'*ones(1,NNeighbors)),1);
idxNeighborsValid=idxNeighbors(:,flagNeighborsValid);
%keep only neighbors that actually exist
flagNeighborsExist=flag(sub2ind(szGrid,idxNeighborsValid(1,:),idxNeighborsValid(2,:)));
idxNeighborsExist=idxNeighborsValid(:,flagNeighborsExist);


