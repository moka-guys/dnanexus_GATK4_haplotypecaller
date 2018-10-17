#!/bin/bash

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

# Download input data
dx-download-all-inputs

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

# Pull GATK docker to workstation
dx-docker pull broadinstitute/gatk:4.0.9.0

# Call Haplotype Caller
dx-docker run -v /home/dnanexus/:${docker_dir} broadinstitute/gatk:4.0.9.0 gatk HaplotypeCaller \
  -R sandbox/${docker_reference_fasta_path} -I sandbox/${docker_input_bam_path} \
  -O sandbox/${docker_input_bam_name}.g.vcf -ERC GVCF -L sandbox/${docker_intervals_list_path}

# Create output directories and move respective files
gvcf_out="out/gvcf"
gvcf_index_out="out/gvcf_index"
mkdir -p ${gvcf_out} && mv *.g.vcf ${gvcf_out}
mkdir -p ${gvcf_index_out} && mv *.g.vcf.idx ${gvcf_index_out}

# Upload output data 
dx-upload-all-outputs
