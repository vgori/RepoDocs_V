#!/bin/bash
exec >> "$1"/logfile_$(date +%F).log 2>&1


# chmod +x Cutoff.sh
# sed -i -e 's/\r$//' Cutoff.sh
# ./Cutoff.sh /media/localarchive/m6A-project/m6A-DGE/arraystar 5 10 15 20 30 40 60 90
# ./Cutoff.sh /media/localarchive/m6A-project/m6A-DGE/arraystar/control_0Gy_A 5 10 15 20 30 40 60 90 &\ 
# ./Cutoff.sh /media/localarchive/m6A-project/m6A-DGE/arraystar/control_0Gy_B 5 10 15 20 30 40 60 90 &\ 
# ./Cutoff.sh /media/localarchive/m6A-project/m6A-DGE/arraystar/control_0Gy_C 5 10 15 20 30 40 60 90 && fg
#PATH=/root/anaconda3/bin:$PATH # Check the path
export HDF5_PLUGIN_PATH="/usr/local/hdf5/lib/plugin"

# Define the common folder path
basecalled_dirs="$1" #"/path/to/common/folder/basecalled"  
basecalled_dirs="${basecalled_dirs%/}" # remove trailing slash (if any)
setname="${basecalled_dirs##*/}"
# -name "fastq_pass" or -name "pass"
path_to_fastq_pass=$(find $basecalled_dirs -name "pass" -type d)
#path_to_fastq_pass=$(find $basecalled_dirs -name "fastq_pass" -type d)
# DGE_cutoff="/data/Cutoff/Output/DGE_input"
mkdir "/media/localarchive/Cutoff_Output/DGE_input"
DGE_cutoff="/media/localarchive/Cutoff_Output/DGE_input"
TimePoint_py="~/Calibration_curve"
time_points=("${@:2}") # Capture all arguments starting from the second one (5 10 15 20 30 40 60 90)
# Generate a random string of alphanumeric characters
# Directory where the files are locateddirectory="/media/localarchive/m6A-P2S-Arraystar/Control-C/20231103_1517_P2S-00698-A_PAS67129_33201de9"

# Iterate over each set basecalled_dirs

	if [[ -d "${basecalled_dirs}" ]]; then
        echo "Processing basecalled_dirs: ${basecalled_dirs}"
        
                fastq_pass_result=$path_to_fastq_pass
               
                if [[ -n "${fastq_pass_result}" ]]; then
                    echo "Found 'pass' folder at: ${fastq_pass_result}"
                    echo -e "${BGreen}Unzipping fastq"
                    for f in $fastq_pass_result/*.gz ; do sudo gzip -d "$f" ; done
                    echo -e "${BGreen}Done"
                fi

        mkdir $basecalled_dirs/data_processing

        echo -e "${BGreen} gather fastq_s in single fastq file"
        cat $fastq_pass_result/*.fastq > $basecalled_dirs/data_processing/single_fastq_$setname.fastq
        # find $fastq_pass_result -name "*.fastq" -type f -exec cat {} + > $basecalled_dirs/data_processing/single_fastq_$setname.fastq		
        
        ### Here we can Call NextFlow with py ###
		
		# python3 $TimePoint_py/TimePoint_cutoff__fastq_by2000Lines_awsprod.py --input $basecalled_dirs/data_processing/single_fastq_$setname.fastq --output $basecalled_dirs/time_cutoff_dir/ -t ${#time_points[@]}
		cutoff_by_minutes_py="python3 $TimePoint_py/TimePoint_cutoff__fastq_by2000Lines_awsprod.py --input "$basecalled_dirs/data_processing/*.fastq""
		for min in "${time_points[@]}"; do
		    mkdir $DGE_cutoff/time_cutoff_$min
            mkdir $DGE_cutoff/time_cutoff_$min/cut_${setname}_$min
			cuts_out=$DGE_cutoff/time_cutoff_$min/cut_${setname}_$min
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
	