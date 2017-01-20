#!/bin/bash

echo -e "===================="

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	echo -e "===================="
	exit 1
fi

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:m:e:s:h" opt;
do
	case $opt in
        	h)
			echo "Available flags and options:" >&2
			echo "-r [FILE] -> Specify the results file."
			echo "-m [NUMBER] -> Specify the mode: 1 - extract selected event columns, 2 - remove selected event columns."
			echo "-e [NUMBER LIST] -> Specify the event column list for extraction/removal."		
			echo "-s [FILE] -> Specify the save file for the concatenated results."
			echo "Mandatory options are: -r"
			exit 0 
        		;;
		#Specify the results file
		r)
			if [[ -n $RESULTS_FILE ]]; then
				echo "Invalid input: option -r has already been used!" >&2
				echo -e "===================="
				exit 1                
			fi
			#Make sure the benchmark directory selected exists
			if [[ ! -e "$OPTARG" ]]; then
				echo "-r $OPTARG does not exist. Please enter the results file to be analyzed!" >&2 
				echo -e "===================="
				exit 1
		    	else
				RESULTS_FILE="$OPTARG"
				RESULTS_START_LINE=$(awk -v SEP='\t' 'BEGIN{FS=SEP}{ if($1 !~ /#/){print (NR);exit} }' < "$RESULTS_FILE")
				#Check if results file contains data
			    	if [[ -z $RESULTS_START_LINE ]]; then 
					echo "Results file contains no data!" >&2
					echo -e "===================="
					exit 1
				else
					#Extract events columns from results file
					EVENTS_COL_START=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i+1; exit} } } }' < "$RESULTS_FILE")
					EVENTS_COL_END=$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ print NF; exit } }' < "$RESULTS_FILE")
				fi
		    	fi
		    	;; 
		e)
			if [[ -n  $EVENTS_LIST ]]; then
		    		echo "Invalid input: option -e has already been used!" >&2
				echo -e "===================="
		    		exit 1
                	fi
			if [[ -z  $RESULTS_FILE ]]; then
		    		echo "Please specify input results file with the -r flag before specifying events list!" >&2
				echo -e "===================="
		    		exit 1
                	fi
			#Extract events list from file
			spaced_OPTARG="${OPTARG//,/ }"
			for EVENT in $spaced_OPTARG
			do
				#Check if events list is in bounds
				if [[ "$EVENT" -gt $EVENTS_COL_END || "$EVENT" -lt $EVENTS_COL_START ]]; then 
					echo "Selected event -e $EVENT is out of bounds/invalid. Needs to be an integer value betweeen [$EVENTS_COL_START:$EVENTS_COL_END]." >&2
					echo -e "===================="
					exit 1
				fi
			done
			#Checkif events string contains duplicates
			if [[ $(echo "$OPTARG" | tr "," "\n" | wc -l) -gt $(echo "$OPTARG" | tr "," "\n" | sort | uniq | wc -l) ]]; then
				echo "Selected event list -e $OPTARG contains duplicates." >&2
				echo -e "===================="
				exit 1
			fi
			EVENTS_LIST="$OPTARG"
		    	;;
		#Specify program mode
		m)
			if [[ -n $MODE ]]; then
		    		echo "Invalid input: option -m has already been used!" >&2
				echo -e "===================="
		    		exit 1                
			fi
			if [[ -z  $EVENTS_LIST ]]; then
		    		echo "Please specify events lsist with the -e flag before specifying program mode!" >&2
				echo -e "===================="
		    		exit 1
                	fi
			if [[ $OPTARG != "1" && $OPTARG != "2" ]]; then 
				echo "Invalid operarion: -m $MODE! Options are: [1;2]." >&2
				echo "Use -h flag for more information on the available modes." >&2
			    	echo -e "===================="
			    	exit 1
			fi	
			MODE="$OPTARG"
			#Depending on mode build header files
			#Extract nonevent related information
			NONEVENTS_LIST=$(echo "$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COL_END="$EVENTS_COL_START" 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<COL_END;i++) print i} }' < "$RESULTS_FILE")" | tr "\n" ","| head -c -1)
			#NONEVENTS_LIST_LABELS=$(echo "$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$NONEVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULTS_FILE")" | tr "\n" "," | head -c -1)
			#Extract events list labels (for sanity check)
			#EVENTS_LIST_LABELS=$(echo "$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) -v COLUMNS="$EVENTS_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULTS_FILE")" | tr "\n" "," | head -c -1)
			#Extract full events list
			EVENTS_LIST_FULL=$(seq "$EVENTS_COL_START" 1 "$EVENTS_COL_END" | tr '\n' ',' | head -c -1)
			#Check if events trim list is the same size as full list
			EVENTS_LIST_SIZE=$(echo "$EVENTS_LIST" | tr "," "\n" | wc -l)
			EVENTS_LIST_FULL_SIZE=$(echo "$EVENTS_LIST_FULL" | tr "," "\n" | wc -l)
			if [[ "$EVENTS_LIST_SIZE"  -eq "$EVENTS_LIST_FULL_SIZE" ]]; then
				echo "ERROR: Selected events is the full events list. Please select a subset." >&2
			    	echo -e "===================="
		    		exit 1
			fi
			case $MODE in
			1)
				#Add events list to full list and extract lables
				FINAL_EXTRACT_LIST="$NONEVENTS_LIST,$EVENTS_LIST"
				;;
			2)
				#Delete selected events from full events list
				EVENTS_LIST_KEEP="$EVENTS_LIST_FULL"
				spaced_EVENTS_LIST="${EVENTS_LIST//,/ }"
				for EV_TRIM in $spaced_EVENTS_LIST
				do	
					EVENTS_LIST_KEEP=$(echo "$EVENTS_LIST_KEEP" | sed "s/^$EV_TRIM,//g;s/,$EV_TRIM,/,/g;s/,$EV_TRIM$//g;s/^$EV_TRIM$//g")
				done
				#Add remaining events to full list
				FINAL_EXTRACT_LIST="$NONEVENTS_LIST,$EVENTS_LIST_KEEP"
				;;
			esac
			#Extract full extract list size labels
			FINAL_EXTRACT_LIST_SIZE=$(echo "$FINAL_EXTRACT_LIST" | tr "," "\n" | wc -l)
			FINAL_EXTRACT_LIST_LABELS=$(echo "$(awk -v SEP='\t' -v START=$((RESULTS_START_LINE-1)) -v COLUMNS="$FINAL_EXTRACT_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if (NR == START){for (i = 1; i <= len; i++){print $ARRAY[i]}}}' < "$RESULTS_FILE")" | tr "\n" "," | head -c -1)
			;;
		#Specify the save file, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n $SAVE_FILE ]]; then
			    	echo "Invalid input: option -s has already been used!" >&2
				echo -e "===================="
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

#Sanity checks
echo -e "===================="
if [[ -z $RESULTS_FILE ]]; then
    	echo "Nothing to run! Expected -r flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $EVENTS_LIST ]]; then
    	echo "No event list specified! Expected -e flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
if [[ -z $MODE ]]; then
    	echo "No mode specified! Expected -m flag." >&2
    	echo -e "====================" >&1
    	exit 1
fi
echo -e "Critical checks passed!"  >&1
echo -e "===================="
echo -e "--------------------" >&1
#Add program sanity checks (filename;mode;event list;header)
#Results file sanito check
echo -e "Using specified results file -> $RESULTS_FILE" >&1
echo -e "--------------------" >&1
#Extract list sanity check
echo -e "Final event extract list -> $FINAL_EXTRACT_LIST{SIZE:$FINAL_EXTRACT_LIST_SIZE}" >&1
echo -e "--------------------" >&1
echo -e "Final extract list labels -> $FINAL_EXTRACT_LIST_LABELS" >&1
echo -e "--------------------" >&1
#Save file sanity check
if [[ -z $SAVE_FILE ]]; then 
	echo "No save file specified! Output to terminal." >&1
else
	echo "Using user specified output save file -> $SAVE_FILE" >&1
fi
echo -e "--------------------" >&1
echo -e "===================="

#Print Header
HEADER=$(echo "$FINAL_EXTRACT_LIST_LABELS" | tr ',' '\t')
[[ -z $SAVE_FILE ]] && echo -e "$HEADER" >&1 || echo -e "$HEADER" > "$SAVE_FILE"
#Extract/deleve event columns and save
if [[ -z $SAVE_FILE ]]; then
	awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COLUMNS="$FINAL_EXTRACT_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if(NR >= START){for (i = 1; i <= len; i++){printf "%s\t", $(ARRAY[i])};printf "\n"}}' < "$RESULTS_FILE"
else
	awk -v SEP='\t' -v START="$RESULTS_START_LINE" -v COLUMNS="$FINAL_EXTRACT_LIST" 'BEGIN{FS = SEP;len=split(COLUMNS,ARRAY,",")}{if(NR >= START){for (i = 1; i <= len; i++){printf "%s\t", $(ARRAY[i])};printf "\n"}}' < "$RESULTS_FILE" >> "$SAVE_FILE"
	echo -e "Finished writing output to file!"  >&1
fi
echo -e "===================="
exit
