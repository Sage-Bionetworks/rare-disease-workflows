#!/bin/bash

## First run the vcf2maf instructions script to load all the required files and set up docker image.

## This script finds all unprocessed vcf files in the folder, checks if any have been converted to maf already, and runs vcf2maf on each file that has noot been processed yet
## Dependencies : the directories vep/ and .vep/ should be pre-loaded on /root/ if using an EC2 instance
## Use a compute-optimized instance with SSD volume for optimum run time for the VCF2MAF functions

for file in ./*.vcf.gz
do
	##Extract the tumorID present in the VCF file 
	export tid=$(echo ${file} | grep -o -E '[0-9]+')
	export tumorid=$(echo ${tid} | tr " " -)
	##Detect the file type and then run the appropriate perl script for VCF2MAF
	if [[ ${file} ==  *".vep.vcf" ]]
	then
		echo "already done"
	## Files from different studies were aligned to different genomes, so detect the file origin and run the appropriate reference genome file
	elif [[ ${file} ==  *_"MS_OnBait.vcf" ]]
	then
		##Rename the output file with the tumorid.vep.maf
		perl /root/vcf2maf-1.6.17/vcf2maf.pl --input-vcf ${file}  --output-maf /root/vcfs/mafs/${tumorid}.vep.maf --tumor-id ${tumorid} --vep-forks 500 --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa
	elif [[ ${file} ==  *_"somatic_snvs_conf_8_to_10.vcf" ]]
	then
		perl /root/vcf2maf-1.6.17/vcf2maf.pl --input-vcf ${file}  --output-maf /root/vcfs/mafs/${tumorid}.vep.maf --tumor-id ${tumorid} --vep-forks 500 --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa
	else
		perl /root/vcf2maf-1.6.17/vcf2maf.pl --input-vcf ${file}  --output-maf /root/vcfs/mafs/${tumorid}.vep.maf --tumor-id ${tumorid} --vep-forks 500 --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/hg19.fa
	fi
done

## If a vcf file is known to originate from a normal sample, set 
	## < --normal-id ${tumorid} >


