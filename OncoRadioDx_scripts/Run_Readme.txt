********************** DOWNLOAD ***************************************
git clone https://github.com/vgori/RepoDocs_V

Pull "OncoRadioDx_scripts" folder to the needed dir
Put the "Target_GeneTranscripts_oncotypedx" folder with target genes to the "/media/localarchive/transcriptome_ref"

********************** UKserver paths *********************************

SHARED_FOLDER="/media/localarchive/ONT-data/real-time-tests"
Reference_Target="/media/localarchive/transcriptome_ref/Target_GeneTranscripts_oncotypedx"
Reference_Genome="/media/localarchive/transcriptome_ref"


*********************** ACTIVATE SCRIPTS ******************************

chmod +x Normalisation_oncotypedx_21gene.R Classification_riskscore_oncotypedx_21gene.R setup_requred_pkg.R run_timemanager_for_P2S.sh livebc_timemanager_main_samtools.sh livebc_mapping.sh start_livebc_minknow_P2S_version.sh

sed -i -e 's/\r$//' Normalisation_oncotypedx_21gene.R Classification_riskscore_oncotypedx_21gene.R setup_requred_pkg.R run_timemanager_for_P2S.sh livebc_timemanager_main_samtools.sh livebc_mapping.sh start_livebc_minknow_P2S_version.sh



************************ RUN ******************************************
cd /path/to/the/OncoRadioDx_scripts
./run_timemanager_for_P2S.sh --input_tsv='FC1 FC2' --output='Oncotypedx_results'

# It will creates two folders with name "FC1" and "FC2" (for P2S output) in the SHARED_FOLDER path:/media/localarchive/ONT-data/real-time-tests
# It will creates two folder 'Oncotypedx_results' for the oncotypedx risks classification at the executive R script path ./