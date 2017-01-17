#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi

RF_NUM=0

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:s:h" opt;
do
	case $opt in
        	h)
			echo "Available flags and options:" >&2
			echo "-r [DIRECTORY] -> Specify the results files."
			echo "-s [DIRECTORY] -> Specify the save directory for the concatenated results."
			echo "Mandatory options are: -r"
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
				eval RESULTS_START_LINE_$RF_NUM="$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#Check if results file contains data
			    	if [[ -z "$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM")" ]]; then 
					echo "ERROR: Results file" "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" "contains no data!" >&2
					exit 1
				fi

				#Exctract sync point 1 (run) information and do checks
				eval RESULTS_RUN_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				eval RESULTS_RUN_LIST_$RF_NUM="$(echo "$(awk -v SEP='\t' -v START="$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM")" -v DATA=0 -v COL="$(eval echo -e "\$RESULTS_RUN_COLUMN_$RF_NUM")" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" | sort -u | sort -g | tr "\n" "," | head -c -1 )")"
				#Compare run column information
				if [[ -z $RESULTS_RUN_LIST ]]; then
					#If first file (no standart run information exists) use its runs as a standart.
					RESULTS_RUN_LIST=$(eval echo -e "\$RESULTS_RUN_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_RUN_LIST != $(eval echo -e "\$RESULTS_RUN_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" "has different number of collected runs! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Exctract sync point 2 (frequency) information and do checks
				eval RESULTS_FREQ_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Frequency/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				eval RESULTS_FREQ_LIST_$RF_NUM="$(echo "$(awk -v SEP='\t' -v START="$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM")" -v DATA=0 -v COL="$(eval echo -e "\$RESULTS_FREQ_COLUMN_$RF_NUM")" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" | sort -u | sort -g | tr "\n" "," | head -c -1 )")"
				#Compare frequency column information
				if [[ -z $RESULTS_FREQ_LIST ]]; then
					#If first file (no standart frequency information exists) use its frequencies as a standart.
					RESULTS_FREQ_LIST=$(eval echo -e "\$RESULTS_FREQ_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_FREQ_LIST != $(eval echo -e "\$RESULTS_FREQ_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" "has different number of collected frequencies! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Exctract sync point 3 (bench) information and do checks
				eval RESULTS_BENCH_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Benchmark/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				eval RESULTS_BENCH_LIST_$RF_NUM="$(echo "$(awk -v SEP='\t' -v START="$(eval echo -e "\$RESULTS_START_LINE_$RF_NUM")" -v DATA=0 -v COL="$(eval echo -e "\$RESULTS_BENCH_COLUMN_$RF_NUM")" 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" | sort -u | sort -g | tr "\n" "," | head -c -1 )")"
				#Compare benchmark column information
				if [[ -z $RESULTS_BENCH_LIST ]]; then
					#If first file (no standart benchmark information exists) use its benchmarks as a standart.
					RESULTS_BENCH_LIST=$(eval echo -e "\$RESULTS_BENCH_LIST_$RF_NUM")
				else
					#If we already have a standart list compare
					if [[ $RESULTS_BENCH_LIST != $(eval echo -e "\$RESULTS_BENCH_LIST_$RF_NUM") ]]; then
				 		echo -e "ERROR: Results file" "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" "has different number of collected benchmarks! Data cannot be merged!" >&2
						exit 1
					fi
				fi
				#Extract other relevant columns
				#Timestamp
				eval RESULTS_TIMESTAMP_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /#Timestamp/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#Power
				eval RESULTS_POWER_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Power/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#CPU Cycles
				eval RESULTS_CCYCLES_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /CPU_CYCLES/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#Temperature
				eval RESULTS_TEMP_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Temperature/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#Voltage
				eval RESULTS_VOLT_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Voltage/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#Current
				eval RESULTS_CURR_COLUMN_$RF_NUM="$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Current/) { print i; exit} } } }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )"
				#PMU Events (one column after cycles until end of columns)
				eval RESULTS_EV_START_COLUMN_$RF_NUM=$(( $(eval echo -e "\$RESULTS_CCYCLES_COLUMN_$RF_NUM") + 1 ))
				#Extrating the event names (header) is a bit tricky. First we store the events as string in temp (note events separated by commas not tabs)
				#We do this so we can pick them up with the eval variable, otherwise every spaced entry is a new command so we cant add them just as a string
				#Also we avoid tabs since echo stores them as spaces, only way around is to separate with commas then tr the final output
				temp=$(echo "$(awk -v SEP='\t' -v START="$(( $(eval echo -e "\$RESULTS_START_LINE_$RF_NUM") - 1 ))"  -v COL_START="$(eval echo -e "\$RESULTS_EV_START_COLUMN_$RF_NUM")" 'BEGIN{FS=SEP}{if(NR==START){ for(i=COL_START;i<=NF;i++) print $i} }' < "$(eval echo -e "\$RESULTS_FILE_$RF_NUM")" )" | tr "\n" "," | head -c -1)
				eval RESULTS_EV_HEADER_$RF_NUM="$temp"
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

if [[ "$RF_NUM" -eq 1 ]]; then
    	echo "Please input more that one files to merge. Expected 2 or more -r flags!" >&2
    	exit 1
fi

#Sanity checks and events header preparation
for i in $(seq 1 $RF_NUM)
do
	eval MERGE_LINE_"$i"="$(eval echo -e "\$RESULTS_START_LINE_$i")"
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
	eval echo -e "Events header -\> \$RESULTS_EV_HEADER_$i" | tr "," "\t" >&1	
	EVENTS_HEADER+=$(eval echo -e ",\$RESULTS_EV_HEADER_$i")
	echo -e "--------------------" >&1
done
#Build Main Header
MAIN_HEADER=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_TIMESTAMP_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_BENCH_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
MAIN_HEADER+=","
MAIN_HEADER+=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE_1-1)) -v COL="$RESULTS_RUN_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START && i=COL ){ print $i} }' < "$RESULTS_FILE_1")
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
	echo -e "$MAIN_HEADER$EVENTS_HEADER" | tr "," "\t" >&1
	echo -e "====================" >&1
else
	echo -e "$MAIN_HEADER$EVENTS_HEADER" | tr "," "\t" > "$SAVE_FILE"
fi

#Main merging part of the script
while [[ $MAIN_LINE -le $(wc -l "$RESULTS_FILE_1" | awk '{print $1}') ]];
do
	#First test if files can be merged by testing sync points
	#Extract main file sync points
	MAIN_RUN=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_RUN_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$RESULTS_FILE_1")
	MAIN_FREQ=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_FREQ_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$RESULTS_FILE_1")
	MAIN_BENCH=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_BENCH_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	for i in $(seq 2 $RF_NUM)
	do
		#Extract merge file sync points
		MERGE_RUN=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_RUN_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		MERGE_FREQ=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_FREQ_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		MERGE_BENCH=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_BENCH_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		#Test sync points
		#Test run sync
		if [[ $MAIN_RUN != $MERGE_RUN ]]; then
			#Run is out of sync. Find next sync points for main and merge files
			MAIN_SYNC_LINE=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_RUN_COLUMN_1" -v SYNC="$MERGE_RUN" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$RESULTS_FILE_1")
			MERGE_SYNC_LINE=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_RUN_COLUMN_$i")" -v SYNC="$MAIN_RUN" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
			if [[ -z $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No sync points found for both files so just break loops. End of merging
				break 2
			elif [[ -n $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No merge sync line found but main sync line exists, update main pointer; break and repeat files merge loop
				#The reason we use continue 2 is to prevent the averaging that comes after the file merge loop
				MAIN_LINE=$MAIN_SYNC_LINE
				continue 2
			elif [[ -z $MAIN_SYNC_LINE && -n $MERGE_SYNC_LINE ]]; then
				#No main sync line found but merge sync line exists, update merge pointer; break and repeat files merge loop
				eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
				continue 2
			else
				MAIN_SYNC_DIFF=$((MAIN_SYNC_LINE-MAIN_LINE))
				MERGE_SYNC_DIFF=$((MERGE_SYNC_LINE-$(eval echo -e "\$MERGE_LINE_$i")))
				#Both sync points exist. Compare difference and choose the closest one
				if [[ $MAIN_SYNC_DIFF -le $MERGE_SYNC_DIFF ]]; then
					#Main sync point is closer (or equal). Update main line pointer and repeat sync loop
					MAIN_LINE=$MAIN_SYNC_LINE
					continue 2
				else
					#Merge sync point is closer. Update merge pointer and repeat sync loop
					eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
					continue 2
				fi
			fi
		fi
		#Test freq sync
		if [[ $MAIN_FREQ != $MERGE_FREQ ]]; then
			echo -e "====================" >&1
			echo "FREQ for file" "$(eval echo -e "\$RESULTS_FILE_$i")" "out of sync."
			echo "$MAIN_FREQ vs $MERGE_FREQ"
			echo -e "====================" >&1
			#Freq is out of sync. Find next sync points for main and merge files
			MAIN_SYNC_LINE=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_FREQ_COLUMN_1" -v SYNC="$MERGE_FREQ" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$RESULTS_FILE_1")
			MERGE_SYNC_LINE=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_FREQ_COLUMN_$i")" -v SYNC="$MAIN_FREQ" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
			if [[ -z $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No sync points found for both files so just break loops. End of merging
				break 2
			elif [[ -n $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No merge sync line found but main sync line exists, update main pointer; break and repeat files merge loop
				#The reason we use continue 2 is to prevent the averaging that comes after the file merge loop
				MAIN_LINE=$MAIN_SYNC_LINE
				continue 2
			elif [[ -z $MAIN_SYNC_LINE && -n $MERGE_SYNC_LINE ]]; then
				#No main sync line found but merge sync line exists, update merge pointer; break and repeat files merge loop
				eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
				continue 2
			else
				MAIN_SYNC_DIFF=$((MAIN_SYNC_LINE-MAIN_LINE))
				MERGE_SYNC_DIFF=$((MERGE_SYNC_LINE-$(eval echo -e "\$MERGE_LINE_$i")))
				#Both sync points exist. Compare difference and choose the closest one
				if [[ $MAIN_SYNC_DIFF -le $MERGE_SYNC_DIFF ]]; then
					#Main sync point is closer (or equal). Update main line pointer and repeat sync loop
					MAIN_LINE=$MAIN_SYNC_LINE
					continue 2
				else
					#Merge sync point is closer. Update merge pointer and repeat sync loop
					eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
					continue 2
				fi
			fi
		fi
		#Test bench sync
		if [[ $MAIN_BENCH != $MERGE_BENCH ]]; then
			#Bench is out of sync. Find next sync points for main and merge files
			MAIN_SYNC_LINE=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_BENCH_COLUMN_1" -v SYNC="$MERGE_BENCH" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$RESULTS_FILE_1")
			MERGE_SYNC_LINE=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_BENCH_COLUMN_$i")" -v SYNC="$MAIN_BENCH" 'BEGIN{FS=SEP}{if(NR>=START&&$COL==SYNC){print NR;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
			if [[ -z $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No sync points found for both files so just break loops. End of merging
				break 2
			elif [[ -n $MAIN_SYNC_LINE && -z $MERGE_SYNC_LINE ]]; then
				#No merge sync line found but main sync line exists, update main pointer; break and repeat files merge loop
				#The reason we use continue 2 is to prevent the averaging that comes after the file merge loop
				MAIN_LINE=$MAIN_SYNC_LINE
				continue 2
			elif [[ -z $MAIN_SYNC_LINE && -n $MERGE_SYNC_LINE ]]; then
				#No main sync line found but merge sync line exists, update merge pointer; break and repeat files merge loop
				eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
				continue 2
			else
				MAIN_SYNC_DIFF=$((MAIN_SYNC_LINE-MAIN_LINE))
				MERGE_SYNC_DIFF=$((MERGE_SYNC_LINE-$(eval echo -e "\$MERGE_LINE_$i")))
				#Both sync points exist. Compare difference and choose the closest one
				if [[ $MAIN_SYNC_DIFF -le $MERGE_SYNC_DIFF ]]; then
					#Main sync point is closer (or equal). Update main line pointer and repeat sync loop
					MAIN_LINE=$MAIN_SYNC_LINE
					continue 2
				else
					#Merge sync point is closer. Update merge pointer and repeat sync loop
					eval MERGE_LINE_"$i"="$MERGE_SYNC_LINE"
					continue 2
				fi
			fi
		fi
	done
	#After syncing has been done extract main file data
	#Extract and initialise sync columns totals with main data to be averaged later on
	TIMESTAMP_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_TIMESTAMP_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	POWER_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_POWER_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	CCYCLES_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_CCYCLES_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	TEMP_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_TEMP_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	VOLT_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_VOLT_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	CURR_TOTAL=$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL="$RESULTS_CURR_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){print$COL;exit}}' < "$RESULTS_FILE_1")
	EVENTS_TOTAL=$(echo "$(awk -v SEP='\t' -v START="$MAIN_LINE" -v COL_START="$RESULTS_EV_START_COLUMN_1" 'BEGIN{FS=SEP}{if(NR==START){for(i=COL_START;i<=NF;i++){print $i}}}' < "$RESULTS_FILE_1")" | tr "\n" "\t" | head -c -1)
	#Then extract data from every synced file and add to total
	for i in $(seq 2 $RF_NUM)
	do
		#Sync points tested. Meaning file data can be merged. Extract rest of points and merge
		#Add timestamp
		MERGE_TIMESTAMP=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_TIMESTAMP_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		TIMESTAMP_TOTAL=$(echo "$TIMESTAMP_TOTAL+$MERGE_TIMESTAMP;" | bc )
		#Add power
		MERGE_POWER=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_POWER_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		POWER_TOTAL=$(echo "$POWER_TOTAL+$MERGE_POWER;" | bc )
		#Add cpu cycles
		MERGE_CCYCLES=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_CCYCLES_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		CCYCLES_TOTAL=$(echo "$CCYCLES_TOTAL+$MERGE_CCYCLES;" | bc )
		#Add temp
		MERGE_TEMP=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_TEMP_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		TEMP_TOTAL=$(echo "$TEMP_TOTAL+$MERGE_TEMP;" | bc )
		#Add volt
		MERGE_VOLT=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_VOLT_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		VOLT_TOTAL=$(echo "$VOLT_TOTAL+$MERGE_VOLT;" | bc )
		#Add curr
		MERGE_CURR=$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL="$(eval echo -e "\$RESULTS_CURR_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){print $COL;exit}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")
		CURR_TOTAL=$(echo "$CURR_TOTAL+$MERGE_CURR;" | bc )
		#Add events
		EVENTS_TOTAL+="\t"$( echo "$(awk -v SEP='\t' -v START="$(eval echo -e "\$MERGE_LINE_$i")" -v COL_START="$(eval echo -e "\$RESULTS_EV_START_COLUMN_$i")" 'BEGIN{FS=SEP}{if(NR==START){for(i=COL_START;i<=NF;i++){print $i}}}' < "$(eval echo -e "\$RESULTS_FILE_$i")")" | tr "\n" "\t" | head -c -1)
	done
	#After merge points have been totalled and averaged add them to output string and print along with data
	#Average timestamp
	TIMESTAMP_AVG=$(echo "scale=0; $TIMESTAMP_TOTAL/$RF_NUM;" | bc )
	#Average power
	POWER_AVG=$(echo "scale=3; $POWER_TOTAL/$RF_NUM;" | bc )
	#Average cpu cycles
	CCYCLES_AVG=$(echo "scale=0; $CCYCLES_TOTAL/$RF_NUM;" | bc )
	#Average temp
	TEMP_AVG=$(echo "scale=0; $TEMP_TOTAL/$RF_NUM;" | bc )
	#Average volt
	VOLT_AVG=$(echo "scale=1; $VOLT_TOTAL/$RF_NUM;" | bc )
	#Average curr
	CURR_AVG=$(echo "scale=3; $CURR_TOTAL/$RF_NUM;" | bc )
	#Output data
	if [[ -z $SAVE_FILE ]]; then
		echo -e "$TIMESTAMP_AVG\t$MAIN_BENCH\t$MAIN_RUN\t$MAIN_FREQ\t$TEMP_AVG\t$VOLT_AVG\t$CURR_AVG\t$POWER_AVG\t$CCYCLES_AVG\t$EVENTS_TOTAL" >&1
	else
		echo -e "$TIMESTAMP_AVG\t$MAIN_BENCH\t$MAIN_RUN\t$MAIN_FREQ\t$TEMP_AVG\t$VOLT_AVG\t$CURR_AVG\t$POWER_AVG\t$CCYCLES_AVG\t$EVENTS_TOTAL" >> "$SAVE_FILE"
	fi
	#Advance the main line pointers
	((MAIN_LINE++))
	#Advance the merge line pointers, we do not do it in merge line loop since if out of sync we need to sync up all files then we start incrementing the lines again
	#Here we just go through all file merge lines and increment them. Temp is used since direct substitution of evaled value into increment function makes it go haywire
	for i in $(seq 2 $RF_NUM)
	do
		temp=$(eval echo -e "\$MERGE_LINE_$i")
		((temp++))
		eval MERGE_LINE_"$i"=$temp
	done
done 

echo -e "====================" >&1
echo "Script Done!" >&1
echo -e "====================" >&1
