#!/bin/bash
# chmod +x run_cuttime_forEach_set.sh
#  sed -i -e 's/\r$//' run_cuttime_forEach_set.sh
# ./run_cuttime_forEach_set.sh /media/localarchive/Calibration-4 /media/localarchive/Cutoffs 5 10 15 20
# Input folder containing subfolders (replace with your actual folder path)
main_folder="$1"
output_folder="$2"
cuttime=("${@:3}")
# Loop through each folder in the main_folder
for folder in "$main_folder"/*; do
    if [ -d "$folder" ]; then
        # Extract the folder name (e.g., Set1_05Gy, Set2_4Gy, etc.)
        folder_name=$(basename "$folder")
        
        # Execute your command for the current folder
        ./Cutoff_CORE.sh "$main_folder"/"$folder_name" "$output_folder" "${cuttime[@]}"
    fi &
done
wait

exit
