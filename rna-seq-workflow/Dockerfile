FROM r-base

RUN apt-get install -y net-tools
RUN apt-get update -qq && apt-get -y install libffi-dev

RUN Rscript -e 'install.packages(c("dplyr", "tidyr", "plyr","optparse"))'

RUN Rscript -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"
RUN Rscript -e "source('http://bioconductor.org/biocLite.R')" -e "biocLite(biomaRt)" -e "biocLite('topGO')"  -e "biocLite('org.Hs.eg.db')"

COPY steps/merge-aligned-files.R /usr/local/bin/merge-aligned-files.R

RUN chmod 777 /usr/local/bin/merge-aligned-files.R

ENV PATH="/usr/local/bin:${PATH}"
