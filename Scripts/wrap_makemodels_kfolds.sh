#!/bin/bash

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#cBench~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#####################################
#LITTLE##############################
#####################################

#automotive_bitcount
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/1.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_automotive_bitcount.data

#automotive_qsort1

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/2.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_automotive_qsort1.data

#automotive_susan_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/3.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_automotive_susan_c.data

#automotive_susan_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/4.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_automotive_susan_e.data

#automotive_susan_s

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/5.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_automotive_susan_s.data

#bzip2d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/6.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_bzip2d.data

#bzip2e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/7.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_bzip2e.data

#consumer_jpeg_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/8.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_jpeg_c.data

#consumer_jpeg_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/9.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_jpeg_d.data

#consumer_tiff2bw

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/10.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_tiff2bw.data

#consumer_tiff2rgba

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/11.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_tiff2rgba.data

#consumer_tiffdither

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/12.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_tiffdither.data

#consumer_tiffmedian

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/13.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_consumer_tiffmedian.data

#network_dijkstra

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/14.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_network_dijkstra.data

#network_patricia

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/15.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_network_patricia.data

#office_ghostscript

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/16.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_office_ghostscript.data

#office_ispell

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/17.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_office_ispell.data

#office_rsynth

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/18.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_office_rsynth.data

#office_stringsearch1

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/19.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_office_stringsearch1.data

#security_blowfish_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/20.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_blowfish_d.data

#security_blowfish_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/21.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_blowfish_e.data

#security_pgp_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/22.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_pgp_d.data

#security_pgp_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/23.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_pgp_e.data

#security_rijndael_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/24.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_rijndael_d.data

#security_rijndael_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/25.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_rijndael_e.data

#security_sha

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/26.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_security_sha.data

#telecom_adpcm_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/27.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_telecom_adpcm_c.data

#telecom_adpcm_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/28.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_telecom_adpcm_d.data

#telecom_CRC32

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/29.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_telecom_CRC32.data

#telecom_gsm

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/LITTLE/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_LITTLE.data -b KFoldsSplits/cBench/30.data -p 6 -e 7,30,26,19,29 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/LITTLE/xu3_1_eMMC_perfcpu_cset_cBench_LITTLE_bestevents_kfolds_telecom_gsm.data

#####################################
#big#################################
#####################################

#automotive_bitcount
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/1.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_automotive_bitcount.data

#automotive_qsort1

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/2.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_automotive_qsort1.data

#automotive_susan_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/3.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_automotive_susan_c.data

#automotive_susan_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/4.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_automotive_susan_e.data

#automotive_susan_s

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/5.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_automotive_susan_s.data

#bzip2d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/6.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_bzip2d.data

#bzip2e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/7.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_bzip2e.data

#consumer_jpeg_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/8.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_jpeg_c.data

#consumer_jpeg_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/9.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_jpeg_d.data

#consumer_tiff2bw

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/10.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_tiff2bw.data

#consumer_tiff2rgba

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/11.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_tiff2rgba.data

#consumer_tiffdither

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/12.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_tiffdither.data

#consumer_tiffmedian

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/13.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_consumer_tiffmedian.data

#network_dijkstra

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/14.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_network_dijkstra.data

#network_patricia

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/15.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_network_patricia.data

#office_ghostscript

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/16.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_office_ghostscript.data

#office_ispell

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/17.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_office_ispell.data

#office_rsynth

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/18.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_office_rsynth.data

#office_stringsearch1

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/19.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_office_stringsearch1.data

#security_blowfish_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/20.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_blowfish_d.data

#security_blowfish_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/21.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_blowfish_e.data

#security_pgp_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/22.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_pgp_d.data

#security_pgp_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/23.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_pgp_e.data

#security_rijndael_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/24.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_rijndael_d.data

#security_rijndael_e

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/25.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_rijndael_e.data

#security_sha

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/26.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_security_sha.data

#telecom_adpcm_c

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/27.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_telecom_adpcm_c.data

#telecom_adpcm_d

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/28.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_telecom_adpcm_d.data

#telecom_CRC32

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/29.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_telecom_CRC32.data

#telecom_gsm

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/allevents/big/xu3_1_cset_perfcpu_cBench_eMMC_allevents_elall_merged_truncated_big.data -b KFoldsSplits/cBench/30.data -p 6 -e 7,18,10,24,42,58 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/cBench/big/xu3_1_eMMC_perfcpu_cset_cBench_big_bestevents_kfolds_telecom_gsm.data

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#PARSEC~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#####################################
#LITTLE##############################
#####################################

#parsec.facesim
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/1.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_parsec_facesim.data

#parsec.dedup

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/2.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_parsec_dedup.data

#parsec.freqmine

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/3.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_parsec_freqmine.data

#parsec.streamcluster

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/4.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_parsec_streamcluster.data

#splash2x.radiosity

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/5.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_splash2x_radiosity.data

#splash2x.raytrace

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/6.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_splash2x_raytrace.data

#splash2x.water_nsquared

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/7.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_splash2x_water_nsquared.data

#splash2x.barnes

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/8.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_splash2x_barnes.data

#splash2x.fmm

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_elall.data -b KFoldsSplits/PARSEC/9.data -p 9 -e 4,10,26,27,14,20 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/LITTLE/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_LITTLE_coreall_bestevents_kfolds_splash2x_fmm.data

#####################################
#big#################################
#####################################

#parsec.facesim
./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/1.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_parsec_facesim.data

#parsec.dedup

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/2.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_parsec_dedup.data

#parsec.freqmine

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/3.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_parsec_freqmine.data

#parsec.streamcluster

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/4.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_parsec_streamcluster.data

#splash2x.radiosity

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/5.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_splash2x_radiosity.data

#splash2x.raytrace

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/6.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_splash2x_raytrace.data

#splash2x.water_nsquared

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/7.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_splash2x_water_nsquared.data

#splash2x.barnes

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/8.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_splash2x_barnes.data

#splash2x.fmm

./octave_makemodel.sh -r Concatenated_Results/cset_data/xu3_1/PARSEC/Multithread/allevents/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_elall.data -b KFoldsSplits/PARSEC/9.data -p 9 -e 4,10,28,18,64,39,60,27 -o 3 -s Analysed_Results/cset_data/xu3_1/KFolds/PARSEC/big/xu3_1_eMMC_perfcpu_cset_PARSEC_greenbench_big_coreall_bestevents_kfolds_splash2x_fmm.data
