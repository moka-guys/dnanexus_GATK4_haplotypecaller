#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
# set -e -x -o pipefail

# Download input data
dx-download-all-inputs

# Pull GATK docker to workstation
dx-docker pull broadinstitute/gatk:4.0.9.0

# Call Haplotype Caller
dx-docker run -v /home/dnanexus/:/gatk broadinstitute/gatk:4.0.9.0 gatk HaplotypeCaller \
  -R ${reference_fasta_path} -I ${input_bam_path} \
  -O ${input_bam_name}.g.vcf -ERC GVCF -L ${intervals_list}

# Create output directories and move respective files
gvcf_out="out/gvcf"
gvcf_index_out="out/gvcf_index"
mkdir -p ${gvcf_out} && mv *.g.vcf ${gvcf_out}
mkdir -p ${gvcf_index_out} && mv *.g.vcf.idx ${gvcf_index_out}

# Upload output data 
dx-upload-all-outputs
