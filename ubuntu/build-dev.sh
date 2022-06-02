
# Run this from the top level directory

# bash ubuntu/build-dev.sh

bash docker/fake-docker.sh docker/base
bash docker/fake-docker.sh docker/mariadb
bash docker/fake-docker.sh docker/dev

