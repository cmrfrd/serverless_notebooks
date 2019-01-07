docker build \
       --pull=false \
       -t serverless_datascience:func-string-test \
       -f ds_dev/Dockerfile.func \
       --build-arg notebook_dir=./notebooks/ \
       --build-arg notebook=notebook_string_test.ipynb \
       .
