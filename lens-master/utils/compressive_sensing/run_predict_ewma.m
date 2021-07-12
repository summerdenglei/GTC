function run_predict_tm(data_set, city, method, 
tm = load('/v/filer4b/v24q005/gene/socialTM/GWL_IntraTM/Austin/dailyTM_CLUSTERED/GWL_Intra_Daily_Austin_CLUSTERED');

%tm = [1 2 3 4 5,
%1 2 3 4 5,
%1 2 3 4 5,
%1 2 3 4 5];
%tm = tm';
%tm = ones(4,5);

predict_tm(1, tm, 0.01, 5)
