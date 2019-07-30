#!/bin/bash

name=$(echo "$1" | cut -f 1 -d '.')
echo $name
java -Xms1g -Xmx10g -jar /usr/picard/picard.jar LiftoverVcf I=$1 O=${name}hg38.vcf CHAIN=/usr/working/hg19ToHg38.over.chain REJECT=${name}rej.vcf R=$2
