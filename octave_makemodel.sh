#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi
#Internal parameters
TIME_CONVERT=1000000000

#Internal variable for quickly setting maximum number of modes and model types
NUM_ML_METHODS=3
NUM_OPT_CRITERIA=3
#NUM_CROSS=1
NUM_OUTPUT_MODES=5

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

#Simple script to get the index of the max of an array, needed to identify the cross-correlation max and get indices
#Need to pass the name of the array as first argument and then the element count as second argument
#Then use BC to compute mean since bash has just integer logic and we are almost surely dealing with fractions for the mean
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
while getopts ":r:t:f:b:p:e:am:c:n:o:s:h" opt;
do
	case $opt in
		h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the concatednated result file to be analyzed." >&1
			echo "-t [FILEPATH] -> Specify the concatednated result file to be used to test model." >&1
			echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
			echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
			echo "-p [NUMBER] -> Specify power column." >&1
			echo "-e [NUMBER LIST] -> Specify events list." >&1
			echo "-a -> Use flag to specify all frequencies model instead of per frequency one." >&1
			echo "-m [NUMBER: 1:$NUM_ML_METHODS]-> Type of automatic machine learning search method: 1 -> Bottom-up; 2 -> Top-down; 3 -> Exhaustive search;" >&1
			echo "-c [NUMBER: 1:$NUM_OPT_CRITERIA]-> Select minimization criteria for model optimisation: 1 -> Absolute error; 2 -> Absolute error standart deviation; 3 -> Maximum event cross-correlation;" >&1
			echo "-n [NUMBER] -> Specify max number of events to include in automatic model generation." >&1
			#echo "-x [NUMBER: 1:$NUM_CROSS]-> Select cross model computation mode 1 -> Use a separate test file;" >&1
			echo "-o [NUMBER: 1:$NUM_OUTPUT_MODES]-> Output mode: 1 -> Measured platform physical data; 2 -> Model detailed performance and coefficients; 3 -> Model shortened performance; 4 -> Platform selected event totals; 5 -> Platform selected event averages;" >&1
			echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
			echo "Mandatory options are: -r, -b, -p, -e, -o"
			exit 0 
			;;

		#Specify the result file
		r)
			if [[ -n $RESULT_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				exit 1                
			else
				RESULT_FILE="$OPTARG"
			fi
		    	;;
		#Specify the test file
		t)
			if [[ -n $TEST_FILE ]]; then
				echo "Invalid input: option -t has already been used!" >&2
				exit 1                
			else
				TEST_FILE="$OPTARG"
			fi
		    	;;
		#Specify frequency list
		f)
		    	if [[ -n $USER_FREQ_LIST ]]; then
			    	echo "Invalid input: option -f has already been used!" >&2
		            	exit 1
			else	
				USER_FREQ_LIST="$OPTARG"
		    	fi
			;;
		#Specify the benchmarks split file, if no benchmarks are chosen the program can be used to make a new randomised benchmark split
		b)
			if [[ -n $BENCH_FILE ]]; then
		    		echo "Invalid input: option -b has already been used!" >&2
		    		exit 1                
			else
				BENCH_FILE="$OPTARG"
			fi
		    	;;
		p)
			if [[ -n  $POWER_COL ]]; then
		    		echo "Invalid input: option -p has already been used!" >&2
		    		exit 1    
			else
				POWER_COL="$OPTARG"            
			fi
		    	;;
		e)
			if [[ -n  $EVENTS_LIST ]]; then
		    		echo "Invalid input: option -e has already been used!" >&2
		    		exit 1
			else
				EVENTS_LIST="$OPTARG"
                	fi
		    	;;
		a)
			if [[ -n  $ALL_FREQUENCY ]]; then
		    		echo "Invalid input: option -a has already been used!" >&2
		    		exit 1                
			fi
		    	ALL_FREQUENCY=1
		    	;;

		m)
			if [[ -n $AUTO_SEARCH ]]; then
		    		echo "Invalid input: option -m has already been used!" >&2
		    		exit 1                
			else
				AUTO_SEARCH="$OPTARG"
			fi
			;;
		c)
			if [[ -n $MODEL_TYPE ]]; then
		    		echo "Invalid input: option -c has already been used!" >&2
		    		exit 1                
			else
				MODEL_TYPE="$OPTARG"
			fi
			;;
		n)
			if [[ -n  $NUM_MODEL_EVENTS ]]; then
		    		echo "Invalid input: option -n has already been used!" >&2
		    		exit 1                
			else
				NUM_MODEL_EVENTS="$OPTARG"
			fi
		    	;;
		o)
			if [[ -n $OUTPUT_MODE ]]; then
		    		echo "Invalid input: option -o has already been used!" >&2
		    		exit 1                
			else	
				OUTPUT_MODE="$OPTARG"
			fi
			;;
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
			    	exit 1                
			else
		    		SAVE_FILE="$OPTARG"
			fi
			;;        
		:)
		    	echo "Option: -$OPTARG requires an argument" >&2
		    	exit 1
		    	;;
		\?)
		    	echo "Invalid option: -$OPTARG" >&2
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
if [[ -z $POWER_COL ]]; then
    	echo "No power! Expected -p flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $EVENTS_LIST ]]; then
    	echo "No events list specified! Expected -e flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $OUTPUT_MODE ]]; then
    	echo "No output mode specified! Expected -o flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
#Check correct flag usage

#-r flag
#Check if result file is present
#Make sure the result file exists
if [[ ! -e "$RESULT_FILE" ]]; then
	echo "-r $RESULT_FILE does not exist. Please enter the result file to be analyzed!" >&2 
	exit 1
else
	#Check if result file contains data
	RESULT_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$RESULT_FILE")
    	if [[ -z $RESULT_START_LINE ]]; then 
		echo "Results file contains no data!" >&2
		exit 1
	fi

	#Exctract run column and list
	RESULT_RUN_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_RUN_COL ]]; then
		echo "Results file contains no run column!" >&2
		exit 1
	fi
	RESULT_RUN_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_RUN_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -g | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_RUN_LIST ]]; then
		echo "Unable to extract run list from result file!" >&2
		exit 1
	fi
	#Extract run number for runtime information now that we have events column
	RESULT_RUN_START=$(echo "$RESULT_RUN_LIST" | tr "," "\n" | head -n 1)
	RESULT_RUN_END=$(echo "$RESULT_RUN_LIST" | tr "," "\n" | tail -n 1)

	#Exctract freq column and list
	RESULT_FREQ_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_FREQ_COL ]]; then
		echo "Results file contains no freqeuncy column!" >&2
		exit 1
	fi
	RESULT_FREQ_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_FREQ_LIST ]]; then
		echo "Unable to extract freqeuncy list from result file!" >&2
		exit 1
	fi

	#Exctract bench column and list
	RESULT_BENCH_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_BENCH_COL ]]; then
		echo "Results file contains no benchmark column!" >&2
		exit 1
	fi
	RESULT_BENCH_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_BENCH_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -d | tr "\n" "," | head -c -1)
	if [[ -z $RESULT_BENCH_LIST ]]; then
		echo "Unable to extract benchmarks from result file!" >&2
		exit 1
	fi

	#Extract events columns from result file
	RESULT_EVENTS_COL_START=$RESULT_FREQ_COL
	RESULT_EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$RESULT_FILE")
	if [[ "$RESULT_EVENTS_COL_START" -eq "$RESULT_EVENTS_COL_END" ]]; then
		echo "No events present in result files!" >&2
		exit 1
	fi
	RESULT_EVENTS_LIST=$(seq "$RESULT_EVENTS_COL_START" 1 "$RESULT_EVENTS_COL_END" | tr '\n' ',' | head -c -1)
	RESULT_EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$RESULT_EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
fi

#-t flag
#Check if test file is present
if [[ -n $TEST_FILE ]]; then
	if [[ ! -e "$TEST_FILE" ]]; then
		echo "-t $TEST_FILE does not exist. Please enter and existing test file!" >&2 
		exit 1
	else
		#Check if test file is the same as the result file
		if [[ "$TEST_FILE" == "$RESULT_FILE" ]]; then
			echo "Results file and test file are the same! File specified using -t flag must be different or it is useless (just use -r flag)." >&2
			exit 1
		fi

		#Check if test file contains data
		TEST_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$TEST_FILE")
	    	if [[ -z $TEST_START_LINE ]]; then 
			echo "Results file contains no data!" >&2
			exit 1
		fi

		#Exctract run column and list
		TEST_RUN_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_RUN_COL ]]; then
			echo "Results file contains no run column!" >&2
			exit 1
		fi
		TEST_RUN_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_RUN_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -g | tr "\n" "," | head -c -1 )
		if [[ -z $TEST_RUN_LIST ]]; then
			echo "Unable to extract run list from test file!" >&2
			exit 1
		fi
		#Extract run number for runtime information now that we have events column
		TEST_RUN_START=$(echo "$TEST_RUN_LIST" | tr "," "\n" | head -n 1)
		TEST_RUN_END=$(echo "$TEST_RUN_LIST" | tr "," "\n" | tail -n 1)

		#Exctract freq column and list
		TEST_FREQ_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_FREQ_COL ]]; then
			echo "Results file contains no freqeuncy column!" >&2
			exit 1
		fi
		TEST_FREQ_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
		if [[ -z $TEST_FREQ_LIST ]]; then
			echo "Unable to extract freqeuncy list from test file!" >&2
			exit 1
		fi

		#Exctract bench column and list
		TEST_BENCH_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_BENCH_COL ]]; then
			echo "Results file contains no benchmark column!" >&2
			exit 1
		fi
		TEST_BENCH_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_BENCH_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -d | tr "\n" "," | head -c -1)
		if [[ -z $TEST_BENCH_LIST ]]; then
			echo "Unable to extract benchmarks from test file!" >&2
			exit 1
		fi

		#Extract events columns from test file
		TEST_EVENTS_COL_START=$TEST_FREQ_COL
		TEST_EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$TEST_FILE")
		if [[ "$TEST_EVENTS_COL_START" -eq "$TEST_EVENTS_COL_END" ]]; then
			echo "No events present in test file!" >&2
			exit 1
		fi
		TEST_EVENTS_LIST=$(seq "$TEST_EVENTS_COL_START" 1 "$TEST_EVENTS_COL_END" | tr '\n' ',' | head -c -1)
		TEST_EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$TEST_EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$TEST_FILE" | tr "\n" "," | head -c -1)

		#Check if test frequencies match result file if no user freqeuncy list
		if [[ -z $USER_FREQ_LIST ]]; then
			if [[ "$TEST_FREQ_LIST" -ne "$RESULT_FREQ_LIST" ]]; then
				echo "Test file frequency list is different than result file freqeuncy list! Please use -f flag to specify specific list." >&2
				exit 1
			fi
		fi

		#Check if test events match result file events
		if [[ "$TEST_EVENTS_LIST_LABELS" != "$RESULT_EVENTS_LIST_LABELS" ]]; then
			echo "Test file events list is different than result file events list! Please trim files so that they have the same events to train/build model from." >&2
			exit 1
		fi
	fi
fi

#-f flag
#Check if user specified frequencies are present in result file and test file
if [[ -n $USER_FREQ_LIST ]]; then
	#Go throught the user frequencies and make sure they are not out of bounds of the train file
	spaced_USER_FREQ_LIST="${USER_FREQ_LIST//,/ }"
	IFS="," read -a FREQ_LIST <<< "$RESULT_FREQ_LIST"
	for FREQ_SELECT in $spaced_USER_FREQ_LIST
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
			echo "selected frequency $FREQ_SELECT for -f is not present in result file."
	       	 	exit 1
		fi
	done
	#Check freq list against test file freq list (if selected)
	if [[ -n $TEST_FILE ]]; then
		IFS="," read -a FREQ_LIST <<< "$TEST_FREQ_LIST"
		for FREQ_SELECT in $spaced_USER_FREQ_LIST
		do
			#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
			if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
				echo "selected frequency $FREQ_SELECT for -f is not present in train file."
		       	 	exit 1
			fi
		done
	fi
	#After both checks have passed use user freq list
	IFS="," read -a FREQ_LIST <<< "$USER_FREQ_LIST"
else
	#Assign FREQ_LIST
	IFS="," read -a FREQ_LIST <<< "$RESULT_FREQ_LIST"
fi

#-b flag
#Check if bench split file exists
if [[ -e "$BENCH_FILE" ]]; then
    	#Extract benchmark split information.
    	BENCH_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$BENCH_FILE")
	#Check if bench file contains data
	if [[ -z $BENCH_START_LINE ]]; then
		echo "Benchmarks split file contains no data!" >&2
		exit 1
	fi
	IFS=";" read -a TRAIN_SET <<< "$(awk -v SEP='\t' -v START="$BENCH_START_LINE" 'BEGIN{FS=SEP}{if (NR >= START){ print $1 }}' < "$BENCH_FILE" | sort -d | tr "\n" ";" | head -c -1 )"
	IFS=";" read -a TEST_SET <<< "$(awk -v SEP='\t' -v START="$BENCH_START_LINE" 'BEGIN{FS=SEP}{if (NR >= START){ print $2 }}' < "$BENCH_FILE" | sort -d | tr "\n" ";" |  head -c -1 )"
	#Check if we have successfully extracted benchmark sets 
	if [[ ${#TRAIN_SET[@]} == 0 || ${#TEST_SET[@]} == 0 ]]; then
		echo "Unable to extract train or test set from benchmarks file!" >&2
		exit 1
	fi
	#Check if benchmarks specified by bench split files are present in train/test files
	IFS="," read -a BENCH_LIST <<< "$RESULT_BENCH_LIST"
	for count in $(seq 0 1 $((${#TRAIN_SET[@]}-1)))
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${BENCH_LIST[@]} " =~ " ${TRAIN_SET[$count]} " ]]; then
			echo "Specified train benchmark ${TRAIN_SET[$count]} for -b is not present in result file."
	       	 	exit 1
		fi
	done
	if [[ -n $TRAIN_FILE ]]; then
		IFS="," read -a BENCH_LIST <<< "$TEST_BENCH_LIST"
		for count in $(seq 0 1 $((${#TEST_SET[@]}-1)))
		do
			#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
			if [[ ! " ${BENCH_LIST[@]} " =~ " ${TEST_SET[$count]} " ]]; then
				echo "Specified test benchmark ${TEST_SET[$count]} for -b is not present in test file."
		       	 	exit 1
			fi
		done
	else
		for count in $(seq 0 1 $((${#TEST_SET[@]}-1)))
		do
			#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
			if [[ ! " ${BENCH_LIST[@]} " =~ " ${TEST_SET[$count]} " ]]; then
				echo "Specified test benchmark ${TEST_SET[$count]} for -b is not present in result file."
		       	 	exit 1
			fi
		done
	fi 
fi

#-p flag
#Check if power is within bounds
if [[ "$POWER_COL" -gt $RESULT_EVENTS_COL_END || "$POWER_COL" -lt $RESULT_EVENTS_COL_START ]]; then 
	echo "Selected power column -p $POWER_COL is out of bounds from result file events. Needs to be an integer value betweeen [$RESULT_EVENTS_COL_START:$RESULT_EVENTS_COL_END]." >&2
	exit 1
fi
if [[ -n $TEST_FILE ]]; then
	if [[ "$POWER_COL" -gt $TEST_EVENTS_COL_END || "$POWER_COL" -lt $TEST_EVENTS_COL_START ]]; then 
		echo "Selected power column -p $POWER_COL is out of bounds from test file events. Needs to be an integer value betweeen [$TEST_EVENTS_COL_START:$TEST_EVENTS_COL_END]." >&2
		exit 1
	fi
fi
POWER_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$POWER_COL" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")



#-e flag
spaced_EVENTS_LIST="${EVENTS_LIST//,/ }"
for EVENT in $spaced_EVENTS_LIST
do
	#Check if events list is in bounds
	if [[ "$EVENT" -gt $RESULT_EVENTS_COL_END || "$EVENT" -lt $RESULT_EVENTS_COL_START ]]; then 
		echo "Selected event -e $EVENT is out of bounds/invalid to result/test file events. Needs to be an integer value betweeen [$RESULT_EVENTS_COL_START:$RESULT_EVENTS_COL_END]." >&2
		exit 1
	fi
	#Check if it contains power
	if [[ "$EVENT" == "$POWER_COL" ]]; then 
		echo "Selected event -e $EVENT is the same as the regressand -p $POWER_COL -> $POWER_LABEL." >&2
		exit 1
	fi
done
#Checkif events string contains duplicates
if [[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -gt $(echo "$EVENTS_LIST" | tr "," "\n" | sort | uniq | wc -l) ]]; then
	echo "Selected event list -e $EVENTS_LIST contains duplicates." >&2
	exit 1
fi

#-m flag
if [[ -n $AUTO_SEARCH ]]; then
	#Check if other flags present
	if  [[ -z $MODEL_TYPE || -z $NUM_MODEL_EVENTS ]]; then
		echo "Expected -c and -n flag when -m flag is used!" >&2
		exit 1
	fi
	#Check if valid input
	if [[ "$AUTO_SEARCH" != "1" && "$AUTO_SEARCH" != "2" && "$AUTO_SEARCH" != "3" ]]; then 
		echo "Invalid operarion: -m $AUTO_SEARCH! Options are: [1:$NUM_ML_METHODS]." >&2
		echo "Use -h flag for more information on the available automatic search algorithms." >&2
	    	echo -e "===================="
	    	exit 1
	fi
fi
#-c flag
if [[ -n $MODEL_TYPE ]]; then
	#Check if other flags present
	if  [[ -z $AUTO_SEARCH || -z $NUM_MODEL_EVENTS ]]; then
		echo "Expected -m and -n flag when -c flag is used!" >&2
		exit 1
	fi
	#Check if valid input
	if [[ "$MODEL_TYPE" != "1" && "$MODEL_TYPE" != "2" && "$MODEL_TYPE" != "3" ]]; then 
		echo "Invalid operarion: -c $MODEL_TYPE! Options are: [1:$NUM_OPT_CRITERIA]." >&2
		echo "Use -h flag for more information on the available model types." >&2
	    	echo -e "===================="
	    	exit 1
	fi	
fi

#-n flag
if [[ -n $NUM_MODEL_EVENTS ]]; then
	#Check if other flags present
	if  [[ -z $AUTO_SEARCH || -z $MODEL_TYPE ]]; then
		echo "Expected -m and -c flag when -n flag is used!" >&2
		exit 1
	fi
	EVENTS_LIST_SIZE=$(echo "$EVENTS_LIST" | tr "," "\n" | wc -l)
	#Check if number is within bounds, which is total number of events - 1 (power)
	if [[ "$NUM_MODEL_EVENTS" -gt "$EVENTS_LIST_SIZE" || "$NUM_MODEL_EVENTS" -le 0 ]]; then 
		echo "Selected number of events -n $EVENTS_LIST_SIZE is out of bounds/invalid. Needs to be an integer value betweeen [1:$EVENTS_LIST_SIZE]." >&2
		exit 1
	fi
	#Initiate variables and unset events_list (since we use events_pool for the automatic list)
	EVENTS_POOL="$EVENTS_LIST"
	unset EVENTS_LIST
fi

#-o flag
if [[ "$OUTPUT_MODE" != "1" && "$OUTPUT_MODE" != "2" && "$OUTPUT_MODE" != "3" && "$OUTPUT_MODE" != "4" && "$OUTPUT_MODE" != "5" ]]; then 
	echo "Invalid operarion: -o $OUTPUT_MODE! Options are: [1:$NUM_OUTPUT_MODES]." >&2
	echo "Use -h flag for more information on the available modes." >&2
    	echo -e "===================="
    	exit 1
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
#Test file sanity check
#-t file
if [[ -n $TEST_FILE ]]; then
	echo -e "--------------------" >&1
	echo -e "Using test file:" >&1
	echo "$TEST_FILE" >&1
fi
#Frequency list sanity check
#-f list
echo -e "--------------------" >&1
if [[ -z $USER_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in result file:" >&1
    	echo "$RESULT_FREQ_LIST" >&1
    	IFS="," read -a FREQ_LIST <<< "$RESULT_FREQ_LIST"
else
	echo "Using user specified frequency list:" >&1
    	echo "$USER_FREQ_LIST" >&1
    	IFS="," read -a FREQ_LIST <<< "$USER_FREQ_LIST"		
fi
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
#Power column (regressand) sanity check
#-p number
echo -e "--------------------" >&1
echo -e "Power (regressand) column:" >&1
echo "$POWER_COL -> $POWER_LABEL" >&1
#Events list sanity check
#-e list
if [[ -z $AUTO_SEARCH ]]; then
	echo -e "--------------------" >&1
	echo -e "Using user specified events list:" >&1
	EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
fi
#All frequency model sanity check
#-a flag
echo -e "--------------------" >&1
if [[ -z $ALL_FREQUENCY ]]; then
    	echo "Computing per-frequency models!" >&1
else
    	echo "Computing full frequency model!" >&1
fi
#Machine learning method sanity checks
#-m number; -c number; -n number
if [[ -n $AUTO_SEARCH ]]; then
	#Number of events in model sanity checks
	echo -e "--------------------" >&1
	echo "Specified search algorithm:" >&1
	case $AUTO_SEARCH in
		1)
			echo "$AUTO_SEARCH -> Use bottom-up approach. Heuristically add events until we cannot improve model or we reach limit -> $NUM_MODEL_EVENTS" >&1
			;;
		2) 
			echo "$AUTO_SEARCH -> Use top-down approach. Heuristically remove events until we cannot improve model or we reach limit -> $NUM_MODEL_EVENTS" >&1
			;;
		3) 
			echo "$AUTO_SEARCH -> Use exhaustive approach. Try all possible combinations of $NUM_MODEL_EVENTS events and use the best one." >&1
			;;
	esac
	#Optimisation criteria sanity checks
	echo -e "--------------------" >&1
	echo "Specified optimisation criteria:" >&1
	case $MODEL_TYPE in
		1)
			echo "$MODEL_TYPE -> Minimize model absolute error." >&1
			;;
		2) 
			echo "$MODEL_TYPE -> Minimize model absolute error standart deviation." >&1
			;;
		3) 
			echo "$MODEL_TYPE -> Minimize model maximum event cross-correlation." >&1
			;;
	esac
	#Events sanity checks
	echo -e "--------------------" >&1
	EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo -e "Full events pool:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
fi
#Output mode sanity check
#-o number
echo -e "--------------------" >&1
echo "Specified program ouput mode:" >&1
case $OUTPUT_MODE in
	1) 
		echo "$OUTPUT_MODE -> Measured platform physical data." >&1
		;;
	2) 
		echo "$OUTPUT_MODE -> Model detailed performance and coefficients." >&1
		;;
	3) 
		echo "$OUTPUT_MODE -> Model shortened performance." >&1
		;;
	4) 
		echo "$OUTPUT_MODE -> Platform selected event totals." >&1
		;;
	5) 
		echo "$OUTPUT_MODE -> Platform selected event averages." >&1
		;;
esac

#Save file sanity check
#-s file
echo -e "--------------------" >&1
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1

#Trim constant events from events pool
if [[ -n $AUTO_SEARCH ]]; then
	echo -e "====================" >&1
	echo -e "--------------------" >&1
	echo -e "Preparing data for automatic model generation." >&1
	echo -e "Removing constant events from events pool." >&1
	echo -e "Current events used:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	echo -e "--------------------" >&1
	spaced_POOL="${EVENTS_POOL//,/ }"
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list to collect results for
		echo -e "********************" >&1
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		echo "Checking event:" >&1
		echo -e "$EV_TEMP -> $EV_TEMP_LABEL" >&1
		unset -v data_count				
		if [[ -n $ALL_FREQUENCY ]]; then
			while [[ $data_count -ne 1 ]]
			do
				#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
				#Split data and collect output, then cleanup
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				echo "here1"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi
				echo "here"
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EV_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )	
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					touch "train_set.data" "test_set.data"
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
					if [[ -n $TEST_FILE ]]; then
						awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
					else
						awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
					fi
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EV_TEMP')" 2> /dev/null)
					#Cleanup
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Check for bad events
		if [[ " ${rel_avg_abs_err[@]} " =~ " Inf " ]]; then
			#If relative error contains infinity then event is bad for linear regression as is removed from list
			EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
			EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
			echo "Bad Event (constant)!" >&1
			echo "Removed from events pool." >&1
			echo -e "********************" >&1
			if [[ $EVENTS_POOL !=  "\n" ]]; then
				echo "New events pool:" >&1
				echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
			else
				echo "New events pool -> (empty)" >&1
				echo "Program cannot continue with an empty events pool." >&1
				echo "Please use non-constant events for model generation." >&1
				exit
			fi
			echo -e "********************" >&1
		fi 
	done
	#Check to see if events pool is overtrimed, that is if the events left are less than specified number to be used in model
	EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
	if [[ $EVENTS_POOL_SIZE -lt $NUM_MODEL_EVENTS ]]; then
		echo "Overtrimmed events pool. Less events are available than specified: $EVENTS_POOL_SIZE < $NUM_MODEL_EVENTS." >&1
		echo "Program cannot continue. Please use more non-constant events in pool or specify a smaller number to be used in model." >&1
		exit
	fi
	#Print final events pool
	echo -e "--------------------" >&1
	echo -e "Final events to be used in automatic generation:" >&1
	EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	echo -e "--------------------" >&1
	echo -e "====================" >&1
fi

#Automatic model generation.
#It will keep going as long as we have not saturated the model (no further events contribute) or we reach max number of model events as specified by user
#If we dont want automatic we just initialise NUM_MODEL_EVENTS to 0 and skip this loop. EZPZ
[[ -n $AUTO_SEARCH ]] && echo -e "Begin automatic model generation:" >&1

#Bottom-up approach
while [[ $NUM_MODEL_EVENTS -gt 0 && $AUTO_SEARCH == 1 ]]
do
	spaced_POOL="${EVENTS_POOL//,/ }"
	echo -e "--------------------" >&1
	if [[ $EVENTS_POOL != "\n" ]]; then
		echo -e "Current events pool:" >&1
		echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	else
		echo "Current events pool -> (empty)" >&1
	fi
	echo -e "--------------------" >&1
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list to collect results for
		[[ -n $EVENTS_LIST ]] && EVENTS_LIST_TEMP="$EVENTS_LIST,$EV_TEMP" || EVENTS_LIST_TEMP="$EV_TEMP"
		echo -e "********************" >&1
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_LIST_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo "Checking event:" >&1
		echo -e "$EV_TEMP -> $EV_TEMP_LABEL" >&1
		echo "Temporaty events list:"
		echo -e "$EVENTS_LIST_TEMP -> $EVENTS_LIST_TEMP_LABELS" >&1
		#Uses temporary files generated for extracting the train and test set. Array indexing starts at 1 in awk.
		#Also uses the extracted benchmark set files to pass arguments in octave since I found that to be the easiest way and quickest for bug checking.
		#Sometimes octave bugs out and does not accept input correctly resulting in missing frequencies.
		#I overcome that with a while loop which checks if we have collected data for all frequencies, if not repeat
		#This bug is totally random and the only way to overcome it is to check and repeat (1 in every 5-6 times is faulty)
		#What causes this is too many quick consequent inputs to octave, sometimes it goes haywire.
		unset -v data_count				
		if [[ -n $ALL_FREQUENCY ]]; then
			while [[ $data_count -ne 1 ]]
			do
				#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
				#Split data and collect output, then cleanup
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )	
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					touch "train_set.data" "test_set.data"
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
					if [[ -n $TEST_FILE ]]; then
						awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
					else
						awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
					fi
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )	
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a avg_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Get the means for both relative error and standart deviation and output
		#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && MEAN_MAX_EV_CROSS_CORR=$(getMean max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && MAX_EV_CROSS_CORR_IND=$(getMaxIndex max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && MAX_EV_CROSS_CORR=${max_ev_cross_corr[$MAX_EV_CROSS_CORR_IND]}
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${max_ev_cross_corr_ev1[$MAX_EV_CROSS_CORR_IND]},${max_ev_cross_corr_ev2[$MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Mean model average event cross-correlation -> $MEAN_AVG_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Mean model max event cross-correlation -> $MEAN_MAX_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Model max event cross-correlation $MAX_EV_CROSS_CORR is at ${FREQ_LIST[$MAX_EV_CROSS_CORR_IND]} MHz between $MAX_EV_CROSS_CORR_EV_LABELS" >&1
		case $MODEL_TYPE in
		1)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
		3)
			EVENTS_LIST_NEW=$MAX_EV_CROSS_CORR
			;;
		esac
		if [[ -n $EVENTS_LIST_MIN ]]; then
			#If events list exits then compare new value and if smaller then store else just move along the events list 
			if [[ $(echo "$EVENTS_LIST_NEW < $EVENTS_LIST_MIN" | bc -l) -eq 1 ]]; then
				#Update events list error and EV
				echo "Good event (improves minimum temporary model)! Using as new minimum!"
				EV_ADD=$EV_TEMP
				EVENTS_LIST_MIN=$EVENTS_LIST_NEW
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
			else
				echo "Bad event (does not improve minimum temporary model)!" >&1
			fi
		else
			#If no event list temp error present this means its the first event to check. Just add it as a new minimum
			EV_ADD=$EV_TEMP
			EVENTS_LIST_MIN=$EVENTS_LIST_NEW
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
			[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
			[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
			[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
			[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
			echo "Good event (first event in model)!" >&1
		fi
	done
	echo -e "********************" >&1
	echo "All events checked!" >&1
	echo -e "********************" >&1
	#Once going through all events see if we can populate events list
	if [[ -n $EV_ADD ]]; then
		#We found an new event to add to list
		[[ -n $EVENTS_LIST ]] && EVENTS_LIST="$EVENTS_LIST,$EV_ADD" || EVENTS_LIST="$EV_ADD"
		EV_ADD_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_ADD" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_ADD,//g;s/,$EV_ADD,/,/g;s/,$EV_ADD$//g;s/^$EV_ADD$//g")
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		#Remove from events pool
		echo -e "--------------------" >&1
		echo -e "********************" >&1
		echo "Add best event to final list and remove from pool:"
		echo "$EV_ADD -> $EV_ADD_LABEL" >&1
		echo -e "********************" >&1
		echo -e "New events list:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
		echo -e "New mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "New mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS"
		echo -e "********************" >&1
		if [[ $EVENTS_POOL !=  "\n" ]]; then
			echo "New events pool:" >&1
			echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
		else
			echo "New events pool -> (empty)" >&1
		fi
		echo -e "********************" >&1
		#reset EV_ADD too see if we can find another one and decrement counter
		unset -v EV_ADD
		((NUM_MODEL_EVENTS--))
	else
		EVENTS_LIST_SIZE=$(echo "$EVENTS_LIST" | tr "," "\n" | wc -l)
		#We did not find a new event to add to list. Just output and break loop (list saturated)		
		echo -e "--------------------" >&1
		echo "No new improving event found. Events list minimised at $EVENTS_LIST_SIZE events." >&1
		echo -e "--------------------" >&1
		echo -e "====================" >&1
		echo -e "Optimal events list found:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
		echo -e "Mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS"
		echo -e "Using final list in full model analysis." >&1
		echo -e "====================" >&1
		break
	fi
done

#Top-down approach
while [[ $(echo "$EVENTS_POOL" | tr "," "\n" | wc -l) -gt $NUM_MODEL_EVENTS && $AUTO_SEARCH == 2 ]]
do
	echo -e "--------------------" >&1
	echo -e "Current events pool:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	#Compute events list error and store as new max
	echo -e "--------------------" >&1
	unset -v data_count				
	if [[ -n $ALL_FREQUENCY ]]; then
		while [[ $data_count -ne 1 ]]
		do
			touch "train_set.data" "test_set.data"
			awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
			if [[ -n $TEST_FILE ]]; then
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
			else
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
			fi	
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL')" 2> /dev/null)
			rm "train_set.data" "test_set.data"
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
		done
	else	
		while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
		do
			unset -v octave_output				
			for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
			do
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
				fi
				octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
			done
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
		done	
	fi
	#Analyse collected results
	#Avg. Rel. Error
	IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Rel. Err. Std. Dev
	IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
	#Avg Ev. Cross. Corr.
	IFS=";" read -a avg_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr.
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr. EV1 
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr_ev1 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr. EV2
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr_ev2 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
	#Get the means for both relative error and standart deviation and output
	#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
	EVENTS_POOL_MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
	EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
	EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
	EVENTS_POOL_MEAN_EVENTS_POOL_MAX_EV_CROSS_CORR=$(getMean EVENTS_POOL_MAX_ev_cross_corr ${#EVENTS_POOL_MAX_ev_cross_corr[@]} )
	EVENTS_POOL_MAX_EV_CROSS_CORR_IND=$(getMaxIndex EVENTS_POOL_MAX_ev_cross_corr ${#EVENTS_POOL_MAX_ev_cross_corr[@]} )
	EVENTS_POOL_MAX_EV_CROSS_CORR=${EVENTS_POOL_MAX_ev_cross_corr[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]}
	EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${EVENTS_POOL_MAX_ev_cross_corr_ev1[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]},${EVENTS_POOL_MAX_ev_cross_corr_ev2[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "Mean model relative error -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR" >&1
	echo "Mean model relative error stdandart deviation -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
	echo "Mean model average event cross-correlation -> $EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR" >&1
	echo "Mean model max event cross-correlation -> $EVENTS_POOL_MEAN_EVENTS_POOL_MAX_EV_CROSS_CORR" >&1
	echo "Model max event cross-correlation $EVENTS_POOL_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS" >&1
	case $MODEL_TYPE in
	1)
		EVENTS_POOL_MIN=$EVENTS_POOL_MEAN_REL_AVG_ABS_ERR
		;;
	2)
		EVENTS_POOL_MIN=$EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV
		;;
	3)
		EVENTS_POOL_MIN=$EVENTS_POOL_MAX_EV_CROSS_CORR
		;;
	esac
	#Start top-down by spacing the pool and iterating the events
	spaced_POOL="${EVENTS_POOL//,/ }"
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list
		#Trim the event which has the highest error
		EVENTS_POOL_TEMP=$(echo "$EVENTS_POOL" | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo -e "********************" >&1
		echo "Checking event:" >&1
		echo -e "$EV_TEMP -> $EV_TEMP_LABEL" >&1
		echo "Temporaty events list:"
		echo -e "$EVENTS_POOL_TEMP -> $EVENTS_POOL_TEMP_LABELS" >&1
		unset -v data_count				
		if [[ -n $ALL_FREQUENCY ]]; then
			while [[ $data_count -ne 1 ]]
			do
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			done
		else	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					touch "train_set.data" "test_set.data"
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
					if [[ -n $TEST_FILE ]]; then
						awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
					else
						awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
					fi
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		IFS=";" read -a avg_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		IFS=";" read -a max_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Get the means for both relative error and standart deviation and output
		#Depending oon type though we use a different value for EVENTS_POOL_NEW to try and minmise
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
		MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
		MEAN_MAX_EV_CROSS_CORR=$(getMean max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		MAX_EV_CROSS_CORR_IND=$(getMaxIndex max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		MAX_EV_CROSS_CORR=${max_ev_cross_corr[$MAX_EV_CROSS_CORR_IND]}
		MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${max_ev_cross_corr_ev1[$MAX_EV_CROSS_CORR_IND]},${max_ev_cross_corr_ev2[$MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo "Mean model average event cross-correlation -> $MEAN_AVG_EV_CROSS_CORR" >&1
		echo "Mean model max event cross-correlation -> $MEAN_MAX_EV_CROSS_CORR" >&1
		echo "Model max event cross-correlation $MAX_EV_CROSS_CORR is at ${FREQ_LIST[$MAX_EV_CROSS_CORR_IND]} MHz between $MAX_EV_CROSS_CORR_EV_LABELS" >&1
		case $MODEL_TYPE in
		1)
			EVENTS_POOL_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_POOL_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
		3)
			EVENTS_POOL_NEW=$MAX_EV_CROSS_CORR
			;;
		esac
		if [[ $(echo "$EVENTS_POOL_NEW < $EVENTS_POOL_MIN" | bc -l) -eq 1 ]]; then
			#Update events list error and EV
			echo "Removing causes best improvement to temporary model! Using as new minimum!"
			EV_REMOVE=$EV_TEMP
			EVENTS_POOL_MIN=$EVENTS_POOL_NEW
			EVENTS_POOL_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
			EVENTS_POOL_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
			EVENTS_POOL_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
			EVENTS_POOL_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
			EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
		else
			echo "Removing event does not improve temporary model!" >&1
		fi
	done

	echo -e "********************" >&1
	echo "All events checked!" >&1
	echo -e "********************" >&1
	#Once going through all events see if we can populate events list
	if [[ -n $EV_REMOVE ]]; then
		#We found an new event to remove from the list
		EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_REMOVE,//g;s/,$EV_REMOVE,/,/g;s/,$EV_REMOVE$//g;s/^$EV_REMOVE$//g")
		EV_REMOVE_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_REMOVE" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		#Remove from events pool
		echo -e "--------------------" >&1
		echo -e "********************" >&1
		echo "Remove worst event from events list:"
		echo "$EV_REMOVE -> $EV_REMOVE_LABEL" >&1
		echo -e "********************" >&1
		#reset EV_REMOVE too see if we can find another one and decrement counter
		unset -v EV_REMOVE
	else
		EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		#We did not find a new event to remove from list. Just output and break loop (list saturated)		
		echo -e "--------------------" >&1
		echo "No new improving event found. Events list minimised at $EVENTS_POOL_SIZE events." >&1
		echo -e "--------------------" >&1
		echo -e "====================" >&1
		echo -e "Optimal events list found:" >&1
		echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
		echo -e "Mean model relative error -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Mean model relative error stdandart deviation -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo -e "Mean model average event cross-correlation -> $EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR" >&1
		echo -e "Mean model max event cross-correlation -> $EVENTS_POOL_MEAN_MAX_EV_CROSS_CORR" >&1
		echo -e "Model max event cross-correlation $EVENTS_POOL_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS"
		echo -e "====================" >&1
		break
	fi
done

#Do exhaustive automatic search
if [[ $AUTO_SEARCH == 3 ]]; then
	echo -e "--------------------" >&1
	echo -e "Current events pool:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	#Use octave to generate combinations. 
	#Octave has a weird bug sometimes where it fails to produce output so my way of overcoming that is to use a loop and make sure our output is useful
	unset -v octave_output
	while [[ -z $octave_output ]]
	do				
		octave_output=$(octave --silent --eval "COMBINATIONS=nchoosek(str2num('$EVENTS_POOL'),$NUM_MODEL_EVENTS);disp(COMBINATIONS);" 2> /dev/null)
		IFS=";" read -a EVENTS_LIST_COMBINATIONS <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{ print $0 }' | tr "\n" ";" | head -c -1)
	done
	echo "Total number of combinations -> ${#EVENTS_LIST_COMBINATIONS[@]}" >&1
	echo -e "--------------------" >&1
	for i in $(seq 0 $((${#EVENTS_LIST_COMBINATIONS[@]}-1)))
	do
		EVENTS_LIST_TEMP=$(echo "${EVENTS_LIST_COMBINATIONS[$i]}" | tr " " ",")
		EVENTS_LIST_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo -e "********************" >&1
		echo "Checking combination events list number -> $((i+1)):"
		echo -e "$EVENTS_LIST_TEMP -> $EVENTS_LIST_TEMP_LABELS" >&1
		#Uses temporary files generated for extracting the train and test set. Array indexing starts at 1 in awk.
		#Also uses the extracted benchmark set files to pass arguments in octave since I found that to be the easiest way and quickest for bug checking.
		#Sometimes octave bugs out and does not accept input correctly resulting in missing frequencies.
		#I overcome that with a while loop which checks if we have collected data for all frequencies, if not repeat
		#This bug is totally random and the only way to overcome it is to check and repeat (1 in every 5-6 times is faulty)
		#What causes this is too many quick consequent inputs to octave, sometimes it goes haywire.
		unset -v data_count				
		if [[ -n $ALL_FREQUENCY ]]; then
			while [[ $data_count -ne 1 ]]
			do
				#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
				#Split data and collect output, then cleanup
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					touch "train_set.data" "test_set.data"
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
					if [[ -n $TEST_FILE ]]; then
						awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
					else
						awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
					fi
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		IFS=";" read -a avg_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		IFS=";" read -a max_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Get the means for both relative error and standart deviation and output
		#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
		MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
		MEAN_MAX_EV_CROSS_CORR=$(getMean max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		MAX_EV_CROSS_CORR_IND=$(getMaxIndex max_ev_cross_corr ${#max_ev_cross_corr[@]} )
		MAX_EV_CROSS_CORR=${max_ev_cross_corr[$MAX_EV_CROSS_CORR_IND]}
		MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${max_ev_cross_corr_ev1[$MAX_EV_CROSS_CORR_IND]},${max_ev_cross_corr_ev2[$MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo "Mean model average event cross-correlation -> $MEAN_AVG_EV_CROSS_CORR" >&1
		echo "Mean model max event cross-correlation -> $MEAN_MAX_EV_CROSS_CORR" >&1
		echo "Model max event cross-correlation $MAX_EV_CROSS_CORR is at ${FREQ_LIST[$MAX_EV_CROSS_CORR_IND]} MHz between $MAX_EV_CROSS_CORR_EV_LABELS" >&1
		case $MODEL_TYPE in
		1)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
		3)
			EVENTS_LIST_NEW=$MAX_EV_CROSS_CORR
			;;
		esac
		if [[ -n $EVENTS_LIST_MIN ]]; then
			#If events list exits then compare new value and if smaller then store else just move along the events list 
			if [[ $(echo "$EVENTS_LIST_NEW < $EVENTS_LIST_MIN" | bc -l) -eq 1 ]]; then
				#Update events list error and EV
				echo "Good list (improves minimum temporary model)! Using as new minimum!"
				EVENTS_LIST_MIN=$EVENTS_LIST_NEW
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
				EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
				EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
				EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
				EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
				EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
				EVENTS_LIST=$EVENTS_LIST_TEMP
			else
				echo "Bad list (does not improve minimum temporary model)!" >&1
			fi
		else
			#If no event list temp error present this means its the first event to check. Just add it as a new minimum
			EVENTS_LIST_MIN=$EVENTS_LIST_NEW
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
			EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
			EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
			EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
			EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
			EVENTS_LIST=$EVENTS_LIST_TEMP
			echo "Good list (first list checked)!" >&1
		fi
	done

	echo -e "********************" >&1
	echo "All combinations checked!" >&1
	echo -e "********************" >&1
	echo -e "====================" >&1
	echo -e "Optimal events list found:" >&1
	EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
	echo -e "Mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
	echo -e "Mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
	echo -e "Mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
	echo -e "Mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
	echo -e "Model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS" >&1
	echo -e "Using final list in full model analysis." >&1
	echo -e "====================" >&1
fi

#Update the events list if used top-down automatic search
if [[ $AUTO_SEARCH == 2 ]]; then
	EVENTS_LIST=$EVENTS_POOL
fi

echo -e "====================" >&1
EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
echo -e "Using events list:" >&1
echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
echo -e "====================" >&1

#This part is for outputing a specified events list or just using the automatically generated one and passing it onto octave
#Anyhow its mandatory to extract results so its always executed even if we skip automatic generation
#Its the same as the automatic generation collection logic, except for the all the automatic iteration, we just use one events list with octave
unset -v data_count				
if [[ -n $ALL_FREQUENCY ]]; then
	while [[ $data_count -ne 1 ]]
	do
		#Collect runtime information depending on the mode
		if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
			#If we are collecting platform physical characteristics
			#We need to average runtime per run
			#Extract runtime per run (converted to seconds) and add to total.
			total_runtime=0
			if [[ -n $TEST_FILE ]]; then
				for runnum in $(seq "$TEST_RUN_START" 1 "$TEST_RUN_END")
				do
					for benchname in $(seq 0 $((${#TEST_SET[@]}-1)))
					do

						runtime_st=$(awk -v START="$TEST_START_LINE" -v SEP='\t' -v RUNCOL="$TEST_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$TEST_BENCH_COL" -v BENCH="${TEST_SET[$benchname]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print $1;exit}}' < "$TEST_FILE")
						#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
						runtime_nd_nr=$(tac "$TEST_FILE" | awk -v START=1 -v SEP='\t' -v RUNCOL="$TEST_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$TEST_BENCH_COL" -v BENCH="${TEST_SET[$benchname]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print NR;exit}}' < "$TEST_FILE")
						#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
						if [[ $runtime_nd_nr == 1 ]];then
							runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
						fi
						runtime_nd=$(tac "$TEST_FILE" | awk -v START=$((runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
						total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
					done
				done
				#Compute average full freq runtime
				avg_total_runtime=$(echo "scale=0;$total_runtime/(($TEST_RUN_END-$TEST_RUN_START+1)*$TIME_CONVERT);" | bc )
			else
				for runnum in $(seq "$RESULT_RUN_START" 1 "$RESULT_RUN_END")
				do
					for benchname in $(seq 0 $((${#TEST_SET[@]}-1)))
					do

						runtime_st=$(awk -v START="$RESULT_START_LINE" -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchname]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print $1;exit}}' < "$RESULT_FILE")
						#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
						runtime_nd_nr=$(tac "$RESULT_FILE" | awk -v START=1 -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchname]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print NR;exit}}' < "$RESULT_FILE")
						#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
						if [[ $runtime_nd_nr == 1 ]];then
							runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
						fi
						runtime_nd=$(tac "$RESULT_FILE" | awk -v START=$((runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
						total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
					done
				done
				#Compute average full freq runtime
				avg_total_runtime=$(echo "scale=0;$total_runtime/(($RESULT_RUN_END-$RESULT_RUN_START+1)*$TIME_CONVERT);" | bc )
			fi
			
			#Collect physical information for test set
			touch "test_set.data"
			if [[ -n $TEST_FILE ]]; then
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
			else
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
			fi
			octave_output=$(octave --silent --eval "load_build_model(1,'test_set.data',1,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			rm "test_set.data"
			
		else
			#If we are collecting model performance
			#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
			#Split data and collect output, then cleanup 	
			#Split input into train and test set
			touch "train_set.data" "test_set.data"
			awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
			if [[ -n $TEST_FILE ]]; then
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
			else
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
			fi
			#Collect octave output this depends on program mode
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			#Cleanup
			rm "train_set.data" "test_set.data"
		fi	
	done
else
	#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
	#Then pass onto octave and store results in a concatenating string	
	while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
	do
		unset -v octave_output				
		for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
		do
			#Collect runtime information depending on the mode
			if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
				#If we are collecting platform physical characteristics
				#We need to average runtime per run
				#Extract runtime per run (converted to seconds) and add to total for the frequency.
				total_runtime=0
				if [[ -n $TEST_FILE ]];then
					for runnum in $(seq "$TEST_RUN_START" 1 "$TEST_RUN_END")
					do
						for benchcount in $(seq 0 $((${#TEST_SET[@]}-1)))
						do
							runtime_st=$(awk -v START="$TEST_START_LINE" -v SEP='\t' -v RUNCOL="$TEST_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$TEST_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v FREQCOL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print $1;exit}}' < "$TEST_FILE")
							#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
							runtime_nd_nr=$(tac "$TEST_FILE" | awk -v START=1 -v SEP='\t' -v RUNCOL="$TEST_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$TEST_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v FREQCOL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print NR;exit}}')
							#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
							if [[ $runtime_nd_nr == 1 ]];then
								runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
							fi
							runtime_nd=$(tac "$TEST_FILE" | awk -v START=$((runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
							total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
						done
					done
					#Compute average per-freq runtime
					avg_total_runtime[$count]=$(echo "scale=0;$total_runtime/(($TEST_RUN_END-$TEST_RUN_START+1)*$TIME_CONVERT);" | bc )
				else
					for runnum in $(seq "$RESULT_RUN_START" 1 "$RESULT_RUN_END")
					do
						for benchcount in $(seq 0 $((${#TEST_SET[@]}-1)))
						do
							runtime_st=$(awk -v START="$RESULT_START_LINE" -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v FREQCOL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print $1;exit}}' < "$RESULT_FILE")
							#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
							runtime_nd_nr=$(tac "$RESULT_FILE" | awk -v START=1 -v SEP='\t' -v RUNCOL="$RESULT_RUN_COL" -v RUN="$runnum" -v BENCHCOL="$RESULT_BENCH_COL" -v BENCH="${TEST_SET[$benchcount]}" -v FREQCOL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print NR;exit}}')
							#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
							if [[ $runtime_nd_nr == 1 ]];then
								runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
							fi
							runtime_nd=$(tac "$RESULT_FILE" | awk -v START=$((runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
							total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
						done
					done
					#Compute average per-freq runtime
					avg_total_runtime[$count]=$(echo "scale=0;$total_runtime/(($RESULT_RUN_END-$RESULT_RUN_START+1)*$TIME_CONVERT);" | bc )
				fi
				
#Collect output for the frequency. Extract freqeuncy level from full set and pass it into octave
				touch "test_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ="${FREQ_LIST[$count]}" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ="${FREQ_LIST[$count]}" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
				fi
				octave_output+=$(octave --silent --eval "load_build_model(1,'test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
				#Cleanup
				rm "test_set.data"
			else
				#Collecting model characteristics
				#Split full set into training and data
				touch "train_set.data" "test_set.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
				fi
				octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
				#Cleanup
				rm "train_set.data" "test_set.data"
			fi
		done
		#Collect data count depending on mode to ensure we got the right data. Octave sometimes hangs so this is necessary to overcome "skipping" frequencies
		if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
		else
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
		fi
	done	
fi

#Extract relevant informaton from octave. Some of these will be empty depending on mode
#Physical information
#Avg. Power
IFS=";" read -a avg_pow <<< $(echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Power"){ print $4 }}' | tr "\n" ";" | head -c -1)
#Measured Power Range
IFS=";" read -a pow_range <<< $(echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power" && $3=="Range"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_totals <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="totals:"){ print substr($0, index($0,$5)) }}' | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_averages <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="averages:"){ print substr($0, index($0,$5)) }}' | tr "\n" ";" | head -c -1)

#Model information
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Avg. Abs. Error
IFS=";" read -a avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Abs. Err. Std. Dev.
IFS=";" read -a std_dev_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Absolute" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Avg. Rel. Error
IFS=";" read -a rel_avg_abs_err <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Rel. Err. Std. Dev
IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Avg Ev. Cross. Corr.
IFS=";" read -a avg_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr.
IFS=";" read -a max_ev_cross_corr <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr. EV1 
IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr. EV2
IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Model coefficients
IFS=";" read -a model_coeff <<< $(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="Coefficients:"){ print substr($0, index($0,$3)) }}' | tr "\n" ";" | head -c -1)

#Modify freqeuncy list first element to list "all"
[[ -n $ALL_FREQUENCY ]] && FREQ_LIST[0]="all"

#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $OUTPUT_MODE in
	1)
		HEADER="CPU Frequency\tTotal Runtime [s]\tAverage Power [W]\tMeasured Power Range [%]"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_total_runtime[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}"
		;;
	2)
		HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]\tAverage Event Cross-Correlation [%]\tMax Event Cross-Correlation [%]\tModel coefficients"
		DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${avg_ev_cross_corr[\$i]}\t\${max_ev_cross_corr[\$i]}\t\${model_coeff[\$i]}"
		;;
	3)
		HEADER="Average Relative Error [%]\tRelative Error Standart Deviation [%]\tAverage Event Cross-Correlation [%]\tMax Event Cross-Correlation [%]"
		DATA="\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${avg_ev_cross_corr[\$i]}\t\${max_ev_cross_corr[\$i]}"
		;;
	4)
		HEADER="Event totals"
		DATA="\${event_totals[\$i]}"
		;;
	5)
		HEADER="Event averages"
		DATA="\${event_averages[\$i]}"
		;;
esac  

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
	if [[ -z $SAVE_FILE ]]; then 
		echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t"
	else
		echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t" >> "$SAVE_FILE"
	fi
	#If all freqeuncy model, there is just one line that needs to be printed
	[[ -n $ALL_FREQUENCY ]] && break;
done

#Print model summary if in mode
if [[ $OUTPUT_MODE == 2 || $OUTPUT_MODE == 3 ]]; then 
	echo -e "--------------------" >&1
	MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
	MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
	MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
	MEAN_MAX_EV_CROSS_CORR=$(getMean max_ev_cross_corr ${#max_ev_cross_corr[@]} )
	MAX_EV_CROSS_CORR_IND=$(getMaxIndex max_ev_cross_corr ${#max_ev_cross_corr[@]} )
	MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${max_ev_cross_corr_ev1[$MAX_EV_CROSS_CORR_IND]},${max_ev_cross_corr_ev2[$MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
	echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
	echo "Mean model average event cross-correlation -> $MEAN_AVG_EV_CROSS_CORR" >&1
	echo "Mean model max event cross-correlation -> $MEAN_MAX_EV_CROSS_CORR" >&1
	echo "Model max event cross-correlation ${max_ev_cross_corr[$MAX_EV_CROSS_CORR_IND]} is at ${FREQ_LIST[$MAX_EV_CROSS_CORR_IND]} MHz between $MAX_EV_CROSS_CORR_EV_LABELS" >&1
	echo -e "--------------------" >&1
fi

echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1
