################################# for PHE ##############################

Dependensied: sudo apt install csvkit

path to scripts:
./test_Cutoff.sh
./create_samplesheet_file.sh
./run_cuttime_forEach_set.sh
./run_dge_forEach_cuttime.sh

input folder structure is *05Gy* *4Gy* ...
*RUN*
# chmod +x test_Cutoff.sh run_cuttime_forEach_set.sh run_dge_forEach_cuttime.sh create_samplesheet_file.sh 
#  sed -i -e 's/\r$//' test_Cutoff.sh run_cuttime_forEach_set.sh run_dge_forEach_cuttime.sh create_samplesheet_file.sh 



./run_cuttime_forEach_set.sh /media/localarchive/m6A-project/m6A-DGE/arraystar 5 10 15 20 30 40 60 90
./run_dge_forEach_cuttime.sh /media/localarchive/Cutoff_Output/DGE_input 4 05

