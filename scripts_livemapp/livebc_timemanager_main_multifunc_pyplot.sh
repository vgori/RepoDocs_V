#!/bin/bash
# chmod +x livebc_timemanager_main_multifunc_pyplot.sh
#  sed -i -e 's/\r$//' livebc_timemanager_main_multifunc_pyplot.sh
# ./livebc_timemanager_main_multifunc_pyplot.sh F transcripts_PRL31_1 transcripts_PRL31_2 transcripts_PRL31_3 transcripts_PRL31_4 transcripts_PRL31_5 transcripts_PRL31_6 transcripts_PRL31_7 transcripts_PRL31_8 transcripts_PRL31_9 transcripts_PRL31_10 transcripts_PRL31_11 transcripts_PRL31_12 transcripts_PRL31_13 transcripts_PRL31_14 transcripts_PRL31_15 transcripts_PRL31_16 transcripts_PRL31_17 transcripts_PRL31_18 transcripts_PRL31_19 transcripts_PRL31_20 transcripts_RPS17_1 transcripts_RPS17_2 transcripts_RPS17_3 transcripts_RPS17_4 transcripts_RPS17_5 transcripts_RPS17_6 transcripts_RPS17_7 transcripts_RPS17_8 transcripts_RPS17_9 transcripts_RPS17_10 transcripts_RPS17_11 transcripts_RPS17_12 transcripts_RPS17_13 transcripts_RPS17_14 transcripts_RPS17_15 transcripts_RPS17_16 transcripts_RPS17_17 transcripts_RPS17_18 transcripts_RPS17_19 transcripts_RPS17_20 transcripts_RPS17_21 transcripts_RPS17_22 transcripts_RPS17_23 transcripts_RPS17_24 transcripts_RPS17_25 transcripts_RPS17_26 transcripts_RPS17_27 transcripts_RPS17_28 transcripts_RPS17_29 transcripts_RPS17_30 transcripts_RPS17_31 transcripts_RPS17_32 transcripts_RPS17_33 transcripts_RPS17_34
# For more gene names add: transcriptsNames4="$5"..., 
#                          csv_to_txt_convert ... "transcriptsNames4"
#                          sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
#                          print_gensums 4 "$transcriptsNames4" "$sum4"
# Change the times of \n:   echo -ne "\n\n\n\033[0K\rNothing interesting for $transcriptsNames.
#################### GeneNames_N - 1 = echo -ne "\n\n\n\...
#################### GeneNames_N = last print_gensums N (for the upper N=N+1)


SHARED_FOLDER="/data/DeepSimulator_data/Output_simulation2/E"/"$1"
# echo "Processing args: $transcriptsNames1, $transcriptsNames2, $transcriptsNames3, $transcriptsNames4, $transcriptsNames5, $transcriptsNames6, $transcriptsNames7, $transcriptsNames8, $transcriptsNames9, $transcriptsNames10, $transcriptsNames54"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/data/Reference_Genome_HomoSapiens/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /data/DeepSimulator_data
t=1
mapp_time=100
n_irr_threshold=40

#transcripts=("$transcripts_PRL31_1" "$transcripts_PRL31_2" "$transcripts_PRL31_3" "$transcripts_PRL31_4" "$transcripts_PRL31_5" "$transcripts_PRL31_6" "$transcripts_PRL31_7" "$transcripts_PRL31_8" "$transcripts_PRL31_9" "$transcripts_PRL31_10" "$transcripts_PRL31_11" "$transcripts_PRL31_12" "$transcripts_PRL31_13" "$transcripts_PRL31_14" "$transcripts_PRL31_15" "$transcripts_PRL31_16" "$transcripts_PRL31_17" "$transcripts_PRL31_18" "$transcripts_PRL31_19" "$transcripts_PRL31_20" "$transcripts_RPS17_1" "$transcripts_RPS17_2" "$transcripts_RPS17_3" "$transcripts_RPS17_4" "$transcripts_RPS17_5" "$transcripts_RPS17_6" "$transcripts_RPS17_7" "$transcripts_RPS17_8" "$transcripts_RPS17_9" "$transcripts_RPS17_10" "$transcripts_RPS17_11" "$transcripts_RPS17_12" "$transcripts_RPS17_13" "$transcripts_RPS17_14" "$transcripts_RPS17_15" "$transcripts_RPS17_16" "$transcripts_RPS17_17" "$transcripts_RPS17_18" "$transcripts_RPS17_19" "$transcripts_RPS17_20" "$transcripts_RPS17_21" "$transcripts_RPS17_22" "$transcripts_RPS17_23" "$transcripts_RPS17_24" "$transcripts_RPS17_25" "$transcripts_RPS17_26" "$transcripts_RPS17_27" "$transcripts_RPS17_28" "$transcripts_RPS17_29" "$transcripts_RPS17_30" "$transcripts_RPS17_31" "$transcripts_RPS17_32" "$transcripts_RPS17_33" "$transcripts_RPS17_34")
transcripts_inp=(transcripts_PRL31_1 transcripts_PRL31_2 transcripts_PRL31_3 transcripts_PRL31_4 transcripts_PRL31_5 transcripts_PRL31_6 transcripts_PRL31_7 transcripts_PRL31_8 transcripts_PRL31_9 transcripts_PRL31_10 transcripts_PRL31_11 transcripts_PRL31_12 transcripts_PRL31_13 transcripts_PRL31_14 transcripts_PRL31_15 transcripts_PRL31_16 transcripts_PRL31_17 transcripts_PRL31_18 transcripts_PRL31_19 transcripts_PRL31_20 transcripts_RPS17_1 transcripts_RPS17_2 transcripts_RPS17_3 transcripts_RPS17_4 transcripts_RPS17_5 transcripts_RPS17_6 transcripts_RPS17_7 transcripts_RPS17_8 transcripts_RPS17_9 transcripts_RPS17_10 transcripts_RPS17_11 transcripts_RPS17_12 transcripts_RPS17_13 transcripts_RPS17_14 transcripts_RPS17_15 transcripts_RPS17_16 transcripts_RPS17_17 transcripts_RPS17_18 transcripts_RPS17_19 transcripts_RPS17_20 transcripts_RPS17_21 transcripts_RPS17_22 transcripts_RPS17_23 transcripts_RPS17_24 transcripts_RPS17_25 transcripts_RPS17_26 transcripts_RPS17_27 transcripts_RPS17_28 transcripts_RPS17_29 transcripts_RPS17_30 transcripts_RPS17_31 transcripts_RPS17_32 transcripts_RPS17_33 transcripts_RPS17_34)
#sums=("$sum1" "$sum2" "$sum3" "$sum4" "$sum5" "$sum6" "$sum7" "$sum8" "$sum9" "$sum10" "$sum11" "$sum12" "$sum13" "$sum14" "$sum15" "$sum16" "$sum17" "$sum18" "$sum19" "$sum20" "$sum21" "$sum22" "$sum23" "$sum24" "$sum25" "$sum26" "$sum27" "$sum28" "$sum29" "$sum30" "$sum31" "$sum32" "$sum33" "$sum34" "$sum35" "$sum36" "$sum37" "$sum38" "$sum39" "$sum40" "$sum41" "$sum42" "$sum43" "$sum44" "$sum45" "$sum46" "$sum47" "$sum48" "$sum49" "$sum50" "$sum51" "$sum52" "$sum53" "$sum54")
# Define the number of transcripts_inp
n_transcripts=${#transcripts_inp[@]}
#echo -ne "$n_transcripts"
# Define the sums array
declare -a sums

# "SHARED_FOLDER" is a "$1" entred script folder for outputs collection
# Launch the scripts for simulaiting fastq generating
~/scripts_livemapp/UKserver_version/livebc_cp_fastq.sh $SHARED_FOLDER &

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

~/scripts_livemapp/UKserver_version/livebc_mapping.sh $SHARED_FOLDER $path_to_fastq_pass &

# Wait until files appear in the mapped_dirfolder
while [ ! "$(ls -A $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai 2>/dev/null)" ]; do
  sleep $t
done
# convert a CSV file to a TXT file and delete the header
function csv_to_txt_convert() {
    for genename_f in $@ ; do
        #echo "Processing file: $genename_f"
		tail -n +2 "$Reference_Target/$genename_f.csv" > "$Reference_Target/$genename_f.txt"
	done
}
#csv_to_txt_convert "$transcriptsNames1" "$transcriptsNames2" "$transcriptsNames3" "$transcriptsNames4" "$transcriptsNames5" "$transcriptsNames6" "$transcriptsNames7" "$transcriptsNames8" "$transcriptsNames9" "$transcriptsNames10" "$transcriptsNames11" "$transcriptsNames12" "$transcriptsNames13" "$transcriptsNames14" "$transcriptsNames15" "$transcriptsNames16" "$transcriptsNames17" "$transcriptsNames18" "$transcriptsNames19" "$transcriptsNames20" "$transcriptsNames21" "$transcriptsNames22" "$transcriptsNames23" "$transcriptsNames24" "$transcriptsNames25" "$transcriptsNames26" "$transcriptsNames27" "$transcriptsNames28" "$transcriptsNames29" "$transcriptsNames30" "$transcriptsNames31" "$transcriptsNames32" "$transcriptsNames33" "$transcriptsNames34" "$transcriptsNames35" "$transcriptsNames36" "$transcriptsNames37" "$transcriptsNames38" "$transcriptsNames39" "$transcriptsNames40" "$transcriptsNames41" "$transcriptsNames42" "$transcriptsNames43" "$transcriptsNames44" "$transcriptsNames45" "$transcriptsNames46" "$transcriptsNames47" "$transcriptsNames48" "$transcriptsNames49" "$transcriptsNames50" "$transcriptsNames51" "$transcriptsNames52" "$transcriptsNames53" "$transcriptsNames54"
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
    echo -e "GeneName,GeneCount,Cycle" > "$TSV_FILE"
fi

declare -g ki=0
# python_called=false
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
                             #\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
			        echo -ne "\rNothing interesting for $transcriptsNames. Yet.... (GeneCount < $n_irr_threshold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
					echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"


			     
				else

			       echo -ne "\rGotcha $transcriptsNames!!! (GeneCount > $n_irr_threshold : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
			       echo -e "$transcriptsNames,$sum,$((ki + 1))"  >> "$TSV_FILE"

				#printf "\033[2K\rNothing interesting for %s. Yet.... (GeneCount < 40 : n = %d)\n" "$transcriptsNames" $sum | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
                           #else
                            #    printf "\033[2K\rGotcha %s!!! (GeneCount > 40 : n = %d)\n" "$transcriptsNames" $sum | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
				
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
			# mv "$SHARED_FOLDER/mapped_dir/singlefastq_bam_bai"/index_*.bam.bai "$SHARED_FOLDER/mapped_dir/bam_saved/"
       
           	# Call the Python script only once riching 2nd cycle, that already writed into tsv file(and it will be launched in a parallel with tsv generating) 
			# [ "$python_called" = false ] && ["$(ls -A $SHARED_FOLDER/mapped_dir/bam_saved 2>/dev/null)"
           if  [ "$ki" -eq 2 ]; then
               # python_called=true
               # Var1='/data/DeepSimulator_data/Output_simulation2/E/F'

               python3 ~/scripts_livemapp/UKserver_version/genecounts_plot.py "$SHARED_FOLDER" &
           fi &
    done
	
    fi
    sleep $t

done &

# Working time of the mapping (5 min)
sleep $mapp_time

tput cup $(($(tput lines) - 1)) $(($(tput cols) - 1))
echo -ne "\n"



kill %3
kill %2
kill %1

# terminate the ss_livebc_timemanager_main.sh after it has completed its execution
exit
