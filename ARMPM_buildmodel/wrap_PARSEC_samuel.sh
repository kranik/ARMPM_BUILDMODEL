#!/bin/bash

A7_freq="200,300,400,500,600,700,800,900,1000,1100,1200,1300,1400"
IFS="," read -a A7_freq_list <<< $A7_freq
A15_freq_list=$2
IFS="," read -a A15_freq_list <<< $2

for count in $(seq 0 $((${#A7_freq_list[@]}-1)))
do
	./octave_makemodel_samuel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_c8_customfreqlist_noevents.data -b $1 -p 8 -e 5 -o 1 -f ${A7_freq_list[$count]} -q ${A15_freq_list[$count]} | awk -v SEP=' ' -v FREQ=${A7_freq_list[$count]} 'BEGIN{FS=SEP}{ if( $1 == FREQ && $2 != '\n' ) {print $5"\t"($3+$4)*$5 }}'
done
