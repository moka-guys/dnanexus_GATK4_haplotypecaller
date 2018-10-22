#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

# Download input data
dx-download-all-inputs

# Move reference genome inputs to the same directory
mv ${reference_fasta_index_path} ${reference_fasta_dict_path} $(dirname $reference_fasta_path)
# Move BAM index file to the same directory
mv ${input_bam_index_path} $(dirname $input_bam_path)

# Set variables and functions for dx-docker
home_dir=/home/dnanexus
docker_dir=/gatk/sandbox

function docker_path(){
	# Replaces the home directory in a given string with the docker directory path. 
	# Affords for correct dx_helper variables in mounted docker containers.
	input_string=$1
	echo $input_string | sed -e "s,$home_dir,$docker_dir,g"
}

docker_reference_fasta_path=$(docker_path $reference_fasta_path)
docker_input_bam_path=$(docker_path $input_bam_path)
docker_intervals_list_path=$(docker_path $intervals_list_path)
docker_input_bam_prefix=${input_bam_prefix}

# Pull GATK docker to workstation
dx-docker pull broadinstitute/gatk:4.0.9.0

# Call Haplotype Caller
dx-docker run -v /home/dnanexus/:${docker_dir} broadinstitute/gatk:4.0.9.0 gatk HaplotypeCaller \
  -R ${docker_reference_fasta_path} -I ${docker_input_bam_path} \
  -O ${docker_dir}/${docker_input_bam_prefix}.g.vcf -ERC GVCF -L ${docker_intervals_list_path}

# Create output directories and move respective files
gvcf_out="out/gvcf"
gvcf_index_out="out/gvcf_index"
mkdir -p ${gvcf_out} && mv *.g.vcf ${gvcf_out}
mkdir -p ${gvcf_index_out} && mv *.g.vcf.idx ${gvcf_index_out}

# Upload output data 
dx-upload-all-outputs
