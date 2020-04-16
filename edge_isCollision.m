%function [flag]=edge_isCollision(vertices1,vertices2)
%Returns  true if the two edges intesect.  Note: if the two edges overlap but are
%colinear, or they overlap only at a single endpoint, they are not considered as
%intersecting (i.e., in these cases the function returns  false). If one of the
%two edges has zero length, the function should always return the result that
%edges are non-intersecting.

function [flag]=edge_isCollision(vertices1,vertices2,fill)
if nargin==2
    fill=1;
end
u=(vertices2(1,1)-vertices1(1,1))*((vertices1(2,2)-vertices1(2,1)))-(vertices1(1,2)-vertices1(1,1))*((vertices2(2,1)-vertices1(2,1)));
v=(vertices2(1,2)-vertices1(1,1))*((vertices1(2,2)-vertices1(2,1)))-(vertices1(1,2)-vertices1(1,1))*((vertices2(2,2)-vertices1(2,1)));
w=(vertices1(1,1)-vertices2(1,1))*((vertices2(2,2)-vertices2(2,1)))-(vertices2(1,2)-vertices2(1,1))*((vertices1(2,1)-vertices2(2,1)));
z=(vertices1(1,2)-vertices2(1,1))*((vertices2(2,2)-vertices2(2,1)))-(vertices2(1,2)-vertices2(1,1))*((vertices1(2,2)-vertices2(2,1)));
if fill==1
    flag=(u*v<=0 && w*z<=0) && (u*v~=0 && w*z~=0);
else
    flag=(u*v<0 && w*z<0);
end
    
%http://www.cnblogs.com/wuwangchuxin0924/p/6218494.html

%The function should be able to handle any orientation of the edges (including
%both vertical and horizontal). Note that the ``overlap'' case needs to be
%checked up to floating-point precision.
