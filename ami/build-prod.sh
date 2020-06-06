
# Run this from the top level directory

# bash ami/build-prod.sh

bash ami/fake-docker.sh docker/base
bash ami/fake-docker.sh docker/prod
