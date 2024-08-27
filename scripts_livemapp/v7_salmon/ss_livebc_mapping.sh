#!/bin/bash
# chmod +x ss_livebc_mapping.sh
# sed -i -e 's/\r$//' ss_livebc_mapping.sh

# $SHARED_FOLDER is a /media/localarchive/ONT-data/real-time-tests/test_A

# Open file descriptor 3 for writing to the log file
exec >> "$1"/logfile_mapping_$(date +%F).log 2>&1

NUM_CPUS=30
SHARED_FOLDER="$1"
path_to_fastq_pass="$2"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Genome="/media/localarchive/transcriptome_ref"

echo "The path to the SHARED folder is $SHARED_FOLDER"
mkdir $SHARED_FOLDER/mapped_dir
mkdir $SHARED_FOLDER/mapped_dir/singlefastq_bam
mkdir $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp
mkdir $SHARED_FOLDER/mapped_dir/fastq_pass_saved

echo -e "Pass to fsatq_pass:  $path_to_fastq_pass "

k=0

while (true); do
    # wait for appearing 2 fastq files in fastq pass folder
    file_count=$(find "$path_to_fastq_pass" -maxdepth 1 -type f | wc -l)
    if [ "$file_count" -ge 2 ]
    then
        # copy two basecalled .fastq or .fastq.gz to “/mapped_dir/fastq_pass_saved” and move to “/mapped_dir/bc_fastq_pass_tmp”
        cp $(ls -1A $path_to_fastq_pass/*.fastq* | head -2) $SHARED_FOLDER/mapped_dir/fastq_pass_saved
        mv $(ls -1A $path_to_fastq_pass/*.fastq* | head -2) $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp
                
        # make a single fastq file from two .fastq or .fastq.gz files
        cat $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp/*.fastq* > $SHARED_FOLDER/mapped_dir/singlefastq_bam/fastq_single_RUN_NAME_$k.fastq
        # Run minimap2	
        minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
        $SHARED_FOLDER/mapped_dir/singlefastq_bam/fastq_single_RUN_NAME_$k.fastq | samtools sort \
        -T tmp -o $SHARED_FOLDER/mapped_dir/singlefastq_bam/aligned_RUN_NAME_$k.bam
				
        echo -e "Run salmon quant in Alignment-Based Mode"
		salmon quant --noErrorModel -p $NUM_CPUS -t $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa -l SF -a $SHARED_FOLDER/mapped_dir/singlefastq_bam/aligned_RUN_NAME_$k.bam -o $SHARED_FOLDER/mapped_dir/salmon_quant_alignmentmode_$k
        # make txt format from quant.sf
		echo -e "Rewrite quant.sf to quant.txt format "
		cp $SHARED_FOLDER/mapped_dir/salmon_quant_alignmentmode_$k/quant.sf $SHARED_FOLDER/mapped_dir/salmon_quant_alignmentmode_$k/quant.txt
        cp $SHARED_FOLDER/mapped_dir/salmon_quant_alignmentmode_$k/quant.txt $SHARED_FOLDER/mapped_dir/singlefastq_bam
		mv $SHARED_FOLDER/mapped_dir/singlefastq_bam/quant.txt $SHARED_FOLDER/mapped_dir/singlefastq_bam/stat_aligned_RUN_NAME_$k.txt
				
		mv $SHARED_FOLDER/mapped_dir/singlefastq_bam/aligned_RUN_NAME_$k.bam $SHARED_FOLDER/mapped_dir/singlefastq_bam/index_aligned_RUN_NAME_$k.bam
		rm $SHARED_FOLDER/mapped_dir/salmon_quant_alignmentmode_$k --recursive
				
		k=$((k+1))
		rm $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp/*.fastq* --recursive
    else
        # waiting till the completely 2 fastq files in folder will be exist
        sleep 10		
    fi
    echo -ne "This is k="$k" iteration. "
done
	
