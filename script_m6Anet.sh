#!/bin/bash
# chmod +x script_test_m6anet.sh
# sed -i -e 's/\r$//' script_test_m6anet.sh
# ./script_test_m6anet.sh /media/localarchive/m6A-P2S-Arraystar/2min-A
#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
ifolder=$(ls $basecalled_dirs)
path_to_fast5_pass=$(find $basecalled_dirs/$ifolder -name "fast5_pass" -type d)
Reference_Genome="/media/localarchive/transcriptome_ref"

# Recursive function to search for the "workspace" folder with basecalled fast5
function search_for_guppy_output_folder() {
    local current_folder="$1"
    
    # Check if the current folder contains a "workspace" subfolder
    if [[ -d "${current_folder}/workspace" ]]; then
        echo "${current_folder}"
        #return
    else
        # Iterate over each subfolder within the current folder
        for subfolder in "${current_folder}"/*; do
            if [[ -d "${subfolder}" ]]; then
                # Recursively call the function for each subfolder
                local result=$(search_for_guppy_output_folder "${subfolder}")
                if [[ -n "${result}" ]]; then
                    echo "${result}"
                    return
                fi
            fi
        done
    fi
}

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        # Call the recursive function for each subfolder within the common folder

			    guppy_folder=$(search_for_guppy_output_folder "${basecalled_dirs}")
                fastq_pass_result=$guppy_folder/pass
				fast5_pass_result=$guppy_folder/workspace
				#sstxt_result=$(search_for_sstxt_folder "${subfolder}")		

				if [ ! -d $fastq_pass_result ] || [ ! -d $fast5_pass_result ]; then
					echo "Error: One or both of the folders do not exist."
					exit 1
                fi
                
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'pass' folder at: ${fastq_pass_result}"
                    echo -e "${BGreen}Unzipping fastq"
                    #cd $fastq_pass_result
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
        nanopolish index -d $path_to_fast5_pass $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq
        echo -e "${BGreen} Launching minimap2 with splice -k14"
        minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq | samtools sort -T tmp -o $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        samtools index $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam
        echo -e "${BGreen} Launching nanopolish eventalign"
        nanopolish eventalign \
        --reads $basecalled_dirs/processing_nanopolish/single_fastq_$setname.fastq \
        --bam $basecalled_dirs/processing_nanopolish/output_sorted_$setname.bam \
        --genome $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
        --scale-events > $basecalled_dirs/processing_nanopolish/eventalign.txt
        
		### m6Anet ###
        echo -e "${BGreen} Launching docker of m6Anet"
        sudo docker pull quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0
        sudo docker run --rm -v /media/localarchive:/localarchive quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet dataprep --eventalign $basecalled_dirs/processing_nanopolish/eventalign.txt \
                    --out_dir $basecalled_dirs/processing_m6anet/output_dataprep --n_processes 4
					

        sudo docker run --rm -v /media/localarchive:/localarchive quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0 m6anet inference --input_dir $basecalled_dirs/processing_m6anet/output_dataprep/ \
        --out_dir $basecalled_dirs/processing_m6anet/output_m6anet --n_processes 4 --num_iterations 1000

	
    else
		echo "Error: Input folder do not exist."
		exit 1
	fi