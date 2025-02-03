**Readme**

All rights reserved. This software code is an exclusive property of HQ Science Limited and the UK Health Security Agency. The distribution of this code or any part of it is prohibited without written authorization from both HQ Science Limited and the UK Health Security Agency.

This software is designed for transcriptome analysis, including mapping and annotation of cDNA (and direct RNA in the future) sequencing data, as well as differential expression analysis.

The pipeline includes the following steps:
1. Prefiltering fastq files using the 'fastcat' tool.
2. Using 'pychopper' for cDNA reads (identification and trimming of primers from reads).
3. Aligning and sorting .bam files with 'minimap2' and 'samtools'.
4. Generating transcript counts using Salmon.

All outputs are collected in the 'data_processing' folder. 
The output from Salmon is in quant.sf format, which is converted to quant.tsv. 
Additionally, there is an output from samtools named stat_aligned_<sample_name>.txt containing the mapped reads (third column). 
These outputs can be used with DEXSeq or edgeR R packages for downstream analysis.



Dependensies:

conda create -n fastcat -c conda-forge -c bioconda -c nanoporetech fastcat
conda install -c conda-forge -c bioconda pychopper



For research purposes only.