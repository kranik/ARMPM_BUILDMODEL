#!/bin/bash

#XU3_1

########
#LITTLE#
########

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 1 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39 -n 5 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall_topdown_relerr.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 2 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39 -n 5 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall_topdown_stddev.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 3 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39 -n 5 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c1_elall_topdown_crosscorr.data


########
#big####
########

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 1 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63 -n 7 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall_topdown_relerr.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 2 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63 -n 7 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall_topdown_stddev.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/c1/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall.data -b PARSEC_split.data -p 8 -e 9 -m 2 -c 3 -l 10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63 -n 7 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_c1_elall_topdown_crosscorr.data

########
#Cross##
########


