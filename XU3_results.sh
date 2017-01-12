#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi


#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:n:s:eh" opt;
do
	case $opt in
        	h)
			echo "Available flags and options:" >&2
			echo "-r [DIRECTORY] -> Specify the save directory for the results of the different runs."
			echo "-n [RUNS] -> specify list of runs to be concatenated. -n 3 for run Number 3. -n 1,3 for runs 1 and 3."
			echo "-s [DIRECTORY] -> Specify the save directory for the concatenated results."
			echo "-e -> Specify the inclusion of events or not (for cases where we do not hve PMU events i.e. overhead analysis)."
			echo "Mandatory options are: ..."
			exit 0 
        		;;
		#Specify the save directory, if no save directory is chosen the results are saved in the $PWD
		r)
			if [[ -n  $RESULTS_DIR ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				exit 1                
			fi
			#If the directory exists, ask the user if he really wants to reuse it. I do not accept symbolic links as a save directory.
			if [[ ! -d $OPTARG ]]; then
			    	echo "Directory specified with -r flag does not exist" >&2
			    	exit 1
			else
				#directory does exists and we can analyse results
				RESULTS_DIR=$OPTARG
				NUM_RUNS=$(ls "$RESULTS_DIR" | grep -c 'Run')
				if [[ $NUM_RUNS -eq 0 ]]; then
					echo "Directory specified with -r flag does not contain any results." >&2
		    			exit 1
				fi
				    	
			fi
			;;     
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
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
		    		SAVE_FILE="$OPTARG"
			fi
			;;
		n)
			if [[ -n $RUNS ]]; then
				echo "Invalid input: option -n has already been used!" >&2
				exit 1
			fi
		
			#Sanity check the directory has been specified. Part of my runs check is to see if the runs are present in the directory, so we need that entered first
			if [[ -z $RESULTS_DIR ]]; then
				echo "Please specify results directory before entering number of runs!" >&2
				exit 1
			fi
		
			spaced_OPTARG="${OPTARG//,/ }"
			#Go throught the selected frequecnies and make sure they are not out of bounds
			#Also make sure they are present in the frequency table located at /sys/devices/system/cpu/cpufreq/iks-cpufreq/freq_table because the kernel rounds up
			#Specifying a higher/lower frequency or an odd frequency is now wrong, jsut the kernel handles it in the background and might lead to collection of unwanted resutls
			for RUN_SELECT in $spaced_OPTARG
			do
				if [[ $RUN_SELECT -gt $NUM_RUNS || $RUN_SELECT -lt 1 ]]; then 
					echo "selected run $RUN_SELECT for -$opt is out of bounds. Runs are [1:$NUM_RUNS]"
					exit 1
				else
					[[ -z "$RUNS" ]] && RUNS="$RUN_SELECT" || RUNS+=" $RUN_SELECT"
				fi
			done
			;;      
		e)
			if [[ -n $WITH_EVENTS ]]; then
		    		echo "Invalid input: option -e has already been used!" >&2
		    		exit 1                
			fi
		    	WITH_EVENTS=1
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

if [[ -z $RESULTS_DIR ]]; then
    	echo "Nothing to run. Expected -r flag!" >&2
    	exit 1
fi

if [[ -z $RUNS ]]; then
    	echo "Nothing to run. Expected -n flag!" >&2
    	exit 1
fi
						
FREQ_LIST=$(ls "$RESULTS_DIR/Run_${RUNS%% *}" | tr " " "\n" | sort -gr | tr "\n" " ")						

#If we have event selection enabled then process raw events and concatenated with events, else jsut concatenate sensor data
if [[ -n $WITH_EVENTS ]]; then
	./process_raw_events.sh -r "$RESULTS_DIR" -n "${RUNS// /,}" -s
	./concatenate_results.sh -r "$RESULTS_DIR" -n "${RUNS// /,}" -e -s
else
	./concatenate_results.sh -r "$RESULTS_DIR" -n "${RUNS// /,}" -s
fi
#Go into results directories and concatenate all the results files in to a big beast!
for i in $RUNS;
do
	for FREQ_SELECT in $FREQ_LIST
	do	
		RESULTS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/results.data"
		RESULTS_BEGIN_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$RESULTS_FILE")
		BENCHMARK_NAME_COLUMN=$(awk -v SEP='\t' -v START=$((RESULTS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$RESULTS_FILE")
		
		TIME_BENCH_HEADER=$(echo "$(awk -v SEP='\t' -v START=$((RESULTS_BEGIN_LINE-1)) -v COL_END=$((BENCHMARK_NAME_COLUMN+1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<COL_END;i++) print $i} }' < "$RESULTS_FILE")" | tr "\n" "\t"| head -c -1)
		#If no events this should just include sensor data (concatenate_results should automatically adjust)
		SENSORS_EVENTS_HEADER=$(echo "$(awk -v SEP='\t' -v START=$((RESULTS_BEGIN_LINE-1)) -v COL_START=$((BENCHMARK_NAME_COLUMN+1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < "$RESULTS_FILE")" | tr "\n" "\t" | head -c -1)
	
		if [[ -z $SAVE_FILE ]]; then
			#Display results header
			[[ -z $HEADER ]] && echo -e "$TIME_BENCH_HEADER\tRun(#)\t$SENSORS_EVENTS_HEADER" >&1; HEADER=1
		else
		   	#Save results header
			[[ -z $HEADER ]] && echo -e "$TIME_BENCH_HEADER\tRun(#)\t$SENSORS_EVENTS_HEADER" > "$SAVE_FILE"; HEADER=1
		fi

		for LINE in $(seq "$RESULTS_BEGIN_LINE" 1 "$(wc -l "$RESULTS_FILE" | awk '{print $1}')") 
		do
			TIME_BENCH_DATA=$(echo "$(awk -v SEP='\t' -v START="$LINE" -v COL_END=$((BENCHMARK_NAME_COLUMN+1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<COL_END;i++) print $i} }' < "$RESULTS_FILE")" | tr "\n" "\t" | head -c -1)
			SENSORS_EVENTS_DATA=$(echo "$(awk -v SEP='\t' -v START="$LINE" -v COL_START=$((BENCHMARK_NAME_COLUMN+1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < "$RESULTS_FILE")" | tr "\n" "\t" | head -c -1) 
			[[ -z $SAVE_FILE ]] && echo -e "$TIME_BENCH_DATA\t$i\t$SENSORS_EVENTS_DATA" >&1 || echo -e "$TIME_BENCH_DATA\t$i\t$SENSORS_EVENTS_DATA" >> "$SAVE_FILE"		 
		done
	done
done
