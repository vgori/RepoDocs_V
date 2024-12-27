#!/bin/bash

# Hardcoded path for outputs /media/localarchive/ONT-data/real-time-tests
# --sample-id parameter is entered by user and the --experiment-group is cut from path "/media/localarchive/ONT-data/real-time-tests" as last name of the folder
# Hardcoded parameters start_protocol.py: host, position, kit, basecall-config, name of experiment-group
#     (expergroup is a "real-time-tests" name included in the hardcoded path "/media/localarchive/ONT-data/real-time-tests". It can be changed with the changing the path in the script)
# Parameters experiment-duration (72 hr) and fastq-reads-per-file (4000) we can change
# Here $1 is sample-id named by user as "test_A"
# and $2 is a "real-time-tests" (name of experiment-group)

sampleid="$1"
expergroup="$2"
# starts the minknow 
sudo systemctl start minknow
#wait for minknow 
sleep 60

python /opt/ont/minknow/ont-python/lib/python3.12/site-packages/minknow_api/examples/start_protocol.py \
--host localhost --position P2S-00698-A \
--sample-id "$sampleid" --experiment-group "$expergroup" \
--experiment-duration 72 \
--kit SQK-PCS114 \
--basecalling \
--basecall-config "dna_r9.4.1_450bps_hac.cfg" \
--fastq \
--fastq-reads-per-file 4000

# --experiment-duration 72 can be defined as a constant that allows the minknow to work 
# experiment-duration = mapping_time + < time for start minknow, basecalling processes > - which is vague for me and how long it will take on Tachyon is unclear.
# Time is not always reliable parameter that can depends on different factors on the machine. spped of reading/writing, 