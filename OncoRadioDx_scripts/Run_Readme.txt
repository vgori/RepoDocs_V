chmod +x Normalisation_oncotypedx_21gene.R Classification_riskscore_oncotypedx_21gene.R setup_requred_pkg.R run_timemanager_for_P2S.sh

sed -i -e 's/\r$//' Normalisation_oncotypedx_21gene.R Classification_riskscore_oncotypedx_21gene.R setup_requred_pkg.R run_timemanager_for_P2S.sh




./run_timemanager_for_P2S.sh --input_tsv='FC1 FC2' --output='Oncotypedx_results'
