FROM serverless_datascience:base

##
## Add notebook from build argument.
## 
##
ARG notebook_dir=.
ENV NOTEBOOK_DIR=$notebook_dir
ARG notebook
ENV NOTEBOOK=$notebook
ADD $NOTEBOOK_DIR/$NOTEBOOK /notebook.ipynb

##
## Notebook execution environment variables
## for notebook execution and parsing
##
## NOTEBOOK             : placeholder name for executing notebook
## JQ_NOTEBOOK_STDOUT   : jq query to parse first stdout output of an executed notebook
##
ENV NOTEBOOK=/notebook.ipynb
ENV JQ_NOTEBOOK_STDOUT="[.cells | .[] | .outputs] | del(.[] | select(. == []))[0] | [ .[] | select( .name == \"stdout\" ) ][0] | .text[0]"

##
## Inline script creation for notebook execution and response
## This is to minimize file artifacts for this docker image
##
## - activate the conda environment to execute the notebook in
## - convert stdin as json to yaml file
## - execute notebook with yaml file paramaters
## - parse executed notebook for stdout and return 
##
## $(cat $ENVIRONMENT | yq .name)
RUN echo 'source activate serverless_datascience &&\
  	      json2yaml > $(pwd)/params.yml &&\
	      (papermill $NOTEBOOK /tmp/out.ipynb \
	                 -f $(pwd)/params.yml \
	                 --no-log-output \
	                 --no-progress-bar \
           	         --not-report-mode > /dev/null 2>&1) &&\  
	      cat /tmp/out.ipynb | jq -c "$JQ_NOTEBOOK_STDOUT"' > execute-notebook-script.sh && \
    chmod +x execute-notebook-script.sh

ENV fprocess="bash execute-notebook-script.sh"

RUN curl -sL https://github.com/openfaas/faas/releases/download/0.9.6/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog
CMD ["fwatchdog"]
HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
