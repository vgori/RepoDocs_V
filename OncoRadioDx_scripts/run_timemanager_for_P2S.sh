#!/bin/bash
# chmod +x run_timemanager_for_P2S.sh
# sed -i -e 's/\r$//' run_timemanager_for_P2S.sh
# RUN: ./run_timemanager_for_P2S.sh FC1 FC2
# run_timemanager_for_P2S.sh --input_tsv='FC1 FC2' --output='Oncotypedx_results'


# Parse arguments
for arg in "$@"
do
  case $arg in
    --input_tsv=*)
      input_tsv="${arg#*=}"
      input_tsv=($input_tsv)  # Convert space-separated string to array
      shift
      ;;
    --output=*)
      output="${arg#*=}"
      shift
      ;;
    *)
      # Unknown option
      ;;
  esac
done

SHARED_FOLDER="/media/localarchive/ONT-data/real-time-tests"
# Define multiple arguments to pass to the R script
# Initialize the args string
args=""

# Build the args string dynamically based on input_tsv array
for tsv in "${input_tsv[@]}"
do
  args="$args $SHARED_FOLDER/$tsv/genecount_table.tsv"
done

# Remove leading whitespace from args
args=$(echo $args | sed 's/^ //')

# Run several scripts in parallel, redirecting their outputs to separate log files
for i in ${!input_tsv[@]}
do
  ./livebc_timemanager_main_samtools.sh ${input_tsv[i]} > "$SHARED_FOLDER/${input_tsv[i]}/output_${input_tsv[i]}.log" 2>&1 &
done

# Wait for both scripts to complete
wait

# Create output directory if it doesn't exist
mkdir -p "./$output"
oncodx_output_dir="./$output"

#Call the Normalization R script module with the arguments
./Normalisation_oncotypedx_21gene.R $args $oncodx_output_dir

#Call the Classification risc score R script module 
./Classification_riskscore_oncotypedx_21gene.R $oncodx_output_dir
