import os.path

run_number=3
#benchmarks = ["stream_cluster","particle_filter","mmumergpu","leukocyte","lavaMD","backprop","bfs","b+tree","cfd","heartwall","hotspot3d","hotspot","hybridsort","kmeans",
#"myocyte","nw","pathfinder","srad_v1","srad_v2"]

#benchmarks = ["binomialOPtions","BlackScholes","MonteCarloMultiGPU","particles","SobolQRNG"]

benchmarks = ["convolutionTexture","FDTD3d","nbody","radixSortThrust","transpose"]


freqs = ["76","153","230","307","384","460","537","614","691","768","844","921","998"]
runs = ["1","2","3"]

path13 = "./files_13pc_3_nvidia2/power_measurement_merged_global.txt"
m = open(path13,'w')
for benchmark in benchmarks:
	for freq in freqs:
		s_p=[0.0] * 100000
		s_0=[0.0] * 100000
		s_1=[0.0] * 100000			
		s_2=[0.0] * 100000
		s_3=[0.0] * 100000
		s_4=[0.0] * 100000
		s_5=[0.0] * 100000
		s_6=[0.0] * 100000
		s_7=[0.0] * 100000
		s_8=[0.0] * 100000
		s_9=[0.0] * 100000
		s_10=[0.0] * 100000
		s_11=[0.0] * 100000
		s_12=[0.0] * 100000
		for run in runs:
			fline=0
			path0 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c0_"+benchmark+"_"+freq+".txt"
			path1 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c1_"+benchmark+"_"+freq+".txt"
			path2 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c2_"+benchmark+"_"+freq+".txt"
			path3 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c3_"+benchmark+"_"+freq+".txt"
			path4 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c4_"+benchmark+"_"+freq+".txt"
			path5 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c5_"+benchmark+"_"+freq+".txt"
			path6 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c6_"+benchmark+"_"+freq+".txt"
			path7 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c7_"+benchmark+"_"+freq+".txt"
			path8 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c8_"+benchmark+"_"+freq+".txt"
			path9 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c9_"+benchmark+"_"+freq+".txt"
			path10 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c10_"+benchmark+"_"+freq+".txt"
			path11 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c11_"+benchmark+"_"+freq+".txt"
			path12 = "./files_13pc_"+run+"_nvidia2/power_measurement_log_c12_"+benchmark+"_"+freq+".txt"
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
			if benchmark == "convolutionTexture" and freq == "76" and run == "1":
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
				if len(l_11) == 0:
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
					if (run == str(run_number)):
						if (w_0[7]) == "nan":
							w_0[7] = "0.0"
						if (w_1[8]) == "nan":
							w_1[8] = "0.0"
						if (w_2[9]) == "nan":
							w_2[9] = "0.0"
						if (w_3[10]) == "nan":
							w_3[10] = "0.0"
						if (w_4[11]) == "nan":
							w_4[11] = "0.0"
						if (w_5[12]) == "nan":
							w_5[12] = "0.0"
						if (w_6[13]) == "nan":
							w_6[13] = "0.0"
						if (w_7[14]) == "nan":
							w_7[14] = "0.0"
						if (w_8[15]) == "nan":
							w_8[15] = "0.0"
						if (w_9[16]) == "nan":
							w_9[16] = "0.0"
						if (w_10[17]) == "nan":
							w_10[17] = "0.0"
						if (w_11[18]) == "nan":
							w_11[18] = "0.0"
						if (w_12[19]) == "nan":
							w_12[19] = "0.0"
						s_l = (float(w_0[6])+ float(w_1[6])+ float(w_2[6])+ float(w_3[6])+ float(w_4[6])+ float(w_5[6])+ float(w_6[6])+float(w_7[6])+float(w_8[6])+float(w_9[6])+float(w_10[6])+float(w_11[6])+float(w_12[6]))/13
						s_p[fline]=(s_p[fline]+s_l)/run_number
						s_0[fline]=(s_0[fline]+float(w_0[7]))/run_number
						s_1[fline]=(s_1[fline]+float(w_1[8]))/run_number				
						s_2[fline]=(s_2[fline]+float(w_2[9]))/run_number
						s_3[fline]=(s_3[fline]+float(w_3[10]))/run_number
						s_4[fline]=(s_4[fline]+float(w_4[11]))/run_number
						s_5[fline]=(s_5[fline]+float(w_5[12]))/run_number
						s_6[fline]=(s_6[fline]+float(w_6[13]))/run_number
						s_7[fline]=(s_7[fline]+float(w_7[14]))/run_number
						s_8[fline]=(s_8[fline]+float(w_8[15]))/run_number
						s_9[fline]=(s_9[fline]+float(w_9[16]))/run_number
						s_10[fline]=(s_10[fline]+float(w_10[17]))/run_number
						s_11[fline]=(s_11[fline]+float(w_11[18]))/run_number
						s_12[fline]=(s_12[fline]+float(w_12[19]))/run_number
						new_line = w_0[0]+"	"+w_0[1]+"	"+w_0[2]+"	"+w_0[3]+"	"+w_0[4]+"	"+w_0[5]+"	"+str(s_p[fline])+"	"+str(s_0[fline])+"	"+str(s_1[fline])+"	"+str(s_2[fline])+"	"+str(s_3[fline])+"	"+str(s_4[fline])+"	"+str(s_5[fline])+"	"+str(s_6[fline])+"	"+str(s_7[fline])+"	"+str(s_8[fline])+"	"+str(s_9[fline])+"	"+str(s_10[fline])+"	"+str(s_11[fline])+"	"+str(s_12[fline])
						print(new_line,file=m)
					else:
						if (w_0[7]) == "nan":
							w_0[7] = "0.0"
						if (w_1[8]) == "nan":
							w_1[8] = "0.0"
						if (w_2[9]) == "nan":
							w_2[9] = "0.0"
						if (w_3[10]) == "nan":
							w_3[10] = "0.0"
						if (w_4[11]) == "nan":
							w_4[11] = "0.0"
						if (w_5[12]) == "nan":
							w_5[12] = "0.0"
						if (w_6[13]) == "nan":
							w_6[13] = "0.0"
						if (w_7[14]) == "nan":
							w_7[14] = "0.0"
						if (w_8[15]) == "nan":
							w_8[15] = "0.0"
						if (w_9[16]) == "nan":
							w_9[16] = "0.0"
						if (w_10[17]) == "nan":
							w_10[17] = "0.0"
						if (w_11[18]) == "nan":
							w_11[18] = "0.0"
						if (w_12[19]) == "nan":
							w_12[19] = "0.0"
						s_l = (float(w_0[6])+ float(w_1[6])+ float(w_2[6])+ float(w_3[6])+ float(w_4[6])+ float(w_5[6])+ float(w_6[6])+float(w_7[6])+float(w_8[6])+float(w_9[6])+float(w_10[6])+float(w_11[6])+float(w_12[6]))/13
						s_p[fline]=s_p[fline]+s_l
						s_0[fline]=s_0[fline]+float(w_0[7])
						s_1[fline]=s_1[fline]+float(w_1[8])				
						s_2[fline]=s_2[fline]+float(w_2[9])
						s_3[fline]=s_3[fline]+float(w_3[10])
						s_4[fline]=s_4[fline]+float(w_4[11])
						s_5[fline]=s_5[fline]+float(w_5[12])
						s_6[fline]=s_6[fline]+float(w_6[13])
						s_7[fline]=s_7[fline]+float(w_7[14])
						s_8[fline]=s_8[fline]+float(w_8[15])
						s_9[fline]=s_9[fline]+float(w_9[16])
						s_10[fline]=s_10[fline]+float(w_10[17])
						s_11[fline]=s_11[fline]+float(w_11[18])
						s_12[fline]=s_12[fline]+float(w_12[19])
				fline=fline+1
c_0.close()
c_1.close()
c_2.close()
c_3.close()
c_4.close()
c_5.close()
m.close()



