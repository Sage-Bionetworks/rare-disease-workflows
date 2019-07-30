#!/bin/bash

name=$(echo "$1" | cut -f 1 -d '.')
echo $name
java -Xms1g -Xmx10g -jar /usr/picard/picard.jar LiftoverVcf I=$1 O=${name}_grch37.vcf CHAIN=/usr/working/hg19ToGRCh37.over.chain REJECT=${name}rej.vcf R=/usr/working/Homo_sapiens.GRCh37.dna.primary_assembly.fa
