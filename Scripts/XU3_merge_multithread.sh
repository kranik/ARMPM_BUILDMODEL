#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

RF_NUM=0

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:c:s:h" opt;
do
	case $opt in
        	h)
			echo "Available flags and options:" >&1
			echo "-r [FILEPATH] -> Specify the multi-thread results files." >&1
			echo "-c [INTEGER LIST] -> Specify the cpu cores list file by file. This allows to just merge 2Core and 4Core results for example. The list needs to be in order of the results files specified with the -r flag." >&1	
			echo "-s [FILEPATH] -> Specify the save file for the concatenated results. If no save file - output to terminal." >&1
			echo "Mandatory options are: -r [FILE1] -r [FILE2] -c [LIST]" >&1
			exit 0 
        		;;
		#Specify the results file
		r)
			#Make sure the results file selected exists
			if [[ ! -e "$OPTARG" ]]; then
				echo "-r $OPTARG does not exist. Please enter the results file to be analyzed!" >&2 
				exit 1
		    	else
				#Update file counter
				((RF_NUM++))
				#Extract file information
				eval RESULTS_FILE_$RF_NUM="$OPTARG"
				eval RESULTS_START_LINE_$RF_NUM="$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")")"
				#Check if results file contains data
			    	if [[ -z $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") ]]; then 
					echo "ERROR: Results file ""$(eval echo -e "\$RESULTS_FILE_$RF_NUM")""contains no data!" >&2
					exit 1
				fi

				#Exctract sync point 1 (run) information and do checks
				eval RESULTS_RUN_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")")"
				eval RESULTS_RUN_LIST_$RF_NUM="$(awk -v SEP='\t' -v START=$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") -v DATA=0 -v COL=$(eval echo -e "\$RESULTS_RUN_COLUMN_$RF_NUM") 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM") | sort -u | sort -g | tr "\n" "," | head -c -1 )"

				#Compare run column information
				if [[ -z $RESULTS_RUN_LIST ]]; then
					#If first file (no standart run information exists) use its runs as a standart.
					RESULTS_RUN_LIST=$(eval echo -e "\$RESULTS_RUN_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_RUN_LIST != $(eval echo -e "\$RESULTS_RUN_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" $(eval echo -e "\$RESULTS_FILE_$RF_NUM") "has different number of collected runs! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Exctract sync point 2 (frequency) information and do checks
				eval RESULTS_FREQ_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 )) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				eval RESULTS_FREQ_LIST_$RF_NUM=$(awk -v SEP='\t' -v START=$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") -v DATA=0 -v COL=$(eval echo -e "\$RESULTS_FREQ_COLUMN_$RF_NUM") 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM") | sort -u | sort -g | tr "\n" "," | head -c -1 )
				#Compare frequency column information
				if [[ -z $RESULTS_FREQ_LIST ]]; then
					#If first file (no standart frequency information exists) use its frequencies as a standart.
					RESULTS_FREQ_LIST=$(eval echo -e "\$RESULTS_FREQ_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_FREQ_LIST != $(eval echo -e "\$RESULTS_FREQ_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" $(eval echo -e "\$RESULTS_FILE_$RF_NUM") "has different number of collected frequencies! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Exctract sync point 3 (bench) information and do checks
				eval RESULTS_BENCH_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 )) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM") )
				eval RESULTS_BENCH_LIST_$RF_NUM=$(awk -v SEP='\t' -v START=$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") -v DATA=0 -v COL=$(eval echo -e "\$RESULTS_BENCH_COLUMN_$RF_NUM") 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM") | sort -u | sort -g | tr "\n" "," | head -c -1 )
				#Compare benchmark column information
				if [[ -z $RESULTS_BENCH_LIST ]]; then
					#If first file (no standart benchmark information exists) use its benchmarks as a standart.
					RESULTS_BENCH_LIST=$(eval echo -e "\$RESULTS_BENCH_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_BENCH_LIST != $(eval echo -e "\$RESULTS_BENCH_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" $(eval echo -e "\$RESULTS_FILE_$RF_NUM") "has different number of collected benchmarks! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Extract other relevant columns
				#Timestamp
				eval RESULTS_TIMESTAMP_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /#Timestamp/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#Power
				eval RESULTS_POWER_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Power/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#CPU Cycles
				eval RESULTS_CCYCLES_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /CPU_CYCLES/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#Temperature
				eval RESULTS_TEMP_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Temperature/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#Voltage
				eval RESULTS_VOLT_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Voltage/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#Current
				eval RESULTS_CURR_COLUMN_$RF_NUM=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Current/) { print i; exit} } } }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM"))
				#PMU Events (one column after cycles until end of columns)
				eval RESULTS_EV_START_COLUMN_$RF_NUM=$(( $(eval echo -e "\$RESULTS_CCYCLES_COLUMN_$RF_NUM") + 1 ))
				#Extrating the event names (header) is a bit tricky. First we store the events as string in temp (note events separated by commas not tabs)
				#We do this so we can pick them up with the eval variable, otherwise every spaced entry is a new command so we cant add them just as a string
				#Also we avoid tabs since echo stores them as spaces, only way around is to separate with commas then tr the final output
				temp=$(awk -v SEP='\t' -v START=$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))  -v COL_START=$(eval echo -e "\$RESULTS_EV_START_COLUMN_$RF_NUM") 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < $(eval echo -e "\$RESULTS_FILE_$RF_NUM") | tr "\n" "," | head -c -1)
				eval RESULTS_EV_HEADER_$RF_NUM="$temp"
				#Compare event column information
				if [[ -z $RESULTS_EV_HEADER ]]; then
					#If first file (no standart event information exists) use its events as a standart.
					RESULTS_EV_HEADER=$(eval echo -e "\$RESULTS_EV_HEADER_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_EV_HEADER != $(eval echo -e "\$RESULTS_EV_HEADER_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" $(eval echo -e "\$RESULTS_FILE_$RF_NUM") "has different list of events! Data cannot be merged!" >&2
						exit 1
					fi
				fi
		    	fi
		    	;;
		c)
			if [[ -n  $CORES_LIST ]]; then
		    		echo "Invalid input: option -c has already been used!" >&2
				echo -e "===================="
		    		exit 1
			else
				CORES_LIST="$OPTARG"
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

if [[ "$RF_NUM" -eq 0 ]]; then
    	echo "Nothing to run. Expected -r flag!" >&2
    	exit 1
fi

if [[ -z $CORES_LIST ]]; then
    	echo "No cores list specified! Expected -c flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi


#-c flag
if [[ -n $CORES_LIST ]]; then
	spaced_CORES_LIST="${CORES_LIST//,/ }"
	for CORE in $spaced_CORES_LIST
	do
		#Check if events list is in bounds
		if [[ "$CORE" -gt 4 || "$CORE" -lt 1 ]]; then 
			echo "Selected core -c $CORE is out of bounds/invalid to result file events. Needs to be an integer value betweeen [1:4](for the ODROID-XU3)." >&2
			echo -e "===================="
			exit 1
		fi
	done
	#Check cores list against number of files
	if [[ $(echo "$spaced_CORES_LIST" | awk -F " " '{print NF}') -ne "$RF_NUM" ]]; then
		echo "Selected core list -c $CORES_LIST does not match the number of files specified with -r ($RF_NUM)." >&2
		echo -e "===================="
		exit 1
	fi
fi

#Checkif events string contains duplicates
if [[ $(echo "$CORES_LIST" | tr "," "\n" | wc -l) -gt $(echo "$CORES_LIST" | tr "," "\n" | sort | uniq | wc -l) ]]; then
	echo "Selected event list -c $CORES_LIST contains duplicates." >&2
	echo -e "===================="
	exit 1
fi

#Put the string into an array
IFS=',' read -r -a CORES_ARRAY <<< "$CORES_LIST"

#Sanity checks and events header preparation
for i in $(seq 1 $RF_NUM)
do
	echo -e "====================" >&1
	echo -e "--------------------" >&1	
	eval echo -e "File -\> \$RESULTS_FILE_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Start line -\> \$RESULTS_START_LINE_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Run column -\> \$RESULTS_RUN_COLUMN_$i" >&1
	eval echo -e "Run list -\> \$RESULTS_RUN_LIST_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Freq column -\> \$RESULTS_FREQ_COLUMN_$i" >&1
	eval echo -e "Freq list -\> \$RESULTS_FREQ_LIST_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Bench column -\> \$RESULTS_BENCH_COLUMN_$i" >&1
	eval echo -e "Bench list -\> \$RESULTS_BENCH_LIST_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Timestamp column -\> \$RESULTS_TIMESTAMP_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Power column -\> \$RESULTS_POWER_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "CPU Cycles column -\> \$RESULTS_CCYCLES_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Temperature column -\> \$RESULTS_TEMP_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Voltage column -\> \$RESULTS_VOLT_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Current column -\> \$RESULTS_CURR_COLUMN_$i" >&1
	echo -e "--------------------" >&1
	eval echo -e "Events start column -\> \$RESULTS_EV_START_COLUMN_$i" >&1
	eval echo -e "Events list -\> \$RESULTS_EV_HEADER_$i" | tr "," "\t" >&1	
	echo -e "--------------------" >&1
done
#Build Main Header
MAIN_HEADER=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_TIMESTAMP_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_BENCH_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_RUN_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+="Cores(#)"
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_FREQ_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_TEMP_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_VOLT_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_CURR_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_POWER_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_CCYCLES_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
#Initiate MAIN_LINE pointer
MAIN_LINE=$RESULTS_START_LINE_1
#Output header
#It has a built in tab between main and events header due to a leading comma at the events header
if [[ -z $SAVE_FILE ]]; then
	echo -e "====================" >&1
	echo -e "$MAIN_HEADER,$RESULTS_EV_HEADER" | tr "," "\t" >&1
	echo -e "====================" >&1
else
	echo -e "$MAIN_HEADER,$RESULTS_EV_HEADER" | tr "," "\t" > "$SAVE_FILE"
fi

for i in $(seq 1 $RF_NUM)
do
	#Initiate MAIN_LINE pointer
	LINE=$(eval echo -e "\$RESULTS_START_LINE_$i")
	while [[ $LINE -le $(wc -l $(eval echo -e "\$RESULTS_FILE_$i") | awk '{print $1}') ]];
	do
		#Extract data from file
		TIMESTAMP=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_TIMESTAMP_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		BENCH=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_BENCH_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		RUN=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_RUN_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		FREQ=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_FREQ_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		TEMP=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_TEMP_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		VOLT=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_VOLT_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		CURR=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_CURR_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		POWER=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_POWER_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		CCYCLES=$(awk -v SEP='\t' -v START=$LINE -v COL=$(eval echo -e "\$RESULTS_CCYCLES_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < $(eval echo -e "\$RESULTS_FILE_$i"))
		EVENTS=$(awk -v SEP='\t' -v START=$LINE -v COL_START=$(eval echo -e "\$RESULTS_EV_START_COLUMN_$i") 'BEGIN{FS=SEP}{if(NR==START){for(i=COL_START;i<=NF;i++){print $i}}}' < $(eval echo -e "\$RESULTS_FILE_$i") | tr "\n" "\t" | head -c -1)
		DATA="$TIMESTAMP\t$BENCH\t$RUN\t\${CORES_ARRAY[\$((\$i-1))]}\t$FREQ\t$TEMP\t$VOLT\t$CURR\t$POWER\t$CCYCLES\t$EVENTS"
		if [[ -z $SAVE_FILE ]]; then
			echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t" >&1
		else
			echo -e "$(eval echo "$(echo -e "$DATA")")" | tr " " "\t" >> "$SAVE_FILE"
		fi
		
		((LINE++))
	done
done

echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1
