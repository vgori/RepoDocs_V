#!/bin/bash

# Hardcode path /media/localarchive/ONT-data/real-time-tests/test_A
# Hardcode: position, kit, basecall-config
# Here $1 is "test_A"
# and $2 is a "real-time-tests"

sampleid="$1"
expergroup="$2"

python /opt/ont/minknow/ont-python/lib/python3.10/site-packages/minknow_api/examples/start_protocol.py \
--host localhost --position MN32167 \
--sample-id "$sampleid" --experiment-group "$expergroup" \
--experiment-duration 2 \
--kit SQK-PCS111 \
--basecalling \ 
--basecall-config dna_r9.4.1_450bps_hac.cfg \ #hac model 
--fastq