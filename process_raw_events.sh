#!/bin/bash

if [[ "$#" -eq 0 ]]; then
  echo "This program requires inputs. Type -h for help." >&2
  exit 1
fi


#Programmable head line and column separator. By default I assume data start at line 1 (first line is description, second is column heads and third is actual data). Columns separated by tab(s).
col_sep="\t"
time_convert=1000000000

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:n:sh" opt;
do
    	case $opt in
        h)
        	echo "Available flags and options:" >&2
        	echo "-r [DIRECTORY] -> Specify the save directory for the results of the different runs."
        	echo "-n [INTEGER] -> specify list of runs to be concatenated. -n 3 for run Number 3. -n 1,3 for runs 1 and 3."
        	echo "-s -> Enable saving of events in results directory."
        	cho "Mandatory options are: -r [DIR] -n [NUM]"
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
	
for i in $RUNS
do
	for FREQ_SELECT in $FREQ_LIST
	do 
		EVENTS_RAW_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/events_raw.data"	        
	   
		#Get event start and FINISH lines for labels header
		TIME_START=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{if($1 ~ /Start/) {print NR;exit}}' < "$EVENTS_RAW_FILE")
		LABEL_START=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{if($1 ~ /Label/) {print NR;exit}}' < "$EVENTS_RAW_FILE")
		LABEL_FINISH=$(awk -v START="$LABEL_START" -v SEP='\t' 'BEGIN{FS=SEP}{if($1 !~ /Label/ && NR > START) {print NR;exit}}' < "$EVENTS_RAW_FILE")
		
		#Get the label and raw identifier field (use regexp to match patterns and return next field
		LABEL_COLUMN=$(awk -v SEP='\t' -v START="$LABEL_START" -v FINISH="$LABEL_FINISH" 'BEGIN{FS=SEP}{ if (NR >= START && NR < FINISH){ for(i=1;i<=NF;i++){ if($i ~ /Label/){ print (i+1); exit } } } }' < "$EVENTS_RAW_FILE")
		RAW_COLUMN=$(awk -v SEP='\t' -v START="$LABEL_START" -v FINISH="$LABEL_FINISH" 'BEGIN{FS=SEP}{ if (NR >= START && NR < FINISH){ for(i=1;i<=NF;i++){ if($i ~ /RAW/){ print (i+1); exit } } } }' < "$EVENTS_RAW_FILE")
		
		#Get events labels and RAW identifieers in list form
		#I take the raw events file then I extract the labels and in orger to turn it int oa nice string I replace all \n with commas and remove the last train=ling comma (caused by replacing the FINISHing \n)
		EVENTS_LABELS=$(echo "$(awk -v START="$LABEL_START" -v FINISH="$LABEL_FINISH" -v COL="$LABEL_COLUMN" -v SEP='\t' 'BEGIN{FS=SEP}{if (NR >= START && NR < FINISH) {print $COL}}' < "$EVENTS_RAW_FILE")" | tr "\n" "\t" | head -c -1)
		#for some obscure reason it cannot convert strings with \n to arrays so I need to extract identfiers then convers \n to commas using tr, then remove trailing last comma (which used to be a \n) and then convert properly
		IFS="," read -a EVENTS_RAW <<< "$(echo "$(awk -v START="$LABEL_START" -v FINISH="$LABEL_FINISH" -v COL="$RAW_COLUMN" -v SEP='\t' 'BEGIN{FS=SEP}{if (NR >= START && NR < FINISH) {print $COL}}' < "$EVENTS_RAW_FILE")" | tr "\n" "," | head -c -1)" 

		if [[ -z $SAVE ]]; then
	   		#Display results header
			[[ -z $HEADER ]] && echo -e "#Timestamp\tFrequency\t$EVENTS_LABELS"; HEADER=1
		else
		   	#Save results header
			EVENTS_FILE="$RESULTS_DIR/Run_$i/$FREQ_SELECT/events.data"
			echo -e "#Timestamp\t$EVENTS_LABELS" > "$EVENTS_FILE"
		fi
		#read lines for event timing skipping event_number lines since perf puts events even during the same timestamp on new lines. this essentially distinguishes the different timestamps
		for linenum in $(seq "$LABEL_FINISH" ${#EVENTS_RAW[@]} "$(wc -l "$EVENTS_RAW_FILE" | awk '{print $1}')") 
		do
			#read timestamp
			time=$(awk -v START="$linenum" -v SEP=$col_sep 'BEGIN{FS = SEP}{if(NR==START){print $1;exit}}' < "$EVENTS_RAW_FILE")
			#get the events for the curent timestamp by going over jsut the nubmer of newlines as the total number of collected events
			for j in $(seq "$linenum" 1 $(( linenum + ${#EVENTS_RAW[@]} - 1 )))
			do
				EVENTS_DATA_STORE+="$(awk -v START="$j" -v SEP=$col_sep 'BEGIN{FS = SEP}{if(NR==START){print $2;exit}}' < "$EVENTS_RAW_FILE")\t"
			done
			
			#remove trailing tab character and any string end so remove last 3 characters
			EVENTS_DATA=$(echo "$EVENTS_DATA_STORE" | head -c -3)
			
			#Convert time to nanoseconds to keep it consistent with how I take benchmark start and ent times. Get start time from the first line in the file in ns to convert to epoch time
			starttime=$(awk -v START="$TIME_START" -v SEP='\t' 'BEGIN{FS = SEP}{ if (NR == START){print $2; exit}}' "$EVENTS_RAW_FILE")
			
			nanotime=$(echo "scale = 0; ($starttime+($time*$time_convert))/1;" | bc )
			[[ -z $SAVE ]] && echo -e "$nanotime\t$FREQ_SELECT\t$EVENTS_DATA" || echo -e "$nanotime\t$EVENTS_DATA" >> "$EVENTS_FILE"
			
			EVENTS_DATA_STORE=""
			EVENTS_DATA=""
		done		
	done
done
