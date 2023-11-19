#!/bin/bash
# chmod +x Dorado_script_m6Anet_docker.sh
# sed -i -e 's/\r$//' Dorado_script_m6Anet_docker.sh
# ./Dorado_script_m6Anet_docker.sh /media/localarchive/m6A-P2S-Arraystar/10min-A
#PATH=/root/anaconda3/bin:$PATH # Check the path
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
        minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq | samtools sort -T tmp -o $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        samtools index $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        echo -e "${BGreen} Launching nanopolish eventalign"
        sudo docker run --rm -v /media:/media quay.io/biocontainers/nanopolish:0.14.0--h773013f_3 nanopolish eventalign \
        --reads $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        --bam $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam \
        --genome $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
	--signal-index \
        -t 10 \
        --scale-events > $basecalled_dirs/processing_nanopolish/eventalign.txt
        
		### m6Anet ###
        echo -e "${BGreen} Launching docker of m6Anet"
        sudo docker pull quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0
        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet dataprep --eventalign $basecalled_dirs/processing_nanopolish/eventalign.txt \
                    --out_dir $basecalled_dirs/processing_m6anet/output_dataprep --n_processes 10
					

        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet inference --input_dir $basecalled_dirs/processing_m6anet/output_dataprep/ \
        --out_dir $basecalled_dirs/processing_m6anet/output_m6anet --n_processes 10 --num_iterations 1000

	
    else
		echo "Error: Input folder do not exist."
		exit 1
	fi
	
