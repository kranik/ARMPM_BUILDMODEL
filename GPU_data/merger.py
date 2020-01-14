import os.path

#benchmarks = ["stream_cluster","particle_filter","mmumergpu","leukocyte","lavaMD","backprop","bfs","b+tree","cfd","heartwall","hotspot3d","hotspot","hybridsort","kmeans",
#"myocyte","nw","pathfinder","srad_v1","srad_v2"]
benchmarks = ["","","","","","","","","","","","","","",
"","","","",""]

freqs = ["76","153","230","307","384","460","537","614","691","768","844","921","998"]

path13 = "./files_13pc_nvidia/power_measurement_merged.txt"
m = open(path13,'w')
for benchmark in benchmarks:
	for freq in freqs:
		path0 = "./files_13pc_nvidia/power_measurement_log_c0_"+benchmark+"_"+freq+".txt"
		path1 = "./files_13pc_nvidia/power_measurement_log_c1_"+benchmark+"_"+freq+".txt"
		path2 = "./files_13pc_nvidia/power_measurement_log_c2_"+benchmark+"_"+freq+".txt"
		path3 = "./files_13pc_nvidia/power_measurement_log_c3_"+benchmark+"_"+freq+".txt"
		path4 = "./files_13pc_nvidia/power_measurement_log_c4_"+benchmark+"_"+freq+".txt"
		path5 = "./files_13pc_nvidia/power_measurement_log_c5_"+benchmark+"_"+freq+".txt"
		path6 = "./files_13pc_nvidia/power_measurement_log_c6_"+benchmark+"_"+freq+".txt"
		path7 = "./files_13pc_nvidia/power_measurement_log_c7_"+benchmark+"_"+freq+".txt"
		path8 = "./files_13pc_nvidia/power_measurement_log_c8_"+benchmark+"_"+freq+".txt"
		path9 = "./files_13pc_nvidia/power_measurement_log_c9_"+benchmark+"_"+freq+".txt"
		path10 = "./files_13pc_nvidia/power_measurement_log_c10_"+benchmark+"_"+freq+".txt"
		path11 = "./files_13pc_nvidia/power_measurement_log_c11_"+benchmark+"_"+freq+".txt"
		path12 = "./files_13pc_nvidia/power_measurement_log_c12_"+benchmark+"_"+freq+".txt"
		if os.path.isfile(path0): 
			c_0 = open(path0,'r')
		if os.path.isfile(path1):
			c_1 = open(path1,'r')
		if os.path.isfile(path2):
			c_2 = open(path2,'r')
		if os.path.isfile(path3):
			c_3 = open(path3,'r')
		if os.path.isfile(path4):
			c_4 = open(path4,'r')
		if os.path.isfile(path5):
			c_5 = open(path5,'r')
		if os.path.isfile(path6):
			c_6 = open(path6,'r')
		if os.path.isfile(path7):
			c_7 = open(path7,'r')
		if os.path.isfile(path8):
			c_8 = open(path8,'r')
		if os.path.isfile(path9):
			c_9 = open(path9,'r')
		if os.path.isfile(path10):
			c_10 = open(path10,'r')
		if os.path.isfile(path11):
			c_11 = open(path11,'r')
		if os.path.isfile(path12):
			c_12 = open(path12,'r')
		l_0=c_0.readline()
		l_1=c_1.readline()
		l_2=c_2.readline()
		l_3=c_3.readline()
		l_4=c_4.readline()
		l_5=c_5.readline()
		l_6=c_6.readline()
		l_7=c_7.readline()
		l_8=c_8.readline()
		l_9=c_9.readline()
		l_10=c_10.readline()
		l_11=c_11.readline()
		l_12=c_12.readline()
		if benchmark == "stream_cluster" and freq == "76":
			print(l_0.rstrip('\n'),file=m)
		print(benchmark)
		no_line=0
		for l_0 in c_0: #read lines one by one
			l_1=c_1.readline()
			if len(l_1) == 0:
				no_line = 1
			l_2=c_2.readline()
			if len(l_2) == 0:		
				no_line = 1
			l_3=c_3.readline()
			if len(l_3) == 0:
				no_line = 1
			l_4=c_4.readline()
			if len(l_4) == 0:
				no_line = 1
			l_5=c_5.readline()
			if len(l_5) == 0:
				no_line = 1
			l_6=c_6.readline()
			if len(l_6) == 0:
				no_line = 1
			l_7=c_7.readline()
			if len(l_7) == 0:
				no_line = 1
			l_8=c_8.readline()
			if len(l_8) == 0:
				no_line = 1
			l_9=c_9.readline()
			if len(l_9) == 0:
				no_line = 1
			l_10=c_10.readline()
			if len(l_10) == 0:
				no_line = 1
			l_11=c_11.readline()
//			if len(l_11) == 0:
				no_line = 1
			l_12=c_12.readline()
			if len(l_12) == 0:
				no_line = 1
			w_0 = l_0.split()
			w_1 = l_1.split()
			w_2 = l_2.split()
			w_3 = l_3.split()
			w_4 = l_4.split()
			w_5 = l_5.split()
			w_6 = l_6.split()
			w_7 = l_7.split()
			w_8 = l_8.split()
			w_9 = l_9.split()
			w_10 = l_10.split()
			w_11 = l_11.split()
			w_12 = l_12.split()

			if (no_line ==0):
				new_line = w_0[0]+"	"+w_0[1]+"	"+w_0[2]+"	"+w_0[3]+"	"+w_0[4]+"	"+w_0[5]+"	"+w_0[6]+"	"+w_0[7]+"	"+w_1[8]+"	"+w_2[9]+"	"+w_3[10]+"	"+w_4[11]+"	"+w_5[12]+"	"+w_6[13]+"	"+w_7[14]+"	"+w_8[15]+"	"+w_9[16]+"	"+w_10[17]+"	"+w_11[18]+"	"+w_12[19]
				print(new_line,file=m)
c_0.close()
c_1.close()
c_2.close()
c_3.close()
c_4.close()
c_5.close()
m.close()



