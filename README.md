This GPU branch has been used with the NVIDIA TX1 Jetson GPU for this paper:

"Run-Time Power Modelling in Embedded GPUs withDynamic Voltage and Frequency Scaling" published in the PARMA-DITAM 2020 as part of the HIPEAC conference.
Authors Jose Nunez-Yanez, Kris Nikov, Kerstin Eder, Mohammad HosseinabadyDepartment of Electrical and Electronic Engineering,University of Bristol, United Kingdom

getting started


To run pmonitor you launch as root like:
 
sudo ./pmonitor
 
 
Copy the directory with results from the board into a machine where you can run the python scripts.
 
splitter_freq.py needs arguments like power_measurement_log_c0.dat,  power_measurement_log_c1.dat ...  power_measurement_log_c12.dat.


For example:


python splitter_freq.py powerpower_measurement_log_c0.dat,  power_measurement_log_c1.dat (other files for the other PC)  power_measurement_log_c12.dat


it will split the files into individual files corresponding to individual benchmarks and frequencies like:


power_measurement_log_c0_binomialoptions_76.dat


etc


Then 
 
global_merger_nvidia.py will go through all the files created from splitter and generate a single file like this:
 
./run_64_nvidia/power_measurement_merged_global.txt


that contains all the performance counter information in the right format for the power model tool to use to create the power model. 
 
You call it like:
 
python global_merger_nvidia.py
 
Depending on where information is located and the name of the files this py scripts will need updating.

Then it is time to create the power model, for example:

octave_makemodel.sh -r measurement.txt  -b benchmark.txt  -f 76,153,230,307,384,460,537,614,691,768,844,921,998 -p 7 -m 1 -l 8,9,10,11,12,13,14,15,16,17,18,19,20 -n 4 -c 1 -o 2

In this listing, the octave_makemodel script receives with -r a measurement.txt text file containing the power and activity counter samples with around 12,000 samples in our case. Then with -b a benchmark.txt file that identifies which benchmarks should be used for training and which for testing. Then with -f all the frequency values that are going to be considered (each frequency value also corresponds to a different voltage as determined by the DVFS table), -p identifies the column number in measurement.txt that contains power information, -m set to 1 is the search mode heuristic defined as bottom-up and -l lists the performance counters selected for analysis as columns in measurement.txt, -n set to 4 instructs the framework to search for the best possible four performance counters that result in a more accurate model as indicated with -c 1.  This means that the script will search up to a maximum of 4 performance counters in the list provided, across all the frequencies and voltages automatically. The result is a set of coefficients for each frequency/voltage pair. 

This octave_model.sh will use octave so you need to install that since it will call the build_model.m octave file.

An example of measurement.txt is provided in run_255_nvidia directory with the name power_measurement_merged_global.txt
An example of benchmark.txt is provided in benchmark_13pc_nvidia2.txt file.


 