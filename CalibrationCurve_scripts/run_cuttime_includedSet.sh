#!/bin/bash
# chmod +x run_cuttime_includedSet.sh
#  sed -i -e 's/\r$//' run_cuttime_includedSet.sh
# ./run_cuttime_includedSet.sh /media/localarchive/Calibration-4 /media/localarchive/Cutoffs 1 3 5 7 8 10
# Input folder containing subfolders (replace with your actual folder names)
folders=("test-H48-2Gy-2" "test-H48-2Gy-3")
your_command="./Cutoff_CORE.sh"
#your_command="./Cutoff.sh"

main_folder="$1"
output_folder="$2"
cuttime=("${@:3}")


for folder in "${folders[@]}"; do
    $your_command "$main_folder/$folder" "$output_folder" "${cuttime[@]}" &
done

wait

exit
