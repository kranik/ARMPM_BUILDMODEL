import sys

#testset = ["binomialOPtions","BlackScholes","MonteCarloMultiGPU","particles","SobolQRNG","convolutionTexture","FDTD3d","nbody","radixSortThrust","transpose"]

testset = ["stream_cluster","particle_filter","mmumergpu","leukocyte","lavaMD","backprop","bfs","b+tree","cfd","heartwall","hotspot3d","hotspot","hybridsort","kmeans",
"myocyte","nw","pathfinder","srad_v1","srad_v2"]

frequency_ref_h = "998"
voltage_ref_h = "1.07"
#static_ref = "0.3336"
static_ref_h = "0.31"

anchor_ref_l=3

frequency_cur = ["998","76","768","384","153","230","307","460","537","614","691","844","921"] 
temp_255 = ["33.98","29.18","30.98","30.65","19.13","29.66","30.15","31.12","31.57","29.32","30.17","31.81","32.76"]

#frequency_cur = ["998","76","768","384"] 

voltage_cur = ["1.07","0.82","0.94","0.82","0.82","0.82","0.82","0.82","0.82","0.86","0.9","0.99","1.03"]
constant = ["2.90377","0.311733","1.75379","0.772069","0.432482","0.544291","0.650025","0.86243","1.00082","1.22428","1.47367","2.04731","2.42993"]

frequency_ref_l = frequency_cur[anchor_ref_l]
voltage_ref_l = voltage_cur[anchor_ref_l]
#static_ref = "0.3336"
static_ref_l = "0.24"


inst_executed_cs = ["9.01E-03","5.19E-04","6.29E-03","2.51E-03","0.00115228","0.00160335","0.00213921","0.00299411","0.00373524","0.00468814","0.00518368","0.00727008","0.00852231"]
m_inst_executed_global_stores = ["0.611382","0.00359891","0.264706","0.0908572","0.0309551","0.0456852","0.0535768","0.121177","0.107271","0.100598","0.256042","0.361086","0.392123"]
gpu_busy = ["-6.68E-03","6.59E-04","5.64E-04","-1.73E-05","-3.39293E-05","0.000411958","0.0016633","0.00056799","0.00182978","0.00379985","-0.00133317","-0.00189551","0.000910451"]	
sm_active_warps = ["0.00017093","1.26E-06","3.68E-05","1.95E-05","4.61377E-06","6.63489E-06","-1.6472E-06","1.64871E-05","2.06549E-06","-1.05896E-05","4.66159E-05","7.3378E-05","4.47702E-05"]

                       

overall_percentual_error_f=0;
overall_percentual_error_u_l=0; 
overall_percentual_error_u_l_t=0;
r_file= open("power_values.txt","w")	
r_file.write("time step,measured,unified model,unified model temp,per-frequency model\r\n")
	
			
#for x in range(4,7):
for x in range(13):
	line_count = 0;	
	print("Frequency is: ", frequency_cur[x])
	path0 = "./run_0/temperature_measurement_merged.txt"
	print("the input file is ",path0) 
	c_0 = open(path0,'r')

	

	header=c_0.readline()
	prediction_error_f = 0;
	prediction_error_u_h = 0;
	prediction_error_u_l = 0;
	prediction_error_u_l_t = 0;


	mean_measured_power = 0;
	mean_average_relative_error_f = 0;
	mean_average_relative_error_u_h = 0;
	mean_average_relative_error_u_l = 0;
	mean_average_relative_error_u_l_t = 0;
	average_temperature = 0

	
	#r_file.write("time step,unified model,per-frequency model\r\n")

	for l_0 in c_0: #read lines one by one
		w_0 = l_0.split()
		frequency = w_0[3]
		benchmark = w_0[1]
		if benchmark in testset:
			if frequency == frequency_cur[x]:
				#print("Frequency is: ", frequency_cur[x])
				# and benchmark == "SobolQRNG":
				line_count = line_count + 1
				# model_d inst_executed_cs,m_inst_executed_global_stores,gpu_busy,sm_active_warps		
				# 8,11,13,19		
				# constant	inst_executed_cs	m_inst_executed_global_stores	gpu_busy	sm_active_warps
				# 2.90377	9.01E-03	0.611382	-6.68E-03	0.00017093
				predicted_power_f = float(w_0[8-1])*float(inst_executed_cs[x])+float(w_0[11-1])*float(m_inst_executed_global_stores[x])+float(w_0[13-1])*float(gpu_busy[x])+float(w_0[19-1])*float(sm_active_warps[x])+float(constant[x])
				
				predicted_power_r_h = float(w_0[8-1])*float(inst_executed_cs[0])+float(w_0[11-1])*float(m_inst_executed_global_stores[0])+float(w_0[13-1])*float(gpu_busy[0])+float(w_0[19-1])*float(sm_active_warps[0])+float(constant[0])
				predicted_power_r_l = float(w_0[8-1])*float(inst_executed_cs[anchor_ref_l])+float(w_0[11-1])*float(m_inst_executed_global_stores[anchor_ref_l])+float(w_0[13-1])*float(gpu_busy[anchor_ref_l])+float(w_0[19-1])*float(sm_active_warps[anchor_ref_l])+float(constant[anchor_ref_l])
				predicted_power_u_h = (predicted_power_r_h-float(static_ref_h))*float(frequency_cur[x])/float(frequency_ref_h)*float(voltage_cur[x])/float(voltage_ref_h)*float(voltage_cur[x])/float(voltage_ref_h)+float(static_ref_h)*float(voltage_cur[x])/float(voltage_ref_h)*float(voltage_cur[x])/float(voltage_ref_h)
				predicted_power_u_l = (predicted_power_r_l-float(static_ref_l))*float(frequency_cur[x])/float(frequency_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)+float(static_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)
				#predicted_static_l_t = float(w_0[4])*0.0114-0.1043
				#best predicted_static_l_t = float(w_0[4])*0.0114-0.1243
				predicted_static_l_t = float(w_0[4])*0.0071+0.0273
				
				#predicted_static_l_t = float(w_0[4])*0.0056+0.0733
				#predicted_static_l_t = float(w_0[4])*0.0066+0.0425
				#predicted_static_l_t_255 = float(temp_255[x])*0.0041+0.0673
				predicted_static_l_t_255 = 0.22
	
				predicted_power_f = (predicted_power_f - float(static_ref_l)) + predicted_static_l_t

				predicted_static_l_t_v = float(predicted_static_l_t)*float(voltage_cur[x])/float(voltage_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)
				#print("temperature ",w_0[4]," predicted_static_l_t ",predicted_static_l_t)
				#predicted_power_u_l_t = (predicted_power_r_l-float(predicted_static_l_t))*float(frequency_cur[x])/float(frequency_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)+float(predicted_static_l_t_v)
				
				predicted_power_u_l_t = (predicted_power_r_l-float(predicted_static_l_t_255))*float(frequency_cur[x])/float(frequency_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)*float(voltage_cur[x])/float(voltage_ref_l)+float(predicted_static_l_t_v)
				#
				#predicted_power_u = (predicted_power_r)*float(frequency_cur[x])/float(frequency_ref)*float(voltage_cur[x])/float(voltage_ref)*float(voltage_cur[x])/float(voltage_ref)				
				measured_power = float(w_0[7-1])
				average_temperature = average_temperature + float(w_0[4])
				#print("predicted_u_l ",predicted_power_u_l,"predicted_u_l_t ",predicted_power_u_l_t,"measured ",measured_power)
				r_file.write("%d,%f,%f,%f,%f\r\n" % (line_count,measured_power,predicted_power_u_l,predicted_power_u_l_t,predicted_power_f))
				prediction_error_f = prediction_error_f + abs(measured_power - predicted_power_f)
				mean_average_relative_error_f = mean_average_relative_error_f+100*abs(measured_power - predicted_power_f)/measured_power
				prediction_error_u_h = prediction_error_u_h + abs(measured_power - predicted_power_u_h)
				mean_average_relative_error_u_h = mean_average_relative_error_u_h+100*abs(measured_power - predicted_power_u_h)/measured_power
				prediction_error_u_l = prediction_error_u_l + abs(measured_power - predicted_power_u_l)
				mean_average_relative_error_u_l = mean_average_relative_error_u_l+100*abs(measured_power - predicted_power_u_l)/measured_power
				prediction_error_u_l_t = prediction_error_u_l_t + abs(measured_power - predicted_power_u_l_t)
				mean_average_relative_error_u_l_t = mean_average_relative_error_u_l_t+100*abs(measured_power - predicted_power_u_l_t)/measured_power
				mean_measured_power = mean_measured_power + measured_power;
				#r_file.write("%d,%f,%f\r\n" % (line_count,100*abs(measured_power - predicted_power_u_l)/measured_power,100*abs(measured_power - predicted_power_f)/measured_power))

	average_temperature = average_temperature/line_count;
	print("average_temperature [C]: ",average_temperature);
	mean_measured_power = mean_measured_power/line_count;
	print("Mean measured power [W]: ",mean_measured_power);
	absolute_error_f = abs(prediction_error_f/line_count);	
	print("Average Absolute Error perfreq[W]: ",absolute_error_f);
	print("Average Percentual Error perfreq [%]: ",mean_average_relative_error_f/line_count)
	absolute_error_u_h = abs(prediction_error_u_h/line_count);
	print("Average Absolute Error unified hf[W]: ",absolute_error_u_h);
	print("Average Percentual Error unified hf[%]: ",mean_average_relative_error_u_h/line_count)
	absolute_error_u_l = abs(prediction_error_u_l/line_count);
	print("Average Absolute Error unified lf[W]: ",absolute_error_u_l);
	print("Average Percentual Error unified lf[%]: ",mean_average_relative_error_u_l/line_count)
	overall_percentual_error_u_l = overall_percentual_error_u_l+mean_average_relative_error_u_l/line_count
	overall_percentual_error_f = overall_percentual_error_f+mean_average_relative_error_f/line_count
	absolute_error_u_l_t = abs(prediction_error_u_l_t/line_count);
	print("Average Absolute Error unified lf with temp[W]: ",absolute_error_u_l_t);
	print("Average Percentual Error unified lf with temp[%]: ",mean_average_relative_error_u_l_t/line_count)
	overall_percentual_error_u_l_t = overall_percentual_error_u_l_t+mean_average_relative_error_u_l_t/line_count


	c_0.close()
print("")
print("")
print("")
print("")
print("Overall Percentual Error unified lf[%]: ",overall_percentual_error_u_l/13)
print("Overall Percentual Error unified lf with temp[%]: ",overall_percentual_error_u_l_t/13)
print("Overall Percentual Error perfreq[%]: ",overall_percentual_error_f/13)
r_file.close()






