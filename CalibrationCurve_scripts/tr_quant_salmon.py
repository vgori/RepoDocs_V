import sys
import os
import argparse
import traceback
from argparse import Namespace
from typing import Dict, Set

def main(enst_list_path: str, quant_path: str, output_folder: str) -> None:
    # Read the ENST list from enst_list.txt and create a set for faster lookups
    with open(enst_list_path, 'r') as enst_file:
        enst_set: Set[str] = {line.strip().strip('"') for line in enst_file}
        # Create dictionaries to store transcript counts and TPM
        transcript_counts: Dict[str, float] = {}
        
    # Read the quant.sf file
    with open(quant_path, 'r') as quant_file:
        header = quant_file.readline().strip().split('\t')
        
        for line in quant_file:
            fields = line.strip().split('\t')
            transcript_id = fields[0]
            counts = float(fields[4])  # NumReads column
            tpm_counts = float(fields[3])  # TPM column

            # Check if this transcript is in your ENST list
            if transcript_id in enst_set:
                transcript_counts[transcript_id] = (counts, tpm_counts)
                #transcript_tpm[transcript_id] = tpm_counts

    # Write the results to a text file
    # Get the current folder name
    current_folder_name = os.path.basename(output_folder)
    output_filename = f"salmon_transcript_{current_folder_name}.txt"
    output_file_path = os.path.join(output_folder, output_filename)
    with open(output_file_path, 'w') as output_file:
        output_file.write("transcript_id\tReadCounts\tTPM\n")
        for enst, (count, TPM) in transcript_counts.items():
            output_file.write(f"{enst}\t{count}\t{TPM}\n")

    print(f"Results written to {output_file_path}")

if __name__ == "__main__":
    # Create an argument parser
    parser = argparse.ArgumentParser(description='quant.sf transcript quantification table formation')
    # Define the arguments that your script accepts
    parser.add_argument('--input', type=str, required=True, help='Path to the input file')
    parser.add_argument('--quant_f', type=str, required=True, help='Path to the quant.sf file')
    parser.add_argument('--output', type=str, required=True, help='Path to the output folder')
    
    # Parse the command line arguments
    args: Namespace = parser.parse_args()
    # Access the arguments in your code
    enst_list_path: str = args.input
    quant_path: str = args.quant_f
    output_folder: str = args.output

    try:
        main(enst_list_path, quant_path, output_folder)
    except BaseException as ex:
        traceback.print_exc()
