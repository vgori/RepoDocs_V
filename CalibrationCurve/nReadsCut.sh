#!/bin/bash

# chmod +x nReadsCut.sh
# sed -i -e 's/\r$//' nReadsCut.sh
# ./nReadsCut.sh 108956 /media/localarchive/ONT-data/4th-calibration/

num_reads=$(($1 * 4))
shared_dir=$2
# find recursively single_fastq files
# input_file=$(find $shared_dir -type f -name "single_fastq_*.fastq")
input_file=$(find "$shared_dir" -type f -regex '.*/single_fastq_.*\.fastq')


# Check if exist all files
if [ -z "$input_file" ]; then
    echo "The files single_fastq_*.fastq not found at the dirrectory $shared_dir"
    exit 1
fi

for input_single_fastq in $input_file; do
    modified_name=$(echo "$input_single_fastq" | sed 's/single_//')
	output_file="${modified_name}.${1}.reads.fastq"
    head -n $num_reads "$input_single_fastq" > "$output_file"
done