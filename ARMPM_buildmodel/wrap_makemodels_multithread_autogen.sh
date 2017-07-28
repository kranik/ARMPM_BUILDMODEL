#!/bin/bash

#XU3_1

########
#LITTLE#
########

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 6 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_botup_relerr.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 2 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 6 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_botup_stddev.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 4 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 6 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_botup_avgcrosscorr.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 32 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_botup_relerr_maxevents.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 2 -c 4 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 6 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_topdown_avgcrosscorr.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b PARSEC_split.data -p 9 -e 10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40 -n 5 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall_botup_relerr_nonumcores.data


########
#big####
########

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64 -n 8 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall_botup_relerr.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 2 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64 -n 8 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall_botup_stddev.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 3 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64 -n 8 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall_botup_crosscorr.data

#./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b PARSEC_split.data -p 9 -e 4,10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64 -n 56 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall_botup_relerr_maxevents.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b PARSEC_split.data -p 9 -e 10 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64 -n 7 -o 2 -s Analysed_Results/cset_data/xu3_1/multithread/models/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall_botup_relerr_nonumcores.data

########
#Cross##
########

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elcommon.data -t Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elcommon.data -b PARSEC_split.data -p 9 -e 4,10 -x 2 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26 -n 8 -o 2 -s Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_bigLITTLE_coreall_elcommon_botup_relerr.data

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elcommon.data -t Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elcommon.data -b PARSEC_split.data -p 9 -e 4,10 -x 2 -m 1 -c 1 -l 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26 -n 6 -o 2 -s Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLEbig_coreall_elcommon_botup_relerr.data


