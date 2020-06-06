
# Run this from the top level directory

# bash ubuntu/build-dev.sh

bash docker/fake-docker.sh docker/base
bash docker/fake-docker.sh docker/mysql
bash docker/fake-docker.sh docker/dev

