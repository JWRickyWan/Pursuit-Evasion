function grid_eval_test()
grid=struct('xx',linspace(-1,1,41),'yy',linspace(-1,1,31));
mu=[0.3;0];
fun=@(x) sqrt((x-mu)'*diag([2,1])*(x-mu));
grid=grid_eval(grid,fun);

[XX,YY]=meshgrid(grid.xx,grid.yy);
surf(XX,YY,grid.F')
