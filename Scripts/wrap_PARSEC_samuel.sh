#!/bin/bash

A7_freq="1400,1300,1200,1100,1000,900,800,700,600,500,400,300,200"
IFS="," read -a A7_freq_list <<< $A7_freq
A15_freq="1800,1700,1600,1500,1400,1300,1200,1100,1000,900,800,700,600,500,400,300,200"
IFS="," read -a A15_freq_list <<< $A15_freq

for count in $(seq 0 $((${#A7_freq_list[@]}-1)))
do
	for count2 in $(seq 0 $((${#A15_freq_list[@]}-1)))
	do	
		./octave_makemodel_samuel.sh -r $1 -b $2 -f ${A7_freq_list[$count]} -q ${A15_freq_list[$count2]} | awk -v SEP=' ' -v A7FREQ=${A7_freq_list[$count]} -v A15FREQ=${A15_freq_list[$count2]} 'BEGIN{FS=SEP}{ if( $1 == A7FREQ && $2 == A15FREQ &&$3 != '\n' ) {print $0 }}'
	done
done
