function [] = load_build_model (varargin)

%Handling variable argument length, this makes my old code reaulable
%Any new functionality I need to add here (by manipulating mode etc.
if ( length (varargin) < 1 )
    error ("Need to pass at least 1 argument to load_build_model(mode)");
    error ("Please use load_build_model(0) for more info");
    return
  else
    mode = varargin{1};
endif

#Detailed infromation about available program modes
if ( mode == 0 )
  disp("List of all the function modes:")
  disp("0) Mode information")
  disp("1) Platformm physical information including averages and totals of model events. No model generation.")
  disp("Need to pass 6 arguments to load_build_model(mode,data_set,start_row,start_col,power_col,events_col)")
  disp("2) Model generation with detailed output.")
  disp("Need to pass 7 arguments to load_build_model(mode,train_set,test_set,start_row,start_col,power_col,events_col)")
  disp("3) Single dimention cross-model generation with detailed output.")
  disp("Need to pass 11 arguments to load_build_model(mode,train_set_1,test_set_1,start_row_1,start_col_1,train_set_2,test_set_2,start_row_2,start_col_2,power_col,events_col)")
  disp("4) Double dimention cross-model generation with detailed output.")
  disp("Need to pass 11 arguments to load_build_model(mode,train_set_1,test_set_1,start_row_1,start_col_1,train_set_2,test_set_2,start_row_2,start_col_2,power_col,events_col)")
  return
endif

if ( mode == 1 )

  %Sanity check argument number
  if ( length (varargin) != 6 )
      error ("Need to pass 6 arguments to load_build_model() for mode 1");
      error ("Please use load_build_model(0) for more info");
      return
  endif
  
  %Read input data
  data_set=varargin{2};
  start_row=varargin{3};
  start_col=varargin{4};
  power_col=varargin{5};
  events_col=varargin{6};
  
  %Open single data set file
  fid = fopen (data_set, "r");
  data_set = dlmread(fid,'\t',start_row,start_col);
  fclose (fid);
  
  %Extract data
  power=data_set(:,power_col.-start_col);
  evts=data_set(:,str2num(events_col).-start_col);
  
  disp("###########################################################");
  disp("Platform physical characteristics");
  disp("###########################################################");
  disp(["Average Power [W]: " num2str(mean(power),"%.3f")]); 
  disp(["Measured Power Range [%]: " num2str((range(power)./min(power))*100,"%d")]);
  disp("###########################################################");
  disp(["Data set event totals: " num2str(sum(evts),"%G\t")]);
  disp("###########################################################");
  disp(["Data set event averages: " num2str(mean(evts),"%G\t")]);
  disp("###########################################################");

endif

if (mode == 2)

  %Sanity check argument number
  if ( length (varargin) != 7 )
      error ("Need to pass 7 arguments to load_build_model() for mode 2");
      error ("Please use load_build_model(0) for more info");
      return
  endif
  
  %Read input data
  train_set=varargin{2};
  test_set=varargin{3};
  start_row=varargin{4};
  start_col=varargin{5};
  power_col=varargin{6};
  events_col=varargin{7};
  
  %Open train set file
  fid = fopen (train_set, "r");
  train_set = dlmread(fid,'\t',start_row,start_col);
  fclose (fid);

  %Extract train data from the file train clomuns specified. 
  %The ones in front are for the constant coefficiant for linear regression
  train_reg=[ones(size(train_set,1),1),train_set(:,str2num(events_col).-start_col)];
  %Compute model
  [m, maxcorr, maxcorrindices, avgcorr] = build_model(train_reg,train_set(:,power_col.-start_col));

  %Open test set file
  fid = fopen (test_set, "r");
  test_set = dlmread(fid,'\t',start_row,start_col);
  fclose (fid);

  %Again extract test data from specified file.
  %Events columns are same as train file
  test_reg=[ones(size(test_set,1),1),test_set(:,str2num(events_col).-start_col)];

  %Extract measured power and range from test data
  test_power=test_set(:,power_col.-start_col);

  %Compute predicted power using model and events
  pred_power=(test_reg(:,:)*m);

  %Compute absolute model errors
  err=(test_power-pred_power);
  abs_err=abs(err);
  avg_abs_err=mean(abs_err);
  std_dev_err=std(abs_err,1);
  %compute realtive model errors and deviation
  rel_abs_err=abs(err./test_power)*100;
  rel_avg_abs_err=mean(rel_abs_err);
  rel_err_std_dev=std(rel_abs_err,1);

  disp("###########################################################");
  disp("Model validation against test set");
  disp("###########################################################"); 
  disp(["Average Predicted Power [W]: " num2str(mean(pred_power),"%.3f")]);  
  disp(["Predicted Power Range [%]: " num2str((range(pred_power)./min(pred_power))*100,"%d")]);
  disp("###########################################################"); 
  disp(["Average Absolute Error [W]: " num2str(avg_abs_err,"%.5f")]);
  disp(["Absolute Error Standart Deviation [W]: " num2str(std_dev_err,"%.5f")]);
  disp("###########################################################");
  disp(["Average Relative Error [%]: " num2str(rel_avg_abs_err,"%.5f")]);
  disp(["Relative Error Standart Deviation [%]: " num2str(rel_err_std_dev,"%.5f")]);
  if (size(str2num(events_col),2) >= 2) 
    disp("###########################################################");
    disp(["Average Event Cross-Correlation [%]: " num2str((avgcorr/1.0)*100,"%.5f")]);
    disp(["Maximum Event Cross-Correlation [%]: " num2str((maxcorr/1.0)*100,"%.5f")]);
    disp(["Most Cross-Correlated Events: " num2str(str2num(events_col)(maxcorrindices(1,1)),"%d") " and " num2str(str2num(events_col)(maxcorrindices(1,2)),"%d")]);
  endif
  disp("###########################################################");
  disp(["Model Coefficients: " num2str(m',"%G\t")]);
  disp("###########################################################");
  
endif

if (mode == 3)

  %Sanity check argument number
  if ( length (varargin) != 11 )
      error ("Need to pass 11 arguments to load_build_model() for mode 3");
      error ("Please use load_build_model(0) for more info");
      return
  endif
  
  %Read input data
  train_set_1=varargin{2};
  test_set_1=varargin{3};
  start_row_1=varargin{4};
  start_col_1=varargin{5};
  
  train_set_2=varargin{6};  
  test_set_2=varargin{7};
  start_row_2=varargin{8};
  start_col_2=varargin{9};
  
  power_col=varargin{10};
  events_col=varargin{11};
  
  %Extract train and test set for file 1
  fid = fopen (train_set_1, "r");
  train_set_1 = dlmread(fid,'\t',start_row_1,start_col_1);
  fclose (fid);
  fid = fopen (test_set_1, "r");
  test_set_1 = dlmread(fid,'\t',start_row_1,start_col_1);
  fclose (fid);
  
  %Extract train and test set for file 2
  fid = fopen (train_set_2, "r");
  train_set_2 = dlmread(fid,'\t',start_row_2,start_col_2);
  fclose (fid);
  fid = fopen (test_set_2, "r");
  test_set_2 = dlmread(fid,'\t',start_row_2,start_col_2);
  fclose (fid);
  
  %Get scaling factors
  train_events_mean_1=mean(train_set_1(:,str2num(events_col).-start_col_1),1);
  train_events_mean_2=mean(train_set_2(:,str2num(events_col).-start_col_2),1);
  scaling_factors=train_events_mean_2./train_events_mean_1;
  
  %Extract train data from the second file
  train_reg=[ones(size(train_set_2,1),1),train_set_2(:,str2num(events_col).-start_col_2)];
  
  %Compute model for second core
  [m, maxcorr, maxcorrindices, avgcorr] = build_model(train_reg,train_set_2(:,power_col.-start_col_2));

  %Again extract test data from first file (first core) and scale events
  test_reg=[ones(size(test_set_1,1),1),test_set_1(:,str2num(events_col).-start_col_1).*scaling_factors];

  %Extract measured power and range for second core
  test_power=test_set_2(:,power_col.-start_col_2);

  %Compute predicted power using model and scaled events from first core
  pred_power=test_reg(:,:)*m;

  %Compute absolute model errors
  err=(mean(test_power)-mean(pred_power));
  abs_err=abs(err);
  %compute realtive model errors and deviation
  rel_abs_err=abs(err./mean(test_power))*100;
  
  disp("###########################################################");
  disp("Model validation against test set");
  disp("###########################################################"); 
  disp(["Average Predicted Power [W]: " num2str(mean(pred_power),"%.3f")]);  
  disp(["Predicted Power Range [%]: " num2str((range(pred_power)./min(pred_power))*100,"%d")]);
  disp("###########################################################"); 
  disp(["Average Absolute Error [W]: " num2str(abs_err,"%.5f")]);
  disp("###########################################################");
  disp(["Average Relative Error [%]: " num2str(rel_abs_err,"%.5f")]);
  if (size(str2num(events_col),2) >= 2) 
    disp("###########################################################");
    disp(["Average Event Cross-Correlation [%]: " num2str((avgcorr/1.0)*100,"%.5f")]);
    disp(["Maximum Event Cross-Correlation [%]: " num2str((maxcorr/1.0)*100,"%.5f")]);
    disp(["Most Cross-Correlated Events: " num2str(str2num(events_col)(maxcorrindices(1,1)),"%d") " and " num2str(str2num(events_col)(maxcorrindices(1,2)),"%d")]);
  endif
  disp("###########################################################");
  disp(["Model Coefficients: " num2str(m',"%G\t")]);
  disp("###########################################################");
  
endif

endfunction