#!/bin/bash

for count in $(seq 200 100 1400)
do
	./octave_makemodel_samuel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_blackscholes_c8_allfreq_run12345_noevents.data -b Parsecsplits/parsec.blackscholes.data -f $count -s Analysed_Results/cset_data/xu3_1/Samuel/LITTLE_$count.data
done
