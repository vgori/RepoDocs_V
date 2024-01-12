#!/bin/bash
# chmod +x ss_livebc_mapping.sh
# sed -i -e 's/\r$//' ss_livebc_mapping.sh

# $SHARED_FOLDER is a /media/localarchive/ONT-data/real-time-tests/test_A
# Processing the fastq.gz files: path_to_fastq_pass/*.fastq*

# Open file descriptor 3 for writing to the log file
exec >> "$1"/logfile_mapping_$(date +%F).log 2>&1

SHARED_FOLDER="$1"
path_to_fastq_pass="$2"
shared_dirs="${SHARED_FOLDER%/}" 
Reference_Genome="/media/localarchive/transcriptome_ref"

echo "The path to the SHARED folder is $SHARED_FOLDER"
mkdir $SHARED_FOLDER/mapped_dir
mkdir $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai
mkdir $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp
mkdir $SHARED_FOLDER/mapped_dir/fastq_pass_saved
#path_to_fastq_pass=$(find $shared_dirs -name "fastq_pass" -type d)
echo -e "Pass to fsatq_pass:  $path_to_fastq_pass "

k=0

    while (true); do
            # wait for appearing 2 fastq files in fastq pass folder
			file_count=$(find "$path_to_fastq_pass" -maxdepth 1 -type f | wc -l)
            if [ "$file_count" -ge 2 ]
            then
                
                cp $(ls -1A $path_to_fastq_pass/*.fastq* | head -2) $SHARED_FOLDER/mapped_dir/fastq_pass_saved
				mv $(ls -1A $path_to_fastq_pass/*.fastq* | head -2) $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp
                
            
				cat $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp/*.fastq* > $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/fastq_single_RUN_NAME_$k.fastq
				# Run minimap2	
        	    minimap2 -ax splice -uf -k14 $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
                $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/fastq_single_RUN_NAME_$k.fastq | samtools sort \
	            -T tmp -o $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME_$k.bam
				
				echo -e "samtools indexing ... "
        	    samtools index $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME_$k.bam
				echo -e "samtools statistics save to file stat_aligned_*.txt"
        	    samtools idxstats $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME_$k.bam > $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/stat_aligned_RUN_NAME_$k.txt
                
				# rename indexed aligned_bam and bai files to index_*.bam, index_*.bai
				mv $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME_$k.bam $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/index_aligned_RUN_NAME_$k.bam
				mv $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/aligned_RUN_NAME_$k.bam.bai $SHARED_FOLDER/mapped_dir/singlefastq_bam_bai/index_aligned_RUN_NAME_$k.bam.bai
				
				k=$((k+1))
				sum_k=$((sum_k+k))
				rm $SHARED_FOLDER/mapped_dir/bc_fastq_pass_tmp/*.fastq* --recursive
            else
				# waiting till the completely 2 fastq files in folder will be exist
				sleep 10
			
			fi
			echo -ne "This is k="$k" iteration. "
    done
	
