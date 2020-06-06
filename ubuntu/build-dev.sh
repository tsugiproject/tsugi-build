
# Run this from the top level directory

# bash ubuntu/build-dev.sh

bash ubuntu/fake-docker.sh docker/base
bash ubuntu/fake-docker.sh docker/mysql
bash ubuntu/fake-docker.sh docker/dev

