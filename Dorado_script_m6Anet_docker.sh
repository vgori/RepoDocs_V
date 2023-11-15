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
search_for_dorado_output_folder=$(find $basecalled_dirs -name "pass-basecalled" -type d)
Reference_Genome="/data/Reference_Genome_HomoSapiens"
summary_file="sequencing_summary.txt"

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        # Call the recursive function for each subfolder within the common folder

			    #dorado_folder=$(search_for_dorado_output_folder "${basecalled_dirs}")
				dorado_folder=$search_for_dorado_output_folder
                fastq_pass_result=$dorado_folder/pass
				ssummary_txt="${dorado_folder%/*}/$summary_file"
				#sstxt_result=$(search_for_sstxt_folder "${subfolder}")		
               
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'pass' folder at: ${fastq_pass_result}"
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
		-t 10 \
        --scale-events > $basecalled_dirs/processing_nanopolish/eventalign.txt
        
		### m6Anet ###
        echo -e "${BGreen} Launching docker of m6Anet"
        sudo docker pull quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0
        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet dataprep --eventalign $basecalled_dirs/processing_nanopolish/eventalign.txt \
                    --out_dir $basecalled_dirs/processing_m6anet/output_dataprep --n_processes 6
					

        sudo docker run --rm -v /media:/media quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet inference --input_dir $basecalled_dirs/processing_m6anet/output_dataprep/ \
        --out_dir $basecalled_dirs/processing_m6anet/output_m6anet --n_processes 6 --num_iterations 1000

	
    else
		echo "Error: Input folder do not exist."
		exit 1
	fi
	
