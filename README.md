# dnanexus_gatk_haplotypecaller v1.0
[broadinstute/gatk:4.0.9.0](https://hub.docker.com/r/broadinstitute/gatk/)

## What does this app do?
This app runs the GATK Haplotype caller on an alignment map file. The output is a variant call file containing genomic variants found by mampping the sample against the reference genome.

## What are typical use cases for this app?
This application is designed to be integrated as part of a variant calling workflow. The GATK joint genotyping pipeline can be applied to any Genomic VCF (GVCF `*.g.vcf`) output files.

## What inputs are required for this app to run?
* Input BAM file (`*.bam`)
* Input BAM index (`*.bam.bai`)
* Intervals list - An input file of genomic coordinates to subset analyses to. Formats can be BED (`.bed`) or GATK interval list (`.list`) containing genomic intervals for processing.
* Input files for the reference genome. The same reference used in mapping to create the input BAM file must be used. GATK requires the following input files:
    * A fasta file
    * Fasta index file (\*.fai)
    * Fasta dict file (\*.dict)

Note: See [GATK resource bundle](https://software.broadinstitute.org/gatk/download/bundle) for prepared reference files.

Further optional arguments may be passed to the app:
* GVCF mode bool - A true/false boolean indicating whether or not to create GVCF output files.
* Extra Options - A string of additional options or flags to pass to Haplotype Caller.

### GATK4 docker image asset
The application runs gatk from a docker image using the dx-docker utility. The image is stored on DNAnexus as an asset, created using `dx-docker create-asset` command. The DNAnexus asset record ID is passed to the "assetDepends" key in the dxapp.json file, bundling this image with the app when built.

## What does this app output?
By default, the app outputs a GVCF file (`*.g.vcf`) and its associated index (`*.g.vcf.idx`). If the flag 'GVCF mode bool' is false, then the output is a VCF file (`.vcf`) and its index (`*.vcf.idx`). 

GVCF files contain a record for every position in the reference genome. Therefore, they record non-variant genomic loci that have the same alleles as the reference genome. Their basic specification is the same as VCFs, which contain only variant loci. Variants missing between samples may be due to poor quality mapping or homozygous alleles that match the reference. These scenarios cannot be distinguished using VCF files, wheras GVCFs can be passed to downstream GATK tools to account for this.

## How does this app work?
1. Download input files from DNAnexus
2. Move reference genome files to the home directory. For downstream GATK commands, only the FASTA is given as input and the remaining files are expected in the same directory.
3. Call GATK Haplotype caller with given inputs using Docker
4. Upload output variant files

## References

*Developed by Viapath Genome Informatics*
