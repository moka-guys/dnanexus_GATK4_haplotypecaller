#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

function manage_reference_data(){
	# Move files to home directory (/home/dnanexus) on the worker. Unzip first if .gz is suffix.
	# Input Args:
    #    1: A reference genome file (fasta, dict or index)
	#    2: A suffix for the output. Written to the home directory using the reference fasta prefix.
	# Example: 
	#    manage_reference_data input.fasta.gz .fasta
	#    (creates)>>> /home/dnanexus/input.fasta

    # Set input arguments to variables
    input_file=${1}
    output_suffix=${2}
    # If input file ends with *.gz suffix, unzip to the home directory.
    if [[ ${input_file} == *.gz ]]; then
        gunzip -c ${input_file} > ${HOME}/${reference_fasta_prefix}${2}
	else
		# Else move input file to the home directory with suffix
		mv $input_file ${HOME}/${reference_fasta_prefix}${2}
	fi
}

# Download input data
dx-download-all-inputs

# Pull GATK docker to workstation
dx-docker pull broadinstitute/gatk:4.0.9.0

# Move BAM file, BAM index and intervals list files to the home directory
mv ${input_bam_index_path} ${input_bam_path} ${intervals_list_path} $HOME
# Move reference data to $HOME directory. If any files end with "*.gz", unzip first.
manage_reference_data ${reference_fasta_path} .fasta
manage_reference_data ${reference_fasta_index_path} .fasta.fai
manage_reference_data ${reference_fasta_dict_path} .dict

# Set flag for GVCF mode if input option gvcf_mode is set to true
if [ $gvcf_mode = true ] ; then
    gvcf_opt="-ERC GVCF"
else
    gvcf_opt=""
fi

# Call Haplotype Caller
# Uses the GATK4 v4.0.9.0 docker image (IMAGE ID : 68b475015074), passed to the appliation via the assetDepends key in dxapp.json
dx-docker run -v /home/dnanexus/:/gatk/sandbox 68b475015074 gatk HaplotypeCaller \
  -R /gatk/sandbox/${reference_fasta_prefix}.fasta \
  -I /gatk/sandbox/${input_bam_name} \
  -O /gatk/sandbox/${input_bam_prefix}.g.vcf \
  -L /gatk/sandbox/${intervals_list_name} \
  ${gvcf_opt} ${extra_opts}

# Create output directories and move respective files
gvcf_out="out/gvcf"
gvcf_index_out="out/gvcf_index"
mkdir -p ${gvcf_out} && mv *.g.vcf ${gvcf_out}
mkdir -p ${gvcf_index_out} && mv *.g.vcf.idx ${gvcf_index_out}

# Upload output data 
dx-upload-all-outputs
