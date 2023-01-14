
# Tsugi base PHP docker

# docker build --tag tsugi_ubuntu .
# docker run -p 8080:80 -p 3306:3306 -e BOB=42 -dit tsugi_ubuntu:latest

# To redo
# docker container prune
# docker image rm tsugi_dev:latest tsugi_mysql:latest tsugi_base:latest tsugi_ubuntu:latest

# Note that as of June 2022, apt-get install mariadb-server fails on a 22.04 fresh container
# So we will delay using 22.04 for a while

# Pull base image.
FROM ubuntu:20.04

COPY tsugi-ubuntu-configure.sh /usr/local/bin/
COPY tsugi-ubuntu-software.sh /usr/local/bin/

# Install.
RUN bash /usr/local/bin/tsugi-ubuntu-software.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-ubuntu-configure.sh"]

# Define default command.  (Should never get here)
CMD ["bash"]
