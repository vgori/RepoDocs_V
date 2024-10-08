#!/bin/bash
# chmod +x run_cuttime_includedSet.sh
#  sed -i -e 's/\r$//' run_cuttime_includedSet.sh
# ./run_cuttime_includedSet.sh /media/localarchive/ONT-data/4th-calibration /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90
# Input folder containing subfolders (replace with your actual folder names)
# Next folders "H14-3Gy" "P1-4Gy" "H14-2Gy" "P1-2Gy" "P1-3Gy" "P1-5Gy" "P32-01Gy" "P32-025Gy"
folders=("H14-01Gy" "H14-025Gy" "H14-3Gy-repeat" "P1-025Gy" "P1-4Gy-repeat" "P32-01Gy-repeat"  "H14-2Gy" "P1-2Gy" "P1-3Gy" "P1-5Gy" "P32-025Gy")
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
