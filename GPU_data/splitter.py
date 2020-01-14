import sys

path0 = "./files_13pc_2/"+sys.argv[position]
	position = position+1
	print("the input file is ",path0) 
	c_0 = open(path0,'r')
	header=c_0.readline()
	l_0 = c_0.readline()
	w_0 = l_0.split()
	bench_name = w_0[1]
	path_out = path0.split("/")
	path_out = path_out[-1].split(".")
	print("the benchmark name is ",bench_name) 
	bench_names.append(bench_name)
	output_file = "./files_13pc_2/"+path_out[0]+"_"+bench_name+".txt"
	m = open(output_file,'a')
	print(header.rstrip('\n'),file=m)
	print(l_0.rstrip('\n'),file=m)
	for l_0 in c_0: #read lines one by one
		w_0 = l_0.split()
		if (w_0[1] == bench_name):
			print(l_0.rstrip('\n'),file=m)
		else: #new_bench_name
			m.close() #close file
			bench_name = w_0[1] #update bench
			print("the benchmark name is ",bench_name) 
			output_file = "./files_13pc_2/"+path_out[0]+"_"+bench_name+".txt"
			m = open(output_file,'a')
			if bench_name not in bench_names:
				bench_names.append(bench_name)
				print(header.rstrip('\n'),file=m)
			print(l_0.rstrip('\n'),file=m)
c_0.close()
m.close()


