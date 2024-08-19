################################# for PHE PC1 ##############################

Dependensied: sudo apt install csvkit
1. Download "Calibration_curve" follder with scripts to your dir
2. Make sure that names of your input Set folders with basecallled fastq contain number of Gy: *05Gy*, *4Gy* (like Set1_05Gy)
3. Check python and following dependensies installed:
   datetime   
   argparse
   traceback
   typing
   itertools
   dateutil.parser
   concurrent.futures



4. Spripts location in the "Calibration_curve" folder:
   ./Cutoff.sh
   ./Cutoff_CORE.sh
   ./run_cuttime_includedSet.sh
   ./run_cuttime_forEach_set.sh
   ./run_dge_forEach_cuttime.sh
   ./SamSal_tools.sh

5. Referenses location:
   /media/localarchive/transcriptome_ref/Homo_sapiens.GRCh38.cdna.all.fa
   /media/localarchive/transcriptome_ref/Target_GeneTranscripts
   Transcript names:(transcripts_AEN transcripts_APOBEC3H transcripts_ASTN2 transcripts_BAX transcripts_BBC3 transcripts_BLOC1S2 transcripts_CCNG1 transcripts_CCR4 transcripts_CD70 transcripts_CDKN1A transcripts_CTSO transcripts_DDB2 transcripts_DOK7 transcripts_DUSP3 transcripts_EDA2R transcripts_FBXW2 transcripts_FDXR transcripts_GADD45A transcripts_GDF15 transcripts_GRM2 transcripts_GZMA transcripts_HPRT1 transcripts_IGFBP5 transcripts_IGLV1-44 transcripts_MAMDC4 transcripts_MDM2 transcripts_MLH1 transcripts_MYC transcripts_NKG7 transcripts_NovelPseudogene_ENSG00000283234 transcripts_PCNA transcripts_PF4 transcripts_PHPT1 transcripts_POLH transcripts_POU2AF1 transcripts_PPM1D transcripts_PRRX1 transcripts_PTP4A1_Pseudogene_ENSG00000278275 transcripts_RAD23A transcripts_RAD51 transcripts_RBM15 transcripts_RBM3 transcripts_RPL23AP42 transcripts_RPS19P1 transcripts_RPS27 transcripts_SESN1 transcripts_SOD1 transcripts_SPATA18 transcripts_TNFRSF10B transcripts_TNFSF4 transcripts_VWCE transcripts_XPC transcripts_ZMAT3 transcripts_WNT3_ENSG00000108379)


6. *** Preare srips for the execution ***
   chmod +x Cutoff.sh Cutoff_CORE.sh run_cuttime_forEach_set.sh run_cuttime_includedSet.sh run_dge_forEach_cuttime.sh SamSal_tools.sh
   sed -i -e 's/\r$//' Cutoff.sh Cutoff_CORE.sh run_cuttime_forEach_set.sh run_cuttime_includedSet.sh run_dge_forEach_cuttime.sh SamSal_tools.sh


7. *** Run cuttime for selected folders ***
  7.1 # In the script run_cuttime_includedSet.sh write desired folder names -> folders=("H14-3Gy" "P1-4Gy" "P32-1Gy")
      # run script with <path where located the folders with seq data> <path to output folder> <minutes for cut> 
      ./run_cuttime_includedSet.sh /media/localarchive/ONT-data/4th-calibration /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90

  7.2 # Run cuttime for each set in a row
      ./run_cuttime_includedSet.sh /media/localarchive/ONT-data/4th-calibration /media/localarchive/ONT-data/4th-calibration/Cutoffs 5 10 15 30 45 60 90

   # By default run_cuttime_includedSet.sh and run_cuttime_forEach_set.sh use Cutoff_CORE.sh with NUM_CPUS=20
   # You can change in Cutoff_CORE.sh num of CORES to other number like NUM_CPUS=30
   
   # Also you can run Cutoff.sh without using specific number of cores. For that change in run_cuttime_includedSet.sh and run_cuttime_forEach_set.sh the name of sh script to Cutoff.sh


8. # Run SamSal_tools.sh
   # Check in script hardcoded paths variables and run
   ./SamSal_tools.sh <Time_cutoff folder name> <cut_Set1_0Gy_1> <Output_SamSaltools_cutoffs>
   # Example for running test-H48-2Gy-2 set with cut 10 min
   ./SamSal_tools.sh time_cutoff_10 cut_test-H48-2Gy-2_10 Output_SamSaltools_cutoffs
   
   8.1 # You can run simultaniously several sets for different cutoffs
       ./SamSal_tools.sh <Time_cutoff folder name> <name of cut set1> <Output folder for SamSaltools_cutoffs> & ./SamSal_tools.sh <Time_cutoff folder name> <name of cut set2> <Output folder for SamSaltools_cutoffs> && fg 

./SamSal_tools.sh time_cutoff_5 cut_H14-05Gy_5 samsal_output \
& ./SamSal_tools.sh time_cutoff_10 cut_H14-05Gy_10 samsal_output \
& ./SamSal_tools.sh time_cutoff_15 cut_H14-05Gy_15 samsal_output && fg

   8.2 # Run subsequently. it continues running the next command even if the previous one fails


# 19.08.24 - Run for sets: "H14-4Gy" "H14-5Gy" "P1-01Gy" "P32-2Gy" "P32-3Gy" "P32-4Gy"

./SamSal_tools.sh time_cutoff_5 cut_H14-4Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-4Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-4Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-4Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-4Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-4Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-4Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-5Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-5Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-5Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-5Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-5Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-5Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-5Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-01Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-01Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-01Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-01Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-01Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-01Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-01Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-2Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-2Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-2Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-2Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-2Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-2Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-2Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-3Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-3Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-3Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-3Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-3Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-3Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-3Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-4Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-4Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-4Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-4Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-4Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-4Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-4Gy_90 samsal_output || true



# Run for sets: "H14-0Gy" "P1-0Gy" "P32-0Gy" "H14-05Gy" "P1-05Gy" "P32-05Gy" "H14-1Gy" "P1-1Gy" "P32-1Gy-repeat"


./SamSal_tools.sh time_cutoff_5 cut_H14-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-0Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-1Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-1Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-1Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-1Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-1Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-1Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-1Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-0Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-1Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-1Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-1Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-1Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-1Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-1Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-1Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-0Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-1Gy-repeat_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-1Gy-repeat_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-1Gy-repeat_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-1Gy-repeat_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-1Gy-repeat_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-1Gy-repeat_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-1Gy-repeat_90 samsal_output || true

################################ ignore this #############################
./SamSal_tools.sh time_cutoff_5 cut_H14-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-0Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-1Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-1Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-1Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-1Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-1Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-1Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-1Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_H14-2Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_H14-2Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_H14-2Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_H14-2Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_H14-2Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_H14-2Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_H14-2Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-0Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-1Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-1Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-1Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-1Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-1Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-1Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-1Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-2Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-2Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-2Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-2Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-2Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-2Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-2Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-3Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-3Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-3Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-3Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-3Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-3Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-3Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P1-5Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P1-5Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P1-5Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P1-5Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P1-5Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P1-5Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P1-5Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-01Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-01Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-01Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-01Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-01Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-01Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-01Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-025Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-025Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-025Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-025Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-025Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-025Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-025Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-05Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-05Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-05Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-05Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-05Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-05Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-05Gy_90 samsal_output \
&& ./SamSal_tools.sh time_cutoff_5 cut_P32-0Gy_5 samsal_output \
&& ./SamSal_tools.sh time_cutoff_10 cut_P32-0Gy_10 samsal_output \
&& ./SamSal_tools.sh time_cutoff_15 cut_P32-0Gy_15 samsal_output \
&& ./SamSal_tools.sh time_cutoff_30 cut_P32-0Gy_30 samsal_output \
&& ./SamSal_tools.sh time_cutoff_45 cut_P32-0Gy_45 samsal_output \
&& ./SamSal_tools.sh time_cutoff_60 cut_P32-0Gy_60 samsal_output \
&& ./SamSal_tools.sh time_cutoff_90 cut_P32-0Gy_90 samsal_output || true



