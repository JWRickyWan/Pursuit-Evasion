function line_linspace_test()
%the following should show a points on a line going from [-1;-1] to [1;1]
thetaPoints=line_linspace([1;1],[0;0],-1,1,31);
plot(thetaPoints(1,:), thetaPoints(2,:), '*');
axis equal;
