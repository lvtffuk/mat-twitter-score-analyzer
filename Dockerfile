FROM rocker/r-ver:latest

ARG NPM_GITHUB_READ
ENV NPM_GITHUB_READ=$NPM_GITHUB_READ
WORKDIR /usr/src/app
COPY . .

RUN apt-get update && apt-get -y install libglu1 libxml2 libglpk-dev

RUN install2.r --error shiny
RUN install2.r --error shinythemes
RUN install2.r --error ade4
RUN install2.r --error vegan
RUN install2.r --error vegan3d
RUN install2.r --error polycor
RUN install2.r --error psych
RUN install2.r --error BayesLCA
RUN install2.r --error igraph

ENV PORT=8080
LABEL org.opencontainers.image.source https://github.com/lvtffuk/mat-twitter-score-analyzer
EXPOSE 8080

CMD [ "Rscript", "main.R" ]
