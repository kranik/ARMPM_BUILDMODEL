#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi
#Internal parameters
TIME_CONVERT=1000000000

#Internal variable for quickly setting maximum number of modes and model types
<<<<<<< HEAD
<<<<<<< HEAD
NUM_MODES=5
NUM_AUTO=3
NUM_TYPES=2

#Extract unique benchmark split from results file
benchmarkSplit () {
	#Read and randomise benchmarks, assumes column 2 is benchmarks.
	#I can automate this by searching the header and extracting column number if I need to, but this is very rarely used.
	local RANDOM_BENCHMARK_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v BENCH=0 'BEGIN{FS=SEP}{ if(NR > START && $2 != BENCH){print ($2);BENCH=$2} }' < $RESULTS_FILE | sort -u | sort -R ) | sed 's/ /\\n/g' )
	local NUM_BENCH=$(echo -e "$RANDOM_BENCHMARK_LIST" | wc -l)
	#Get midpoint to split the randomised list
	local MIDPOINT=$(echo "scale = 0; $NUM_BENCH/2;" | bc )
	#I need to use this temp to extract the string
	#Bash gets confused with too many variable substitutions, that why I need the temp
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | head -n $MIDPOINT | sort -d ) | sed 's/ /,/g')
	IFS="," read -a TRAIN_SET <<< "$temp"
	local temp=$(echo $(echo -e $RANDOM_BENCHMARK_LIST | tail -n $(echo "scale = 0; $NUM_BENCH-$MIDPOINT;" | bc ) | sort -d ) | sed 's/ /,/g')
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
NUM_ML_METHODS=3
NUM_OPT_CRITERIA=3
NUM_CROSS_MODES=2
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	IFS="," read -a TEST_SET <<< "$temp"
}

#Simple script to get the mean of an array
#Need to pass the name of the array as first argument and then the element count as second argument
#Then use BC to compute mean since bash has just integer logic and we are almost surely dealing with fractions for the mean
getMean () {
	local total=0
	local -n array=$1
<<<<<<< HEAD
<<<<<<< HEAD
	for i in `seq 0 $(($2-1))`
	do
		total=$(echo "$total+${array[$i]};" | bc )
	done
	echo $(echo "scale=5; $total/$2;" | bc )
}

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:f:b:c:e:am:n:l:t:s:h" opt;
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
do
	case $opt in
		h)
			echo "Available flags and options:" >&1
<<<<<<< HEAD
<<<<<<< HEAD
			echo "-r [FILEPATH] -> Specify the concatednated results file to be analyzed." >&1
			echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
			echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
			echo "-c [NUMBER] -> Specify power column." >&1
			echo "-e [NUMBER LIST] -> Specify events list." >&1
			echo "-a -> Use flag to specify all frequencies model instead of per frequency one." >&1
			echo "-m [NUMBER: 1:$NUM_MODES]-> Mode of operation: 1 -> Measured platform physical data; 2 -> Model detailed performance and coefficients; 3 -> Model shortened performance; 4 -> Platform selected event totals; 5 -> Platform selected event averages;" >&1
			echo "-n [NUMBER] -> Specify max number of events to include in automatic model generation." >&1
			echo "-l [NUMBER: 1:$NUM_AUTO]-> Type of automatic machine learning search approach: 1 -> Bottom-up; 2 -> Top-down; 3 -> Exhaustive search;" >&1
			echo "-t [NUMBER: 1:$NUM_TYPES]-> Select minimization criteria for model optimisation: 1 -> Minimal absolute error; 2 -> Minimal absolute error standart deviation;" >&1
			echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
			echo "Mandatory options are: -r, -b, -c, -e, -m"
			exit 0 
			;;

		#Specify the save directory, if no save directory is chosen the results are saved in the $PWD
		r)
			if [[ -n $RESULTS_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				exit 1                
			fi
			#Make sure the benchmark directory selected exists
			if [[ ! -e "$OPTARG" ]]; then
				echo "-r $OPTARG does not exist. Please enter the results file to be analyzed!" >&2 
				exit 1
		    	else
				RESULTS_FILE="$OPTARG"
				RESULTS_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < $RESULTS_FILE)
				#Check if results file contains data
			    	if [[ -z $RESULTS_START_LINE ]]; then 
					echo "Results file contains no data!" >&2
					exit 1
				fi  
				RESULTS_FREQ_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v FREQ=0 'BEGIN{FS=SEP}{ if(NR >= START && $4 != FREQ){print ($4);FREQ=$4} }' < $RESULTS_FILE | sort -u | sort -gr ) | tr " " ",")
				#Check if we have successfully extracted freqeuncies
				if [[ -z $RESULTS_FREQ_LIST ]]; then
					echo "Unable to extract freqeuncies from results file!" >&2
					exit 1
				fi  
		    	fi
		    	;;
		f)
		    	if [[ -n $CORE_FREQ ]]; then
			    	echo "Invalid input: option -f has already been used!" >&2
		            	exit 1
		    	fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting frequency list!" >&2
				exit 1
			fi

			#Go throught the selected frequecnies and make sure they are not out of bounds
	    		#Also make sure they are present in the frequency table located at /sys/devices/system/cpu/cpufreq/iks-cpufreq/freq_table because the kernel rounds up
			#Specifying a higher/lower frequency or an odd frequency is now wrong, jsut the kernel handles it in the background and might lead to collection of unwanted resutls
			spaced_OPTARG="${OPTARG//,/ }"
			IFS="," read -a FREQ_LIST <<< "$RESULTS_FREQ_LIST"
			for FREQ_SELECT in $spaced_OPTARG
			do
				#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
				if [[ " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
					[[ -z "$USER_FREQ_LIST" ]] && USER_FREQ_LIST="$FREQ_SELECT" || USER_FREQ_LIST+=",$FREQ_SELECT"	
				else
					echo "selected frequency $FREQ_SELECT for -$opt is not present in concatenated results file."
			       	 	exit 1
				fi
			done
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			echo "-r [FILEPATH] -> Specify the concatednated result file to be analyzed." >&1
			echo "-t [FILEPATH] -> Specify the concatednated result file to be used to test model." >&1
			echo "-f [FREQENCY LIST][MHz] -> Specify the frequencies to be analyzed, separated by commas." >&1
			echo "-b [FILEPATH] -> Specify the benchmark split file for the analyzed results. Can also use an unused filename to generate new split."
			echo "-p [NUMBER] -> Specify power column." >&1
			echo "-e [NUMBER LIST] -> Specify events list." >&1
			echo "-a -> Use flag to specify all frequencies model instead of per frequency one." >&1
			echo "-x [NUMBER: 1:$NUM_CROSS_MODES]-> Select cross model computation mode: 1 -> Intra-core model (no -t, just use -r onto intself but with a cross-model methodology); 2 -> Inter-core cross-model (-r file to -t file and they should have differing frequency information, but same events list);" >&1
			echo "-q [FREQENCY LIST][MHz] -> Specify the frequencies to be used in cross-model for the second core (specified with -t flag)." >&1
			echo "-m [NUMBER: 1:$NUM_ML_METHODS]-> Type of automatic machine learning search method: 1 -> Bottom-up; 2 -> Top-down; 3 -> Exhaustive search;" >&1
			echo "-c [NUMBER: 1:$NUM_OPT_CRITERIA]-> Select minimization criteria for model optimisation: 1 -> Absolute error; 2 -> Absolute error standart deviation; 3 -> Maximum event cross-correlation;" >&1
			echo "-l [NUMBER LIST] -> Specify events pool." >&1
			echo "-n [NUMBER] -> Specify max number of events to include in automatic model generation." >&1
			echo "-o [NUMBER: 1:$NUM_OUTPUT_MODES]-> Output mode: 1 -> Measured platform physical data; 2 -> Model detailed performance and coefficients; 3 -> Model shortened performance; 4 -> Platform selected event totals; 5 -> Platform selected event averages;" >&1
			echo "-s [FILEPATH] -> Specify the save file for the analyzed results." >&1
			echo "Mandatory options are: -r, -b, -p, -e/(-m -c -n -l), -o"
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
		#Specify the test/cross file
		t)
			if [[ -n $TEST_FILE ]]; then
				echo "Invalid input: option -t has already been used!" >&2
				echo -e "===================="
				exit 1                
			else
				TEST_FILE="$OPTARG"
			fi
		    	;;
		#Specify frequency list
		f)
		    	if [[ -n $USER_FREQ_LIST ]]; then
			    	echo "Invalid input: option -f has already been used!" >&2
				echo -e "===================="
		            	exit 1
			else	
				USER_FREQ_LIST="$OPTARG"
		    	fi
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			;;
		#Specify the benchmarks split file, if no benchmarks are chosen the program can be used to make a new randomised benchmark split
		b)
			if [[ -n $BENCH_FILE ]]; then
		    		echo "Invalid input: option -b has already been used!" >&2
<<<<<<< HEAD
<<<<<<< HEAD
		    		exit 1                
			fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting benchmark split!" >&2
				exit 1
			fi
			if [[ ! -e "$OPTARG" ]]; then
			    	echo "-b $OPTARG does not exist. Do you want to create a new benchmark split and save in file? (Y/N)" >&1
			    	#wait on user input here (Y/N)
			    	#if user says Y set writing directory to that
			    	#if no then exit and ask for better input parameters
			    	while true;
			    	do
					read USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Creating new benchmark split file $OPTARG" >&1
		    				BENCH_FILE="$OPTARG"
		    				#Perform randomised split and 
		    				benchmarkSplit
		    				#Store benchmarks
		    				echo -e "#Train Set\tTest Set" > $BENCH_FILE
					 	for i in `seq 0 $((${#TEST_SET[@]}-1))`
						do
							echo -e "${TRAIN_SET[$i]}\t${TEST_SET[$i]}" >> $BENCH_FILE 
						done
						break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled creating benchmark split file $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
			else
			    	#Extract benchmark split information.
			    	BENCH_FILE="$OPTARG"
			    	BENCH_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < $BENCH_FILE)
				#Check if bench file contains data
				if [[ -z $BENCH_START_LINE ]]; then
					echo "Benchmarks split file contains no data!" >&2
					exit 1
				fi
				IFS=";" read -a TRAIN_SET <<< "$( echo $(awk -v SEP='\t' -v START=$BENCH_START_LINE 'BEGIN{FS=SEP}{if (NR >= START){ print $1 }}' $BENCH_FILE | sort -d ) | tr " " ";" | head -c -1 )"
				IFS=";" read -a TEST_SET <<< "$( echo $(awk -v SEP='\t' -v START=$BENCH_START_LINE 'BEGIN{FS=SEP}{if (NR >= START){ print $2 }}' $BENCH_FILE | sort -d) | tr " " ";" |  head -c -1 )"
				#Check if we have successfully extracted benchmark sets 
				if [[ ${#TRAIN_SET[@]} == 0 || ${#TEST_SET[@]} == 0 ]]; then
					echo "Unable to extract train or test set from benchmarks file!" >&2
					exit 1
				fi 	            	
			fi
		    	;;
		c)
			if [[ -n  $POWER_COL ]]; then
		    		echo "Invalid input: option -c has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $RESULTS_FILE ]]; then
				echo "Please specify results file before selecting power column!" >&2
				exit 1
			fi
			#Extract events columns from results file
			EVENTS_COL_START=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i+1; exit} } } }' < $RESULTS_FILE)
			EVENTS_COL_END=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < $RESULTS_FILE)				
	
			#Check if power is within bounds
			if [[ "$OPTARG" -gt $EVENTS_COL_END || "$OPTARG" -lt $EVENTS_COL_START ]]; then 
				echo "Selected power -c $OPTARG is out of bounds/invalid. Needs to be an integer value betweeen [$EVENTS_COL_START:$EVENTS_COL_END]." >&2
				exit 1
			fi
	    		POWER_COL="$OPTARG"
			POWER_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$POWER_COL 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
			#Extract run number for runtime information now that we have events column
			BENCH_RUNS_START=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v COL=$(($EVENTS_COL_START-1)) 'BEGIN{FS = SEP}{if (NR == START){print $COL;exit}}' < $RESULTS_FILE)
			BENCH_RUNS_END=$(awk -v START=$(wc -l $RESULTS_FILE | awk '{print $1}') -v SEP='\t' -v COL=$(($EVENTS_COL_START-1)) 'BEGIN{FS = SEP}{if (NR == START){print $COL;exit}}' < $RESULTS_FILE)

=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				echo -e "===================="
		    		exit 1                
			else
				BENCH_FILE="$OPTARG"
			fi
		    	;;
		p)
			if [[ -n  $POWER_COL ]]; then
		    		echo "Invalid input: option -p has already been used!" >&2
				echo -e "===================="
		    		exit 1    
			else
				POWER_COL="$OPTARG"            
			fi
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    	;;
		e)
			if [[ -n  $EVENTS_LIST ]]; then
		    		echo "Invalid input: option -e has already been used!" >&2
<<<<<<< HEAD
<<<<<<< HEAD
		    		exit 1
                	fi
			if [[ -z $POWER_COL ]]; then
				echo "Please specify power column before selecting events list!" >&2
				exit 1
			fi
			spaced_OPTARG="${OPTARG//,/ }"
			for EVENT in $spaced_OPTARG
			do
				#Check if events list is in bounds
				if [[ "$EVENT" -gt $EVENTS_COL_END || "$EVENT" -lt $EVENTS_COL_START ]]; then 
					echo "Selected event -e $EVENT is out of bounds/invalid. Needs to be an integer value betweeen [$EVENTS_COL_START:$EVENTS_COL_END]." >&2
					exit 1
				fi
				#Check if it contains power
				if [[ "$EVENT" == $POWER_COL ]]; then 
					echo "Selected event -e $EVENT is the same as the power $POWER_COL -> $POWER_LABEL." >&2
					exit 1
				fi
			done
			#Checkif events string contains duplicates
			if [[ $(echo $OPTARG | tr "," "\n" | wc -l) -gt $(echo $OPTARG | tr "," "\n" | sort | uniq | wc -l) ]]; then
				echo "Selected event list -e $OPTARG contains duplicates." >&2
				exit 1
			fi
			EVENTS_LIST="$OPTARG"
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				echo -e "===================="
		    		exit 1
			else
				EVENTS_LIST="$OPTARG"
                	fi
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    	;;
		a)
			if [[ -n  $ALL_FREQUENCY ]]; then
		    		echo "Invalid input: option -a has already been used!" >&2
<<<<<<< HEAD
<<<<<<< HEAD
=======
				echo -e "===================="
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
				echo -e "===================="
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    		exit 1                
			fi
		    	ALL_FREQUENCY=1
		    	;;
<<<<<<< HEAD
<<<<<<< HEAD
		m)
			if [[ -n $MODE ]]; then
		    		echo "Invalid input: option -m has already been used!" >&2
		    		exit 1                
			fi
			if [[ $OPTARG != "1" && $OPTARG != "2" && $OPTARG != "3" && $OPTARG != "4" && $OPTARG != "5" ]]; then 
				echo "Invalid operarion: -m $MODE! Options are: [1:$NUM_MODES]." >&2
				echo "Use -h flag for more information on the available modes." >&2
			    	echo -e "===================="
			    	exit 1
			fi		
			MODE="$OPTARG"      	
			;;

		n)
			if [[ -n  $NUM_MODEL_EVENTS ]]; then
		    		echo "Invalid input: option -n has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $EVENTS_LIST ]]; then
				echo "Please specify events list file before selecting number of events in model(automatic)!" >&2
				exit 1
			fi
			EVENTS_LIST_SIZE=$(echo $EVENTS_LIST | tr "," "\n" | wc -l)
			#Check if number is within bounds, which is total number of events - 1 (power)
			if [[ "$OPTARG" -gt $EVENTS_LIST_SIZE || "$OPTARG" -le 0 ]]; then 
				echo "Selected number of events -n $EVENTS_LIST_SIZE is out of bounds/invalid. Needs to be an integer value betweeen [1:$EVENTS_LIST_SIZE]." >&2
				exit 1
			fi
			#Initiate variables and unset events_list (since we use events_pool for the automatic list)
	    		NUM_MODEL_EVENTS="$OPTARG"
			EVENTS_POOL=$EVENTS_LIST
			unset EVENTS_LIST
		    	;;
		l)
			if [[ -n $AUTO_SEARCH ]]; then
		    		echo "Invalid input: option -l has already been used!" >&2
		    		exit 1                
			fi
			if [[ -z $NUM_MODEL_EVENTS ]]; then
				echo "Please specify the number of events in model before you select the automatic search algorithm!" >&2
				exit 1
			fi
			if [[ $OPTARG != "1" && $OPTARG != "2" && $OPTARG != "3" ]]; then 
				echo "Invalid operarion: -l $AUTO_SEARCH! Options are: [1:$NUM_AUTO]." >&2
				echo "Use -h flag for more information on the available automatic search algorithms." >&2
			    	echo -e "===================="
			    	exit 1
			fi
			AUTO_SEARCH="$OPTARG"      	
			;;
		t)
			if [[ -n $MODEL_TYPE ]]; then
		    		echo "Invalid input: option -t has already been used!" >&2
		    		exit 1                
			fi
			if [[ $OPTARG != "1" && $OPTARG != "2" ]]; then 
				echo "Invalid operarion: -t $MODEL_TYPE! Options are: [1:$NUM_TYPES]." >&2
				echo "Use -h flag for more information on the available model types." >&2
			    	echo -e "===================="
			    	exit 1
			fi		
			MODEL_TYPE="$OPTARG"      	
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		x)
			if [[ -n $CM_MODE ]]; then
		    		echo "Invalid input: option -x has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else
				CM_MODE="$OPTARG"
			fi
		    	;;

		#Specify frequency list for cross-model
		q)
		    	if [[ -n $USER_CROSS_FREQ_LIST ]]; then
			    	echo "Invalid input: option -q has already been used!" >&2
				echo -e "===================="
		            	exit 1
			else	
				USER_CROSS_FREQ_LIST="$OPTARG"
		    	fi
			;;
		m)
			if [[ -n $AUTO_SEARCH ]]; then
		    		echo "Invalid input: option -m has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else
				AUTO_SEARCH="$OPTARG"
			fi
			;;
		c)
			if [[ -n $MODEL_TYPE ]]; then
		    		echo "Invalid input: option -c has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else
				MODEL_TYPE="$OPTARG"
			fi
			;;
		l)
			if [[ -n  $EVENTS_POOL ]]; then
		    		echo "Invalid input: option -l has already been used!" >&2
				echo -e "===================="
		    		exit 1
			else
				EVENTS_POOL="$OPTARG"
                	fi
		    	;;
		n)
			if [[ -n  $NUM_MODEL_EVENTS ]]; then
		    		echo "Invalid input: option -n has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else
				NUM_MODEL_EVENTS="$OPTARG"
			fi
		    	;;
		o)
			if [[ -n $OUTPUT_MODE ]]; then
		    		echo "Invalid input: option -o has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			else	
				OUTPUT_MODE="$OPTARG"
			fi
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			;;
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
<<<<<<< HEAD
<<<<<<< HEAD
			    	exit 1                
			fi

			if [[ -e "$OPTARG" ]]; then
			    	#wait on user input here (Y/N)
			    	#if user says Y set writing directory to that
			    	#if no then exit and ask for better input parameters
			    	echo "-s $OPTARG already exists. Continue writing in file? (Y/N)" >&1
			    	while true;
			    	do
					read USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Using existing file $OPTARG" >&1
				    		break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled using save file $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
			    	SAVE_FILE="$OPTARG"
			else
		    		#file does not exist, set mkdir flag.
=======
				echo -e "===================="
			    	exit 1                
			else
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
				echo -e "===================="
			    	exit 1                
			else
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    		SAVE_FILE="$OPTARG"
			fi
			;;        
		:)
		    	echo "Option: -$OPTARG requires an argument" >&2
<<<<<<< HEAD
<<<<<<< HEAD
=======
			echo -e "===================="
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
			echo -e "===================="
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    	exit 1
		    	;;
		\?)
		    	echo "Invalid option: -$OPTARG" >&2
<<<<<<< HEAD
<<<<<<< HEAD
=======
			echo -e "===================="
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
			echo -e "===================="
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		    	exit 1
		    	;;
	esac
done

#Critical sanity checks
echo -e "===================="
<<<<<<< HEAD
<<<<<<< HEAD
if [[ -z $RESULTS_FILE ]]; then
=======
if [[ -z $RESULT_FILE ]]; then
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
if [[ -z $RESULT_FILE ]]; then
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
<<<<<<< HEAD
<<<<<<< HEAD
if [[ -z $MODE ]]; then
    	echo "No mode specified! Expected -m flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use flag with existing file or an empty file to gererate random benchmark split." >&2
=======
if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use -b flag with existing file or an empty file to generate random benchmark split." >&2
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
if [[ -z $BENCH_FILE ]]; then
	echo "No benchmark file specified! Please use -b flag with existing file or an empty file to generate random benchmark split." >&2
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "====================" >&1
	exit 1
fi
if [[ -z $POWER_COL ]]; then
<<<<<<< HEAD
<<<<<<< HEAD
    	echo "No power! Expected -c flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $EVENTS_LIST && -z $EVENTS_POOL ]]; then
    	echo "No event list specified! Expected -e flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -n $NUM_MODEL_EVENTS && -z $AUTO_SEARCH ]]; then
    	echo "No automatic search algorithm specified! Expected -l flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -n $NUM_MODEL_EVENTS && -z $MODEL_TYPE ]]; then
    	echo "No model type specified! Expected -t flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
echo -e "Critical checks passed!"  >&1

#Regular sanity checks
echo -e "====================" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
    	echo "No power! Expected -p flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $EVENTS_LIST && -z $AUTO_SEARCH ]]; then
    	echo "No events list specified! Expected -e flag when auto search not used (no -m flag)." >&2
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
	RESULT_FREQ_COL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$RESULT_FILE")
	if [[ -z $RESULT_FREQ_COL ]]; then
		echo "Results file contains no freqeuncy column!" >&2
		echo -e "===================="
		exit 1
	fi
	RESULT_FREQ_LIST=$(awk -v SEP='\t' -v START="$RESULT_START_LINE" -v DATA=0 -v COL="$RESULT_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$RESULT_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
	if [[ -z $RESULT_FREQ_LIST ]]; then
		echo "Unable to extract freqeuncy list from result file!" >&2
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

	#Extract events columns from result file
	RESULT_EVENTS_COL_START=$RESULT_FREQ_COL
	RESULT_EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$RESULT_FILE")
	if [[ "$RESULT_EVENTS_COL_START" -eq "$RESULT_EVENTS_COL_END" ]]; then
		echo "No events present in result files!" >&2
		echo -e "===================="
		exit 1
	fi
fi

#-t flag
#Check if test/cross file is present
if [[ -n $TEST_FILE ]]; then
	if [[ ! -e "$TEST_FILE" ]]; then
		echo "-t $TEST_FILE does not exist. Please enter and existing test/cross file!" >&2 
		echo -e "===================="
		exit 1
	else
		#Check if test/cross file is the same as the result file
		if [[ "$TEST_FILE" == "$RESULT_FILE" ]]; then
			echo "Results file and test/cross file are the same! File specified using -t flag must be different or it is useless (just use -r flag)." >&2
			echo -e "===================="
			exit 1
		fi

		#Check if test/cross file contains data
		TEST_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$TEST_FILE")
	    	if [[ -z $TEST_START_LINE ]]; then 
			echo "Results file contains no data!" >&2
			echo -e "===================="
			exit 1
		fi

		#Exctract run column and list
		TEST_RUN_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_RUN_COL ]]; then
			echo "Results file contains no run column!" >&2
			echo -e "===================="
			exit 1
		fi
		TEST_RUN_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_RUN_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -g | tr "\n" "," | head -c -1 )
		if [[ -z $TEST_RUN_LIST ]]; then
			echo "Unable to extract run list from test/cross file!" >&2
			echo -e "===================="
			exit 1
		fi
		#Extract run number for runtime information now that we have events column
		TEST_RUN_START=$(echo "$TEST_RUN_LIST" | tr "," "\n" | head -n 1)
		TEST_RUN_END=$(echo "$TEST_RUN_LIST" | tr "," "\n" | tail -n 1)

		#Exctract freq column and list
		TEST_FREQ_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_FREQ_COL ]]; then
			echo "Results file contains no freqeuncy column!" >&2
			echo -e "===================="
			exit 1
		fi
		TEST_FREQ_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_FREQ_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -gr | tr "\n" "," | head -c -1 )
		if [[ -z $TEST_FREQ_LIST ]]; then
			echo "Unable to extract freqeuncy list from test/cross file!" >&2
			echo -e "===================="
			exit 1
		fi

		#Exctract bench column and list
		TEST_BENCH_COL=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$TEST_FILE")
		if [[ -z $TEST_BENCH_COL ]]; then
			echo "Results file contains no benchmark column!" >&2
			echo -e "===================="
			exit 1
		fi
		TEST_BENCH_LIST=$(awk -v SEP='\t' -v START="$TEST_START_LINE" -v DATA=0 -v COL="$TEST_BENCH_COL" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$TEST_FILE" | sort -u | sort -d | tr "\n" "," | head -c -1)
		if [[ -z $TEST_BENCH_LIST ]]; then
			echo "Unable to extract benchmarks from test/cross file!" >&2
			echo -e "===================="
			exit 1
		fi

		#Extract events columns from test/cross file
		TEST_EVENTS_COL_START=$TEST_FREQ_COL
		TEST_EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$TEST_FILE")
		if [[ "$TEST_EVENTS_COL_START" -eq "$TEST_EVENTS_COL_END" ]]; then
			echo "No events present in test/cross file!" >&2
			echo -e "===================="
			exit 1
		fi

		#Check if test frequencies match result file if no user freqeuncy list
		if [[ -z $USER_FREQ_LIST && -z $CM_MODE ]]; then
			if [[ "$TEST_FREQ_LIST" != "$RESULT_FREQ_LIST" ]]; then
				echo "Test file frequency list is different than result file freqeuncy list! Please use -f flag to specify specific list." >&2
				echo -e "===================="
				exit 1
			fi
		fi
	fi
fi

#-f flag
#Check if user specified frequencies are present in result file and test/cross file
if [[ -n $USER_FREQ_LIST ]]; then
	#Go throught the user frequencies and make sure they are not out of bounds of the train file
	spaced_USER_FREQ_LIST="${USER_FREQ_LIST//,/ }"
	IFS="," read -a FREQ_LIST <<< "$RESULT_FREQ_LIST"
	for FREQ_SELECT in $spaced_USER_FREQ_LIST
	do
		#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
		if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
			echo "selected frequency $FREQ_SELECT for -f is not present in result file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
	#Check freq list against test file freq list (if selected)
	#Ignore when doing cross models, then we can extract and use CROSS_FREQ_LIST from -t file
	if [[ -n $TEST_FILE && -z $CM_MODE ]]; then
		IFS="," read -a FREQ_LIST <<< "$TEST_FREQ_LIST"
		for FREQ_SELECT in $spaced_USER_FREQ_LIST
		do
			#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
			if [[ ! " ${FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
				echo "selected frequency $FREQ_SELECT for -f is not present in test/cross file."
				echo -e "===================="
		       	 	exit 1
			fi
		done
	fi
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
	if [[ -n $TRAIN_FILE ]]; then
		IFS="," read -a BENCH_LIST <<< "$TEST_BENCH_LIST"
		for count in $(seq 0 1 $((${#TEST_SET[@]}-1)))
		do
			#containsElement "$FREQ_SELECT" "${FREQ_LIST[@]}"
			if [[ ! " ${BENCH_LIST[@]} " =~ " ${TEST_SET[$count]} " ]]; then
				echo "Specified test benchmark ${TEST_SET[$count]} for -b is not present in test/cross file."
				echo -e "===================="
		       	 	exit 1
			fi
		done
	else
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
fi

#-p flag
#Check if power is within bounds
if [[ "$POWER_COL" -gt $RESULT_EVENTS_COL_END || "$POWER_COL" -lt $RESULT_EVENTS_COL_START ]]; then 
	echo "Selected power column -p $POWER_COL is out of bounds from result file events. Needs to be an integer value betweeen [$RESULT_EVENTS_COL_START:$RESULT_EVENTS_COL_END]." >&2
	echo -e "===================="
	exit 1
fi
if [[ -n $TEST_FILE ]]; then
	if [[ "$POWER_COL" -gt $TEST_EVENTS_COL_END || "$POWER_COL" -lt $TEST_EVENTS_COL_START ]]; then 
		echo "Selected power column -p $POWER_COL is out of bounds from test/cross file events. Needs to be an integer value betweeen [$TEST_EVENTS_COL_START:$TEST_EVENTS_COL_END]." >&2
		echo -e "===================="
		exit 1
	fi
fi
POWER_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$POWER_COL" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")



#-e flag
if [[ -n $EVENTS_LIST ]]; then
	spaced_EVENTS_LIST="${EVENTS_LIST//,/ }"
	for EVENT in $spaced_EVENTS_LIST
	do
		#Check if events list is in bounds
		if [[ "$EVENT" -gt $RESULT_EVENTS_COL_END || "$EVENT" -lt $RESULT_EVENTS_COL_START ]]; then 
			echo "Selected event -e $EVENT is out of bounds/invalid to result file events. Needs to be an integer value betweeen [$RESULT_EVENTS_COL_START:$RESULT_EVENTS_COL_END]." >&2
			echo -e "===================="
			exit 1
		fi
		#Check event list against test/cross file event list (if selected)
		if [[ -n $TEST_FILE ]]; then
			if [[ "$EVENT" -gt $TEST_EVENTS_COL_END || "$EVENT" -lt $TEST_EVENTS_COL_START ]]; then 
				echo "Selected event -e $EVENT is out of bounds/invalid to test/cross file events. Needs to be an integer value betweeen [$TEST_EVENTS_COL_START:$TEST_EVENTS_COL_END]." >&2
				echo -e "===================="
				exit 1
			fi
			#Check if events list is the same for both test and result files
			RESULT_EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
			TEST_EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$TEST_FILE" | tr "\n" "," | head -c -1)
			if [[ "$TEST_EVENTS_LIST_LABELS" != "$RESULT_EVENTS_LIST_LABELS" ]]; then
				echo "The selected events list -e $EVENTS_LIST is different between result file and test/cross file!" >&2
				echo "Result list -> $RESULT_EVENTS_LIST_LABELS" >&2
				echo "Test list -> $TEST_EVENTS_LIST_LABELS" >&2
				echo -e "===================="
				exit 1
			fi
		fi
		#Check if it contains power
		if [[ "$EVENT" == "$POWER_COL" ]]; then 
			echo "Selected event -e $EVENT is the same as the regressand -p $POWER_COL -> $POWER_LABEL." >&2
			echo -e "===================="
			exit 1
		fi
	done
fi

#Checkif events string contains duplicates
if [[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -gt $(echo "$EVENTS_LIST" | tr "," "\n" | sort | uniq | wc -l) ]]; then
	echo "Selected event list -e $EVENTS_LIST contains duplicates." >&2
	echo -e "===================="
	exit 1
fi


#-x flag
if [[ -n $CM_MODE ]]; then
	if [[ $CM_MODE -eq 2 && -z $TEST_FILE ]]; then
		echo "Expected -t flag when -x [OPTION=2] flag is used in order to specify cross-core data!" >&2
		echo -e "===================="
		exit 1
	fi
	#Check if valid input
	if [[ "$CM_MODE" != "1" && "$CM_MODE" != "2" ]]; then 
		echo "Invalid operarion: -x $CM_MODE! Options are: [1:$NUM_CROSS_MODES]." >&2
		echo "Use -h flag for more information on the available cross model computation modes." >&2
	    	echo -e "===================="
	    	exit 1
	fi	
fi

#-q flag
#Check if user specified frequencies are present in result file and test/cross file
if [[ -n $USER_CROSS_FREQ_LIST ]]; then
	if [[ $CM_MODE -ne 2 ]]; then
		echo "-q flag can only be used with -x [OPTION=2] flag in order to specify cross-core computation mode and frequency list!" >&2
		echo -e "===================="
		exit 1
	fi
	if [[ -z $TEST_FILE ]]; then
		echo "Expected -t flag when -q flag is used in order to specify cross-core data!" >&2
		echo -e "===================="
		exit 1
	fi
	#Go throught the user frequencies and make sure they are not out of bounds of the train file
	spaced_USER_CROSS_FREQ_LIST="${USER_CROSS_FREQ_LIST//,/ }"
	IFS="," read -a CROSS_FREQ_LIST <<< "$TEST_FREQ_LIST"
	for FREQ_SELECT in $spaced_USER_CROSS_FREQ_LIST
	do
		#containsElement "$FREQ_SELECT" "${CROSS_FREQ_LIST[@]}"
		if [[ ! " ${CROSS_FREQ_LIST[@]} " =~ " $FREQ_SELECT " ]]; then
			echo "selected frequency $FREQ_SELECT for -q is not present in test(cross) file."
			echo -e "===================="
	       	 	exit 1
		fi
	done
	#After both checks have passed use user freq list
	IFS="," read -a CROSS_FREQ_LIST <<< "$USER_CROSS_FREQ_LIST"
else
	#Assign CROSS_FREQ_LIST; if no -x this is unused
	IFS="," read -a CROSS_FREQ_LIST <<< "$TEST_FREQ_LIST"
fi

#-m flag
if [[ -n $AUTO_SEARCH ]]; then
	#Check if other flags present
	if  [[ -z $MODEL_TYPE || -z $NUM_MODEL_EVENTS || -z $EVENTS_POOL ]]; then
		echo "Expected -c, -l and -n flag when -m flag is used!" >&2
		echo -e "===================="
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
	if  [[ -z $AUTO_SEARCH || -z $NUM_MODEL_EVENTS || -z $EVENTS_POOL ]]; then
		echo "Expected -m, -l and -n flag when -c flag is used!" >&2
	    	echo -e "===================="
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

#-l flag
if [[ -n $EVENTS_POOL ]]; then
	#Check if other flags present
	if  [[ -z $AUTO_SEARCH || -z $MODEL_TYPE || -z $NUM_MODEL_EVENTS ]]; then
		echo "Expected -m, -c and -n flag when -l flag is used!" >&2
	    	echo -e "===================="
		exit 1
	fi
	spaced_EVENTS_POOL="${EVENTS_POOL//,/ }"
	for EVENT in $spaced_EVENTS_POOL
	do
		#Check if events pool is in bounds
		if [[ "$EVENT" -gt $RESULT_EVENTS_COL_END || "$EVENT" -lt $RESULT_EVENTS_COL_START ]]; then 
			echo "Selected event -l $EVENT is out of bounds/invalid to result file events. Needs to be an integer value betweeen [$RESULT_EVENTS_COL_START:$RESULT_EVENTS_COL_END]." >&2
			echo -e "===================="
			exit 1
		fi
		#Check event pool against test/cross file event pool (if selected)
		if [[ -n $TEST_FILE ]]; then
			if [[ "$EVENT" -gt $TEST_EVENTS_COL_END || "$EVENT" -lt $TEST_EVENTS_COL_START ]]; then 
				echo "Selected event -l $EVENT is out of bounds/invalid to test/cross file events. Needs to be an integer value betweeen [$TEST_EVENTS_COL_START:$TEST_EVENTS_COL_END]." >&2
				echo -e "===================="
				exit 1
			fi
			#Check if events pool is the same for both test and result files
			RESULT_EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
			TEST_EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((TEST_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$TEST_FILE" | tr "\n" "," | head -c -1)
			if [[ "$TEST_EVENTS_POOL_LABELS" != "$RESULT_EVENTS_POOL_LABELS" ]]; then
				echo "The selected events pool -r $EVENTS_POOL is different between result file and test/cross file!" >&2
				echo "Result events -> $RESULT_EVENTS_POOL_LABELS" >&2
				echo "Test events -> $TEST_EVENTS_POOL_LABELS" >&2
				echo -e "===================="
				exit 1
			fi
		fi
		#Check if it contains power
		if [[ "$EVENT" == "$POWER_COL" ]]; then 
			echo "Selected event -l $EVENT is the same as the regressand -p $POWER_COL -> $POWER_LABEL." >&2
			echo -e "===================="
			exit 1
		fi
		#Check if it contains events from events list (if present)
		if [[ -n $EVENTS_LIST ]]; then
			for EVENT2 in $spaced_EVENTS_LIST
			do
				if [[ "$EVENT" == "$EVENT2" ]]; then 
					echo "Selected event -l $EVENT is also present in default events list -e $EVENTS_LIST. Please exclude from pool." >&2
					echo -e "===================="
					exit 1
				fi
			done
		fi
	done

	#Check if events string contains duplicates
	if [[ $(echo "$EVENTS_POOL" | tr "," "\n" | wc -l) -gt $(echo "$EVENTS_POOL" | tr "," "\n" | sort | uniq | wc -l) ]]; then
		echo "Selected event pool -l $EVENTS_POOL contains duplicates." >&2
		echo -e "===================="
		exit 1
	fi
fi

#-n flag
if [[ -n $NUM_MODEL_EVENTS ]]; then
	#Check if other flags present
	if  [[ -z $AUTO_SEARCH || -z $MODEL_TYPE || -z $EVENTS_POOL ]]; then
		echo "Expected -m, -l and -c flag when -n flag is used!" >&2
	    	echo -e "===================="
		exit 1
	fi

	if [[ -n $EVENTS_LIST ]]; then
		EVENTS_LIST_SIZE=$(echo "$EVENTS_LIST" | tr "," "\n" | wc -l)
	else
		EVENTS_LIST_SIZE=0
	fi

	EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
	EVENTS_FULL_SIZE=$(echo "$EVENTS_LIST_SIZE+$EVENTS_POOL_SIZE;" | bc )
	#Check if number is within bounds, which is total number of events - 1 (power)
	if [[ "$NUM_MODEL_EVENTS" -gt "$EVENTS_FULL_SIZE" || "$NUM_MODEL_EVENTS" -le 0 ]]; then 
		echo "Selected number of events -n $EVENTS_LIST_SIZE is out of bounds/invalid. Needs to be an integer value betweeen [1:$EVENTS_FULL_SIZE]." >&2
	    	echo -e "===================="
		exit 1
	fi
fi

#-o flag
if [[ "$OUTPUT_MODE" != "1" && "$OUTPUT_MODE" != "2" && "$OUTPUT_MODE" != "3" && "$OUTPUT_MODE" != "4" && "$OUTPUT_MODE" != "5" ]]; then 
	echo "Invalid operarion: -o $OUTPUT_MODE! Options are: [1:$NUM_OUTPUT_MODES]." >&2
	echo "Use -h flag for more information on the available modes." >&2
    	echo -e "===================="
    	exit 1
<<<<<<< HEAD
=======
else
	if [[ "$OUTPUT_MODE" != "2" && "$OUTPUT_MODE" != "3" && -n $CM_MODE ]]; then 
		echo "Incompatible flags: -o $OUTPUT_MODE and -x $CM_MODE" >&2
		echo "Please do not use physical characteristics output for cross model. You can extract this information separately for each cluster usign the standart modes." >&2
	    	echo -e "===================="
	    	exit 1
	fi
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
	echo -e "Using test/cross file:" >&1
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
echo -e "--------------------" >&1
echo -e "Train Set:" >&1
echo "${TRAIN_SET[*]}" >&1
echo -e "--------------------" >&1
echo -e "Test Set:" >&1
echo "${TEST_SET[*]}" >&1
<<<<<<< HEAD
<<<<<<< HEAD
echo -e "--------------------" >&1
#Check for dupicates in benchmark sets
for i in `seq 0 $((${#TEST_SET[@]}-1))`
do
	if [[ " ${TRAIN_SET[@]} " =~ " ${TEST_SET[$i]} " ]]; then
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
#Check for dupicates in benchmark sets
for i in $(seq 0 $((${#TEST_SET[@]}-1)))
do
	if [[ " ${TRAIN_SET[@]} " =~ " ${TEST_SET[$i]} " ]]; then
		echo -e "--------------------" >&1
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		echo -e "Warning! Benchmark sets share benchmark \"${TEST_SET[$i]}\"" >&1
	fi
done
#Issue warning if train sets are different sizes
<<<<<<< HEAD
<<<<<<< HEAD
if [[ ${#TRAIN_SET[@]} != ${#TEST_SET[@]} ]]; then 
	echo "Warning! Benchmark sets are different sizes [${#TRAIN_SET[@]};${#TEST_SET[@]}]" >&1
	echo -e "--------------------" >&1
fi
#Output freqeuncy list
if [[ -z $USER_FREQ_LIST ]]; then
    	echo "No user specified frequency list! Using default frequency list in results file:" >&1
    	echo $RESULTS_FREQ_LIST >&1
    	IFS="," read -a FREQ_LIST <<< "$RESULTS_FREQ_LIST"
else
	echo "Using user specified frequency list:" >&1
    	echo $USER_FREQ_LIST >&1
    	IFS="," read -a FREQ_LIST <<< "$USER_FREQ_LIST"		
fi
echo -e "--------------------" >&1
#Model type check
if [[ -z $ALL_FREQUENCY ]]; then
    	echo "Computing per-frequency models!" >&1
else
    	echo "Computing full frequency model!" >&1
fi
echo -e "--------------------" >&1
#Mode sanity checks
echo "Specified program mode:" >&1
case $MODE in
	1) 
		echo "$MODE -> Measured platform physical data." >&1
		OCTAVE_MODE=1
		;;
	2) 
		echo "$MODE -> Model detailed performance and coefficients." >&1
		OCTAVE_MODE=2
		;;
	3) 
		echo "$MODE -> Model shortened performance." >&1
		OCTAVE_MODE=2
		;;
	4) 
		echo "$MODE -> Platform selected event totals." >&1
		OCTAVE_MODE=1
		;;
	5) 
		echo "$MODE -> Platform selected event averages." >&1
		OCTAVE_MODE=1
		;;
esac
echo -e "--------------------" >&1
#Model type sanity checks
echo "Specified model type:" >&1
case $MODEL_TYPE in
	1)
		echo "$MODEL_TYPE -> Minimize model absolute error." >&1
		;;
	2) 
		echo "$MODEL_TYPE -> Minimize model absolute error standart deviation." >&1
		;;
esac
echo -e "--------------------" >&1
#Automatic search algorithm sanity checks
echo "Specified model type:" >&1
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
echo -e "--------------------" >&1
#Events sanity checks
echo -e "Power Column:" >&1
echo "$POWER_COL -> $POWER_LABEL" >&1
echo -e "--------------------" >&1
if [[ -z $NUM_MODEL_EVENTS ]]; then
	EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
    	echo "No maximum number of event specified (for automatic generation). Using full user specified list." >&1
	echo -e "--------------------" >&1
	echo -e "Events list:" >&1
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
	NUM_MODEL_EVENTS=0
else	
	echo "Using user specified maximum number of events for automatic generation -> $NUM_MODEL_EVENTS" >&1
	echo -e "--------------------" >&1
	EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
	echo -e "Events pool:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
fi
echo -e "--------------------" >&1
#Save file sanity check
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
	if [[ -z $CM_MODE ]]; then
    		echo "Computing full frequency model!" >&1
	else
		echo "-a flag cannot be used together with cross-model -x flag. Cannot scale the events for the full-freqeuncy model successfully to achieve good results." >&2
		exit 1
	fi
=======
	#if [[ -z $CM_MODE ]]; then
    		echo "Computing full frequency model!" >&1
	#else
	#	echo "-a flag cannot be used together with cross-model -x flag. Cannot scale the events for the full-freqeuncy model successfully to achieve good results." >&2
	#	exit 1
	#fi
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
fi
#Cross model computation mode sanity check
#-x flag
if [[ -n $CM_MODE ]]; then
	echo "Specified cross-model computation mode:" >&1
	case $CM_MODE in
		1)
			echo -e "--------------------" >&1
			#Check for test file and replace test file stuff with results file (intra-core)
			if [[ -n $TEST_FILE ]]; then
				echo "-t flag cannot be used together with -x [OPTION=1] flag. No need for a test/cross file sicne we are doing intra-core models." >&2
				exit 1
			else
				TEST_FILE=$RESULT_FILE
				TEST_START_LINE=$RESULT_START_LINE
	    			TEST_RUN_COL=$RESULT_RUN_COL
				TEST_RUN_START=$RESULT_RUN_START
				TEST_RUN_END=$RESULT_RUN_END
				TEST_FREQ_COL=$RESULT_FREQ_COL
				TEST_BENCH_COL=$RESULT_BENCH_COL
				TEST_EVENTS_COL_START=$TEST_FREQ_COL
			fi
			echo "$CM_MODE -> Intra-core cross-model;" >&1
			echo "Using -r frequency list." >&1
			CROSS_FREQ_LIST=( "${FREQ_LIST[@]}" )
			;;
		2) 
			echo -e "--------------------" >&1
			echo "$CM_MODE -> Inter-core cross-model;" >&1
			#Cross model frequency list sanity check
			#-q list
			echo -e "--------------------" >&1
			if [[ -z $USER_CROSS_FREQ_LIST ]]; then
			    	echo "No user specified frequency list! Using default frequency list in test/cross file:" >&1
			    	echo "$TEST_FREQ_LIST" >&1
				echo "Using results file frequency list as cross-freq list and test/cross file freqeuncy list as main output list." >&1
				CROSS_FREQ_LIST=( "${FREQ_LIST[@]}" )
			    	IFS="," read -a FREQ_LIST <<< "$TEST_FREQ_LIST"		
			else
				echo "Using user specified cross-model frequency list:" >&1
			    	echo "$USER_CROSS_FREQ_LIST" >&1
				echo "Using results file frequency list as cross-freq list and test/cross file freqeuncy list as main output list." >&1
				CROSS_FREQ_LIST=( "${FREQ_LIST[@]}" )
			    	IFS="," read -a FREQ_LIST <<< "$USER_CROSS_FREQ_LIST"		
			fi
			;;
	esac
fi

#Machine learning method sanity checks
#-m number; -c number; -n number; -l list
if [[ -n $AUTO_SEARCH ]]; then
	#Number of events in model sanity checks
	echo -e "--------------------" >&1
	echo "Specified search algorithm:" >&1
	case $AUTO_SEARCH in
		1)
			echo "$AUTO_SEARCH -> Use bottom-up approach. Heuristically add events until we cannot improve model or we reach limit. -> $NUM_MODEL_EVENTS" >&1
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
	if [[ -n $EVENTS_LIST ]]; then
		echo -e "--------------------" >&1
		EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo -e "Using user specified list as initial model in search:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1		
	fi

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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1

<<<<<<< HEAD
<<<<<<< HEAD

#Trim constant events from events pool
if [[ -n $NUM_MODEL_EVENTS ]]; then
	echo -e "====================" >&1
	echo -e "--------------------" >&1
	echo -e "Removing constant events." >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
#Trim constant events from events pool
if [[ -n $AUTO_SEARCH ]]; then
	echo -e "====================" >&1
	echo -e "--------------------" >&1
	echo -e "Preparing data for automatic model generation." >&1
	echo -e "--------------------" >&1
	echo -e "Removing constant events from events pool." >&1
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "Current events used:" >&1
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	echo -e "--------------------" >&1
	spaced_POOL="${EVENTS_POOL//,/ }"
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list to collect results for
		echo -e "********************" >&1
<<<<<<< HEAD
<<<<<<< HEAD
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_TEMP 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
=======
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		echo "Checking event:" >&1
		echo -e "$EV_TEMP -> $EV_TEMP_LABEL" >&1
		unset -v data_count				
		if [[ -n $ALL_FREQUENCY ]]; then
			while [[ $data_count -ne 1 ]]
			do
				#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
				#Split data and collect output, then cleanup
				touch "train_set.data" "test_set.data"
<<<<<<< HEAD
<<<<<<< HEAD
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EV_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
				do
					touch "train_set.data" "test_set.data"
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EV_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )	
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string
			unset -v data_count
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					if [[ -n $CM_MODE ]]; then
						unset -v cross_data_count
						while [[ $cross_data_count -ne ${#CROSS_FREQ_LIST[@]} ]]
						do
							unset -v cross_octave_output
							for cross_count in $(seq 0 $((${#CROSS_FREQ_LIST[@]}-1)))
							do
								touch "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
								awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set_1.data"
								awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set_1.data"
								awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "train_set_2.data"
								awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set_2.data"
								cross_octave_output+=$(octave --silent --eval "load_build_model(3,'train_set_1.data','test_set_1.data',0,$((RESULT_EVENTS_COL_START-1)),'train_set_2.data','test_set_2.data',0,$((TEST_EVENTS_COL_START-1)),$POWER_COL,'$EV_TEMP')" 2> /dev/null)
								#Cleanup
								rm "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
							done
							cross_data_count=$(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
						done
						#When done checking if I have collected all frequencies add the full output to octave_output, by the end we should have ${#FREQ_LIST[@]} x ${#CROSS_FREQ_LIST[@]} fields and if any of the cross-freq models are inf then we abort
						octave_output+="$cross_octave_output"
					else
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
					fi
					
				done
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
				#If we have cross-model enabled then divide data_count by ${#CROSS_FREQ_LIST[@]} to see if we get all outer freq, we have already done an inner loop to get all the per-freq checks for the cross-core freqs				
				if [[ -n $CM_MODE ]]; then
					data_count=$(echo "$data_count/${#CROSS_FREQ_LIST[@]};" | bc )
				fi
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
<<<<<<< HEAD
<<<<<<< HEAD
		IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
		#Check for bad events
		if [[ " ${rel_avg_abs_err[@]} " =~ " Inf " ]]; then
			#If relative error contains infinity then event is bad for linear regression as is removed from list
			EVENTS_POOL=$(echo $EVENTS_POOL | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
			EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Check for bad events
		if [[ " ${rel_avg_abs_err[@]} " =~ " Inf " ]]; then
			#If relative error contains infinity then event is bad for linear regression as is removed from list
			EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
			EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
	EVENTS_POOL_SIZE=$(echo $EVENTS_POOL | tr "," "\n" | wc -l)
=======
	EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
	EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	if [[ $EVENTS_POOL_SIZE -lt $NUM_MODEL_EVENTS ]]; then
		echo "Overtrimmed events pool. Less events are available than specified: $EVENTS_POOL_SIZE < $NUM_MODEL_EVENTS." >&1
		echo "Program cannot continue. Please use more non-constant events in pool or specify a smaller number to be used in model." >&1
		exit
	fi
	#Print final events pool
	echo -e "--------------------" >&1
	echo -e "Final events to be used in automatic generation:" >&1
<<<<<<< HEAD
<<<<<<< HEAD
	EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
	EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
	EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
	echo -e "--------------------" >&1
	echo -e "====================" >&1
fi

<<<<<<< HEAD
<<<<<<< HEAD
#Automatic model generation.
#It will keep going as long as we have not saturated the model (no further events contribute) or we reach max number of model events as specified by user
#If we dont want automatic we just initialise NUM_MODEL_EVENTS to 0 and skip this loop. EZPZ
echo -e "Begin automatic model generation:" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30

#Automatic model generation.
#It will keep going as long as we have not saturated the model (no further events contribute) or we reach max number of model events as specified by user
#If we dont want automatic we just initialise NUM_MODEL_EVENTS to 0 and skip this loop. EZPZ
[[ -n $AUTO_SEARCH ]] && echo -e "Begin automatic model generation:" >&1
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30

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
<<<<<<< HEAD
<<<<<<< HEAD
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_TEMP 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_LIST_TEMP_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_LIST_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_LIST_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
				do
					touch "train_set.data" "test_set.data"
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )	
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string
			unset -v data_count	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
				for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
				do
					if [[ -n $CM_MODE ]]; then
						unset -v cross_data_count
						while [[ $cross_data_count -ne ${#CROSS_FREQ_LIST[@]} ]]
						do
							unset -v cross_octave_output
							for cross_count in $(seq 0 $((${#CROSS_FREQ_LIST[@]}-1)))
							do
								touch "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
								awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set_1.data"
								awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set_1.data"
								awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "train_set_2.data"
								awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set_2.data"
								cross_octave_output+=$(octave --silent --eval "load_build_model(3,'train_set_1.data','test_set_1.data',0,$((RESULT_EVENTS_COL_START-1)),'train_set_2.data','test_set_2.data',0,$((TEST_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
								#Cleanup
								rm "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
							done
							cross_data_count=$(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
						done
						#After collecting all cross freqeuncies analyse data and store in octave_output to ensure correct processing later on in script (so we don't have to break previous functionality)
						#Analyse collected results
						#Avg. Pred. Power
						IFS=";" read -a cross_avg_pred_pow <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)
						#Avg. Rel. Error
						IFS=";" read -a cross_rel_avg_abs_err <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
						#Avg Ev. Cross. Corr.
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_avg_ev_cross_corr <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
						#Max Ev. Cross. Corr.
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
						#Max Ev. Cross. Corr. EV1 
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr_ev1 <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
						#Max Ev. Cross. Corr. EV2
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr_ev2 <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)

						#Average and prepare outputs
						CROSS_MEAN_AVG_PRED_POW=$(getMean cross_avg_pred_pow ${#cross_avg_pred_pow[@]} )
						CROSS_MEAN_REL_AVG_ABS_ERR=$(getMean cross_rel_avg_abs_err ${#cross_rel_avg_abs_err[@]} )
						CROSS_REL_AVG_ABS_ERR_STD_DEV=$(getStdDev cross_rel_avg_abs_err ${#cross_rel_avg_abs_err[@]} )

						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MEAN_AVG_EV_CROSS_CORR=$(getMean cross_avg_ev_cross_corr ${#cross_avg_ev_cross_corr[@]} )
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MAX_EV_CROSS_CORR_IND=$(getMaxIndex cross_max_ev_cross_corr ${#cross_max_ev_cross_corr[@]} )
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MAX_EV_CROSS_CORR=${cross_max_ev_cross_corr[$CROSS_MAX_EV_CROSS_CORR_IND]}
						#Output processed event averages for each main core frequency
						octave_output+="###########################################################\n"
						octave_output+="Model validation against test set\n"
						octave_output+="###########################################################\n"
						octave_output+="Average Predicted Power [W]: $CROSS_MEAN_AVG_PRED_POW\n"
						octave_output+="###########################################################\n"
						octave_output+="Average Relative Error [%]: $CROSS_MEAN_REL_AVG_ABS_ERR\n"
						octave_output+="Relative Error Standart Deviation [%]: $CROSS_REL_AVG_ABS_ERR_STD_DEV\n"
						octave_output+="###########################################################\n"
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Average Event Cross-Correlation [%]: $CROSS_MEAN_AVG_EV_CROSS_CORR\n"
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Maximum Event Cross-Correlation [%]: $CROSS_MAX_EV_CROSS_CORR\n"
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Most Cross-Correlated Events: ${cross_max_ev_cross_corr_ev1[$CROSS_MAX_EV_CROSS_CORR_IND]} and ${cross_max_ev_cross_corr_ev2[$CROSS_MAX_EV_CROSS_CORR_IND]}\n"
						[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="###########################################################\n"
					else
						touch "train_set.data" "test_set.data"
						awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
						if [[ -n $TEST_FILE ]]; then
							awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
						else
							awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data"
						fi
						octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
						rm "train_set.data" "test_set.data"
					fi
				done
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
<<<<<<< HEAD
<<<<<<< HEAD
		IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a avg_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		#Get the means for both relative error and standart deviation and output
		#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
<<<<<<< HEAD
<<<<<<< HEAD
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		case $MODEL_TYPE in
		1)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
<<<<<<< HEAD
<<<<<<< HEAD
=======
		3)
			EVENTS_LIST_NEW=$MAX_EV_CROSS_CORR
			;;
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		3)
			EVENTS_LIST_NEW=$MAX_EV_CROSS_CORR
			;;
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
				[[ $(echo "$EVENTS_LIST_TEMP" | tr "," "\n" | wc -l) -ge 2 ]] && EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			else
				echo "Bad event (does not improve minimum temporary model)!" >&1
			fi
		else
			#If no event list temp error present this means its the first event to check. Just add it as a new minimum
<<<<<<< HEAD
<<<<<<< HEAD
			EVENTS_LIST_MIN=$EVENTS_LIST_NEW
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			EV_ADD=$EV_TEMP
			echo "Good event (first event in model)!" >&1
		fi
	done

=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "********************" >&1
	echo "All events checked!" >&1
	echo -e "********************" >&1
	#Once going through all events see if we can populate events list
	if [[ -n $EV_ADD ]]; then
		#We found an new event to add to list
		[[ -n $EVENTS_LIST ]] && EVENTS_LIST="$EVENTS_LIST,$EV_ADD" || EVENTS_LIST="$EV_ADD"
<<<<<<< HEAD
<<<<<<< HEAD
		EV_ADD_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_ADD 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		EVENTS_POOL=$(echo $EVENTS_POOL | sed "s/^$EV_ADD,//g;s/,$EV_ADD,/,/g;s/,$EV_ADD$//g;s/^$EV_ADD$//g")
		EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		EV_ADD_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_ADD" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_ADD,//g;s/,$EV_ADD,/,/g;s/,$EV_ADD$//g;s/^$EV_ADD$//g")
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
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
		EVENTS_LIST_SIZE=$(echo $EVENTS_LIST | tr "," "\n" | wc -l)
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "New model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS"
		if [[ $NUM_MODEL_EVENTS -eq 1 ]]; then
			echo -e "********************" >&1
			echo "Reached specified number of model events." >&1
			
		else
			echo -e "********************" >&1
			if [[ $EVENTS_POOL !=  "\n" ]]; then
				echo "New events pool:" >&1
				echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
			else
				echo "New events pool -> (empty). Exhausted all events in pool." >&1
			fi
		fi
		#reset EV_ADD too see if we can find another one and decrement counter
		unset -v EV_ADD
		((NUM_MODEL_EVENTS--))
		echo -e "********************" >&1
	else
		EVENTS_LIST_SIZE=$(echo "$EVENTS_LIST" | tr "," "\n" | wc -l)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		#We did not find a new event to add to list. Just output and break loop (list saturated)		
		echo -e "--------------------" >&1
		echo "No new improving event found. Events list minimised at $EVENTS_LIST_SIZE events." >&1
		echo -e "--------------------" >&1
		echo -e "====================" >&1
		echo -e "Optimal events list found:" >&1
		echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
<<<<<<< HEAD
<<<<<<< HEAD
		echo -e "Events list mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Events list mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		echo -e "Mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo -e "Model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS"
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		echo -e "Using final list in full model analysis." >&1
		echo -e "====================" >&1
		break
	fi
done

#Top-down approach
<<<<<<< HEAD
<<<<<<< HEAD
while [[ $(echo $EVENTS_POOL | tr "," "\n" | wc -l) -gt $NUM_MODEL_EVENTS && $AUTO_SEARCH == 2 ]]
=======
while [[ $(echo "$EVENTS_POOL" | tr "," "\n" | wc -l) -gt $NUM_MODEL_EVENTS && $AUTO_SEARCH == 2 ]]
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
while [[ $(echo "$EVENTS_POOL" | tr "," "\n" | wc -l) -gt $NUM_MODEL_EVENTS && $AUTO_SEARCH == 2 ]]
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL')" 2> /dev/null)
			rm "train_set.data" "test_set.data"
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
			if [[ -n $TEST_FILE ]]; then
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
			else
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
			fi	
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL')" 2> /dev/null)
			rm "train_set.data" "test_set.data"
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		done
	else	
		while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
		do
			unset -v octave_output				
<<<<<<< HEAD
<<<<<<< HEAD
			for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
			do
				touch "train_set.data" "test_set.data"
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
				octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
			done
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
		done	
	fi
	IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
	IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
	EVENTS_POOL_MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
	EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
	echo "Mean model relative error -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR" >&1
	echo "Mean model relative error stdandart deviation -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
		done	
	fi
	#Analyse collected results
	#Avg. Rel. Error
	IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Rel. Err. Std. Dev
	IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
	#Avg Ev. Cross. Corr.
	IFS=";" read -a avg_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr.
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr. EV1 
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr_ev1 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
	#Max Ev. Cross. Corr. EV2
	IFS=";" read -a EVENTS_POOL_MAX_ev_cross_corr_ev2 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	case $MODEL_TYPE in
	1)
		EVENTS_POOL_MIN=$EVENTS_POOL_MEAN_REL_AVG_ABS_ERR
		;;
	2)
		EVENTS_POOL_MIN=$EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV
		;;
<<<<<<< HEAD
<<<<<<< HEAD
	esac

=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	3)
		EVENTS_POOL_MIN=$EVENTS_POOL_MAX_EV_CROSS_CORR
		;;
	esac
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	#Start top-down by spacing the pool and iterating the events
	spaced_POOL="${EVENTS_POOL//,/ }"
	for EV_TEMP in $spaced_POOL
	do
		#Initiate temp event list
		#Trim the event which has the highest error
<<<<<<< HEAD
<<<<<<< HEAD
		EVENTS_POOL_TEMP=$(echo $EVENTS_POOL | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_TEMP 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_POOL_TEMP_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
		EVENTS_POOL_TEMP=$(echo "$EVENTS_POOL" | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		EVENTS_POOL_TEMP=$(echo "$EVENTS_POOL" | sed "s/^$EV_TEMP,//g;s/,$EV_TEMP,/,/g;s/,$EV_TEMP$//g;s/^$EV_TEMP$//g")
		EV_TEMP_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_TEMP" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			done
		else	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
<<<<<<< HEAD
<<<<<<< HEAD
				for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
				do
					touch "train_set.data" "test_set.data"
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_POOL_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			done	
		fi
		IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
		IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		IFS=";" read -a avg_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		IFS=";" read -a max_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		case $MODEL_TYPE in
		1)
			EVENTS_POOL_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_POOL_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
<<<<<<< HEAD
<<<<<<< HEAD
=======
		3)
			EVENTS_POOL_NEW=$MAX_EV_CROSS_CORR
			;;
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		3)
			EVENTS_POOL_NEW=$MAX_EV_CROSS_CORR
			;;
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		esac
		if [[ $(echo "$EVENTS_POOL_NEW < $EVENTS_POOL_MIN" | bc -l) -eq 1 ]]; then
			#Update events list error and EV
			echo "Removing causes best improvement to temporary model! Using as new minimum!"
			EV_REMOVE=$EV_TEMP
			EVENTS_POOL_MIN=$EVENTS_POOL_NEW
			EVENTS_POOL_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
			EVENTS_POOL_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
			EVENTS_POOL_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
			EVENTS_POOL_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
			EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
		EVENTS_POOL=$(echo $EVENTS_POOL | sed "s/^$EV_REMOVE,//g;s/,$EV_REMOVE,/,/g;s/,$EV_REMOVE$//g;s/^$EV_REMOVE$//g")
		EV_REMOVE_LABEL=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COL=$EV_REMOVE 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < $RESULTS_FILE)
		EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
		EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_REMOVE,//g;s/,$EV_REMOVE,/,/g;s/,$EV_REMOVE$//g;s/^$EV_REMOVE$//g")
		EV_REMOVE_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_REMOVE" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		EVENTS_POOL=$(echo "$EVENTS_POOL" | sed "s/^$EV_REMOVE,//g;s/,$EV_REMOVE,/,/g;s/,$EV_REMOVE$//g;s/^$EV_REMOVE$//g")
		EV_REMOVE_LABEL=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COL="$EV_REMOVE" 'BEGIN{FS=SEP}{if(NR==START){ print $COL; exit } }' < "$RESULT_FILE")
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		#Remove from events pool
		echo -e "--------------------" >&1
		echo -e "********************" >&1
		echo "Remove worst event from events list:"
		echo "$EV_REMOVE -> $EV_REMOVE_LABEL" >&1
		echo -e "********************" >&1
		#reset EV_REMOVE too see if we can find another one and decrement counter
		unset -v EV_REMOVE
	else
<<<<<<< HEAD
<<<<<<< HEAD
		EVENTS_POOL_SIZE=$(echo $EVENTS_POOL | tr "," "\n" | wc -l)
		EVENTS_POOL_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
=======
		EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		EVENTS_POOL_SIZE=$(echo "$EVENTS_POOL" | tr "," "\n" | wc -l)
		EVENTS_POOL_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_POOL" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		#We did not find a new event to remove from list. Just output and break loop (list saturated)		
		echo -e "--------------------" >&1
		echo "No new improving event found. Events list minimised at $EVENTS_POOL_SIZE events." >&1
		echo -e "--------------------" >&1
		echo -e "====================" >&1
		echo -e "Optimal events list found:" >&1
		echo "$EVENTS_POOL -> $EVENTS_POOL_LABELS" >&1
<<<<<<< HEAD
<<<<<<< HEAD
		echo -e "Events list mean model relative error -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Events list mean model relative error stdandart deviation -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo -e "Using final list in full model analysis." >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		echo -e "Mean model relative error -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR" >&1
		echo -e "Mean model relative error stdandart deviation -> $EVENTS_POOL_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
		echo -e "Mean model average event cross-correlation -> $EVENTS_POOL_MEAN_AVG_EV_CROSS_CORR" >&1
		echo -e "Mean model max event cross-correlation -> $EVENTS_POOL_MEAN_MAX_EV_CROSS_CORR" >&1
		echo -e "Model max event cross-correlation $EVENTS_POOL_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_POOL_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_POOL_MAX_EV_CROSS_CORR_EV_LABELS"
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
		IFS=";" read -a EVENTS_LIST_COMBINATIONS <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{ print $0 }' ) | tr "\n" ";" | head -c -1)
	done
	echo "Total number of combinations -> ${#EVENTS_LIST_COMBINATIONS[@]}" >&1
	echo -e "--------------------" >&1
	for i in `seq 0 $((${#EVENTS_LIST_COMBINATIONS[@]}-1))`
	do
		EVENTS_LIST_TEMP=$(echo ${EVENTS_LIST_COMBINATIONS[$i]} | tr " " ",")
		EVENTS_LIST_TEMP_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
		echo -e "********************" >&1
		echo "Checking combination events list number -> $(($i+1)):"
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		IFS=";" read -a EVENTS_LIST_COMBINATIONS <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{ print $0 }' | tr "\n" ";" | head -c -1)
	done
	echo "Total number of combinations -> ${#EVENTS_LIST_COMBINATIONS[@]}" >&1
	echo -e "--------------------" >&1
	for i in $(seq 0 $((${#EVENTS_LIST_COMBINATIONS[@]}-1)))
	do
		EVENTS_LIST_TEMP=$(echo "${EVENTS_LIST_COMBINATIONS[$i]}" | tr " " ",")
		EVENTS_LIST_TEMP_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST_TEMP" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
		echo -e "********************" >&1
		echo "Checking combination events list number -> $((i+1)):"
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data" 	
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
				if [[ -n $TEST_FILE ]]; then
					awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
				else
					awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
				fi
				octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
				rm "train_set.data" "test_set.data"
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			done
		else
			#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
			#Then pass onto octave and store results in a concatenating string	
			while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
			do
				unset -v octave_output				
<<<<<<< HEAD
<<<<<<< HEAD
				for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
				do
					touch "train_set.data" "test_set.data"
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
					awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
					octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST_TEMP')" 2> /dev/null)
					rm "train_set.data" "test_set.data"
				done
				data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			done	
		fi
		#Analyse collected results
		#Avg. Rel. Error
<<<<<<< HEAD
<<<<<<< HEAD
		IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Rel. Err. Std. Dev
		IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
		#Avg Ev. Cross. Corr.
		IFS=";" read -a avg_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr.
		IFS=";" read -a max_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV1 
		IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
		#Max Ev. Cross. Corr. EV2
		IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		#Get the means for both relative error and standart deviation and output
		#Depending oon type though we use a different value for EVENTS_LIST_NEW to try and minmise
		MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
		MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
<<<<<<< HEAD
<<<<<<< HEAD
		echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
		echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		case $MODEL_TYPE in
		1)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR
			;;
		2)
			EVENTS_LIST_NEW=$MEAN_REL_AVG_ABS_ERR_STD_DEV
			;;
<<<<<<< HEAD
<<<<<<< HEAD
		esac
		if [[ -n $EVENTS_LIST ]]; then
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		3)
			EVENTS_LIST_NEW=$MAX_EV_CROSS_CORR
			;;
		esac
		if [[ -n $EVENTS_LIST_MIN ]]; then
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			#If events list exits then compare new value and if smaller then store else just move along the events list 
			if [[ $(echo "$EVENTS_LIST_NEW < $EVENTS_LIST_MIN" | bc -l) -eq 1 ]]; then
				#Update events list error and EV
				echo "Good list (improves minimum temporary model)! Using as new minimum!"
				EVENTS_LIST_MIN=$EVENTS_LIST_NEW
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
				EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
				EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
				EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
				EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
				EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				EVENTS_LIST=$EVENTS_LIST_TEMP
			else
				echo "Bad list (does not improve minimum temporary model)!" >&1
			fi
		else
			#If no event list temp error present this means its the first event to check. Just add it as a new minimum
			EVENTS_LIST_MIN=$EVENTS_LIST_NEW
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR=$MEAN_REL_AVG_ABS_ERR
			EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV=$MEAN_REL_AVG_ABS_ERR_STD_DEV
<<<<<<< HEAD
<<<<<<< HEAD
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR=$MEAN_AVG_EV_CROSS_CORR
			EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR=$MEAN_MAX_EV_CROSS_CORR
			EVENTS_LIST_MAX_EV_CROSS_CORR_IND=$MAX_EV_CROSS_CORR_IND
			EVENTS_LIST_MAX_EV_CROSS_CORR=$MAX_EV_CROSS_CORR
			EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS=$MAX_EV_CROSS_CORR_EV_LABELS
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			EVENTS_LIST=$EVENTS_LIST_TEMP
			echo "Good list (first list checked)!" >&1
		fi
	done

	echo -e "********************" >&1
	echo "All combinations checked!" >&1
	echo -e "********************" >&1
	echo -e "====================" >&1
	echo -e "Optimal events list found:" >&1
<<<<<<< HEAD
<<<<<<< HEAD
	EVENTS_LIST_LABELS=$((awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < $RESULTS_FILE) | tr "\n" "," | head -c -1)
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
	echo -e "Events list mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
	echo -e "Events list mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "$EVENTS_LIST -> $EVENTS_LIST_LABELS" >&1
	echo -e "Mean model relative error -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR" >&1
	echo -e "Mean model relative error stdandart deviation -> $EVENTS_LIST_MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
	echo -e "Mean model average event cross-correlation -> $EVENTS_LIST_MEAN_AVG_EV_CROSS_CORR" >&1
	echo -e "Mean model max event cross-correlation -> $EVENTS_LIST_MEAN_MAX_EV_CROSS_CORR" >&1
	echo -e "Model max event cross-correlation $EVENTS_LIST_MAX_EV_CROSS_CORR is at ${FREQ_LIST[$EVENTS_LIST_MAX_EV_CROSS_CORR_IND]} MHz between $EVENTS_LIST_MAX_EV_CROSS_CORR_EV_LABELS" >&1
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "Using final list in full model analysis." >&1
	echo -e "====================" >&1
fi

#Update the events list if used top-down automatic search
if [[ $AUTO_SEARCH == 2 ]]; then
	EVENTS_LIST=$EVENTS_POOL
<<<<<<< HEAD
<<<<<<< HEAD
	EVENTS_LIST_LABELS=$EVENTS_POOL_LABELS
fi

echo -e "====================" >&1
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
fi

echo -e "====================" >&1
EVENTS_LIST_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
		if [[ $MODE == 1 || $MODE == 4 || $MODE == 5 ]]; then
=======
		if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
		if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			#If we are collecting platform physical characteristics
			#We need to average runtime per run
			#Extract runtime per run (converted to seconds) and add to total.
			total_runtime=0
<<<<<<< HEAD
<<<<<<< HEAD
			for runnum in `seq $BENCH_RUNS_START 1 $BENCH_RUNS_END`
			do
				for benchname in `seq 0 $((${#TEST_SET[@]}-1))`
				do
					runtime_st=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v RUNCOL=$(($EVENTS_COL_START-1)) -v RUN=$runnum -v BENCHCOL=$(($EVENTS_COL_START-2)) -v BENCH=${TEST_SET[$benchname]} 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print $1;exit}}' < $RESULTS_FILE)
					#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
					runtime_nd_nr=$(tac $RESULTS_FILE | awk -v START=1 -v SEP='\t' -v RUNCOL=$(($EVENTS_COL_START-1)) -v RUN=$runnum -v BENCHCOL=$(($EVENTS_COL_START-2)) -v BENCH=${TEST_SET[$benchname]} 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH){print NR;exit}}' < $RESULTS_FILE)
					#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
					if [[ $runtime_nd_nr == 1 ]];then
						runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
					fi
					runtime_nd=$(tac $RESULTS_FILE | awk -v START=$(($runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
					total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
				done
			done
			#Compute average full freq runtime
			avg_total_runtime=$(echo "scale=0;$total_runtime/(($BENCH_RUNS_END-$BENCH_RUNS_START+1)*$TIME_CONVERT);" | bc )
			
			#Collect physical information for test set
			touch "test_set.data"
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
			octave_output=$(octave --silent --eval "load_build_model(1,'test_set.data',1,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
			rm "test_set.data"

			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
			rm "test_set.data"
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
			
		else
			#If we are collecting model performance
			#If all freqeuncy model then use all freqeuncies in octave, as in use the fully populated train and test set files
<<<<<<< HEAD
			#Split data and collect output, then cleanup 	
			#Split input into train and test set
			touch "train_set.data" "test_set.data"
<<<<<<< HEAD
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
			awk -v START=$RESULTS_START_LINE -v SEP='\t' -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
			#Collect octave output this depends on program mode
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
=======
			awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set.data"
			if [[ -n $TEST_FILE ]]; then
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set.data"
			else
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set.data" 	
			fi
			#Collect octave output this depends on program mode
			octave_output=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$((RESULT_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
			#Cleanup
			rm "train_set.data" "test_set.data"
=======
			if [[ -n $CM_MODE ]]; then
				#if cross model then procede to split into two train and two test files
				#Split data and collect output, then cleanup 	
				#Split input into train and test set
				touch "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set_1.data"
				awk -v START="$RESULT_START_LINE" -v SEP='\t' -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set_1.data"
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "train_set_2.data"
				awk -v START="$TEST_START_LINE" -v SEP='\t' -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set_2.data"

				#Collect octave output this depends on program mode
				octave_output=$(octave --silent --eval "load_build_model(3,'train_set_1.data','test_set_1.data',0,$((RESULT_EVENTS_COL_START-1)),'train_set_2.data','test_set_2.data',0,$((TEST_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
				#There is no standart deviation sicne the error is only 1 number so just add N/A
				octave_output+="\nRelative Error Standart Deviation [%]: null\n"
				octave_output+="###########################################################\n"
				echo $octave_output
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
				#Cleanup
				rm "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
			else
				#if no cross model then procede standart
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
				data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
				#Cleanup
				rm "train_set.data" "test_set.data"
			fi
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		fi	
	done
else
	#If per-frequency models, split benchmarks for each freqeuncy (with cleanup so we get fresh split every frequency)
<<<<<<< HEAD
<<<<<<< HEAD
	#Then pass onto octave and store results in a concatenating string	
	while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
	do
		unset -v octave_output				
		for count in `seq 0 $((${#FREQ_LIST[@]}-1))`
		do
			#Collect runtime information depending on the mode
			if [[ $MODE == 1 || $MODE == 4 || $MODE == 5 ]]; then
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	#Then pass onto octave and store results in a concatenating string
	unset -v data_count	
	while [[ $data_count -ne ${#FREQ_LIST[@]} ]]
	do
		unset -v octave_output				
		for count in $(seq 0 $((${#FREQ_LIST[@]}-1)))
		do
			#Collect runtime information depending on the mode
			if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
				#If we are collecting platform physical characteristics
				#We need to average runtime per run
				#Extract runtime per run (converted to seconds) and add to total for the frequency.
				total_runtime=0
<<<<<<< HEAD
<<<<<<< HEAD
				for runnum in `seq $BENCH_RUNS_START 1 $BENCH_RUNS_END`
				do
					for benchcount in `seq 0 $((${#TEST_SET[@]}-1))`
					do
						runtime_st=$(awk -v START=$RESULTS_START_LINE -v SEP='\t' -v RUNCOL=$(($EVENTS_COL_START-1)) -v RUN=$runnum -v BENCHCOL=$(($EVENTS_COL_START-2)) -v BENCH=${TEST_SET[$benchcount]} -v FREQCOL=$EVENTS_COL_START -v FREQ=${FREQ_LIST[$count]} 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print $1;exit}}' < $RESULTS_FILE)
						#Use previous line timestamp (so this is reverse which means the next sensor reading) as final timestamp
						runtime_nd_nr=$(tac $RESULTS_FILE | awk -v START=1 -v SEP='\t' -v RUNCOL=$(($EVENTS_COL_START-1)) -v RUN=$runnum -v BENCHCOL=$(($EVENTS_COL_START-2)) -v BENCH=${TEST_SET[$benchcount]} -v FREQCOL=$EVENTS_COL_START -v FREQ=${FREQ_LIST[$count]} 'BEGIN{FS = SEP}{if (NR >= START && $RUNCOL == RUN && $BENCHCOL == BENCH && $FREQCOL == FREQ){print NR;exit}}')
						#If we are at the last (first in reverse) line, then increment to avoid going out of bounds when decrementing the line for the runtime_nd extraction
						if [[ $runtime_nd_nr == 1 ]];then
							runtime_nd_nr=$(echo "$runtime_nd_nr+1;" | bc )
						fi
						runtime_nd=$(tac $RESULTS_FILE | awk -v START=$(($runtime_nd_nr-1)) -v SEP='\t' 'BEGIN{FS = SEP}{if (NR == START){print $1;exit}}')
						total_runtime=$(echo "scale=0;$total_runtime+($runtime_nd-$runtime_st);" | bc )
					done
				done
				#Compute average per-freq runtime
				avg_total_runtime[$count]=$(echo "scale=0;$total_runtime/(($BENCH_RUNS_END-$BENCH_RUNS_START+1)*$TIME_CONVERT);" | bc )
				
#Collect output for the frequency. Extract freqeuncy level from full set and pass it into octave
				touch "test_set.data"
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
				octave_output+=$(octave --silent --eval "load_build_model(1,'test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
				#Cleanup
				rm "test_set.data"
			else
				#Collecting model characteristics
				#Split full set into training and data
				touch "train_set.data" "test_set.data"
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "train_set.data" 
				awk -v START=$RESULTS_START_LINE -v SEP='\t' -v FREQ=${FREQ_LIST[$count]} -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $4 == FREQ){for (i = 1; i <= len; i++){if ($2 == ARRAY[i]){print $0;next}}}}' $RESULTS_FILE > "test_set.data"
				octave_output+=$(octave --silent --eval "load_build_model(2,'train_set.data','test_set.data',0,$(($EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
				#Cleanup
				rm "train_set.data" "test_set.data"
			fi
		done
		#Collect data count depending on mode to ensure we got the right data. Octave sometimes hangs so this is necessary to overcome "skipping" frequencies
		if [[ $MODE == 1 || $MODE == 4 || $MODE == 5 ]]; then
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
		else
			data_count=$(echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
				#Collecting model data
				if [[ -n $CM_MODE ]]; then
					#If cross model we need to average the cross-models since its many-to-many mapping
					unset -v cross_data_count
					while [[ $cross_data_count -ne ${#CROSS_FREQ_LIST[@]} ]]
					do
						unset -v cross_octave_output
						for cross_count in $(seq 0 $((${#CROSS_FREQ_LIST[@]}-1)))
						do
							touch "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
							awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "train_set_1.data"
							awk -v START="$RESULT_START_LINE" -v SEP='\t' -v FREQ_COL="$RESULT_FREQ_COL" -v FREQ="${CROSS_FREQ_LIST[$cross_count]}" -v BENCH_COL="$RESULT_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$RESULT_FILE" > "test_set_1.data"
							awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TRAIN_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "train_set_2.data"
							awk -v START="$TEST_START_LINE" -v SEP='\t' -v FREQ_COL="$TEST_FREQ_COL" -v FREQ="${FREQ_LIST[$count]}" -v BENCH_COL="$TEST_BENCH_COL" -v BENCH_SET="${TEST_SET[*]}" 'BEGIN{FS = SEP;len=split(BENCH_SET,ARRAY," ")}{if (NR >= START && $FREQ_COL == FREQ){for (i = 1; i <= len; i++){if ($BENCH_COL == ARRAY[i]){print $0;next}}}}' < "$TEST_FILE" > "test_set_2.data"
							cross_octave_output+=$(octave --silent --eval "load_build_model(3,'train_set_1.data','test_set_1.data',0,$((RESULT_EVENTS_COL_START-1)),'train_set_2.data','test_set_2.data',0,$((TEST_EVENTS_COL_START-1)),$POWER_COL,'$EVENTS_LIST')" 2> /dev/null)
							#Cleanup
							rm "train_set_1.data" "test_set_1.data" "train_set_2.data" "test_set_2.data"
						done
						cross_data_count=$(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power" ){ count++ }}END{print count}' )
					done
					#After collecting all cross freqeuncies analyse data and store in octave_output to ensure correct processing later on in script (so we don't have to break previous functionality)
					#Analyse collected results
					#Avg. Pred. Power
					IFS=";" read -a cross_avg_pred_pow <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Pred. Power Range
					IFS=";" read -a cross_pred_pow_range <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Avg. Abs. Error
					IFS=";" read -a cross_avg_abs_err <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Avg. Rel. Error
					IFS=";" read -a cross_rel_avg_abs_err <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Avg Ev. Cross. Corr.
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_avg_ev_cross_corr <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Max Ev. Cross. Corr.
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
					#Max Ev. Cross. Corr. EV1 
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr_ev1 <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
					#Max Ev. Cross. Corr. EV2
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a cross_max_ev_cross_corr_ev2 <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
					#Model coefficients
					IFS=";" read -a cross_model_coeff <<< $(echo -e "$cross_octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="Coefficients:"){ print substr($0, index($0,$3)) }}' | tr "\n" ";" | head -c -1)

					#Average and prepare outputs
					CROSS_MEAN_AVG_PRED_POW=$(getMean cross_avg_pred_pow ${#cross_avg_pred_pow[@]} )
					CROSS_MEAN_PRED_POW_RANGE=$(getMean cross_pred_pow_range ${#cross_pred_pow_range[@]} )
					CROSS_MEAN_AVG_ABS_ERR=$(getMean cross_avg_abs_err ${#cross_avg_abs_err[@]} )					
					CROSS_AVG_ABS_ERR_STD_DEV=$(getStdDev cross_avg_abs_err ${#cross_avg_abs_err[@]} )
					CROSS_MEAN_REL_AVG_ABS_ERR=$(getMean cross_rel_avg_abs_err ${#cross_rel_avg_abs_err[@]} )
					CROSS_REL_AVG_ABS_ERR_STD_DEV=$(getStdDev cross_rel_avg_abs_err ${#cross_rel_avg_abs_err[@]} )

					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MEAN_AVG_EV_CROSS_CORR=$(getMean cross_avg_ev_cross_corr ${#cross_avg_ev_cross_corr[@]} )
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MAX_EV_CROSS_CORR_IND=$(getMaxIndex cross_max_ev_cross_corr ${#cross_max_ev_cross_corr[@]} )
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && CROSS_MAX_EV_CROSS_CORR=${cross_max_ev_cross_corr[$CROSS_MAX_EV_CROSS_CORR_IND]}
					#Output processed event averages for each main core frequency
					octave_output+="###########################################################\n"
					octave_output+="Model validation against test set\n"
					octave_output+="###########################################################\n"
					octave_output+="Average Predicted Power [W]: $CROSS_MEAN_AVG_PRED_POW\n"
					octave_output+="Predicted Power Range [%]: $CROSS_MEAN_PRED_POW_RANGE\n"
					octave_output+="###########################################################\n"
					octave_output+="Average Absolute Error [W]: $CROSS_MEAN_AVG_ABS_ERR\n"
					octave_output+="Absolute Error Standart Deviation [W]: $CROSS_AVG_ABS_ERR_STD_DEV\n"
					octave_output+="###########################################################\n"
					octave_output+="Average Relative Error [%]: $CROSS_MEAN_REL_AVG_ABS_ERR\n"
					octave_output+="Relative Error Standart Deviation [%]: $CROSS_REL_AVG_ABS_ERR_STD_DEV\n"
					octave_output+="###########################################################\n"
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Average Event Cross-Correlation [%]: $CROSS_MEAN_AVG_EV_CROSS_CORR\n"
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Maximum Event Cross-Correlation [%]: $CROSS_MAX_EV_CROSS_CORR\n"
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="Most Cross-Correlated Events: ${cross_max_ev_cross_corr_ev1[$CROSS_MAX_EV_CROSS_CORR_IND]} and ${cross_max_ev_cross_corr_ev2[$CROSS_MAX_EV_CROSS_CORR_IND]}\n"
					[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && octave_output+="###########################################################\n"
					octave_output+="Model Coefficients: ${cross_model_coeff[0]}\n"
					octave_output+="###########################################################\n"
				else
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
			fi
		done
		#Collect data count depending on mode to ensure we got the right data. Octave sometimes hangs so this is necessary to overcome "skipping" frequencies
		if [[ $OUTPUT_MODE == 1 || $OUTPUT_MODE == 4 || $OUTPUT_MODE == 5 ]]; then
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Power"){ count++ }}END{print count}' )
		else
			data_count=$(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP;count=0}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ count++ }}END{print count}' )
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		fi
	done	
fi

#Extract relevant informaton from octave. Some of these will be empty depending on mode
#Physical information
#Avg. Power
<<<<<<< HEAD
<<<<<<< HEAD
IFS=";" read -a avg_pow <<< $((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Power"){ print $4 }}' ) | tr "\n" ";" | head -c -1)
#Measured Power Range
IFS=";" read -a pow_range <<< $((echo "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_totals <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="totals:"){ print substr($0, index($0,$5)) }}' ) | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_averages <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="averages:"){ print substr($0, index($0,$5)) }}' ) | tr "\n" ";" | head -c -1)

#Model information
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Avg. Abs. Error
IFS=";" read -a avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Abs. Err. Std. Dev.
IFS=";" read -a std_dev_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Absolute" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
#Avg. Rel. Error
IFS=";" read -a rel_avg_abs_err <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' ) | tr "\n" ";" | head -c -1)
#Rel. Err. Std. Dev
IFS=";" read -a rel_avg_abs_err_std_dev <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' ) | tr "\n" ";" | head -c -1)
#Model coefficients
IFS=";" read -a model_coeff <<< $((echo "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="coefficients:"){ print substr($0, index($0,$3)) }}' ) | tr "\n" ";" | head -c -1)

#Modify freqeuncy list first element to list "all"
[[ -n $ALL_FREQUENCY ]] && FREQ_LIST[0]=$(echo "all")

#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $MODE in
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
IFS=";" read -a avg_pow <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Power"){ print $4 }}' | tr "\n" ";" | head -c -1)
#Measured Power Range
IFS=";" read -a pow_range <<< $(echo -e "$octave_output" |awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Measured" && $2=="Power" && $3=="Range"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_totals <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="totals:"){ print substr($0, index($0,$5)) }}' | tr "\n" ";" | head -c -1)
#Event totals
IFS=";" read -a event_averages <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($3=="event" && $4=="averages:"){ print substr($0, index($0,$5)) }}' | tr "\n" ";" | head -c -1)

#Model information
#Average Pred. Power
IFS=";" read -a avg_pred_pow <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Predicted" && $3=="Power"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Pred. Power Range
IFS=";" read -a pred_pow_range <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Predicted" && $2=="Power" && $3=="Range"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Avg. Abs. Error
IFS=";" read -a avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Absolute" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Abs. Err. Std. Dev.
IFS=";" read -a std_dev_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Absolute" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Avg. Rel. Error
IFS=";" read -a rel_avg_abs_err <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Relative" && $3=="Error"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Rel. Err. Std. Dev
IFS=";" read -a rel_avg_abs_err_std_dev <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Relative" && $2=="Error" && $3=="Standart" && $4=="Deviation"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Avg Ev. Cross. Corr.
[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a avg_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Average" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr.
[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Maximum" && $2=="Event" && $3=="Cross-Correlation"){ print $5 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr. EV1 
[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev1 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:"){ print $4 }}' | tr "\n" ";" | head -c -1)
#Max Ev. Cross. Corr. EV2
[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && IFS=";" read -a max_ev_cross_corr_ev2 <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Most" && $2=="Cross-Correlated" && $3=="Events:" && $5=="and"){ print $6 }}' | tr "\n" ";" | head -c -1)
#Model coefficients
IFS=";" read -a model_coeff <<< $(echo -e "$octave_output" | awk -v SEP=' ' 'BEGIN{FS=SEP}{if ($1=="Model" && $2=="Coefficients:"){ print substr($0, index($0,$3)) }}' | tr "\n" ";" | head -c -1)

#Modify freqeuncy list first element to list "all"
[[ -n $ALL_FREQUENCY ]] && FREQ_LIST[0]="all"

#Adjust output depending on mode  	
#I store the varaible references as special characters in the DATA string then eval to evoke subsittution. Eliminates repetitive code.
case $OUTPUT_MODE in
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	1)
		HEADER="CPU Frequency\tTotal Runtime [s]\tAverage Power [W]\tMeasured Power Range [%]"
		DATA="\${FREQ_LIST[\$i]}\t\${avg_total_runtime[\$i]}\t\${avg_pow[\$i]}\t\${pow_range[\$i]}"
		;;
	2)
<<<<<<< HEAD
<<<<<<< HEAD
		HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]\tModel coefficients"
		DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${model_coeff[\$i]}"
		;;
	3)
		HEADER="Average Relative Error [%]\tRelative Error Standart Deviation [%]"
		DATA="\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}"
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]\tAverage Event Cross-Correlation [%]\tMax Event Cross-Correlation [%]\tModel coefficients" || HEADER="Average Predicted Power [W]\tPredicted Power Range [%]\tAverage Absolute Error [W]\tAbsolute Error Stdandart Deviation [W]\tAverage Relative Error [%]\tRelative Error Standart Deviation [%]\tModel coefficients"
		[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${avg_ev_cross_corr[\$i]}\t\${max_ev_cross_corr[\$i]}\t\${model_coeff[\$i]}" || DATA="\${avg_pred_pow[\$i]}\t\${pred_pow_range[\$i]}\t\${avg_abs_err[\$i]}\t\${std_dev_err[\$i]}\t\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${model_coeff[\$i]}"
		;;
	3)
		HEADER="Average Relative Error [%]\tRelative Error Standart Deviation [%]\tAverage Event Cross-Correlation [%]\tMax Event Cross-Correlation [%]"
		DATA="\${rel_avg_abs_err[\$i]}\t\${rel_avg_abs_err_std_dev[\$i]}\t\${avg_ev_cross_corr[\$i]}\t\${max_ev_cross_corr[\$i]}"
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
<<<<<<< HEAD
	echo -e $HEADER
	echo -e "--------------------" >&1
else
	echo -e $HEADER > $SAVE_FILE
fi
for i in `seq 0 $((${#FREQ_LIST[@]}-1))`
do
	if [[ -z $SAVE_FILE ]]; then 
		echo -e $(eval echo `echo -e "$DATA"`) | tr " " "\t"
	else
		echo -e $(eval echo `echo -e "$DATA"`) | tr " " "\t" >> $SAVE_FILE
=======
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
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
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	fi
	#If all freqeuncy model, there is just one line that needs to be printed
	[[ -n $ALL_FREQUENCY ]] && break;
done

#Print model summary if in mode
<<<<<<< HEAD
<<<<<<< HEAD
if [[ $MODE == 2 || $MODE == 3 ]]; then 
	echo -e "--------------------" >&1
	MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
	MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
	echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
	echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
=======
if [[ $OUTPUT_MODE == 2 || $OUTPUT_MODE == 3 ]]; then 
=======
if [[ $OUTPUT_MODE == 2 || $OUTPUT_MODE == 3  ]]; then
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "--------------------" >&1
	MEAN_REL_AVG_ABS_ERR=$(getMean rel_avg_abs_err ${#rel_avg_abs_err[@]} )
	MEAN_REL_AVG_ABS_ERR_STD_DEV=$(getMean rel_avg_abs_err_std_dev ${#rel_avg_abs_err_std_dev[@]} )
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && MEAN_AVG_EV_CROSS_CORR=$(getMean avg_ev_cross_corr ${#avg_ev_cross_corr[@]} )
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && MEAN_MAX_EV_CROSS_CORR=$(getMean max_ev_cross_corr ${#max_ev_cross_corr[@]} )
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && MAX_EV_CROSS_CORR_IND=$(getMaxIndex max_ev_cross_corr ${#max_ev_cross_corr[@]} )
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && [[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && MAX_EV_CROSS_CORR_EV_LABELS=$(awk -v SEP='\t' -v START=$((RESULT_START_LINE-1)) -v COLUMNS="${max_ev_cross_corr_ev1[$MAX_EV_CROSS_CORR_IND]},${max_ev_cross_corr_ev2[$MAX_EV_CROSS_CORR_IND]}" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULT_FILE" | tr "\n" "," | head -c -1)
	echo "Mean model relative error -> $MEAN_REL_AVG_ABS_ERR" >&1
	echo "Mean model relative error stdandart deviation -> $MEAN_REL_AVG_ABS_ERR_STD_DEV" >&1
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Mean model average event cross-correlation -> $MEAN_AVG_EV_CROSS_CORR" >&1
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Mean model max event cross-correlation -> $MEAN_MAX_EV_CROSS_CORR" >&1
	[[ $(echo "$EVENTS_LIST" | tr "," "\n" | wc -l) -ge 2 ]] && echo "Model max event cross-correlation ${max_ev_cross_corr[$MAX_EV_CROSS_CORR_IND]} is at ${FREQ_LIST[$MAX_EV_CROSS_CORR_IND]} MHz between $MAX_EV_CROSS_CORR_EV_LABELS" >&1
<<<<<<< HEAD
>>>>>>> 113fade9c5df9572588e61fd917c7782e7824365
=======
>>>>>>> 1e9d7615504fc9f2cac1629b8c53358dc8a4ec30
	echo -e "--------------------" >&1
fi

echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1
