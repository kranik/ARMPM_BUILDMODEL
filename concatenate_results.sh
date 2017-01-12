#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi


#Programmable head line and column separator. By default I assume data start at line 1 (first line is description, second is column heads and third is actual data). Columns separated by tab(s).
COL_SEP="\t"
#time_convert=1000000000

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:n:esh" opt;
do
    case $opt in
        h)
        	echo "Available flags and options:" >&2
        	echo "-r [DIRECTORY] -> Specify the save directory for the results of the different runs."
        	echo "-n [RUNS] -> specify list of runs to be concatenated. -n 3 for run Number 3. -n 1,3 for runs 1 and 3."
        	echo "-s -> Enable saving of events in results directory."
		echo "-e -> Specify the inclusion of events or not (for cases where we do not hve PMU events i.e. overhead analysis)."
        	cho "Mandatory options are: -r [DIR] -n [NUM]"
        	exit 0 
	        ;;
        #Specify the save directory, if no save directory is chosen the results are saved in the $PWD
        r)
		if [[ -n  "$RESULTS_DIR" ]]; then
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
			else
				if [[ $(echo "$RESULTS_DIR" | grep -c 'LITTLE') -gt 0 ]]; then
					CORETYPE="LITTLE"	
				elif [[ $(echo "$RESULTS_DIR" | grep -c 'big') -gt 0 ]]; then
					CORETYPE="big"
				else	
					echo "Directory specified with -r flag does not specify core type." >&2
			    		exit 1                        				
				fi
			fi
		fi
		;;
        #Specify if yo uwant to save resutls file where events_raw file was (easier scripts) if not print on stdout
        s)
        	if [[ -n $SAVE ]]; then
            		echo "Invalid input: option -s has already been used!" >&2
           	 	exit 1                
        	else
            		SAVE=1
        	fi
		;;
        n)
		if [[ -n $RUNS ]]; then
			echo "Invalid input: option -f has already been used!" >&2
			exit 1
		fi

		#Sanity check the directory has been specified. Part of my runs check is to see if the runs are present in the directory, so we need that entered first
		if [[ -z "$RESULTS_DIR" ]]; then
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

if [[ -z "$RESULTS_DIR" ]]; then
    	echo "Nothing to run. Expected -r flag!" >&2
    	exit 1
fi

if [[ -z $RUNS ]]; then
    	echo "Nothing to run. Expected -n flag!" >&2
    	exit 1
fi

FREQ_LIST=$(ls "$RESULTS_DIR/Run_${RUNS%% *}" | tr " " "\n" | sort -gr | tr "\n" " ")

for i in $RUNS
do
	for FREQ_SELECT in $FREQ_LIST
	do 
		#Get local file names
		BENCHMARKS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/benchmarks.data"
		SENSORS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/sensors.data"
		#If we have events selected then use events file
		[[ -n $WITH_EVENTS ]] && EVENTS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/events.data"
		
		
		#Extract header information
		#Fele data start (first lines with no #)
		BENCHMARKS_BEGIN_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$BENCHMARKS_FILE")
		SENSORS_BEGIN_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$SENSORS_FILE")
		#Only extract events if selected
		[[ -n $WITH_EVENTS ]] && EVENTS_BEGIN_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$EVENTS_FILE")
						
		#Extract field information position from header lines - header line is assumed to be last line before data
		#Benchmarks
		BENCH_NAME_COLUMN=$(awk -v SEP='\t' -v START=$((BENCHMARKS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Name/) { print i; exit} } } }' < "$BENCHMARKS_FILE")
		BENCH_START_COLUMN=$(awk -v SEP='\t' -v START=$((BENCHMARKS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Start/) { print i; exit} } } }' < "$BENCHMARKS_FILE")
		BENCH_END_COLUMN=$(awk -v SEP='\t' -v START=$((BENCHMARKS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /End/) { print i; exit} } } }' < "$BENCHMARKS_FILE")
		
		#Sensors
		case $CORETYPE in
			big)
				SENSORS_COL_START=$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /A7 Power/) { print (i+1); exit} } } }' < "$SENSORS_FILE")
				SENSORS_COL_END=$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /A15 Power/) { print i; exit} } } }' < "$SENSORS_FILE")
				SENSORS_LABELS=$(echo "$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) -v COL_START="$SENSORS_COL_START" -v COL_END="$SENSORS_COL_END" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=COL_END;i++) print $i} }' < "$SENSORS_FILE")" | tr "\n" "\t" | head -c -1)
				;;
			LITTLE)
				SENSORS_COL_START=$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i !~ /Timestamp/) { print i; exit} } } }' < "$SENSORS_FILE")
				SENSORS_COL_END=$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /A7 Power/) { print i; exit} } } }' < "$SENSORS_FILE")
				SENSORS_LABELS=$(echo "$(awk -v SEP='\t' -v START=$((SENSORS_BEGIN_LINE-1)) -v COL_START="$SENSORS_COL_START" -v COL_END="$SENSORS_COL_END" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=COL_END;i++) print $i} }' < "$SENSORS_FILE")" | tr "\n" "\t" | head -c -1)
				;;
		esac
		
		#Events
		if [[ -n $WITH_EVENTS ]]; then
			EVENTS_COL_START=$(awk -v SEP='\t' -v START=$((EVENTS_BEGIN_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i !~ /Timestamp/) { print i; exit} } } }' < "$EVENTS_FILE")
			EVENTS_LABELS=$(echo "$(awk -v SEP='\t' -v START=$((EVENTS_BEGIN_LINE-1)) -v COL_START="$EVENTS_COL_START" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < "$EVENTS_FILE")" | tr "\n" "\t" | head -c -1)
		fi
		
	   	if [[ -z $SAVE ]]; then
	   		#Display results header
	   		if [[ -z $HEADER ]]; then
				[[ -n $WITH_EVENTS ]] && echo -e "#Timestamp\tBenchmark\t$SENSORS_LABELS\t$EVENTS_LABELS" || echo -e "#Timestamp\tBenchmark\t$SENSORS_LABELS"
				HEADER=1
			fi
		else
		   	#Save results header
			RESULTS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/results.data"
			[[ -n $WITH_EVENTS ]] && echo -e "#Timestamp\tBenchmark\t$SENSORS_LABELS\t$EVENTS_LABELS" > "$RESULTS_FILE" || echo -e "#Timestamp\tBenchmark\t$SENSORS_LABELS" > "$RESULTS_FILE"
		fi		
		
		#Extract sensor and event information
		for BENCH_LINE in $(seq "$BENCHMARKS_BEGIN_LINE" "$(wc -l "$BENCHMARKS_FILE" | awk '{print $1}')")
		do 
			#Get start and end of each benchmark
			BENCH_NAME=$(awk -v START="$BENCH_LINE" -v SEP=$COL_SEP -v COL="$BENCH_NAME_COLUMN" 'BEGIN{FS=SEP}{if (NR == START){print $COL;exit}}' < "$BENCHMARKS_FILE")
			BENCH_START=$(awk -v START="$BENCH_LINE" -v SEP=$COL_SEP -v COL="$BENCH_START_COLUMN" 'BEGIN{FS=SEP}{if (NR == START){print $COL;exit}}' < "$BENCHMARKS_FILE")
			BENCH_FINISH=$(awk -v START="$BENCH_LINE" -v SEP=$COL_SEP -v COL="$BENCH_END_COLUMN" 'BEGIN{FS=SEP}{if (NR == START){print $COL;exit}}' < "$BENCHMARKS_FILE")
			#BENCH_RUNTIME=$(echo "scale = 10; ($BENCH_FINISH-$BENCH_START)/$time_convert;" | bc) 
			for SENSORS_LINE in $(awk -v START="$SENSORS_BEGIN_LINE" -v SEP=' ' -v B_ST="$BENCH_START" -v B_F="$BENCH_FINISH" 'BEGIN{FS = SEP} {if (NR >= START && $1 >= B_ST && $1 <= B_F) print NR }' < "$SENSORS_FILE")
			do
				SENSORS_TIMESTAMP=$(awk -v START="$SENSORS_LINE" -v SEP=' ' 'BEGIN{FS=SEP}{if (NR==START){print $1;exit}}'  < "$SENSORS_FILE")
				SENSORS_TIMESTAMP_NEXT=$(awk -v START=$((SENSORS_LINE+1)) -v SEP=' ' 'BEGIN{FS=SEP}{if (NR==START){print $1;exit}}'  < "$SENSORS_FILE")
				SENSORS_DATA=$(echo "$(awk -v START="$SENSORS_LINE" -v SEP=' ' -v COL_START="$SENSORS_COL_START" -v COL_END="$SENSORS_COL_END" 'BEGIN{FS = SEP}{if(NR==START){ for(i=COL_START;i<=COL_END;i++) print $i} }' < "$SENSORS_FILE")" | tr "\n" "\t" | head -c -1)
				if [[ -n $WITH_EVENTS ]]; then
					for EVENTS_LINE in $(awk -v START="$EVENTS_BEGIN_LINE" -v SEP="\t" -v S_ST="$SENSORS_TIMESTAMP" -v S_F="$SENSORS_TIMESTAMP_NEXT" 'BEGIN{FS=SEP}{if (NR >= START && $1 >= S_ST && $1 < S_F){print NR;exit}}' < "$EVENTS_FILE")
					do
						EVENTS_DATA=$(echo "$(awk -v START="$EVENTS_LINE" -v SEP="\t" -v COL_START="$EVENTS_COL_START" 'BEGIN{FS = SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i } }' < "$EVENTS_FILE")" | tr "\n" "\t" | head -c -1)					
						[[ -z $SAVE ]] && echo -e "$SENSORS_TIMESTAMP\t$BENCH_NAME\t$SENSORS_DATA\t$EVENTS_DATA" || echo -e "$SENSORS_TIMESTAMP\t$BENCH_NAME\t$SENSORS_DATA\t$EVENTS_DATA" >> "$RESULTS_FILE"
						EVENTS_DATA=""
					done
				else
					#Print only sensors data if no events
					[[ -z $SAVE ]] && echo -e "$SENSORS_TIMESTAMP\t$BENCH_NAME\t$SENSORS_DATA" || echo -e "$SENSORS_TIMESTAMP\t$BENCH_NAME\t$SENSORS_DATA" >> "$RESULTS_FILE"
				fi
				SENSORS_DATA=""
			done   
		done
	done
done
