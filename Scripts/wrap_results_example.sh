#!/bin/bash

#####################################
#########cBench######################
#####################################

#CPU - big
#We startby concatenating the results between the benchmark timestamps, PMU events and sensor data for each set of 5 collected events (a.k.a. event list)
#In this example I have just three frequencies and two benchmark runs, but you can do more since the scripts can be programmed.

#Events1
./XU3_results.sh -r ../Examples/Raw_Data/cBench/big/events_list_1/ -n 1,2 -e -s ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_el1_big.data

#Events2
./XU3_results.sh -r ../Examples/Raw_Data/cBench/big/events_list_2/ -n 1,2 -e -s ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_el2_big.data

#Merge
#After we have concatednated the two lists into two files (one for each) we must merge them into one big file to facilitate the model generation
./XU3_merge_events.sh -r ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_el1_big.data -r ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_el2_big.data -s ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_big.data

#Truncate
#In this example column 10 contains the SW_INCR event which is triggered very rarely by the benchmark and is useless for the power models. I have a script which can help manually delete unwanted event columns. 
./truncate_event_columns.sh -r ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_big.data -e 10 -m 2 -s ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_big_truncated.data

#Models
#Finally we have the script to generte the models using octave on the final concatenated file. We use CPU Power (column 8) as the regressand and we start by using CPU_CYCLES as the first regressor. We can go up to 7 events since those are the number of practical events which can be collected at the same time by the Cortex-A15 PMU. Please use $ ./octave_makemodel.sh -h for an explanation avbout the other options.
./octave_makemodel.sh -r ../Examples/Concatenated_Data/cBench/xu3_cset_perfcpu_cBench_eMMC_big_truncated.data -b ../Examples/cbench_split.data -p 8 -e 9 -m 1 -c 1 -l 10,11,12,13,14,15,16,17,18,19,20 -n 7 -o 2

#####################################
#########PARSEC######################
#####################################

#CPU - big
#It is the same situation for the Multicore/Multithread case. However here we have even more separation by the number of cores used by the benchmark.

#1Core

#Events1
./XU3_results.sh -r ../Examples/Raw_Data/PARSEC/1core/big/events_list_1/ -n 1,2 -e -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_el1_big.data

#Events2
./XU3_results.sh -r ../Examples/Raw_Data/PARSEC/1core/big/events_list_2/ -n 1,2 -e -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_el2_big.data

#2Core

#Events1
./XU3_results.sh -r ../Examples/Raw_Data/PARSEC/2core/big/events_list_1/ -n 1,2 -e -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_el1_big.data

#Events2
./XU3_results.sh -r ../Examples/Raw_Data/PARSEC/2core/big/events_list_2/ -n 1,2 -e -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_el2_big.data

#Merge
#The distinct part is we must first merge the different events lists per core configuration and then move on to merging all core configurations into one file for the power modelling script.

./XU3_merge_events.sh -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_el1_big.data -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_el2_big.data -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_big.data

./XU3_merge_events.sh -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_el1_big.data -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_el2_big.data -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_big.data

./XU3_merge_multithread.sh -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_1core_big.data -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_2core_big.data -s ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_big.data

#Truncate
#No need to truncate for the PARSEC case, since the examples do not contain any bad events

#Models
#Same situation here as with the Single-Thread/Core model. We use the final concatenated file to generate the models using octave. This time we have an extra column 4 - CPU Cores, which we use as a starting point regressor alongside CPU_CYCLES for the models. CPU Power is column 9 in this file.  
./octave_makemodel.sh -r ../Examples/Concatenated_Data/PARSEC/xu3_cset_perfcpu_PARSEC_eMMC_big.data -b ../Examples/PARSEC_split.data -p 9 -e 4,10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22 -n 7 -o 2
