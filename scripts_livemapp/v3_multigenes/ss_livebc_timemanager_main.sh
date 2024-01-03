#!/bin/bash
# chmod +x livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' ss_livebc_timemanager_main.sh  
# ./ss_livebc_timemanager_main.sh /media/localarchive/ONT-data/real-time-tests/test_A transcripts_PRL31 transcripts_RPS17 transcripts_FDXR transcripts_DDB2  


# For more gene names add: transcriptsNames4="$5"..., 
#                          csv_to_txt_convert ... "transcriptsNames4"
#                          sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
#                          print_gensums 4 "$transcriptsNames4" "$sum4"
# Change the times of \n:   echo -ne "\n\n\n\033[0K\rNothing interesting for $transcriptsNames.
#################### GeneNames_N - 1 = echo -ne "\n\n\n\...
#################### GeneNames_N = last print_gensums N (for the upper N=N+1)



SHARED_FOLDER="$1"
transcriptsNames="$2"
transcriptsNames2="$3"
transcriptsNames3="$4"
transcriptsNames4="$5"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /media/localarchive/ONT-data
t=1
mapp_time=60
n_irr_threshold=40

# "SHARED_FOLDER" is a "$1" entred script folder for outputs collection
# Launch the scripts for simulaiting fastq generating
~/scripts_livemapp/v3_multigenes/start_livebc_minknow.sh $sample_id $experiment_group &

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
~/scripts_livemapp/v3_multigenes/livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai 2>/dev/null)" ]; do
  sleep $t
done
# convert a CSV file to a TXT file and delete the header
#tail -n +2 "$Reference_Target/$transcriptsNames.csv" > "$Reference_Target/$transcriptsNames.txt"
function csv_to_txt_convert() {
    for genename_f in $@ ; do
	    tail -n +2 "$Reference_Target/$genename_f.csv" > "$Reference_Target/$genename_f.txt"
	done
}
csv_to_txt_convert "$transcriptsNames1"  "$transcriptsNames2" "$transcriptsNames3" "$transcriptsNames4"

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

					echo -ne "\n\n\n\033[0K\rNothing interesting for $transcriptsNames. Yet.... (GeneCount < 40 : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
			    else

					echo -ne "\n\n\n\033[2K\rGotcha $transcriptsNames!!! (GeneCount > 40 : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
			    fi
                #tput sc
			    tput cup $(($(tput lines) - i)) 0 # start i = 4(genenames amount) + 1
				#tput rc
			 }
			
			# Call the function for gene sum of the transcript files transcriptsNames1 
            sum1=$(process_files "$Reference_Target/$transcriptsNames1.txt" "$sum1")
			print_gensums 7 "$transcriptsNames1" "$sum1" 

            # Call the function for gene sum of the transcript files transcriptsNames2  
			sum2=$(process_files "$Reference_Target/$transcriptsNames2.txt" "$sum2")
            print_gensums 6 "$transcriptsNames2" "$sum2"
			
			# Call the function for gene sum of the transcript files transcriptsNames3 
            sum3=$(process_files "$Reference_Target/$transcriptsNames3.txt" "$sum3")
			print_gensums 5 "$transcriptsNames3" "$sum3" 

            # Call the function for gene sum of the transcript files transcriptsNames4  
			sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
            print_gensums 4 "$transcriptsNames4" "$sum4"
         
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam "$SHARED_FOLDER/mapped_dir/bam_saved/"
            
    done
	fi
	sleep $t
done &
# Working time of the mapping (5 min)
sleep $mapp_time

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
echo -ne "\n"

sudo service minknow stop
sleep 30
sudo service doradod stop
sleep 5
kill %2
kill %1

