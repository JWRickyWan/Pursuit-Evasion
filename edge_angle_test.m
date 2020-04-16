%Test edge_angle
function edge_angle_test()
vertex0=[1;1];
vertex1=[2;0];

testValuesAndInputs={{45,[2;1]},{90,[2;2]},{135,[1;2]},...
    {180,[0;2]},{-135,[0;1]},{-90,[0;0]},...
    {45,[2;1],'unsigned'},{90,[2;2],'unsigned'},{135,[1;2],'unsigned'},...
    {180,[0;2],'unsigned'},{225,[0;1],'unsigned'},{270,[0;0],'unsigned'}};

nbTests=length(testValuesAndInputs);
for iTest=1:nbTests
    args=testValuesAndInputs{iTest};
    disp(['Angle should be ' num2str(args{1})])
    disp(rad2deg(edge_angle(vertex0,vertex1,args{2:end})))
end

