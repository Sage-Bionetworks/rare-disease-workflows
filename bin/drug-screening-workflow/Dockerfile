FROM r-base

RUN R -e 'install.packages(c("magrittr", "dplyr", "tidyr", "plyr", "nplr"))'

COPY dose-response-fit.R /usr/local/bin/dose-response-fit.R

RUN chmod 777 /usr/local/bin/dose-response-fit.R

ENV PATH="/usr/local/bin:${PATH}"