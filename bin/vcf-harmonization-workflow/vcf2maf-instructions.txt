#Log into your own docker hub
docker login 

#Pull the latest Genie docker image from the Sage bionetworks repo (since Tom's VCF2MAF docker image resides within Genie)
docker pull sagebionetworks/genie

#Download VEP files and env from Synapse: https://www.synapse.org/#!Synapse:syn18491780
### Make sure you have "vep" folder and ".vep" folder unzipped

#Run docker image
#----------------
#Make it interactive (add -ti)
#Load "vep" and ".vep" folder onto your docker root dir
#Load folder with VCFs onto docker root dir and make it read-writeable (add rw)
#Add Genie docker image name : sagebionetworks/genie:vcf2maf-develop

docker run -ti -v /absolute_path_to_vep/95vep/vep:/root/vep -v /absolute_path_to_.vep/95vep/.vep:/root/.vep -v /absolute_path_to_vcfs/vcfs:/root/vcfs:rw sagebionetworks/genie:vcf2maf-develop

#Run VCF2MAF on test file that is present inside the vep folder
#---------------------------------------------------------------
perl /root/vcf2maf-1.6.17/vcf2maf.pl --input-vcf /root/vcf2maf-1.6.17/tests/test.vcf --output-maf /root/vcf2maf-1.6.17/tests/test.vep.maf --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

#Here the reference fasta file is specifically pointed to since it is unzipped already and gets rid of some errors
#If everything goes well, you should see a test.vep.maf file in your test dir

#Now run VCF2MAF on one VCF file
#If the process gets killed, you are probably running it on your local machine and have exhausted all memory. Spin up an EC2 instance with at least 32GB RAM and SSD vol to do further analysis

perl /root/vcf2maf-1.6.17/vcf2maf.pl --input-vcf /root/vcfs/file.vcf --output-maf /root/vcfs/file.vep.maf --tumor-id file --vep-forks 4 --buffer-size 50 --ref-fasta /root/.vep/homo_sapiens/95_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa

## Next step -- run run_vcf2maf.sh to process all vcf files together

#If running on an instance, make sure you have docker installed and follow the instructions from the top.
