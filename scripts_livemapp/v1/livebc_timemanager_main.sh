#!/bin/bash
# chmod +x livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' livebc_timemanager_main.sh
# ./livebc_timemanager_main.sh /media/localarchive/m6A-P2S-Arraystar/10min-A transcriptsNames_RPS17_Gene
SHARED_FOLDER="$1"
transcriptsNames="$2"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"

# "SHARED_FOLDER" is a "$1" entred script folder for outputs collection
# Launch the scripts for simulaiting fastq generating
#~/scripts_livemapp/livebc_cp_fastq.sh $SHARED_FOLDER &

# waiting for 'fastq_pass' folder appeares in the seq output
path_to_fastq_pass=""
while [ -z "$path_to_fastq_pass" ]; do
  path_to_fastq_pass=$(find $shared_dirs -name "fastq_pass" -type d)
  sleep 3
done

~/scripts_livemapp/livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai 2>/dev/null)" ]; do
  sleep 2
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
        	#bam_file=$SHARED_FOLDER"/mapped_dir/singlefastq_bam_bai/index_aligned_RUN_NAME.bam"
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
			if [ "$sum" -le 40 ]; then
			    #echo -ne $(echo -ne "\033[2K\rNothing interesting. Yet.... (GeneCount < 40 : n = $sum)" | sed 's/\x1B\[[0-9;]*[JKmsu]//g') | tee -a "$1"/logfile_genecounts_$(date +%F).log
				echo -ne "\033[0K\rNothing interesting. Yet.... (GeneCount < 40 : n = $sum)" | tee -a "$1"/logfile_genecounts_$(date +%F).log
				#echo -ne "Nothing interesting for "$2". Yet.... (GeneCount < 40 : n = $sum)"\\r | tee -a "$1"/logfile_genecounts_$(date +%F).log
				
			else 
			    #echo -ne $(echo -ne "\033[2K\rGotcha!!! (GeneCount > 40 : n = $sum)" | sed 's/\x1B\[[0-9;]*[JKmsu]//g') | tee -a "$1"/logfile_genecounts_$(date +%F).log
				echo -ne "\033[2K\rGotcha!!! (GeneCount > 40 : n = $sum)" | tee -a "$1"/logfile_genecounts_$(date +%F).log
				#echo -ne "Gotcha "$2" !!! (GeneCount > 40 : n = $sum)"\\r | tee -a "$1"/logfile_genecounts_$(date +%F).log
				
			fi
			tput sc
            tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
            tput rc
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam "$SHARED_FOLDER/mapped_dir/bam_saved/"
            
    done
	fi
	sleep 5
done &
# Working time of the mapping (5 min)
sleep 300

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))


kill %1
kill %2

