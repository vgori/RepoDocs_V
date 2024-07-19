#!/bin/bash
exec >> "$1"/logfile_$(date +%F).log 2>&1


# chmod +x test_Cutoff.sh
# sed -i -e 's/\r$//' test_Cutoff.sh
# ./test_Cutoff.sh /data/Cutoff/Input/Sam-UK-Test/MK_05Gy-A Output_blood 5 10 15 20 30 40 60 90
# ./test_Cutoff.sh /data/Cutoff/Input/Sam-UK-Test_awsS3/MK-05Gy-2 5 10 15 20 30 40 60 90 &\ 
# ./test_Cutoff.sh /data/Cutoff/Input/Sam-UK-Test_awsS3/SJS_05Gy 5 10 15 20 30 40 60 90 &\ 
# ./test_Cutoff.sh /data/Cutoff/Input/Sam-UK-Test_awsS3/SK-05Gy 5 10 15 20 30 40 60 90 && fg
#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
# -name "fastq_pass" or -name "pass"
path_to_fastq_pass=$(find $basecalled_dirs -name "data_processing" -type d)

mkdir -p "$2" #"/data/Cutoff/Output/DGE_input"
Output_cutoff="$2" #"/data/Cutoff/Output/DGE_input"

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
		
		cutoff_by_minutes_py="python3 TimePoint_cutoff__fastq_by2000Lines_awsprod.py --input "$basecalled_dirs/data_processing/single_fastq_$setname.fastq""
		for min in "${time_points[@]}"; do
		    mkdir $Output_cutoff/time_cutoff_$min
            mkdir $Output_cutoff/time_cutoff_$min/cut_${setname}_$min
			cuts_out=$Output_cutoff/time_cutoff_$min/cut_${setname}_$min
			python_cmd="$cutoff_by_minutes_py --output \"$cuts_out\" -t $min"
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
	

