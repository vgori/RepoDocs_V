#!/bin/bash

# chmod +x QC-reads-loop-inclusive.sh
# sed -i -e 's/\r$//' QC-reads-loop-inclusive.sh
# ./QC-reads-loop-inclusive.sh

for dir in RM9-24h-NL-Blood RM9-8wk-NL-Blood; do
  ./QC_reads_FastCat_Pychoper_vUK.sh /buffer_drive/ERASMUS_RadioMarker_PLM/$dir &
done

wait
fg