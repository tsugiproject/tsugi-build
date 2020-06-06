
# Run this from the top level directory

# bash ami/build-dev.sh

bash ami/fake-docker.sh docker/base
bash ami/fake-docker.sh docker/mysql
bash ami/fake-docker.sh docker/dev
