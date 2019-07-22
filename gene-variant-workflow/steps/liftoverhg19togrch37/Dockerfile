FROM broadinstitute/picard

COPY hg19ToGRCh37.over.chain.gz hg19ToGRCh37.over.chain.gz
RUN gzip -d hg19ToGRCh37.over.chain.gz

RUN wget ftp://ftp.ensembl.org/pub/grch37/current/fasta/homo_sapiens/dna/Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz
RUN gzip -d Homo_sapiens.GRCh37.dna.primary_assembly.fa.gz

RUN java -jar /usr/picard/picard.jar CreateSequenceDictionary R=Homo_sapiens.GRCh37.dna.primary_assembly.fa

COPY liftover-vcf.sh liftover-vcf.sh 
RUN chmod 777 liftover-vcf.sh

ENV TMPDIR=/usr/working

ENTRYPOINT []
CMD []