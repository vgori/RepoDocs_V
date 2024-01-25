#!/bin/bash
# chmod +x ss_livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' ss_livebc_timemanager_main.sh
# ./ss_livebc_timemanager_main.sh test_A 
# For more gene names add: transcriptsNames4="$5"..., 
#                          csv_to_txt_convert ... "transcriptsNames4", ..., ...
#                          sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
#                          print_gensums 4 "$transcriptsNames4" "$sum4"
# Change the times of \n:   echo -ne "\n\n\n\033[2K\rNothing interesting for $transcriptsNames.
#################### GeneNames_N - 1 = echo -ne "\n\n\n\...
#################### GeneNames_N = last print_gensums N (for the upper N=counts(n\)+N) is 3+4 or 5+6 or 53+54



SHARED_FOLDER="/media/localarchive/ONT-data/real-time-tests"/"$1"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /media/localarchive/ONT-data
t=1
mapp_time=259200 # 72h =  259200s
n_irr_threshold=12

transcripts_inp=(transcripts_AEN transcripts_APOBEC3H transcripts_ASTN2 transcripts_BAX transcripts_BBC3 transcripts_BLOC1S2 transcripts_CCNG1 transcripts_CCR4 transcripts_CD70 transcripts_CDKN1A transcripts_CTSO transcripts_DDB2 transcripts_DOK7 transcripts_DUSP3 transcripts_EDA2R transcripts_FBXW2 transcripts_FDXR transcripts_GADD45A transcripts_GDF15 transcripts_GRM2 transcripts_GZMA transcripts_HPRT1 transcripts_IGFBP5 transcripts_IGLV1-44 transcripts_MAMDC4 transcripts_MDM2 transcripts_MLH1 transcripts_MYC transcripts_NKG7 transcripts_NovelPseudogene_ENSG00000283234 transcripts_PCNA transcripts_PF4 transcripts_PHPT1 transcripts_POLH transcripts_POU2AF1 transcripts_PPM1D transcripts_PRRX1 transcripts_PTP4A1_Pseudogene_ENSG00000278275 transcripts_RAD23A transcripts_RAD51 transcripts_RBM15 transcripts_RBM3 transcripts_RPL23AP42 transcripts_RPS19P1 transcripts_RPS27 transcripts_SESN1 transcripts_SOD1 transcripts_SPATA18 transcripts_TNFRSF10B transcripts_TNFSF4 transcripts_VWCE transcripts_XPC transcripts_ZMAT3 transcripts_WNT3_ENSG00000108379)

# Define the number of transcripts_inp
n_transcripts=${#transcripts_inp[@]}
#echo -ne "$n_transcripts"
# Define the sums array
declare -a sums

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
~/scripts_livemapp/ss_livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

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
                    echo -ne "\rNothing interesting for $transcriptsNames. Yet.... (GeneCount < 12 : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"
			    else
				    echo -ne "\rGotcha $transcriptsNames!!! (GeneCount > 12 : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"
				fi

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
            echo -ne "\n_____________________END of the "$ki" cycle___________________________________" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
    
			mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam "$SHARED_FOLDER/mapped_dir/bam_saved/"
            
    done
	fi
	sleep $t
done &
# Working time of the mapping (5 min)
sleep $mapp_time

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
echo -ne "\n"

#sudo service minknow stop
sudo systemctl stop minknow
sleep 30

#sudo service doradod stop
sudo systemctl stop doradod

sleep 5
kill %2
kill %1

# terminate the ss_livebc_timemanager_main.sh after it has completed its execution
exit