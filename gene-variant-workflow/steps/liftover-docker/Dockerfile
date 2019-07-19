FROM broadinstitute/picard

RUN wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/liftOver/hg19ToHg38.over.chain.gz
RUN gzip -d hg19ToHg38.over.chain.gz

RUN wget http://hgdownload.cse.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
RUN gzip -d hg38.fa.gz

RUN java -jar /usr/picard/picard.jar CreateSequenceDictionary R=hg38.fa

COPY liftover-vcf.sh liftover-vcf.sh 
RUN chmod 777 liftover-vcf.sh

ENV TMPDIR=/usr/working

ENTRYPOINT []
CMD []