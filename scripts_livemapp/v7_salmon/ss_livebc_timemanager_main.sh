#!/bin/bash
# chmod +x ss_livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' ss_livebc_timemanager_main.sh
# ./ss_livebc_timemanager_main.sh test_A 


# "SHARED_FOLDER" is a full path including "$1" sample_id name entered from a user for outputs collection
SHARED_FOLDER="/media/localarchive/ONT-data/real-time-tests"/"$1"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A 1st input variable for start_livebc_minknow.sh
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests 2nd input variable for start_livebc_minknow.sh
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /media/localarchive/ONT-data
# waiting time  
t=1

# time for mapping run 
# In test mode with copying 2 fastq files per 1sec, was accepted whole mapping time 80sec, which equivalent 5cycles 
# In real Tachyon mode the condition is: 45min =  2700s that aproximately equivalent to 45 cycles for ONT sequencing 2 files per 1 minute
mapp_time=80 
# threshold array for gene countings [1x54]
n_irr_threshold=(1 2 2 31 0 83 49 3 380 10 210 10 18 2 18 18 220 100)


# Array [1x18] of the transcripts names (for 18 transcripts). This is a harcoded names for gene transcripts which correspond to .csv names listed in "Target_GeneTranscripts" folder
transcripts_inp=(transcripts_AEN transcripts_PHPT1 transcripts_BAX transcripts_PCNA transcripts_FDXR transcripts_DDB2 transcripts_CCNG1 transcripts_APOBEC3H transcripts_NKG7 transcripts_SOD1 transcripts_RBM3 transcripts_BBC3 transcripts_GADD45A transcripts_GADD45B transcripts_GADD45G transcripts_GADD45GIP1 transcripts_PRL31 transcripts_RPS17)
# Define the number of transcripts_inp
n_transcripts=${#transcripts_inp[@]}

# Define the sums array
declare -a sums
# Define a temporary file to store sums
sums_file="$SHARED_FOLDER/sums.txt"

# Launch the scripts for simulaiting fastq generating. Arguments sample_id from user and experiment_group
~/scripts_livemapp/v7_salmon/start_livebc_minknow.sh $sample_id $experiment_group &

while [ ! -d "$shared_dirs" 2>/dev/null ]; do
	sleep $t
done
# waiting for 'fastq_pass' folder appeares in the seq output
path_to_fastq_pass=""
while [ -z "$path_to_fastq_pass" 2>/dev/null ]; do
    path_to_fastq_pass=$(find $shared_dirs -name "fastq_pass" -type d)
	sleep $t
done

# echo -e "Pass to fsatq_pass:  $path_to_fastq_pass "
# Launch the scripts for mapping and indexing
~/scripts_livemapp/v7_salmon/ss_livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam 2>/dev/null)" ]; do
    sleep $t
done

# convert a CSV file to a TXT file and delete the header
function csv_to_txt_convert() {
	for genename_f in $@ ; do
		tail -n +2 "$Reference_Target/$genename_f.csv" > "$Reference_Target/$genename_f.txt"
	done
}
csv_to_txt_convert "${transcripts_inp[@]}"

mkdir $SHARED_FOLDER/mapped_dir/quant_txt_saved

function process_files() {
    
    local sum=$2
	
    for file in "$1"; do
		# Read the list of transcripts into an array

		value=$(awk '
			BEGIN {
				# Read the transcripts into an array
				while ((getline < "'$file'") > 0) {
					gsub(/"/, "", $1)
					transcripts[$1] = 1
				}
				sum=$2
			}
			{
				# If the transcript is in the array, add the NumReads value to the sum
				if ($1 in transcripts) {
					sum += $5
				}
			}
			END {
				print sum
			}
		' "$quant_file_txt")
		
		sum=$(($sum+$value))
		
		done

    echo $sum
}

# Define the file name and path
TSV_FILE="$SHARED_FOLDER/genecount_table.tsv"
user_output1="$SHARED_FOLDER/exposure_ornot_report.txt"
user_output2="$SHARED_FOLDER/dose_exposure_report.txt"

# Add the header row to the file if it does not exist
if [ ! -f "$TSV_FILE" ]; then
	echo -e "GeneName,CopyNumbers,CycleNumber" > "$TSV_FILE"
fi

ki=0
while true; do

	# Wait until files appear in the mapped_dirfolder
	if ls "$SHARED_FOLDER/mapped_dir/singlefastq_bam"/stat_aligned_RUN_NAME_*.txt >/dev/null 2>&1; then
	for quant_file_txt in "$SHARED_FOLDER/mapped_dir/singlefastq_bam"/stat_aligned_RUN_NAME_*.txt
		do
			# function for printing sum of gene counts to the .log file and to the terminal
			function print_gensums() {
				# line number where start to print the output (for each gene) 
				local i=$1
				# file name of the gene transcripts (from the array)
				local transcriptsNames=$2
				# input array with threasholds
				local thrashold=$3
				# collected sum of the gene counts (during the cycles)
				local sum=$4
					
				# condition for checking gene threshold 
				if [ "$sum" -le "$thrashold" ]; then
					echo -ne "\rNothing interesting for $transcriptsNames. Yet.... (GeneCount < $thrashold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"
				else
					echo -ne "\rGotcha $transcriptsNames!!! (GeneCount > $thrashold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"
				fi

				#printf "\n%.0s" $(seq 1 $(($(tput lines) - i))) 
				printf "\n%.0s" $(seq 1 0)

			}
				
			# Loop through the transcripts_inp and call the process_files function for each transcript file
			for i in $(seq 0 $((n_transcripts - 1))); do
				sums[$i]=$(process_files "$Reference_Target/${transcripts_inp[$i]}.txt" "${sums[$i]}" &)
			done

			# Wait for all the processes to finish
			wait
				
			# clear the terminal for the next output
			clear
				
			# clean sums.txt temporary file to write the last updated gene sums.
			> $sums_file
			# Loop through the transcripts_inp and call the print_gensums function for each transcript file
			for i in $(seq 0 $((n_transcripts - 1))); do
				print_gensums $((n_transcripts + n_transcripts - i - 1)) "${transcripts_inp[$i]}" "${n_irr_threshold[$i]}" "${sums[$i]}"
				# write gene sums into the temporary file
				echo "${sums[$i]}" >> "$sums_file"
			done 
				
				
			ki=$((ki+1))
			echo -ne "\n_____________________END of the "$ki" cycle___________________________________" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
		
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam"/stat_aligned_RUN_NAME_$((ki-1)).txt "$SHARED_FOLDER/mapped_dir/quant_txt_saved/"

				
			### check the 13th cycle $ki ###
			####################### with thrashold conditions  #########################
			# In test mode when copying 2 fastq files per 1sec, was accepted 3 cycles 
			# In real Tachyon mode the condition is: 13min =  780s  it is equivalent to 13 cycles for ONT sequencing 2 files per 1 minute

			if [ $ki -eq 3 ]; then
				# if one at least sums is TRUE (not sucseed the threashold) => not exposed
				# example of tested values with threshhold =(5 2 10 2) and sums=(3 3 18 3)
                if  [ ${sums[1]} -le ${n_irr_threshold[1]} ] || [ ${sums[2]} -le ${n_irr_threshold[2]} ] ||
				   [ ${sums[9]} -le ${n_irr_threshold[9]} ] || [ ${sums[13]} -le ${n_irr_threshold[13]} ] ; then
					echo -ne "**NOT Exposed**" > "$user_output1"
					killall start_livebc_minknow.sh # kill %1
					killall ss_livebc_mapping.sh  # kill %2
					killall ss_livebc_timemanager_main.sh # kill 0
					exit 
				else
					# example of tested values with threshhold =(2 2 10 2)
					echo -ne "**Exposed**" > "$user_output1"
				fi
			fi
				
	done
	fi
	sleep $t
done &
# Working time of the mapping
sleep $mapp_time

# Read sums from the temporary sums.txt file
while IFS= read -r line; do
	sums+=("$line")
done < "$sums_file"
# Here the if RULES about the dose assesment
# print out the gene counts (sub_set2 of genes) file output with Radiation Dose 
if [ ${sums[13]} -gt ${n_irr_threshold[13]} ] && [ ${sums[16]} -gt ${n_irr_threshold[16]} ] && [ ${sums[17]} -gt ${n_irr_threshold[17]} ] ; then
    # threshhold =(4 220 100) and 5 cycle genesum=(5 420 170)
	echo " [ ${sums[13]} , ${sums[16]} , ${sums[17]}] Radiation dose is > 2 Gy" > "$user_output2"
else
	# threshhold =(18 220 100) and 5 cycle genesum=(5 420 170)
	echo " [ ${sums[13]} , ${sums[16]}, ${sums[17]}] Radiation dose is < 2 Gy" > "$user_output2"
fi

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
echo -ne "\n"

#stop minknow service
sudo systemctl stop minknow
sleep 30

#stop doradod service 
sudo systemctl stop doradod

sleep 5
kill %1
kill %2
kill %3

# terminate the ss_livebc_timemanager_main.sh after it has completed its execution
exit