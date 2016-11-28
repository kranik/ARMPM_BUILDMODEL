#!/bin/bash

if [[ "$#" -eq 0 ]]; then
	echo "This program requires inputs. Type -h for help." >&2
	exit 1
fi


#Programmable head line and column separator. By default I assume data start at line 1 (first line is description, second is column heads and third is actual data). Columns separated by tab(s).
head_line=1
col_sep="\t"
time_convert=1000000000

#requires getops, but this should not be an issue since ints built in bash
while getopts ":r:n:s:h" opt;
do
	case $opt in
        	h)
			echo "Available flags and options:" >&2
			echo "-r [File] -> Specify the results file to be split."
			echo "-s [DIRECTORY] -> Specify the save directory for the split results."
			echo "Mandatory options are: -r -s "
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
				else
					#Extract runs
					RESULTS_RUN_COLUMN=$(awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){ for(i=1;i<=NF;i++){ if($i ~ /Run/) { print i; exit} } } }' < $RESULTS_FILE )
					RESULTS_RUN_LIST=$(echo $(awk -v SEP='\t' -v START=$RESULTS_START_LINE -v DATA=0 -v COL=$RESULTS_RUN_COLUMN 'BEGIN{FS=SEP}{ if(NR >= START && $COL != DATA){print ($COL);DATA=$COL} }' < $RESULTS_FILE | sort -u | sort -gr ) | tr " " ",")
					#Check if we have successfully extracted freqeuncies
					if [[ -z $RESULTS_RUN_LIST ]]; then
						echo "Unable to extract runs from results file!" >&2
						exit 1
					else
						echo "Extracted run list:" >&1
						echo "$RESULTS_RUN_LIST" >&1
						#Check if list > 1 if not just terminate since its uselsess
						if [[ $(echo $RESULTS_RUN_LIST | tr "," "\n" | wc -l) -gt 1 ]]; then 
							spaced_RUN_LIST="${RESULTS_RUN_LIST//,/ }"
							#Extract file characteristics
							#Finish this later
							SAVE_FULL_FILENAME=$(basename "$RESULTS_FILE")
							SAVE_FILENAME="${SAVE_FULL_FILENAME%.*}_run_\$i.${SAVE_FULL_FILENAME##*.}"
						else
							echo "Extracted run lust only contains one run. Nothing to split!" >&2
							exit 1
						fi
					fi
				fi
		    	fi
		    	;;    
		#Specify the save directory, if no save directory is chosen the results are printed on terminal
		s)
			if [[ -n  $SAVE_DIR ]]; then
				echo "Invalid input: option -s has already been used!" >&2
				exit 1                
			fi
			#If the directory exists, ask the user if he really wants to reuse it. I do not accept symbolic links as a save directory.
			if [[ ! -d $OPTARG ]]; then
			    	echo "Directory specified with -s flag does not exist" >&2
			    	exit 1
			else
				#directory does exists and we can analyse results
				SAVE_DIR=$OPTARG
				echo "-s $OPTARG already exists. Ensure it is empty to avoid overwriting files. Continue Saving in directory? (Y/N)" >&1
			    	while true;
			    	do
					read USER_INPUT
					if [[ "$USER_INPUT" == Y || "$USER_INPUT" == y ]]; then
				    		echo "Using existing dir $OPTARG" >&1
				    		break
					elif [[ "$USER_INPUT" == N || "$USER_INPUT" == n ]]; then
				    		echo "Cancelled using save dir $OPTARG Program exiting." >&1
				    		exit 0                            
					else
				    		echo "Invalid input: $USER_INPUT !(Expected Y/N)" >&2
						echo "Please enter correct input: " >&2
					fi
			    	done
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

if [[ -z $RESULTS_FILE ]]; then
    	echo "Nothing to run. Expected -r flag!" >&2
    	exit 1
fi

if [[ -z $SAVE_DIR ]]; then
    	echo "Nothing to save to. Expected -s flag!" >&2
    	exit 1
fi
			
#Go into results directories and concatenate all the results files in to a big beast!
for i in $spaced_RUN_LIST;
do
	echo "Extracting run: $i"
	#Print header run save file
	awk -v SEP='\t' -v START=$(($RESULTS_START_LINE-1)) 'BEGIN{FS=SEP}{if(NR==START){print $0;exit}}' < $RESULTS_FILE > $(echo $(echo "$SAVE_DIR/")$(eval echo -e $SAVE_FILENAME))
	#Print results
	awk -v SEP='\t' -v START=$RESULTS_START_LINE -v COL=$RESULTS_RUN_COLUMN -v DATA=$i 'BEGIN{FS=SEP}{if(NR >= START){ if($COL==DATA) {print $0} }}' < $RESULTS_FILE >> $(echo $(echo "$SAVE_DIR/")$(eval echo -e $SAVE_FILENAME))
	echo -e "Finished writing into file -> "$(echo $(echo "$SAVE_DIR/")$(eval echo -e $SAVE_FILENAME))
done
