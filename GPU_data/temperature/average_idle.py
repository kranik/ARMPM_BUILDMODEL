import os.path

freqs = ["76","153","230","307","384","460","537","614","691","768","844","921","998"]

#path_in = "./idle_0/temperature_measurement_merged.txt"
path_in = "./idle_48/power_measurement_log_c0.dat"

input = open(path_in,'r')

first_line = input.readline()

path_out = "./idle_48/temperature_measurement_average.txt"

output = open(path_out,'w')

freq_index = 0
temperature_avg = 0
power_avg = 0
sample = 0

for l_0 in input: #read lines one by one
	w_0 = l_0.split()
	#print(w_0)
	#sample=sample+1
	sample = 1
	#print("freq is ",w_0[3]) 
	if (w_0[3] == freqs[freq_index]):
		print("freq is ",freqs[freq_index]) 
		#temperature_avg = temperature_avg + float(w_0[4])
		#power_avg = power_avg + float(w_0[6])
		temperature_avg = float(w_0[4])
		power_avg = float(w_0[6])

	else:
		temperature_avg = temperature_avg/sample
		power_avg = power_avg/sample
		new_line = str(freqs[freq_index])+"	"+str(w_0[5])+"	"+str(temperature_avg)+"	"+str(power_avg)
		print(new_line,file=output)
		sample = 0
		temperature_avg = 0
		power_avg = 0
		freq_index=freq_index+1
temperature_avg = temperature_avg/sample
power_avg = power_avg/sample
new_line = str(freqs[freq_index])+"	"+str(w_0[5])+"	"+str(temperature_avg)+"	"+str(power_avg)
print(new_line,file=output)
input.close()
output.close()