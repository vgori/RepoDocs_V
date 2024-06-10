#!/bin/bash
# Dependensied: sudo apt install csvkit
# chmod +x create_samplesheet_file.sh
#  sed -i -e 's/\r$//' create_samplesheet_file.sh
# ./create_samplesheet_file.sh /data/Cutoff/Output/DGE_input/time_cutoff_5 4 05

main_folder="$1" # "/data/Cutoff/Input/FTO-KO_DGE/time_cutoff_10" # "/path/to/Main_Folder"
#gy="$2"
gy=("${@:2}")

for gray in "${gy[@]}"; do
	mkdir "${main_folder}/processing_0vs"${gray}"Gy"
	path_gy="${main_folder}/processing_0vs"${gray}"Gy"
	# Create the header for the "tmp_sample_sheet.csv" file
	echo "barcode,alias,ID,condition" > "$path_gy/tmp_sample_sheet.csv"

	# Initialize the ID counters for control and irradiated
	control_ID=0
	irradiated_ID=0

	# Loop through each folder
	for folder in "${main_folder}"/cut_*; do
		# Extract the barcode from the folder name
		barcode=$(basename "$folder")

		# Extract the condition (control or irradiated) from the barcode
		if [[ "$barcode" == *"0Gy"* || "$barcode" == *"0GY"* ]]; then
			condition="control"
			((control_ID++))
			ID="$control_ID"
			alias="control$ID"  
		elif [[ "$barcode" == *""$gray"Gy"* || "$barcode" == *""$gray"GY"* ]]; then
			condition="irradiated"
			((irradiated_ID++))
			ID="$irradiated_ID"
			alias="exp$ID"
		else
			# Skip folders that don't match the expected pattern
			continue
		fi

		# Append the data to the "tmp_sample_sheet" file
		echo "$barcode,$alias,$ID,$condition" >> "$path_gy/tmp_sample_sheet.csv"
	done

	# Sort the tmp_sample_sheet.csv file by condition (controls first)
	csvsort -c 'condition' "$path_gy/tmp_sample_sheet.csv" >> "$path_gy/sample_sheet.csv"
	# head -n1 "$main_folder/sample_sheet_"$gray"Gy.csv"; tail -n+2 "$main_folder/processing_0vs"$gy"Gy/sample_sheet.csv" | sort -k4 -r
	echo "Done! 'sample_sheet.csv' created in '$path_gy'."

	# remove the tmp not ordered tmp_sample_sheet
	rm "$path_gy/tmp_sample_sheet.csv"

	echo "Create a new file 'nextflow_instruction' in '$main_folder'."
	# Create a new file named 'nextflow_instruction' with the specified content

	echo "nextflow run CMB-research/wf-transcriptomes \\
	--fastq $main_folder \\
	--transcriptome-source precomputed \\
	--de_analysis \\
	--ref_annotation /data/Reference_Genome_HomoSapiens/Homo_sapiens.GRCh38.102.gtf \\
	--ref_transcriptome /data/Reference_Genome_HomoSapiens/Homo_sapiens2.GRCh38.cdna.all.fa \\
	--minimap2_index_opts '-uf -k14' \\
	--sample_sheet $path_gy/sample_sheet.csv \\
	--ref_genome /data/Reference_Genome_HomoSapiens/Homo_sapiens2.GRCh38.cdna.all.fa \\
	-c ~/.nextflow/assets/CMB-research/wf-transcriptomes/nextflow.config \\
	--out_dir $path_gy/output" > "$path_gy/nextflow_instruction"
  
	# Read from the nextflow_instruction the command into variable
	dge_command=$(cat "$main_folder/processing_0vs"$gray"Gy/nextflow_instruction")

    dge_cmd="sudo $dge_command"
	echo "Executing DGE pipeline script for group pair Control vs "$gray" ..."
    eval "$dge_cmd" &
done
#sudo nextflow clean -f
# Wait for all the processes to finish
wait
sudo rm ./work/ --recursive