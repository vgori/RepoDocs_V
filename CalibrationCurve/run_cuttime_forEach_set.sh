#!/bin/bash
# chmod +x run_cuttime_forEach_set.sh
#  sed -i -e 's/\r$//' run_cuttime_forEach_set.sh
# ./run_cuttime_forEach_set.sh /media/localarchive/m6A-project/m6A-DGE/arraystar 5 10 15 20 30 40 60 90
# Input folder containing subfolders (replace with your actual folder path)
main_folder="$1"
cuttime=("${@:2}")
# Loop through each folder in the main_folder
for folder in "$main_folder"/*; do
    if [ -d "$folder" ]; then
        # Extract the folder name (e.g., control_0Gy_A, control_0Gy_B, .. , MK_05Gy_A, etc.)
        folder_name=$(basename "$folder")
        
        # Execute your command for the current folder
        ./Cutoff.sh "$main_folder"/"$folder_name" "${cuttime[@]}"
    fi &
done
wait