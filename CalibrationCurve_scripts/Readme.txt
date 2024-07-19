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
   /data/Reference_Genome_HomoSapiens/Homo_sapiens.GRCh38.cdna.all.fa
   /data/Reference_Genome_HomoSapiens/Target_GeneTranscripts
   Transcript names:(transcripts_AEN transcripts_APOBEC3H transcripts_ASTN2 transcripts_BAX transcripts_BBC3 transcripts_BLOC1S2 transcripts_CCNG1 transcripts_CCR4 transcripts_CD70 transcripts_CDKN1A transcripts_CTSO transcripts_DDB2 transcripts_DOK7 transcripts_DUSP3 transcripts_EDA2R transcripts_FBXW2 transcripts_FDXR transcripts_GADD45A transcripts_GDF15 transcripts_GRM2 transcripts_GZMA transcripts_HPRT1 transcripts_IGFBP5 transcripts_IGLV1-44 transcripts_MAMDC4 transcripts_MDM2 transcripts_MLH1 transcripts_MYC transcripts_NKG7 transcripts_NovelPseudogene_ENSG00000283234 transcripts_PCNA transcripts_PF4 transcripts_PHPT1 transcripts_POLH transcripts_POU2AF1 transcripts_PPM1D transcripts_PRRX1 transcripts_PTP4A1_Pseudogene_ENSG00000278275 transcripts_RAD23A transcripts_RAD51 transcripts_RBM15 transcripts_RBM3 transcripts_RPL23AP42 transcripts_RPS19P1 transcripts_RPS27 transcripts_SESN1 transcripts_SOD1 transcripts_SPATA18 transcripts_TNFRSF10B transcripts_TNFSF4 transcripts_VWCE transcripts_XPC transcripts_ZMAT3 transcripts_WNT3_ENSG00000108379)


6. *** Preare srips for the execution ***
   chmod +x Cutoff.sh Cutoff_CORE.sh run_cuttime_forEach_set.sh run_cuttime_includedSet.sh run_dge_forEach_cuttime.sh SamSal_tools.sh
   sed -i -e 's/\r$//' Cutoff.sh Cutoff_CORE.sh run_cuttime_forEach_set.sh run_cuttime_includedSet.sh run_dge_forEach_cuttime.sh SamSal_tools.sh


7. *** Run cuttime for selected folders ***
  7.1 # In the script run_cuttime_includedSet.sh write desired folder names -> folders=("test-H48-2Gy-2" "test-H48-2Gy-3")
      # run script with <path where located the folders with seq data> <path to output folder> <minutes for cut> 
      ./run_cuttime_includedSet.sh /media/localarchive/Calibration-4 /media/localarchive/Cutoffs 5 10 15 20

  7.2 # Run cuttime for each set in a row
      ./run_cuttime_forEach_set.sh /media/localarchive/Calibration-4 /media/localarchive/Cutoffs 5 10 15 20

   # By default run_cuttime_includedSet.sh and run_cuttime_forEach_set.sh use Cutoff_CORE.sh with NUM_CPUS=30
   # You can change in Cutoff_CORE.sh num of CORES to other number like NUM_CPUS=40
   
   # Also you can run Cutoff.sh without using specific number of cores. For that change in run_cuttime_includedSet.sh and run_cuttime_forEach_set.sh the name of sh script to Cutoff.sh


8. # Run SamSal.sh
   # Check in script hardcoded paths variables and run
   ./SamSal_tools.sh <Time_cutoff folder name> <cut_Set1_0Gy_1> <Output_SamSaltools_cutoffs>
   # Example for running test-H48-2Gy-2 set with cut 10 min
   ./SamSal_tools.sh time_cutoff_10 cut_test-H48-2Gy-2_10 Output_SamSaltools_cutoffs
   
   # You can run simultaniously several sets for different cutoffs
   ./SamSal_tools.sh <Time_cutoff folder name> <name of cut set1> <Output folder for SamSaltools_cutoffs> & ./SamSal_tools.sh <Time_cutoff folder name> <name of cut set2> <Output folder for SamSaltools_cutoffs> && fg 



