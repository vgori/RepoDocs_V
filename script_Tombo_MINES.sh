#!/bin/bash
# chmod +x script_Tombo_MINES.sh
# sed -i -e 's/\r$//' script_Tombo_MINES.sh
# ./script_Tombo_MINES.sh /media/localarchive/m6A-P2S-Arraystar/2min-A
#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
Reference_Genome="/media/localarchive/transcriptome_ref"
mines_path="/media/localarchive/m6a-tools/MINES"

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

# Define the input basecalled folder path
#basecalled_dirs="/media/localarchive/m6a-arraystar-P2S/" + !Have to check existing folders! /ont-guppy_bc/workspace/
# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
        #cd $basecalled_dirs
        # Call the recursive function for each subfolder within the common folder
        #for subfolder in ./*; do
            #if [[ -d "${subfolder}" ]]; then
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
            #fi
        #done
        echo -e "${BGreen}Launching multi_to_single_fast5"
        multi_to_single_fast5 -i $fast5_pass_result -s $basecalled_dirs/$input_subfolder/processing_TomboMINES/SingleFast5s/ --recursive
        #echo -e "${BGreen}Launching tombo preprocess"
        #tombo preprocess annotate_raw_with_fastqs --fast5-basedir $basecalled_dirs/$input_subfolder/processing_TomboMINES/SingleFast5s/ \
		#--fastq-filenames $fastq_pass_result/*.fastq --sequencing-summary-filenames $sstxt_result \
		#--overwrite --processes 18
        # Run Tombo
        echo -e "${BGreen}Launching tombo resquiggle"
        tombo resquiggle $basecalled_dirs/$input_subfolder/processing_TomboMINES/SingleFast5s/ $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa \
		--rna --processes 18 --overwrite --num-most-common-errors 5
        echo -e "${BGreen}Launching tombo detect_modifications"
        tombo detect_modifications de_novo --fast5-basedirs $basecalled_dirs/$input_subfolder/processing_TomboMINES/SingleFast5s/ \
		--statistics-file-basename $basecalled_dirs/$input_subfolder/processing_TomboMINES/$setname.de_novoFisher_m6A-detect \
		--fishers-method-context 3 --per-read-statistics-basename $basecalled_dirs/$input_subfolder/processing_TomboMINES/$setname.per-read.de_novoFisher_m6A-detec \
		--processes 18
        echo -e "${BGreen}Launching tombo text_output"
        tombo text_output browser_files --fast5-basedirs $basecalled_dirs/$input_subfolder/processing_TomboMINES/SingleFast5s/ \
		--statistics-filename $basecalled_dirs/$input_subfolder/processing_TomboMINES/$setname.de_novoFisher_m6A-detect.tombo.stats \
		--browser-file-basename $basecalled_dirs/$input_subfolder/processing_TomboMINES/output_$setname.de_novo --file-types coverage fraction
        echo -e "${BGreen}Launching wig2bed"
        time wig2bed --multisplit bar --keep-header < $basecalled_dirs/$input_subfolder/processing_TomboMINES/output_$setname.de_novo.fraction_modified_reads.plus.wig > $basecalled_dirs/$input_subfolder/processing_TomboMINES/output_$setname.de_novo.fraction_modified_reads.plus.wig.bed
        # Run MINES
        echo -e "${BGreen}Launching cDNA_MINES"
        mkdir $basecalled_dirs/$input_subfolder/processing_TomboMINES/MINES_output
        python $mines_path/cDNA_MINES.py \
		--fraction_modified $basecalled_dirs/$input_subfolder/processing_TomboMINES/output_$setname.de_novo.fraction_modified_reads.plus.wig.bed \
		--coverage $basecalled_dirs/$input_subfolder/processing_TomboMINES/output_$setname.de_novo.coverage.plus.bedgraph \
		--output $basecalled_dirs/$input_subfolder/processing_TomboMINES/MINES_output/$setname.de_novo.Fisher.plus-cDNA.bed \
        --ref $Reference_Genome/Homo_sapiens.GRCh38.cdna.all.fa --kmer_models $mines_path/Final_Models/GGACT_9_random_forest_model.pickle

    else
		echo "Error: Input folder do not exist."
		exit 1
	fi	
