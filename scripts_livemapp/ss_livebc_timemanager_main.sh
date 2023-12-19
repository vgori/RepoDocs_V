#!/bin/bash
# chmod +x livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' ss_livebc_timemanager_main.sh
# ./ss_livebc_timemanager_main.sh /media/localarchive/ONT-data/real-time-tests/test_A transcripts_FDXR
SHARED_FOLDER="$1"
transcriptsNames="$2"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /media/localarchive/ONT-data
t=1
mapp_time=30
n_irr_threshold=40

# "SHARED_FOLDER" is a "$1" entred script folder for outputs collection
# Launch the scripts for simulaiting fastq generating
~/scripts_livemapp/start_livebc_minknow.sh $sample_id $experiment_group &

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
~/scripts_livemapp/livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai 2>/dev/null)" ]; do
  sleep $t
done
# convert a CSV file to a TXT file and delete the header
tail -n +2 "$Reference_Target/$transcriptsNames.csv" > "$Reference_Target/$transcriptsNames.txt"
mkdir $SHARED_FOLDER/mapped_dir/bam_saved

while true; do

    # Wait until files appear in the mapped_dirfolder
    if ls "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam >/dev/null 2>&1; then
    for bam_file in "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam
        do
        	# Path to the BAM file
        	#bam_file=$SHARED_FOLDER"/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME.bam"
        	# Path to the file containing the list of transcripts
        	transcript_file="$Reference_Target/$transcriptsNames.txt"
        	# Read the list of transcripts into an array
        	transcripts=($(cat "$transcript_file"))
        	# Build the samtools view count_mapped_reads_to_Gene
        	count_mapped_reads_to_Gene="samtools view -c -F 0x4 $bam_file"
        	# Append each transcript to the count_mapped_reads_to_Gene
        	gcount=""
        	for transcript in "${transcripts[@]}"; do
            	count_mapped_reads_to_Gene+=" $transcript"
        	done

        	# Run the command
        	# eval "$count_mapped_reads_to_Gene"
        	gcount=$(eval "$count_mapped_reads_to_Gene")
        	# Convert gcount to an integer
        	gcount_int=$(echo "$gcount" | awk '{print int($0)}')

	    	# Add gcount_int to the sum
        	sum=$((sum + gcount_int))
			
			# Check the gcount sum condition 
			if [ "$sum" -le $n_irr_threshold ]; then
			    #echo -ne $(echo -ne "\033[2K\rNothing interesting. Yet.... (GeneCount < 40 : n = $sum)" | sed 's/\x1B\[[0-9;]*[JKmsu]//g') | tee -a "$1"/logfile_genecounts_$(date +%F).log
				echo -ne "\033[0K\rNothing interesting for "$2". Yet.... (GeneCount < 40 : n = $sum)" | tee -a "$1"/logfile_genecounts_$(date +%F).log
				#echo -ne "Nothing interesting for "$2". Yet.... (GeneCount < 40 : n = $sum)"\\r | tee -a "$1"/logfile_genecounts_$(date +%F).log
				
			else 
			    #echo -ne $(echo -ne "\033[2K\rGotcha!!! (GeneCount > 40 : n = $sum)" | sed 's/\x1B\[[0-9;]*[JKmsu]//g') | tee -a "$1"/logfile_genecounts_$(date +%F).log
				echo -ne "\033[2K\rGotcha "$2"!!! (GeneCount > 40 : n = $sum)" | tee -a "$1"/logfile_genecounts_$(date +%F).log
				#echo -ne "Gotcha "$2" !!! (GeneCount > 40 : n = $sum)"\\r | tee -a "$1"/logfile_genecounts_$(date +%F).log
				
			fi
			tput sc
            tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
            tput rc
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam "$SHARED_FOLDER/mapped_dir/bam_saved/"
            
    done
	fi
	sleep $t
done &
# Working time of the mapping (5 min)
sleep $mapp_time

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))

sudo service minknow stop
sleep 30
sudo service doradod stop
sleep 5
kill %2
kill %1

