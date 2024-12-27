#!/bin/bash
# chmod +x livebc_timemanager_main_multifunc.sh
#  sed -i -e 's/\r$//' livebc_timemanager_main_multifunc.sh
# ./livebc_timemanager_main_multifunc.sh F 
#transcripts_PRL31_1 transcripts_PRL31_2 transcripts_PRL31_3 transcripts_PRL31_4 transcripts_PRL31_5 transcripts_PRL31_6 transcripts_PRL31_7 transcripts_PRL31_8 transcripts_PRL31_9 transcripts_PRL31_10 transcripts_PRL31_11 transcripts_PRL31_12 transcripts_PRL31_13 transcripts_PRL31_14 transcripts_PRL31_15 transcripts_PRL31_16 transcripts_PRL31_17 transcripts_PRL31_18 transcripts_PRL31_19 transcripts_PRL31_20 transcripts_RPS17_1 transcripts_RPS17_2 transcripts_RPS17_3 transcripts_RPS17_4 transcripts_RPS17_5 transcripts_RPS17_6 transcripts_RPS17_7 transcripts_RPS17_8 transcripts_RPS17_9 transcripts_RPS17_10 transcripts_RPS17_11 transcripts_RPS17_12 transcripts_RPS17_13 transcripts_RPS17_14 transcripts_RPS17_15 transcripts_RPS17_16 transcripts_RPS17_17 transcripts_RPS17_18 transcripts_RPS17_19 transcripts_RPS17_20 transcripts_RPS17_21 transcripts_RPS17_22 transcripts_RPS17_23 transcripts_RPS17_24 transcripts_RPS17_25 transcripts_RPS17_26 transcripts_RPS17_27 transcripts_RPS17_28 transcripts_RPS17_29 transcripts_RPS17_30 transcripts_RPS17_31 transcripts_RPS17_32 transcripts_RPS17_33 transcripts_RPS17_34
# For more gene names add: transcriptsNames4="$5"..., 
#                          csv_to_txt_convert ... "transcriptsNames4"
#                          sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
#                          print_gensums 4 "$transcriptsNames4" "$sum4"
# Change the times of \n:   echo -ne "\n\n\n\033[0K\rNothing interesting for $transcriptsNames.
#################### GeneNames_N - 1 = echo -ne "\n\n\n\...
#################### GeneNames_N = last print_gensums N (for the upper N=N+1)


SHARED_FOLDER="/media/localarchive/ONT-data/real-time-tests"/"$1"
#p2s_folder="$2"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target"/media/localarchive/transcriptome_ref/Target_GeneTranscripts_oncotypedx"
# Specify the path to the file containing the names 
#genenames_path="$Reference_Target/genenames_list.txt"
sample_id=$(basename "$SHARED_FOLDER") #FC1 or FC2
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /data/DeepSimulator_data
t=1
mapp_time=55
n_irr_threshold=40

transcripts_inp=(transcripts_ACTB transcripts_AURKA transcripts_BAG1 transcripts_BCL2 transcripts_BIRC5 transcripts_CCNB1 transcripts_CD68 transcripts_CTSV transcripts_ERBB2 transcripts_ESR1 transcripts_GAPDH transcripts_GRB7 transcripts_GSTM1 transcripts_GUSB transcripts_MKI67 transcripts_MMP11 transcripts_MYBL2 transcripts_PGR transcripts_RPLP0 transcripts_SCUBE2 transcripts_TFRC)
# Read the names of the files in the folder and assign them to an array 
# transcripts_inp=($(ls -1 "$Reference_Target"))

# Read the file names into an array
# readarray -t transcripts_inp < <(tr -d '\r' < "$genenames_path")

# Define the number of transcripts_inp
n_transcripts=${#transcripts_inp[@]}
#echo -ne "$n_transcripts"
# Define the sums array
declare -a sums

# "SHARED_FOLDER" is a "$1" entred script folder for outputs collection
# Launch the scripts for simulaiting fastq generating
./start_livebc_minknow_P2S_version.sh $sample_id $experiment_group &

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

./livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai 2>/dev/null)" ]; do
  sleep $t
done
# convert a CSV file to a TXT file and delete the header
function csv_to_txt_convert() {
    for genename_f in $@ ; do
        #echo "Processing file: $genename_f"
		#tail -n +2 "$Reference_Target/$genename_f.csv" > "$Reference_Target/$genename_f.txt"
		
		# Remove the header and carriage return characters 
		tail -n +2 "$Reference_Target/$genename_f.csv" | tr -d '\r' > "$Reference_Target/$genename_f.txt"
	done
}
csv_to_txt_convert "${transcripts_inp[@]}"


mkdir $SHARED_FOLDER/mapped_dir/bam_saved

function process_files() {
    local sum=$2
	for file in "$1"; do
        		
		# Read the list of transcripts into an array
        transcripts=($(cat "$file"))
        # Build the samtools view count_mapped_reads_to_Gene
        count_mapped_reads_to_Gene="samtools view -c -F 0x4 $bam_file"
        # Append each transcript to the count_mapped_reads_to_Gene
        for transcript in "${transcripts[@]}"; do
            count_mapped_reads_to_Gene+=" $transcript"
        done

        # Run the command
        gcount=$(eval "$count_mapped_reads_to_Gene")
        # Convert gcount to an integer
        gcount_int=$(echo "$gcount" | awk '{print int($0)}')

        # Add gcount_int to the sum
        sum=$((sum + gcount_int))
		
    done
	echo "$sum"
}

# Define the file name and path
TSV_FILE="$SHARED_FOLDER/genecount_table.tsv"

# Add the header row to the file if it does not exist
if [ ! -f "$TSV_FILE" ]; then
    echo -e "GeneName,CopyNumbers,CycleNumber" > "$TSV_FILE"
fi

ki=0
while true; do

    # Wait until files appear in the mapped_dirfolder
    if ls "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam >/dev/null 2>&1; then
    for bam_file in "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam
        
        do
        	            
			function print_gensums() {
			    local i=$1
			    local transcriptsNames=$2
			    local sum=$3

			    if [ "$sum" -le $n_irr_threshold ]; then
         
			        echo -ne "\rNothing interesting for $transcriptsNames. Yet.... (GeneCount < $n_irr_threshold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"


			     
				else

			       echo -ne "\rGotcha $transcriptsNames!!! (GeneCount > $n_irr_threshold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
			       echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"
			
				fi
                
			    #tput -T xterm cup $(($(tput lines) - i)) 0 # start i = 4(genenames amount) + 1
			     printf "\n%.0s" $(seq 1 $(($(tput lines) - i))) 

			 }
			 
			# Loop through the transcripts_inp and call the process_files function for each transcript file
            for i in $(seq 0 $((n_transcripts - 1))); do
               sums[$i]=$(process_files "$Reference_Target/${transcripts_inp[$i]}.txt" "${sums[$i]}" &)
            done

            # Wait for all the processes to finish
            wait
			
            
            clear
			# Loop through the transcripts_inp and call the print_gensums function for each transcript file
            for i in $(seq 0 $((n_transcripts - 1))); do
                print_gensums $((n_transcripts + n_transcripts - i - 1)) "${transcripts_inp[$i]}" "${sums[$i]}"
            done 

			ki=$((ki+1))
                echo -ne "\n_____________________END of "$ki" cycle___________________________________" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam "$SHARED_FOLDER/mapped_dir/bam_saved/"
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam.bai "$SHARED_FOLDER/mapped_dir/bam_saved/"
            
    done
	
	fi
	sleep $t
done &
# Working time of the mapping (5 min)
sleep $mapp_time

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
echo -ne "\n"


#kill %3
#kill %2
#kill %1

killall start_livebc_minknow_P2S_version.sh # kill %2
killall livebc_mapping.sh  # kill %3
killall livebc_timemanager_main_samtools.sh # kill 1 

# terminate the ss_livebc_timemanager_main.sh after it has completed its execution
exit
