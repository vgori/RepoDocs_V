#!/bin/bash
# chmod +x ss_livebc_timemanager_main.sh
#  sed -i -e 's/\r$//' ss_livebc_timemanager_main.sh
# ./ss_livebc_timemanager_main.sh /media/localarchive/ONT-data/real-time-tests/test_A transcripts_AEN transcripts_APOBEC3H transcripts_ASTN2 transcripts_BAX transcripts_BBC3 transcripts_BLOC1S2 transcripts_CCNG1 transcripts_CCR4 transcripts_CD70 transcripts_CDKN1A transcripts_CTSO transcripts_DDB2 transcripts_DOK7 transcripts_DUSP3 transcripts_EDA2R transcripts_FBXW2 transcripts_FDXR transcripts_GADD45A transcripts_GDF15 transcripts_GRM2 transcripts_GZMA transcripts_HPRT1 transcripts_IGFBP5 transcripts_IGLV1-44 transcripts_MAMDC4 transcripts_MDM2 transcripts_MLH1 transcripts_MYC transcripts_NKG7 transcripts_NovelPseudogene_ENSG00000283234 transcripts_PCNA transcripts_PF4 transcripts_PHPT1 transcripts_POLH transcripts_POU2AF1 transcripts_PPM1D transcripts_PRRX1 transcripts_PTP4A1_Pseudogene_ENSG00000278275 transcripts_RAD23A transcripts_RAD51 transcripts_RBM15 transcripts_RBM3 transcripts_RPL23AP42 transcripts_RPS19P1 transcripts_RPS27 transcripts_SESN1 transcripts_SOD1 transcripts_SPATA18 transcripts_TNFRSF10B transcripts_TNFSF4 transcripts_VWCE transcripts_XPC transcripts_ZMAT3 transcripts_WNT3__ENSG00000108379

# For more gene names add: transcriptsNames4="$5"..., 
#                          csv_to_txt_convert ... "transcriptsNames4", ..., ...
#                          sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4")
#                          print_gensums 4 "$transcriptsNames4" "$sum4"
# Change the times of \n:   echo -ne "\n\n\n\033[2K\rNothing interesting for $transcriptsNames.
#################### GeneNames_N - 1 = echo -ne "\n\n\n\...
#################### GeneNames_N = last print_gensums N (for the upper N=counts(n\)+N) is 3+4 or 5+6 or 53+54



SHARED_FOLDER="$1"
transcriptsNames1="$2"
transcriptsNames2="$3"
transcriptsNames3="$4"
transcriptsNames4="$5"
transcriptsNames5="$6"
transcriptsNames6="$7"
transcriptsNames7="$8"
transcriptsNames8="$9"
transcriptsNames9="${10}"
transcriptsNames10="${11}"
transcriptsNames11="${12}"
transcriptsNames12="${13}"
transcriptsNames13="${14}"
transcriptsNames14="${15}"
transcriptsNames15="${16}"
transcriptsNames16="${17}"
transcriptsNames17="${18}"
transcriptsNames18="${19}"
transcriptsNames19="${20}"
transcriptsNames20="${21}"
transcriptsNames21="${22}"
transcriptsNames22="${23}"
transcriptsNames23="${24}"
transcriptsNames24="${25}"
transcriptsNames25="${26}"
transcriptsNames26="${27}"
transcriptsNames27="${28}"
transcriptsNames28="${29}"
transcriptsNames29="${30}"
transcriptsNames30="${31}"
transcriptsNames31="${32}"
transcriptsNames32="${33}"
transcriptsNames33="${34}"
transcriptsNames34="${35}"
transcriptsNames35="${36}"
transcriptsNames36="${37}"
transcriptsNames37="${38}"
transcriptsNames38="${39}"
transcriptsNames39="${40}"
transcriptsNames40="${41}"
transcriptsNames41="${42}"
transcriptsNames42="${43}"
transcriptsNames43="${44}"
transcriptsNames44="${45}"
transcriptsNames45="${46}"
transcriptsNames46="${47}"
transcriptsNames47="${48}"
transcriptsNames48="${49}"
transcriptsNames49="${50}"
transcriptsNames50="${51}"
transcriptsNames51="${52}"
transcriptsNames52="${53}"
transcriptsNames53="${54}"
transcriptsNames54="${55}"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts"
sample_id=$(basename "$SHARED_FOLDER") #test_A
experiment_group=$(basename "$(dirname "$SHARED_FOLDER")") # real-time-tests
parent_dir=$(dirname $(dirname "$SHARED_FOLDER")) # /media/localarchive/ONT-data
t=1
mapp_time=259200 # 72h =  259200s
n_irr_threshold=12

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
# csv_to_txt_convert "$transcriptsNames1" "$transcriptsNames2" "$transcriptsNames3" "$transcriptsNames4" "$transcriptsNames5" "$transcriptsNames6" "$transcriptsNames7" "$transcriptsNames8" "$transcriptsNames9" "$transcriptsNames10" "$transcriptsNames11" "$transcriptsNames12" "$transcriptsNames13" "$transcriptsNames14" "$transcriptsNames15" "$transcriptsNames16" "$transcriptsNames17" "$transcriptsNames18" "$transcriptsNames19" "$transcriptsNames20" "$transcriptsNames21" "$transcriptsNames22" "$transcriptsNames23" "$transcriptsNames24" "$transcriptsNames25" "$transcriptsNames26" "$transcriptsNames27" "$transcriptsNames28" "$transcriptsNames29" "$transcriptsNames30" "$transcriptsNames31" "$transcriptsNames32" "$transcriptsNames33" "$transcriptsNames34" "$transcriptsNames35" "$transcriptsNames36" "$transcriptsNames37" "$transcriptsNames38" "$transcriptsNames39" "$transcriptsNames40" "$transcriptsNames41" "$transcriptsNames42" "$transcriptsNames43" "$transcriptsNames44" "$transcriptsNames45" "$transcriptsNames46" "$transcriptsNames47" "$transcriptsNames48" "$transcriptsNames49" "$transcriptsNames50" "$transcriptsNames51" "$transcriptsNames52" "$transcriptsNames53" "$transcriptsNames54"

# Call the function in parallel for each variable
csv_to_txt_convert "$transcriptsNames1" &
csv_to_txt_convert "$transcriptsNames2" &
csv_to_txt_convert "$transcriptsNames3" &
csv_to_txt_convert "$transcriptsNames4" &
csv_to_txt_convert "$transcriptsNames5" &
csv_to_txt_convert "$transcriptsNames6" &
csv_to_txt_convert "$transcriptsNames7" &
csv_to_txt_convert "$transcriptsNames8" &
csv_to_txt_convert "$transcriptsNames9" &
csv_to_txt_convert "$transcriptsNames10" &
csv_to_txt_convert "$transcriptsNames11" &
csv_to_txt_convert "$transcriptsNames12" &
csv_to_txt_convert "$transcriptsNames13" &
csv_to_txt_convert "$transcriptsNames14" &
csv_to_txt_convert "$transcriptsNames15" &
csv_to_txt_convert "$transcriptsNames16" &
csv_to_txt_convert "$transcriptsNames17" &
csv_to_txt_convert "$transcriptsNames18" &
csv_to_txt_convert "$transcriptsNames19" &
csv_to_txt_convert "$transcriptsNames20" &
csv_to_txt_convert "$transcriptsNames21" &
csv_to_txt_convert "$transcriptsNames22" &
csv_to_txt_convert "$transcriptsNames23" &
csv_to_txt_convert "$transcriptsNames24" &
csv_to_txt_convert "$transcriptsNames25" &
csv_to_txt_convert "$transcriptsNames26" &
csv_to_txt_convert "$transcriptsNames27" &
csv_to_txt_convert "$transcriptsNames28" &
csv_to_txt_convert "$transcriptsNames29" &
csv_to_txt_convert "$transcriptsNames30" &
csv_to_txt_convert "$transcriptsNames31" &
csv_to_txt_convert "$transcriptsNames32" &
csv_to_txt_convert "$transcriptsNames33" &
csv_to_txt_convert "$transcriptsNames34" &
csv_to_txt_convert "$transcriptsNames35" &
csv_to_txt_convert "$transcriptsNames36" &
csv_to_txt_convert "$transcriptsNames37" &
csv_to_txt_convert "$transcriptsNames38" &
csv_to_txt_convert "$transcriptsNames39" &
csv_to_txt_convert "$transcriptsNames40" &
csv_to_txt_convert "$transcriptsNames41" &
csv_to_txt_convert "$transcriptsNames42" &
csv_to_txt_convert "$transcriptsNames43" &
csv_to_txt_convert "$transcriptsNames44" &
csv_to_txt_convert "$transcriptsNames45" &
csv_to_txt_convert "$transcriptsNames46" &
csv_to_txt_convert "$transcriptsNames47" &
csv_to_txt_convert "$transcriptsNames48" &
csv_to_txt_convert "$transcriptsNames49" &
csv_to_txt_convert "$transcriptsNames50" &
csv_to_txt_convert "$transcriptsNames51" &
csv_to_txt_convert "$transcriptsNames52" &
csv_to_txt_convert "$transcriptsNames53" &
csv_to_txt_convert "$transcriptsNames54" &
# Wait for all functions to complete
wait

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
			    else
				    echo -ne "\rGotcha $transcriptsNames!!! (GeneCount > 12 : n = $sum)" | tee -a $SHARED_FOLDER/logfile_genecounts_$(date +%F).log
				fi

			    #tput cup $(($(tput lines) - i)) 0 # start i = 4(genenames amount) + 1
				printf "\n%.0s" $(seq 1 $(($(tput lines) - i))) 

			 }
			
            # Call the function for gene sum of the transcript files transcriptsNames1 
            sum1=$(process_files "$Reference_Target/$transcriptsNames1.txt" "$sum1" &) 
			
            # Call the function for gene sum of the transcript files transcriptsNames2  
			sum2=$(process_files "$Reference_Target/$transcriptsNames2.txt" "$sum2" &) 
            
			# Call the function for gene sum of the transcript files transcriptsNames3 
            sum3=$(process_files "$Reference_Target/$transcriptsNames3.txt" "$sum3" &) 
			 
            # Call the function for gene sum of the transcript files transcriptsNames4  
			sum4=$(process_files "$Reference_Target/$transcriptsNames4.txt" "$sum4" &)
		    
			# Call the function for gene sum of the transcript files transcriptsNames5 
            sum5=$(process_files "$Reference_Target/$transcriptsNames5.txt" "$sum5" &) 
			 
            # Call the function for gene sum of the transcript files transcriptsNames6  
			sum6=$(process_files "$Reference_Target/$transcriptsNames6.txt" "$sum6" &)
			sum7=$(process_files "$Reference_Target/$transcriptsNames7.txt" "$sum7" &)
			sum8=$(process_files "$Reference_Target/$transcriptsNames8.txt" "$sum8" &)
			sum9=$(process_files "$Reference_Target/$transcriptsNames9.txt" "$sum9" &) 
			sum10=$(process_files "$Reference_Target/$transcriptsNames10.txt" "$sum10" &)
			sum11=$(process_files "$Reference_Target/$transcriptsNames11.txt" "$sum11" &)
			sum12=$(process_files "$Reference_Target/$transcriptsNames12.txt" "$sum12" &)
			sum13=$(process_files "$Reference_Target/$transcriptsNames13.txt" "$sum13" &)
			sum14=$(process_files "$Reference_Target/$transcriptsNames14.txt" "$sum14" &)
			sum15=$(process_files "$Reference_Target/$transcriptsNames15.txt" "$sum15" &)
			sum16=$(process_files "$Reference_Target/$transcriptsNames16.txt" "$sum16" &)
			sum17=$(process_files "$Reference_Target/$transcriptsNames17.txt" "$sum17" &)
			sum18=$(process_files "$Reference_Target/$transcriptsNames18.txt" "$sum18" &)
			sum19=$(process_files "$Reference_Target/$transcriptsNames19.txt" "$sum19" &)
			sum20=$(process_files "$Reference_Target/$transcriptsNames20.txt" "$sum20" &)
			sum21=$(process_files "$Reference_Target/$transcriptsNames21.txt" "$sum21" &)
			sum22=$(process_files "$Reference_Target/$transcriptsNames22.txt" "$sum22" &)
			sum23=$(process_files "$Reference_Target/$transcriptsNames23.txt" "$sum23" &)
			sum24=$(process_files "$Reference_Target/$transcriptsNames24.txt" "$sum24" &)
			sum25=$(process_files "$Reference_Target/$transcriptsNames25.txt" "$sum25" &)
			sum26=$(process_files "$Reference_Target/$transcriptsNames26.txt" "$sum26" &)
			sum27=$(process_files "$Reference_Target/$transcriptsNames27.txt" "$sum27" &)
			sum28=$(process_files "$Reference_Target/$transcriptsNames28.txt" "$sum28" &)
			sum29=$(process_files "$Reference_Target/$transcriptsNames29.txt" "$sum29" &)
			sum30=$(process_files "$Reference_Target/$transcriptsNames30.txt" "$sum30" &)
			sum31=$(process_files "$Reference_Target/$transcriptsNames31.txt" "$sum31" &)
			sum32=$(process_files "$Reference_Target/$transcriptsNames32.txt" "$sum32" &)
			sum33=$(process_files "$Reference_Target/$transcriptsNames33.txt" "$sum33" &)
			sum34=$(process_files "$Reference_Target/$transcriptsNames34.txt" "$sum34" &)
			sum35=$(process_files "$Reference_Target/$transcriptsNames35.txt" "$sum35" &)
			sum36=$(process_files "$Reference_Target/$transcriptsNames36.txt" "$sum36" &)
			sum37=$(process_files "$Reference_Target/$transcriptsNames37.txt" "$sum37" &)
			sum38=$(process_files "$Reference_Target/$transcriptsNames38.txt" "$sum38" &)
			sum39=$(process_files "$Reference_Target/$transcriptsNames39.txt" "$sum39" &)
			sum40=$(process_files "$Reference_Target/$transcriptsNames40.txt" "$sum40" &)
			sum41=$(process_files "$Reference_Target/$transcriptsNames41.txt" "$sum41" &)
			sum42=$(process_files "$Reference_Target/$transcriptsNames42.txt" "$sum42" &)
			sum43=$(process_files "$Reference_Target/$transcriptsNames43.txt" "$sum43" &)
			sum44=$(process_files "$Reference_Target/$transcriptsNames44.txt" "$sum44" &)
			sum45=$(process_files "$Reference_Target/$transcriptsNames45.txt" "$sum45" &)
			sum46=$(process_files "$Reference_Target/$transcriptsNames46.txt" "$sum46" &)
			sum47=$(process_files "$Reference_Target/$transcriptsNames47.txt" "$sum47" &)
			sum48=$(process_files "$Reference_Target/$transcriptsNames48.txt" "$sum48" &)
			sum49=$(process_files "$Reference_Target/$transcriptsNames49.txt" "$sum49" &)
			sum50=$(process_files "$Reference_Target/$transcriptsNames50.txt" "$sum50" &)
			sum51=$(process_files "$Reference_Target/$transcriptsNames51.txt" "$sum51" &)
			sum52=$(process_files "$Reference_Target/$transcriptsNames52.txt" "$sum52" &)
			sum53=$(process_files "$Reference_Target/$transcriptsNames53.txt" "$sum53" &)
			sum54=$(process_files "$Reference_Target/$transcriptsNames54.txt" "$sum54" &)

			wait
			clear
			print_gensums 107 "$transcriptsNames1" "$sum1"
			print_gensums 106 "$transcriptsNames2" "$sum2"
			print_gensums 105 "$transcriptsNames3" "$sum3"
			print_gensums 104 "$transcriptsNames4" "$sum4"
			print_gensums 103 "$transcriptsNames5" "$sum5"
			print_gensums 102 "$transcriptsNames6" "$sum6"
			print_gensums 101 "$transcriptsNames7" "$sum7"
			print_gensums 100 "$transcriptsNames8" "$sum8"
			print_gensums 99 "$transcriptsNames9" "$sum9"
			print_gensums 98 "$transcriptsNames10" "$sum10"
			print_gensums 97 "$transcriptsNames11" "$sum11"
			print_gensums 96 "$transcriptsNames12" "$sum12"
			print_gensums 95 "$transcriptsNames13" "$sum13"
			print_gensums 94 "$transcriptsNames14" "$sum14"
			print_gensums 93 "$transcriptsNames15" "$sum15"
			print_gensums 92 "$transcriptsNames16" "$sum16"
			print_gensums 91 "$transcriptsNames17" "$sum17"
			print_gensums 90 "$transcriptsNames18" "$sum18"
			print_gensums 89 "$transcriptsNames19" "$sum19"
			print_gensums 88 "$transcriptsNames20" "$sum20"
			print_gensums 87 "$transcriptsNames21" "$sum21"
			print_gensums 86 "$transcriptsNames22" "$sum22"
			print_gensums 85 "$transcriptsNames23" "$sum23"
			print_gensums 84 "$transcriptsNames24" "$sum24"
			print_gensums 83 "$transcriptsNames25" "$sum25"
			print_gensums 82 "$transcriptsNames26" "$sum26"
			print_gensums 81 "$transcriptsNames27" "$sum27"
			print_gensums 80 "$transcriptsNames28" "$sum28"
			print_gensums 79 "$transcriptsNames29" "$sum29"
			print_gensums 78 "$transcriptsNames30" "$sum30"
			print_gensums 77 "$transcriptsNames31" "$sum31"
			print_gensums 76 "$transcriptsNames32" "$sum32"
			print_gensums 75 "$transcriptsNames33" "$sum33"
			print_gensums 74 "$transcriptsNames34" "$sum34"
			print_gensums 73 "$transcriptsNames35" "$sum35"
			print_gensums 72 "$transcriptsNames36" "$sum36"
			print_gensums 71 "$transcriptsNames37" "$sum37"
			print_gensums 70 "$transcriptsNames38" "$sum38"
			print_gensums 69 "$transcriptsNames39" "$sum39"
			print_gensums 68 "$transcriptsNames40" "$sum40"
			print_gensums 67 "$transcriptsNames41" "$sum41"
			print_gensums 66 "$transcriptsNames42" "$sum42"
			print_gensums 65 "$transcriptsNames43" "$sum43"
			print_gensums 64 "$transcriptsNames44" "$sum44"
			print_gensums 63 "$transcriptsNames45" "$sum45"
			print_gensums 62 "$transcriptsNames46" "$sum46"
			print_gensums 61 "$transcriptsNames47" "$sum47"
			print_gensums 60 "$transcriptsNames48" "$sum48"
			print_gensums 59 "$transcriptsNames49" "$sum49"
			print_gensums 58 "$transcriptsNames50" "$sum50"
			print_gensums 57 "$transcriptsNames51" "$sum51"
			print_gensums 56 "$transcriptsNames52" "$sum52"
			print_gensums 55 "$transcriptsNames53" "$sum53"
			print_gensums 54 "$transcriptsNames54" "$sum54"
			
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