# !/bin/bash
set -euo pipefail
# chmod +x SamSal_tools.sh
#  sed -i -e 's/\r$//' SamSal_tools.sh
# ./SamSal_tools.sh <Time_cutoff folder name> <cut_Set1_0Gy_1> <Output_SamSaltools_cutoffs>
# ./SamSal_tools.sh time_cutoff_10 cut_Set1_0Gy_10 Output_SamSaltools_cutoffs


NUM_CPUS=30
# input folder
SHARED_FOLDER="/media/localarchive/Cutoffs"/"$1"/"$2"
expanded_SHARED_FOLDER=$(python -c "import os; print(os.path.expanduser('$SHARED_FOLDER'))")
transcripts_inp=(transcripts_AEN transcripts_APOBEC3H transcripts_ASTN2 transcripts_BAX transcripts_BBC3 transcripts_BLOC1S2 transcripts_CCNG1 transcripts_CCR4 transcripts_CD70 transcripts_CDKN1A transcripts_CTSO transcripts_DDB2 transcripts_DOK7 transcripts_DUSP3 transcripts_EDA2R transcripts_FBXW2 transcripts_FDXR transcripts_GADD45A transcripts_GDF15 transcripts_GRM2 transcripts_GZMA transcripts_HPRT1 transcripts_IGFBP5 transcripts_IGLV1-44 transcripts_MAMDC4 transcripts_MDM2 transcripts_MLH1 transcripts_MYC transcripts_NKG7 transcripts_NovelPseudogene_ENSG00000283234 transcripts_PCNA transcripts_PF4 transcripts_PHPT1 transcripts_POLH transcripts_POU2AF1 transcripts_PPM1D transcripts_PRRX1 transcripts_PTP4A1_Pseudogene_ENSG00000278275 transcripts_RAD23A transcripts_RAD51 transcripts_RBM15 transcripts_RBM3 transcripts_RPL23AP42 transcripts_RPS19P1 transcripts_RPS27 transcripts_SESN1 transcripts_SOD1 transcripts_SPATA18 transcripts_TNFRSF10B transcripts_TNFSF4 transcripts_VWCE transcripts_XPC transcripts_ZMAT3 transcripts_WNT3_ENSG00000108379)
# output folder
OUTPUT_FOLDER="/media/localarchive"/"$3"/"counts_$2"
expanded_OUTPUT_FOLDER=$(python -c "import os; print(os.path.expanduser('$OUTPUT_FOLDER'))")
mkdir -p $expanded_OUTPUT_FOLDER
#wirite into log file all processes
exec >> "$expanded_OUTPUT_FOLDER"/logfile_$(date +%F).log 2>&1
sample_id=$(basename "$expanded_OUTPUT_FOLDER") #cut_Set1_0Gy_10
Reference_Genome_cdna="/data/Reference_Genome_HomoSapiens/Homo_sapiens.GRCh38.cdna.all.fa"
Reference_Target="/data/Reference_Genome_HomoSapiens/Target_GeneTranscripts"
Reference_Folder="/data/Reference_Genome_HomoSapiens"
# Expand the tildes to absolute paths using Python
expanded_Reference_Genome_cdna=$(python -c "import os; print(os.path.expanduser('$Reference_Genome_cdna'))")
expanded_Reference_Target=$(python -c "import os; print(os.path.expanduser('$Reference_Target'))")
expanded_Reference_Folder=$(python -c "import os; print(os.path.expanduser('$Reference_Folder'))")
# Define the file name and path
TSV_FILE="$expanded_OUTPUT_FOLDER/genecount53_table_$sample_id.tsv"
# Define the number of transcripts_inp
n_transcripts=${#transcripts_inp[@]}
#echo -ne "$n_transcripts"
# Define the sums array
declare -a sums

function process_files() {
    local sum=$2
	for file in "$1"; do
        		
		# Read the list of transcripts into an array
        transcripts=($(cat "$file"))
        # Build the samtools view count_mapped_reads_to_Gene
        count_mapped_reads_to_Gene="samtools view -@ $NUM_CPUS -c -F 0x4 $bam_file"
        # Append each transcript to the count_mapped_reads_to_Gene
        for transcript in "${transcripts[@]}"; do
            count_mapped_reads_to_Gene+=" $transcript"
        done

        # Run the command
        gcount=$(eval "$count_mapped_reads_to_Gene")
        # Convert gcount to an integer
        gcount_int=$(echo "$gcount" | awk '{print int($0)}')

        # Add gcount_int to the sum
        sum=$((sum + gcount_int))
		
    done
	echo "$sum"
}

function print_gensums() {
			    local i=$1
			    local transcriptsNames=$2
			    local sum=$3
				echo -e "$transcriptsNames,$sum"  >> "$TSV_FILE"

}
			 
# convert a CSV file to a TXT file and delete the header
function csv_to_txt_convert() {
    for genename_f in $@ ; do
        #echo "Processing file: $genename_f"
		tail -n +2 "$expanded_Reference_Target/$genename_f.csv" > "$expanded_Reference_Target/$genename_f.txt"
	done
}
csv_to_txt_convert "${transcripts_inp[@]}"
			 


# Add the header row to the file if it does not exist
if [ ! -f "$TSV_FILE" ]; then
    echo -e "GeneName,ReadCounts" > "$TSV_FILE"
fi

# chek if exist folder with bam file
if [[ -d "${expanded_OUTPUT_FOLDER}" ]]; then
    # Check if there are any .bam files in the folder
    bam_files=("$expanded_OUTPUT_FOLDER"/*.bam)
    if [[ ${#bam_files[@]} -gt 0 ]]; then
        echo "Processing .bam files in: ${expanded_OUTPUT_FOLDER}"
	  else
        echo "No .bam files found in: $expanded_OUTPUT_FOLDER"
		exit 1
    fi

else
    echo "Error: Folder $expanded_OUTPUT_FOLDER does not exist."
    exit 1
fi

# Run minimap2	
    minimap2 -ax splice -uf -k14 -t $NUM_CPUS $expanded_Reference_Genome_cdna \
    $expanded_SHARED_FOLDER/output_Cutted_*.fastq | samtools sort \
	-T tmp -o $expanded_OUTPUT_FOLDER/aligned_Cutted_$sample_id.bam
# Run samtools				
	echo -e "samtools indexing ... "
    samtools index -@ $NUM_CPUS $expanded_OUTPUT_FOLDER/aligned_Cutted_$sample_id.bam
	echo -e "samtools statistics save to file stat_aligned_*.txt"
    samtools idxstats $expanded_OUTPUT_FOLDER/aligned_Cutted_$sample_id.bam > $expanded_OUTPUT_FOLDER/samtools_aligned_Cutted_$sample_id.txt
    
	# Run 52gene counts after samtools output satat file
	for bam_file in "$expanded_OUTPUT_FOLDER"/aligned_Cutted_$sample_id.bam; do 
	    
			# Loop through the transcripts_inp and call the process_files function for each transcript file
            for i in $(seq 0 $((n_transcripts - 1))); do
               sums[$i]=$(process_files "$expanded_Reference_Target/${transcripts_inp[$i]}.txt" "${sums[$i]:=0}" &)
            done
			wait
			# Loop through the transcripts_inp and call the print_gensums function for each transcript file
            for i in $(seq 0 $((n_transcripts - 1))); do
                print_gensums $((n_transcripts + n_transcripts - i - 1)) "${transcripts_inp[$i]}" "${sums[$i]}"
            done 

    done 

# Run Salmon quant to quntify ENSTs counts aligned reads

	
	echo -e "Run salmon quant in Alignment-Based Mode"
	# OR use Way2: Alignment-Based Mode
	# use same version GRCh38.cdna.all.fa as for bam file 
	salmon quant --noErrorModel -p $NUM_CPUS -t $expanded_Reference_Genome_cdna -l SF -a $expanded_OUTPUT_FOLDER/aligned_Cutted_$sample_id.bam -o $expanded_OUTPUT_FOLDER/salmon_quant_alignmentmode
    
	# Create or extract ENST list enst_list.txt from referense genome file
	# Check if exist file if not - create
	if [ ! -f "$expanded_Reference_Folder/enst_list.txt" ]; then
		# Create or extract ENST list from reference genome file
		grep "^>" $expanded_Reference_Genome_cdna | cut -d " " -f 1 > $expanded_Reference_Folder/enst_list.txt
		sed -i.bak -e 's/>//g' $expanded_Reference_Folder/enst_list.txt
	else
		echo "ENST list already exists: $expanded_Reference_Folder/enst_list.txt"
	fi
	# Run py script for table formation gene counts from salmon sf
	salmon_transcript_quant_py="python3 tr_quant_salmon.py --input '$expanded_Reference_Folder/enst_list.txt' --quant_f '$expanded_OUTPUT_FOLDER/salmon_quant_alignmentmode/quant.sf'"
	python_salmon_cmd="$salmon_transcript_quant_py --output '$expanded_OUTPUT_FOLDER'" 
	# executing my Python script with the constructed command
    echo "Executing Python script for salmon quant.sf transcript quantification table formation..."
    eval "$python_salmon_cmd"
