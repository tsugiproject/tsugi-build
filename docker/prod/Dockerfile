
# Tsugi plus mysql
# docker build --tag tsugi_dev .
# docker run -p 8080:80 -p 3306:3306 -e TSUGI_SERVICENAME=TSFUN -dit tsugi_dev:latest

# Navigate to http://localhost:8080

# To log in and dig around...
# docker attach d37...

# To re-generate
# docker container prune
# docker image rm tsugi_dev:latest

FROM tsugi_base:latest

COPY tsugi-prod-configure.sh /usr/local/bin

# COPY ./www ./www

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443 3306
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-prod-configure.sh"]

# Define default command.
CMD ["bash"]
