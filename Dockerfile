FROM rocker/tidyverse:3.6.0

# Set Environment Variables
ENV PROJECT_NAME poker
ENV APP_ROOT /home/rstudio/poker

LABEL org.redventures.image.authors="Keith Williams" \
      org.redventures.image.vendor="Data Science" \
      org.redventures.image.title="poker" \
      org.redventures.image.description="Development Environment for poker" \
      org.redventures.image.source="https://github.com/keithgw/poker"

WORKDIR ${APP_ROOT}

# If installed, deactivate `renv`.  This prevents issue with the shim for `install.packages()`
RUN Rscript - e "if('renv' %in% rownames(installed.packages()) == TRUE) {renv::deactivate()}"

# Install `remotes` and `renv`
RUN Rscript -e 'install.packages("remotes"); library(remotes);'
RUN R -e 'remotes::install_github("rstudio/renv@0.7.1-20"); library(renv)'

COPY ./renv.lock .
RUN Rscript -e 'renv::consent(provided = TRUE);'
RUN Rscript -e "renv::restore(library = '/usr/lib/R/site-library');"

CMD ["/init"]
