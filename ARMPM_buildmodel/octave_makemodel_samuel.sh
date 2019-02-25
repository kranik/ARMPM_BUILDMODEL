#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi
#Internal parameters
TIME_CONVERT=1000000000

#Extract unique benchmark split from result file
benchmarkSplit () {
	#Read and randomise benchmarks, assumes column 2 is benchmarks.
	#I can automate this by searching the header and extracting column number if I need to, but this is very rarely used.
	local RANDOM_BENCHMARK_LIST
	RANDOM_BENCHMARK_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v COL="$RESULT_BENCH_COL" -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $COL != BENCH){print ($COL);BENCH=$COL} }' < "$RESULT_FILE" | sort -u | sort -R | sed 's/ /\\n/g' )
	local NUM_BENCH
	NUM_BENCH=$(echo -e "$RANDOM_BENCHMARK_LIST" | wc -l)
	#Get midpoint to split the randomised list
	local MIDPOINT
	MIDPOINT=$(echo "scale = 0; $NUM_BENCH/2;" | bc )
	#I need to use this temp to extract the string
	#Bash gets confused with too many variable substitutions, that why I need the temp
	local temp
	temp=$(echo -e "$RANDOM_BENCHMARK_LIST" | head -n "$MIDPOINT" | sort -d | tr "\n" "," | head -c -1)
	IFS="," read -a TRAIN_SET <<< "$temp"
	temp=$(echo -e "$RANDOM_BENCHMARK_LIST" | tail -n "$(echo "scale = 0; $NUM_BENCH-$MIDPOINT;" | bc )" | sort -d | tr "\n" "," | head -c -1)
	IFS="," read -a TEST_SET <<< "$temp"
}

#Simple script to get the mean of an array
#Need to pass the name of the array as first argument and then the element count as second argument
#Then use BC to compute mean since bash has just integer logic and we are almost surely dealing with fractions for the mean
getMean () {
	local total=0
	local -n array=$1
	for i in $(seq 0 $(($2-1)))
	do
		total=$(echo "$total+${array[$i]};" | bc )
	done
	echo "scale=5; $total/$2;" | bc
}

#Simple script to get the standart deviation of an array. Need for cross-models
#Need to pass the name of the array as first argument and then the element count as second argument
#Build the input string to octave using the array indexes then use the octave function to get answer
getStdDev () {
	local total=0
	local -n array=$1
	matrix_string="[ "
	for i in $(seq 0 $(($2-1)))
	do
		matrix_string+="${array[$i]} "
	done
	matrix_string+="]"
	out=""
	while [[ $out == "" ]]
	do
		#Use octave to compute the std deviation of the string and remove leading whitespace with sed
		out=$(octave --silent --eval "disp(std($matrix_string,1))" 2> /dev/null | sed 's/ //g')
	done
	echo "$out"
}

#Simple script to get the index of the max of an array, needed to identify the cross-correlation max and get indices
#Need to pass the name of the array as first argument and then the element count as second argument
getMaxIndex () {
	local max=0
	local maxindex=0
	local -n array=$1
	for i in $(seq 0 $(($2-1)))
	do
		if [[ "${array[$i]}" > $max ]];then
			max=${array[$i]}
			maxindex=$i
		fi
	done
	echo "$maxindex"
}

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:t:f:b:p:e:ax:q:m:c:l:n:o:s:h" opt;
do
	case $opt in
		h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the concatednated result file to be analyzed." >&1
			echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
			echo "-q [FREQENCY LIST][MHz] -> Specify the frequencies to be used in cross-model for the second core (specified with -t flag)." >&1
			echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
			echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
			echo "Mandatory options are: -r, -b"
			exit 0 
			;;

		#Specify the result file
		r)
			if [[ -n $RESULT_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				echo -e "===================="
				exit 1                
			else
				RESULT_FILE="$OPTARG"
			fi
		    	;;
		#Specify frequency list
		f)
		    	if [[ -n $A7_FREQ_LIST ]]; then
			    	echo "Invalid input: option -f has already been used!" >&2
				echo -e "===================="
		            	exit 1
			else	
				A7_FREQ_LIST="$OPTARG"
		    	fi
			;;
		q)
		    	if [[ -n $A15_FREQ_LIST ]]; then
			    	echo "Invalid input: option -q has already been used!" >&2
				echo -e "===================="
		            	exit 1
			else	
				A15_FREQ_LIST="$OPTARG"
		    	fi
			;;
		#Specify the benchmarks split file, if no benchmarks are chosen the program can be used to make a new randomised benchmark split
		b)
			if [[ -n $BENCH_FILE ]]; then
		    		echo "Invalid input: option -b has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else
				BENCH_FILE="$OPTARG"
			fi
		    	;;
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
				echo -e "===================="
			    	exit 1                
			else
		    		SAVE_FILE="$OPTARG"
			fi
			;;        
		:)
		    	echo "Option: -$OPTARG requires an argument" >&2
			echo -e "===================="
		    	exit 1
		    	;;
		\?)
		    	echo "Invalid option: -$OPTARG" >&2
			echo -e "===================="
		    	exit 1
		    	;;
	esac
done

#Critical sanity checks
echo -e "===================="
if [[ -z $RESULT_FILE ]]; then
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use -b flag with existing file or an empty file to generate random benchmark split." >&2
	echo -e "====================" >&1
	exit 1
fi
#Check correct flag usage

#-r flag
#Check if result file is present
#Make sure the result file exists
if [[ ! -e "$RESULT_FILE" ]]; then
	echo "-r $RESULT_FILE does not exist. Please enter the result file to be analyzed!" >&2
	echo -e "===================="
	exit 1
else
	#Check if result file contains data
	RESULT_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$RESULT_FILE")
    	if [[ -z $RESULT_START_LINE ]]; then 
		echo "Results file contains no data!" >&2
		echo -e "===================="
		exit 1
	fi

	#Exctract run column and list
	RESULT_RUN_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_RUN_COL ]]; then
		echo "Results file contains no run column!" >&2
		echo -e "===================="
		exit 1
	fi

	RESULT_RUN_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_RUN_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -g | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_RUN_LIST ]]; then
		echo "Unable to extract run list from result file!" >&2
		echo -e "===================="
		exit 1
	fi
	#Extract run number for runtime information now that we have events column
	RESULT_RUN_START=$(echo "$RESULT_RUN_LIST" | tr "," "\n" | head -n 1)
	RESULT_RUN_END=$(echo "$RESULT_RUN_LIST" | tr "," "\n" | tail -n 1)

	#Exctract freq column and list
	A7_FREQ_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="CPU(0) Frequency(MHz)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A7_FREQ_COL ]]; then
		echo "Results file contains no LITTLE freqeuncy column!" >&2
		echo -e "===================="
		exit 1
	fi

	A15_FREQ_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="CPU(4) Frequency(MHz)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A15_FREQ_COL ]]; then
		echo "Results file contains no big freqeuncy column!" >&2
		echo -e "===================="
		exit 1
	fi

	RESULT_A7_FREQ_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$A7_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_A7_FREQ_LIST ]]; then
		echo "Unable to extract LITTLE freqeuncy list from result file!" >&2
		echo -e "===================="
		exit 1
	fi

	RESULT_A15_FREQ_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$A15_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_A15_FREQ_LIST ]]; then
		echo "Unable to extract big freqeuncy list from result file!" >&2
		echo -e "===================="
		exit 1
	fi

	#Exctract power columns
	A7_VOLTAGE_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="A7 Voltage(V)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A7_VOLTAGE_COL ]]; then
		echo "Results file contains no LITTLE voltage column!" >&2
		echo -e "===================="
		exit 1
	fi

	A15_VOLTAGE_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="A15 Voltage(V)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A15_VOLTAGE_COL ]]; then
		echo "Results file contains no big voltage column!" >&2
		echo -e "===================="
		exit 1
	fi

	#Exctract power columns
	A7_POWER_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="A7 Power(W)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A7_POWER_COL ]]; then
		echo "Results file contains no LITTLE power column!" >&2
		echo -e "===================="
		exit 1
	fi

	A15_POWER_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v STRING="A15 Power(W)" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i == STRING) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $A15_POWER_COL ]]; then
		echo "Results file contains no big power column!" >&2
		echo -e "===================="
		exit 1
	fi

	#Exctract bench column and list
	RESULT_BENCH_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_BENCH_COL ]]; then
		echo "Results file contains no benchmark column!" >&2
		echo -e "===================="
		exit 1
	fi

	RESULT_BENCH_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_BENCH_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -d | tr "\n" "," | head -c -1)
	if [[ -z $RESULT_BENCH_LIST ]]; then
		echo "Unable to extract benchmarks from result file!" >&2
		echo -e "===================="
		exit 1
	fi
fi

#-f flag
#Check if user specified frequencies are present in result file and test/cross file
if [[ -n $A7_FREQ_LIST ]]; then
	#Go throught the user frequencies and make sure they are not out of bounds of the train file
	spaced_A7_FREQ_LIST="${A7_FREQ_LIST//,/ }"
	IFS="," read -a FREQ_LIST <<< "$RESULT_A7_FREQ_LIST"
	for FREQ_SELECT in $spaced_A7_FREQ_LIST
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
			echo "selected frequency $FREQ_SELECT for -f is not present in result file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
fi

#-q flag
#Check if user specified frequencies are present in result file and test/cross file
if [[ -n $A15_FREQ_LIST ]]; then
	#Go throught the user frequencies and make sure they are not out of bounds of the train file
	spaced_A15_FREQ_LIST="${A15_FREQ_LIST//,/ }"
	IFS="," read -a FREQ_LIST <<< "$RESULT_A15_FREQ_LIST"
	for FREQ_SELECT in $spaced_A15_FREQ_LIST
	do
		#containsElement "$FREQ_SELECT" "${CROSS_FREQ_LIST[@]}"
		if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
			echo "selected frequency $FREQ_SELECT for -q is not present in test(cross) file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
fi

#-b flag
#Check if bench split file exists
if [[ -e "$BENCH_FILE" ]]; then
    	#Extract benchmark split information.
    	BENCH_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$BENCH_FILE")
	#Check if bench file contains data
	if [[ -z $BENCH_START_LINE ]]; then
		echo "Benchmarks split file contains no data!" >&2
		echo -e "===================="
		exit 1
	fi
	IFS=";" read -a TRAIN_SET <<< "$(awk -v SEP='\t' -v START="$BENCH_START_LINE" 'BEGIN{FS=SEP}{if (NR >= START){ print $1 }}' < "$BENCH_FILE" | sort -d | tr "\n" ";" | head -c -1 )"
	IFS=";" read -a TEST_SET <<< "$(awk -v SEP='\t' -v START="$BENCH_START_LINE" 'BEGIN{FS=SEP}{if (NR >= START){ print $2 }}' < "$BENCH_FILE" | sort -d | tr "\n" ";" |  head -c -1 )"
	#Check if we have successfully extracted benchmark sets 
	if [[ ${#TRAIN_SET[@]} == 0 || ${#TEST_SET[@]} == 0 ]]; then
		echo "Unable to extract train or test set from benchmarks file!" >&2
		echo -e "===================="
		exit 1
	fi
	#Check if benchmarks specified by bench split files are present in train/test/cross files
	IFS="," read -a BENCH_LIST <<< "$RESULT_BENCH_LIST"
	for count in $(seq 0 1 $((${#TRAIN_SET[@]}-1)))
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${BENCH_LIST[@]} " =~ " ${TRAIN_SET[$count]} " ]]; then
			echo "Specified train benchmark ${TRAIN_SET[$count]} for -b is not present in result file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
	for count in $(seq 0 1 $((${#TEST_SET[@]}-1)))
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${BENCH_LIST[@]} " =~ " ${TEST_SET[$count]} " ]]; then
			echo "Specified test benchmark ${TEST_SET[$count]} for -b is not present in result file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
fi

echo -e "Critical checks passed!"  >&1
echo -e "===================="
#Regular sanity checks
#After all critical checks pass do empty/existing file overwrite (-b; -s flag) 
#-b flag
if [[ ! -e "$BENCH_FILE" ]]; then
    	echo "-b $BENCH_FILE does not exist. Do you want to create a new benchmark split and save in file? (Y/N)" >&1
    	[[ -n $TEST_FILE ]] && echo "Note only benchmarks found in  result file $RESULT_FILE (specified with -r flag) will be used and -t $TEST_FILE will be ignored. If you want to use both, please concatenate both files and rerun program with -r new_cat_file" >&1
    	#wait on user input here (Y/N)
    	#if user says Y set writing directory to that
    	#if no then exit and ask for better input parameters
    	while true;
    	do
		read USER_INPUT
		if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
	    		echo "Creating new benchmark split file $BENCH_FILE using benchmarks in train file -r $RESULT_FILE" >&1
			#Perform randomised split and 
			benchmarkSplit
			#Store benchmarks
			echo -e "#Train Set\tTest Set" > "$BENCH_FILE"
		 	for i in $(seq 0 $((${#TEST_SET[@]}-1)))
			do
				echo -e "${TRAIN_SET[$i]}\t${TEST_SET[$i]}" >> "$BENCH_FILE" 
			done
			break
		elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
	    		echo "Cancelled creating benchmark split file $BENCH_FILE Program exiting." >&1
	    		exit 0                            
		else
	    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
			echo "Please enter correct input: " >&2
		fi
    	done
fi

#-s flag
#Check if files exists and if yes -> overwrite
if [[ -e $SAVE_FILE ]]; then
	#wait on user input here (Y/N)
	#if user says Y set writing directory to that
	#if no then exit and ask for better input parameters
	echo "-s $SAVE_FILE already exists. Continue writing in file? (Y/N)" >&1
	while true;
	do
		read USER_INPUT
		if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
	    		echo "Using existing file $SAVE_FILE" >&1
	    		break
		elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
	    		echo "Cancelled using save file $SAVE_FILE Program exiting." >&1
	    		exit 0                            
		else
	    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
			echo "Please enter correct input: " >&2
		fi
	done
fi

echo -e "Soft checks passed!"  >&1
#Internal variable checks and assignments#
echo -e "====================" >&1
#Result file sanity check
#-r file
echo -e "--------------------" >&1
echo -e "Using result file:" >&1
echo "$RESULT_FILE" >&1

#Frequency list sanity check
#-f list
echo -e "--------------------" >&1
if [[ -z $A7_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in result file:" >&1
	A7_FREQ_LIST="$RESULT_A7_FREQ_LIST"
else
	echo "Using user specified a7 frequency list:" >&1
fi
echo "$A7_FREQ_LIST" >&1

#-q list
echo -e "--------------------" >&1
if [[ -z $A15_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in result file:" >&1
	A15_FREQ_LIST="$RESULT_A15_FREQ_LIST"
else
	echo "Using user specified a15 frequency list:" >&1
fi
echo "$A15_FREQ_LIST" >&1

#Benchmark split sanity check
#-b file
echo -e "--------------------" >&1
echo -e "Train Set:" >&1
echo "${TRAIN_SET[*]}" >&1
echo -e "--------------------" >&1
echo -e "Test Set:" >&1
echo "${TEST_SET[*]}" >&1
#Check for dupicates in benchmark sets
for i in $(seq 0 $((${#TEST_SET[@]}-1)))
do
	if [[ " ${TRAIN_SET[@]} " =~ " ${TEST_SET[$i]} " ]]; then
		echo -e "--------------------" >&1
		echo -e "Warning! Benchmark sets share benchmark \"${TEST_SET[$i]}\"" >&1
	fi
done

#Issue warning if train sets are different sizes
if [[ ${#TRAIN_SET[@]} != ${#TEST_SET[@]} ]]; then
	echo -e "--------------------" >&1
	echo "Warning! Benchmark sets are different sizes [${#TRAIN_SET[@]};${#TEST_SET[@]}]" >&1
fi

echo -e "--------------------" >&1
echo -e "A7 Voltage: -> $A7_VOLTAGE_COL" >&1
echo -e "A15 Voltage: -> $A15_VOLTAGE_COL" >&1

echo -e "--------------------" >&1
echo -e "A7 Power: -> $A7_POWER_COL" >&1
echo -e "A15 Power: -> $A15_POWER_COL" >&1

#Save file sanity check
#-s file
echo -e "--------------------" >&1
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1


echo "$A7_FREQ_LIST,$A15_FREQ_LIST"
unset -v octave_output
while [[ -z $octave_output ]]
do				
	octave_output=$(octave --silent --eval "COMBINATIONS=nchoosek(str2num('$A7_FREQ_LIST,$A15_FREQ_LIST'),2);disp(COMBINATIONS);" 2> /dev/null)
	IFS=";" read -a FREQ_COMB <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{ print $0 }' | sed 's/^[ \t]*//;s/[ \t]*$//' | tr "\n" ";" | head -c -1)
done
echo "Total number of combinations -> ${#FREQ_COMB[@]}" >&1
echo -e "--------------------" >&1
spaced_A7_FREQ_LIST="${A7_FREQ_LIST//,/ }"
spaced_A15_FREQ_LIST="${A15_FREQ_LIST//,/ }"
count=0
unset -v FREQ_LIST
for i in $(seq 0 $((${#FREQ_COMB[@]}-1)))
do
	echo "Combination $i: ${FREQ_COMB[$i]}"
	#Sanity check combinations and add to freq pairings
	IFS=" " read -a TEMP_FREQ_COMB <<< "${FREQ_COMB[$i]}"
	echo "A7 : ${TEMP_FREQ_COMB[0]}"
	echo "A15 : ${TEMP_FREQ_COMB[1]}"
	#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
	if [[ ! " $spaced_A7_FREQ_LIST " =~ " ${TEMP_FREQ_COMB[0]} " ]]; then
		echo "A7 frequency is ${TEMP_FREQ_COMB[0]} not present in result file. Not using in combination check."
		continue
	fi
	if [[ ! " $spaced_A15_FREQ_LIST " =~ " ${TEMP_FREQ_COMB[1]} " ]]; then
		echo "A15 frequency ${TEMP_FREQ_COMB[1]} is not present in result file. Not using in combination check."
		continue
	fi
	
	if [[ -z $FREQ_LIST ]]; then
		#first pair in lsit
		FREQ_LIST[$count]="${TEMP_FREQ_COMB[0]},${TEMP_FREQ_COMB[1]}"
		count=$count+1
	else
		#Check for duplication	
		for j in $(seq 0 $((${#FREQ_LIST[@]}-1)))
		do
			if [[ "${TEMP_FREQ_COMB[0]},${TEMP_FREQ_COMB[1]}" == "${FREQ_LIST[$j]}" ]]; then
				echo "Frequency list already containes combination ${TEMP_FREQ_COMB[0]},${TEMP_FREQ_COMB[1]}"
				continue 2
			fi
		done
		FREQ_LIST[$count]="${TEMP_FREQ_COMB[0]},${TEMP_FREQ_COMB[1]}"
		count=$count+1
	fi
done

echo "Final frequency list"
echo "A7,A15"
for i in $(seq 0 $((${#FREQ_LIST[@]}-1)))
do
	echo "Combination $i: ${FREQ_LIST[$i]}"
done

while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
do
	unset -v octave_output
	for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
	do
		IFS="," read -a TEMP_FREQ <<< "${FREQ_LIST[$count]}"
		echo "${TEMP_FREQ[0]},${TEMP_FREQ[1]}"
		total_runtime=0
		for runnum in $(seq "$RESULT_RUN_START" 1 "$RESULT_RUN_END")
		do
			#echo "runnum="$runnum"/$RESULT_RUN_END"
			for benchcount in $(seq 0 $((${#TEST_SET[@]}-1)))
			do
				#echo "benchcount="$benchcount"/$((${#TEST_SET[@]}-1))"
				runtime_st=$(awk -v START="$RESULT_START_LINE" -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v A7FREQCOL="$A7_FREQ_COL" -v A7FREQ="${TEMP_FREQ[0]}" -v A15FREQCOL="$A15_FREQ_COL" -v A15FREQ="${TEMP_FREQ[1]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $A7FREQCOL == A7FREQ && $A15FREQCOL == A15FREQ){print $1;exit}}' < "$RESULT_FILE")
				#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
				runtime_nd_nr=$(tac "$RESULT_FILE" | awk -v START=1 -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v A7FREQCOL="$A7_FREQ_COL" -v A7FREQ="${TEMP_FREQ[0]}" -v A15FREQCOL="$A15_FREQ_COL" -v A15FREQ="${TEMP_FREQ[1]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $A7FREQCOL == A7FREQ && $A15FREQCOL == A15FREQ){print NR;exit}}')
				runtime_nd=$(tac "$RESULT_FILE" | awk -v START=$runtime_nd_nr -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
				total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
			done
		done
		#Compute average per-freq runtime
		avg_total_runtime[$count]=$(echo "scale=9;$total_runtime/(($RESULT_RUN_END-$RESULT_RUN_START+1)*$TIME_CONVERT);" | bc )	
		#Collect output for the frequency. Extract freqeuncy level from full set and pass it into octave
		touch "test_set.data"

		awk -v START="$RESULT_START_LINE" -v SEP='\t' -v A7FREQCOL="$A7_FREQ_COL" -v A7FREQ="${TEMP_FREQ[0]}" -v A15FREQCOL="$A15_FREQ_COL" -v A15FREQ="${TEMP_FREQ[1]}" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $A7FREQCOL == A7FREQ && $A15FREQCOL == A15FREQ){for (i = 1; i <= len; i++){if ($BENCHCOL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
		octave_output+=$(octave --silent --eval "load_build_model_samuel('test_set.data',0,3,$A7_VOLTAGE_COL,$A15_VOLTAGE_COL,$A7_POWER_COL,$A15_POWER_COL)" 2> /dev/null)
		#Cleanup
		rm "test_set.data"
	done
	#Collect data count depending on mode to ensure we got the right data. Octave sometimes hangs so this is necessary to overcome "skipping" frequencies
	data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="A7" && $3=="Power"){ count++ }}END{print count}' )
	echo "data_count=$data_count"
	echo "numfreqs=${#FREQ_LIST[@]}"
done	

#Extract relevant informaton from octave. Some of these will be empty depending on mode
#Physical information
#Avg. Voltage
IFS=";" read -a avg_volt_a7 <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="A7" && $3=="Voltage"){ print $5 }}' | tr "\n" ";" | head -c -1)
IFS=";" read -a avg_volt_a15 <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="A15" && $3=="Voltage"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Avg. Power
IFS=";" read -a avg_pow_a7 <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="A7" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)
IFS=";" read -a avg_pow_a15 <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="A15" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)

#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.

HEADER="A7 Frequency\tA15 Frequency\tA7 Voltage\tA15 Voltage\tAverage A7 Power [W]\tAverage A15 Power [W]\tTotal Runtime [s]"
DATA="\${TEMP_FREQ[0]}\t\${TEMP_FREQ[1]}\t\${avg_volt_a7[\$i]}\t\${avg_volt_a15[\$i]}\t\${avg_pow_a7[\$i]}\t\${avg_pow_a15[\$i]}\t\${avg_total_runtime[\$i]}"

#Output to file or terminal. First header, then data depending on model
#If per-frequency models, iterate frequencies then print
#If full frequency just print the one model
if [[ -z $SAVE_FILE ]]; then
	echo -e "--------------------" >&1
	echo -e "$HEADER"
	echo -e "--------------------" >&1
else
	echo -e "$HEADER" > "$SAVE_FILE"
fi
for i in $(seq 0 $((${#FREQ_LIST[@]}-1)))
do
	IFS="," read -a TEMP_FREQ <<< "${FREQ_LIST[$i]}"	
	if [[ -z $SAVE_FILE ]]; then 
		echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t"
	else
		echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t" >> "$SAVE_FILE"
	fi
done

echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1
