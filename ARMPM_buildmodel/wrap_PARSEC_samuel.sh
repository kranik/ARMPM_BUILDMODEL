#!/bin/bash

#Run $1

#parsec.facesim
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/parsec.facesim.data -p 8 -e 5 -o 1

#parsec.dedup
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/parsec.dedup.data -p 8 -e 5 -o 1

#parsec.freqmine
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/parsec.freqmine.data -p 8 -e 5 -o 1

#parsec.streamcluster
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/parsec.streamcluster.data -p 8 -e 5 -o 1

#splash2x.radiosity
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/splash2x.radiosity.data -p 8 -e 5 -o 1

#splash2x.raytrace
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/splash2x.raytrace.data -p 8 -e 5 -o 1

#splash2x.barnes
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/splash2x.barnes.data -p 8 -e 5 -o 1

#splash2x.fmm
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/splash2x.fmm.data -p 8 -e 5 -o 1

#parsec.dedup
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Samuel/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_c4_maxfreq_noevents_run_$1.data -b Parsecsplits/splash2x.water_nsquared.data -p 8 -e 5 -o 1
