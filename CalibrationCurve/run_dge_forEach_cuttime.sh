#!/bin/bash
# chmod +x run_dge_forEach_cuttime.sh
#  sed -i -e 's/\r$//' run_dge_forEach_cuttime.sh
# ./run_dge_forEach_cuttime.sh /media/localarchive/Cutoff_Output/DGE_input 4 05
# Input folder containing subfolders (replace with your actual folder path)
main_folder="$1"
gy=("${@:2}")
# Loop through each folder in the main_folder
for folder in "$main_folder"/*; do
    if [ -d "$folder" ]; then
        # Extract the folder name (e.g., time_cutoff_5, time_cutoff_10, etc.)
        folder_name=$(basename "$folder")
        
        # Execute your command for the current folder
        ./dge_for_Cutoff.sh "$main_folder"/"$folder_name" "${gy[@]}"
    fi &
done
wait
