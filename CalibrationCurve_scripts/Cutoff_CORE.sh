#!/bin/bash
exec >> "$1"/logfile_$(date +%F).log 2>&1


# chmod +x Cutoff_CORE.sh
# sed -i -e 's/\r$//' Cutoff_CORE.sh
# ./Cutoff_CORE.sh /media/localarchive/ONT-data/4th-calibration/H14-3Gy /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90 \
# & ./Cutoff_CORE.sh /media/localarchive/ONT-data/4th-calibration/P1-4Gy /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90 \ 
# & ./Cutoff_CORE.sh /media/localarchive/ONT-data/4th-calibration/P32-1Gy /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90 && fg
 
#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"
NUM_CPUS=20
# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
# -name "fastq_pass" or -name "pass"
path_to_fastq_pass=$(find $basecalled_dirs -name "data_processing" -type d)

mkdir -p "$2" 
Output_cutoff="$2" 

time_points=("${@:3}") # Capture all arguments starting from the second one (5 10 15 20 30 40 60 90)

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        fastq_pass_result=$path_to_fastq_pass

        #echo -e "${BGreen} gather fastq_s in single fastq file"
        #cat $fastq_pass_result/*.fastq > $basecalled_dirs/data_processing/single_fastq_$setname.fastq
        #find "$fastq_pass_result" -name '*.fastq' -print0 | xargs -0 cat > "$basecalled_dirs/data_processing/single_fastq_$setname.fastq"
        #find $fastq_pass_result -name "*.fastq" -type f -exec cat {} + > $basecalled_dirs/data_processing/single_fastq_$setname.fastq		
        
        ### Here we can Call NextFlow with py ###
		
		cutoff_by_minutes_py="python3 TimePoint_cutoff__fastq_by2000Lines_awsprod_CORE.py --input "$basecalled_dirs/data_processing/single_fastq_$setname.fastq""
		for min in "${time_points[@]}"; do
		    mkdir $Output_cutoff/time_cutoff_$min
            mkdir $Output_cutoff/time_cutoff_$min/cut_${setname}_$min
			cuts_out=$Output_cutoff/time_cutoff_$min/cut_${setname}_$min
			python_cmd="$cutoff_by_minutes_py --output \"$cuts_out\" -t $min --cores $NUM_CPUS"
			# executing my Python script with the constructed command
            echo "Executing Python script with time points: $min..."
            eval "$python_cmd" &
        done
        # Wait for all the processes to finish
        wait

	
    else
		echo "Error: Input folder do not exist."
		exit 1
	fi
	


