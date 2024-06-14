################################# for PHE ##############################

Dependensied: sudo apt install csvkit
1. Download "Calibration_curve" follder with scripts to your dir
2. Make sure that names of your input Set folders with basecallled fastq contain number of Gy: *05Gy*, *4Gy* (like Set1_05Gy)
3. To RUN. In terminal go to the "Calibration_curve" folder and execute the ./run_cuttime_forEach_set.sh with input parameters: <Inputh path to the Sets> <Output path> <cut min_1> <cut_min_2> ect.

Spripts location in the "Calibration_curve" folder:
./test_Cutoff.sh
./create_samplesheet_file.sh
./run_cuttime_forEach_set.sh
./run_dge_forEach_cuttime.sh

*RUN Cutoff*
# chmod +x test_Cutoff.sh run_cuttime_forEach_set.sh run_dge_forEach_cuttime.sh create_samplesheet_file.sh 
#  sed -i -e 's/\r$//' test_Cutoff.sh run_cuttime_forEach_set.sh run_dge_forEach_cuttime.sh create_samplesheet_file.sh 

./run_cuttime_forEach_set.sh /media/localarchive/m6A-project/m6A-DGE/arraystar /data/Cutoff/Output_blood 5 10 15 20 

Output path:/data/Cutoff/Output_blood

*RUN DGR for Cutoff*
./run_dge_forEach_cuttime.sh /media/localarchive/Cutoff_Output/DGE_input 4 05



