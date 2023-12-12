#!/bin/bash

# chmod +x test_Dorado_script_QC.sh
# sed -i -e 's/\r$//' test_Dorado_script_QC.sh
# ./test_Dorado_script_QC.sh /media/localarchive/m6A-P2S-Arraystar/10min-A

exec >> "$1"/logfile_$(date +%F).log 2>&1
# Start time for Launching script
start=$(date +%s)

#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
path_to_fastq_pass=$(find $basecalled_dirs -name "fastq_pass" -type d)
Reference_Genome="/media/localarchive/transcriptome_ref"
# Generate a random string of alphanumeric characters
# Directory where the files are locateddirectory="/media/localarchive/m6A-P2S-Arraystar/Control-C/20231103_1517_P2S-00698-A_PAS67129_33201de9"

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        # Call the recursive function for each subfolder within the common folder

			    #dorado_folder=$(search_for_dorado_output_folder "${basecalled_dirs}")
				dorado_folder=$search_for_dorado_output_folder
                fastq_pass_result=$path_to_fastq_pass
               
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'pass' folder at: ${fastq_pass_result}"
                    echo -e "${BGreen}Unzipping fastq"
                    for f in $fastq_pass_result/*.gz ; do sudo gzip -d "$f" ; done
                    echo -e "${BGreen}Done"
                fi

            #fi
        #done
        mkdir $basecalled_dirs/data_processing

        echo -e "${BGreen} gather fastq_s in single fastq file"
        cat $fastq_pass_result/*.fastq > $basecalled_dirs/data_processing/single_fastq_$setname.fastq
        # find $fastq_pass_result -name "*.fastq" -type f -exec cat {} + > $basecalled_dirs/data_processing/single_fastq_$setname.fastq		
        echo -e "${BGreen} Launching nanopolish indexing"
		echo -e "Found 'pass-basecalled' folder at: ${search_for_dorado_output_folder}"


        echo -e "${BGreen} Launching minimap2 with splice -k14"
		start_map=$(date +%s)
        minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens2.GRCh38.cdna.all.fa $basecalled_dirs/data_processing/single_fastq_$setname.fastq | samtools sort -T tmp -o $basecalled_dirs/data_processing/output_sorted_$setname.bam
        end_map=$(date +%s)
		start_samindex=$(date +%s)
		samtools index $basecalled_dirs/data_processing/output_sorted_$setname.bam
		end_samindex=$(date +%s)
        
		echo -e "all aligned:"
        count_all_reads_to_Gene="samtools view -c $basecalled_dirs/data_processing/output_sorted_$setname.bam"
		all_gcount=$(eval "$count_all_reads_to_Gene")
        echo -e "successfully aligned:"
        count_mapped_reads_to_Gene="samtools view -F 4 -c $basecalled_dirs/data_processing/output_sorted_$setname.bam" #successfully aligned
        mapped_gcount=$(eval "$count_mapped_reads_to_Gene")
       	# Convert gcount to an integer
	    # Calculate the ratio of mapped reads to all reads
        ratio_sucsessful_mapped=$(awk "BEGIN {printf \"%.2f\", $mapped_gcount/$all_gcount*100}")
		
		# Print the results
        echo "All reads: $all_gcount"
        echo "Mapped reads: $mapped_gcount"
		echo -e "Ratio of successfully mapped reads to all reads: $ratio_sucsessful_mapped%"
		if (( $(echo "$ratio_sucsessful_mapped <= 54" | bc -l) )); then
            echo -e "!!!!!!!!! Warning: The sucsessful_mapped reads less or equal 54% => $ratio_sucsessful_mapped%" 
        fi
		
		
	
    else
		echo "Error: Input folder do not exist."
		exit 1
	fi
	
# End time of the end of script
end=$(date +%s)

# Time elapsed
elapsed=$((end - start))
elapsed_map=$((end_map - start_map))
elapsed_samindex=$((end_samindex - start_samindex))  

# Overall time in day hour minutes seconds format
day_hour_min_sec=$(date -ud "@$elapsed" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_map=$(date -ud "@$elapsed_map" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_samindex=$(date -ud "@$elapsed_samindex" +'%d days %H hours %M minutes %S seconds')

echo -e "************************ TIME **************************"
echo -e "Time points statistics:"
echo -e "     "
echo -e "Overal script run time"
printf "Start time: %s\n" "$(date -d @$start)"
printf "End time: %s\n" "$(date -d @$end)"
printf "Overall time run: %s\n" "$day_hour_min_sec"
echo -e "     "
echo -e "Mapping run time"
printf  "Start time: %s\n" "$(date -d @$start_map)"
printf  "End time: %s\n" "$(date -d @$end_map)"
printf  "Overall time run: %s\n" "$day_hour_min_sec_map"
echo -e "     "
echo -e "Samtools index run time"
printf  "Start time: %s\n" "$(date -d @$start_samindex)"
printf  "End time: %s\n" "$(date -d @$end_samindex)"
printf  "Overall time run: %s\n" "$day_hour_min_sec_samindex"