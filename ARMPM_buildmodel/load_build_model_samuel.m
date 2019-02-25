function [] = load_build_model_samuel (varargin)

%Handling variable argument length, this makes my old code reaulable
%Any new functionality I need to add here (by manipulating mode etc.
if ( length (varargin) < 1 )
    error ("Need to pass at least 1 argument to load_build_model(mode)");
    error ("Please use load_build_model(0) for more info");
    return
  else
    mode = varargin{1};
endif

  
%Read input data
data_set=varargin{1};
start_row=varargin{2};
start_col=varargin{3};
a7_voltage_col=varargin{4};
a15_voltage_col=varargin{5};
a7_power_col=varargin{6};
a15_power_col=varargin{7};


%Open single data set file
fid = fopen (data_set, "r");
data_set = dlmread(fid,'\t',start_row,start_col);
fclose (fid);

%Extract data
a7_voltage=data_set(:,a7_voltage_col.-start_col);
a15_voltage=data_set(:,a15_voltage_col.-start_col);
a7_power=data_set(:,a7_power_col.-start_col);
a15_power=data_set(:,a15_power_col.-start_col);

disp("###########################################################");
disp("Platform physical characteristics");
disp("###########################################################");
disp(["Average A7 Voltage [V]: " num2str(mean(a7_voltage),"%.3f")]); 
disp(["Average A15 Voltage [V]: " num2str(mean(a15_voltage),"%.3f")]); 
disp(["Average A7 Power [W]: " num2str(mean(a7_power),"%.3f")]); 
disp(["Average A15 Power [W]: " num2str(mean(a15_power),"%.3f")]); 
disp("###########################################################");


endfunction