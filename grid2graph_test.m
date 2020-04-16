function grid2graph_test
s=load('graph_testData');
graphVectorMedium=grid2graph(s.gridMedium);
graph_plot(graphVectorMedium)
