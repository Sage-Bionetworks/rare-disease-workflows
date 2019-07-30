FROM r-base

RUN apt-get update -qq && apt-get -y install libssl-dev && apt-get -y install libffi-dev
RUN apt-get install -y net-tools && apt-get install -y libcurl4-openssl-dev && apt-get install -y libxml2-dev

RUN Rscript -e 'install.packages(c("optparse","R.utils"))'

RUN Rscript -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"

COPY synapse-table-store.R /usr/local/bin/synapse-table-store.R

RUN chmod 777 /usr/local/bin/synapse-table-store.R

ENV PATH="/usr/local/bin:${PATH}"
