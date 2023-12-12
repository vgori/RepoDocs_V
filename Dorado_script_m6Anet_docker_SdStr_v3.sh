<<<<<<< HEAD
#!/bin/bash

# chmod +x Dorado_script_m6Anet_docker_SdStr_v3.sh
# sed -i -e 's/\r$//' Dorado_script_m6Anet_docker_SdStr_v3.sh
# ./Dorado_script_m6Anet_docker_SdStr_v3.sh /media/localarchive/m6A-P2S-Arraystar/10min-A

exec >> "$1"/logfile_$(date +%F).log 2>&1
# Start time for Launching script
start=$(date +%s)

export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
#ifolder=$(ls $basecalled_dirs)
path_to_fast5_pass=$(find $basecalled_dirs -name "fast5_pass" -type d)
path_to_fastq_pass=$(find $basecalled_dirs -name "fastq_pass" -type d)
Reference_Genome="/media/localarchive/transcriptome_ref"
# Find the summary_file with the specified pattern
summary_file=$(find $basecalled_dirs -type f -name "sequencing_summary_*.txt")
if the summary_file is foundif [ -z "$summary_file" ]; then
    echo "No summary_file found with the specified pattern"    exit 1
fi
# Output the found summary_file pathecho "Found summary_file: $summary_file"
# Example of how to use the summary_file path in a subsequent command

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        # Call the recursive function for each subfolder within the common folder

			    #dorado_folder=$(search_for_dorado_output_folder "${basecalled_dirs}")
				dorado_folder=$search_for_dorado_output_folder
                fastq_pass_result=$path_to_fastq_pass
				ssummary_txt=$summary_file	
               
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'fastq_pass' folder at: ${fastq_pass_result}"
                    echo -e "${BGreen}Unzipping fastq"
                    for f in $fastq_pass_result/*.gz ; do sudo gzip -d "$f" ; done
                    echo -e "${BGreen}Done"
                fi

        mkdir $basecalled_dirs/processing_nanopolish
        mkdir $basecalled_dirs/processing_m6anet
        mkdir $basecalled_dirs/processing_m6anet/output_dataprep
        mkdir $basecalled_dirs/processing_m6anet/output_m6anet
        echo -e "${BGreen} gather fastq_s in single fastq file"
        cat $fastq_pass_result/*.fastq > $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq 
        # find $fastq_pass_result -name "*.fastq" -type f -exec cat {} + > $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq
		echo -e "${BGreen} Launching nanopolish indexing"
        echo -e "Found 'sequencing_summary.txt' file at: ${ssummary_txt}"
        echo -e "Found 'fast5_pass' folder at: ${path_to_fast5_pass}"
        # nanopolish info https://bioconda.github.io/recipes/nanopolish/README.html
        # new_path="${path#/*/}"
		# /media/localarchive:/localarchive
		sudo docker pull quay.io/biocontainers/nanopolish:0.14.0--h773013f_3
        sudo docker run --rm -v /media:/media quay.io/biocontainers/nanopolish:0.14.0--h773013f_3 nanopolish index \
        -d $path_to_fast5_pass $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        -s $ssummary_txt
        echo -e "${BGreen} Launching minimap2 with splice -k14"
        start_map=$(date +%s)
		minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq | samtools sort -T tmp -o $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        end_map=$(date +%s)
		start_samindex=$(date +%s)
		samtools index $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
		end_samindex=$(date +%s)
        
		
		echo -e "all aligned:"
        count_all_reads_to_Gene="samtools view -c $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam"
		all_gcount=$(eval "$count_all_reads_to_Gene")
        echo -e "successfully aligned:"
        count_mapped_reads_to_Gene="samtools view -F 4 -c $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam" #successfully aligned
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
		
		echo -e "${BGreen} Launching nanopolish eventalign"
		start_eventalign=$(date +%s)
        sudo docker run --rm -v /media:/media quay.io/biocontainers/nanopolish:0.14.0--h773013f_3 nanopolish eventalign \
        --reads $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        --bam $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam \
        --genome $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
		--signal-index \
        -t 10 \
        --scale-events > $basecalled_dirs/processing_nanopolish/eventalign.txt
        end_eventalign=$(date +%s)
		### m6Anet ###
        echo -e "${BGreen} Launching docker of m6Anet"
		start_m6Anet_dataprep=$(date +%s)
        sudo docker pull quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0
        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet dataprep --eventalign $basecalled_dirs/processing_nanopolish/eventalign.txt \
        --out_dir $basecalled_dirs/processing_m6anet/output_dataprep --n_processes 10
		end_m6Anet_dataprep=$(date +%s)
					
        start_m6Anet_inference=$(date +%s)
		sudo docker run --rm -v /media:/media --shm-size=900g quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet inference --input_dir $basecalled_dirs/processing_m6anet/output_dataprep/ \
        --out_dir $basecalled_dirs/processing_m6anet/output_m6anet --n_processes 10 --num_iterations 1000
		end_m6Anet_inference=$(date +%s)

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
elapsed_eventalign=$((end_eventalign - start_eventalign))
elapsed_dataprep=$((end_m6Anet_dataprep - start_m6Anet_dataprep))
elapsed_inference=$((end_m6Anet_inference - start_m6Anet_inference))
# Overall time in day hour minutes seconds format
day_hour_min_sec=$(date -ud "@$elapsed" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_map=$(date -ud "@$elapsed_map" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_samindex=$(date -ud "@$elapsed_samindex" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_eventalign=$(date -ud "@$elapsed_eventalign" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_dataprep=$(date -ud "@$elapsed_dataprep" +'%d days %H hours %M minutes %S seconds')
day_hour_min_sec_inference=$(date -ud "@$elapsed_inference" +'%d days %H hours %M minutes %S seconds')
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
echo -e "     "
echo -e "Eventalign run time"
printf  "Start time: %s\n" "$(date -d @$start_eventalign)"
printf "End time: %s\n" "$(date -d @$end_eventalign)"
printf "Overall time run: %s\n" "$day_hour_min_sec_eventalign"
echo -e "     "
echo -e "m6Anet dataprep run time"
printf "Start time: %s\n" "$(date -d @$start_m6Anet_dataprep)"
printf "End time: %s\n" "$(date -d @$end_m6Anet_dataprep)"
printf "Overall time run: %s\n" "$day_hour_min_sec_dataprep"
echo -e "     "
echo -e "m6Anet inference run time"
printf "Start time: %s\n" "$(date -d @$start_m6Anet_inference)"
printf "End time: %s\n" "$(date -d @$end_m6Anet_inference)"
=======
#!/bin/bash

# chmod +x Dorado_script_m6Anet_docker_SdStr_v3.sh
# sed -i -e 's/\r$//' Dorado_script_m6Anet_docker_SdStr_v3.sh
# ./Dorado_script_m6Anet_docker_SdStr_v3.sh /media/localarchive/m6A-P2S-Arraystar/10min-A

exec >> "$1"/logfile_$(date +%F).log 2>&1
# Start time for Launching script
start=$(date +%s)

export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
#ifolder=$(ls $basecalled_dirs)
path_to_fast5_pass=$(find $basecalled_dirs -name "fast5_pass" -type d)
path_to_fastq_pass=$(find $basecalled_dirs -name "fastq_pass" -type d)
Reference_Genome="/media/localarchive/transcriptome_ref"
# Find the summary_file with the specified pattern
summary_file=$(find $basecalled_dirs -type f -name "sequencing_summary_*.txt")
if the summary_file is foundif [ -z "$summary_file" ]; then
    echo "No summary_file found with the specified pattern"    exit 1
fi
# Output the found summary_file pathecho "Found summary_file: $summary_file"
# Example of how to use the summary_file path in a subsequent command

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        # Call the recursive function for each subfolder within the common folder

			    #dorado_folder=$(search_for_dorado_output_folder "${basecalled_dirs}")
				dorado_folder=$search_for_dorado_output_folder
                fastq_pass_result=$path_to_fastq_pass
				ssummary_txt=$summary_file	
               
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'fastq_pass' folder at: ${fastq_pass_result}"
                    echo -e "${BGreen}Unzipping fastq"
                    for f in $fastq_pass_result/*.gz ; do sudo gzip -d "$f" ; done
                    echo -e "${BGreen}Done"
                fi

        mkdir $basecalled_dirs/processing_nanopolish
        mkdir $basecalled_dirs/processing_m6anet
        mkdir $basecalled_dirs/processing_m6anet/output_dataprep
        mkdir $basecalled_dirs/processing_m6anet/output_m6anet
        echo -e "${BGreen} gather fastq_s in single fastq file"
        cat $fastq_pass_result/*.fastq > $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq 
        # find $fastq_pass_result -name "*.fastq" -type f -exec cat {} + > $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq
		echo -e "${BGreen} Launching nanopolish indexing"
        echo -e "Found 'sequencing_summary.txt' file at: ${ssummary_txt}"
        echo -e "Found 'fast5_pass' folder at: ${path_to_fast5_pass}"
        # nanopolish info https://bioconda.github.io/recipes/nanopolish/README.html
        # new_path="${path#/*/}"
		# /media/localarchive:/localarchive
		sudo docker pull quay.io/biocontainers/nanopolish:0.14.0--h773013f_3
        sudo docker run --rm -v /media:/media quay.io/biocontainers/nanopolish:0.14.0--h773013f_3 nanopolish index \
        -d $path_to_fast5_pass $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        -s $ssummary_txt
        echo -e "${BGreen} Launching minimap2 with splice -k14"
        start_map=$(date +%s)
		minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq | samtools sort -T tmp -o $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        end_map=$(date +%s)
		start_samindex=$(date +%s)
		samtools index $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
		end_samindex=$(date +%s)
        
		
		echo -e "all aligned:"
        count_all_reads_to_Gene="samtools view -c $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam"
		all_gcount=$(eval "$count_all_reads_to_Gene")
        echo -e "successfully aligned:"
        count_mapped_reads_to_Gene="samtools view -F 4 -c $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam" #successfully aligned
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
		
		echo -e "${BGreen} Launching nanopolish eventalign"
		start_eventalign=$(date +%s)
        sudo docker run --rm -v /media:/media quay.io/biocontainers/nanopolish:0.14.0--h773013f_3 nanopolish eventalign \
        --reads $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        --bam $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam \
        --genome $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
		--signal-index \
        -t 10 \
        --scale-events > $basecalled_dirs/processing_nanopolish/eventalign.txt
        end_eventalign=$(date +%s)
		### m6Anet ###
        echo -e "${BGreen} Launching docker of m6Anet"
		start_m6Anet_dataprep=$(date +%s)
        sudo docker pull quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0
        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet dataprep --eventalign $basecalled_dirs/processing_nanopolish/eventalign.txt \
        --out_dir $basecalled_dirs/processing_m6anet/output_dataprep --n_processes 10
		end_m6Anet_dataprep=$(date +%s)
					
        start_m6Anet_inference=$(date +%s)
		sudo docker run --rm -v /media:/media --shm-size=900g quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet inference --input_dir $basecalled_dirs/processing_m6anet/output_dataprep/ \
        --out_dir $basecalled_dirs/processing_m6anet/output_m6anet --n_processes 10 --num_iterations 1000
		end_m6Anet_inference=$(date +%s)

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
elapsed_eventalign=$((end_eventalign - start_eventalign))
elapsed_dataprep=$((end_m6Anet_dataprep - start_m6Anet_dataprep))
elapsed_inference=$((end_m6Anet_inference - start_m6Anet_inference))
# Overall time in day hour minutes seconds format
day_hour_min_sec=$(date -ud "@$elapsed" +'%H hours %M minutes %S seconds')
day_hour_min_sec_map=$(date -ud "@$elapsed_map" +'%H hours %M minutes %S seconds')
day_hour_min_sec_samindex=$(date -ud "@$elapsed_samindex" +'%H hours %M minutes %S seconds')
day_hour_min_sec_eventalign=$(date -ud "@$elapsed_eventalign" +'%H hours %M minutes %S seconds')
day_hour_min_sec_dataprep=$(date -ud "@$elapsed_dataprep" +'%H hours %M minutes %S seconds')
day_hour_min_sec_inference=$(date -ud "@$elapsed_inference" +'%H hours %M minutes %S seconds')
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
echo -e "     "
echo -e "Eventalign run time"
printf  "Start time: %s\n" "$(date -d @$start_eventalign)"
printf "End time: %s\n" "$(date -d @$end_eventalign)"
printf "Overall time run: %s\n" "$day_hour_min_sec_eventalign"
echo -e "     "
echo -e "m6Anet dataprep run time"
printf "Start time: %s\n" "$(date -d @$start_m6Anet_dataprep)"
printf "End time: %s\n" "$(date -d @$end_m6Anet_dataprep)"
printf "Overall time run: %s\n" "$day_hour_min_sec_dataprep"
echo -e "     "
echo -e "m6Anet inference run time"
printf "Start time: %s\n" "$(date -d @$start_m6Anet_inference)"
printf "End time: %s\n" "$(date -d @$end_m6Anet_inference)"
>>>>>>> cab5bb7235da41ecf301e596694407c368736ad5
printf "Overall time run: %s\n" "$day_hour_min_sec_inference"