
# Tsugi plus mariadb
# docker build --tag tsugi_dev .
# docker run -p 8080:80 -p 3306:3306 -e TSUGI_SERVICENAME=TSFUN -dit tsugi_dev:latest

# Navigate to http://localhost:8080

# To log in and dig around...
# docker attach d37...

# To re-generate
# docker container prune
# docker image rm tsugi_dev:latest

FROM tsugi_mariadb:latest

COPY tsugi-dev-configure.sh /usr/local/bin

COPY ./www /root/www
COPY ./phpMyAdmin-5.1.1-all-languages.zip /root/phpMyAdmin-5.1.1-all-languages.zip
COPY apache2.conf /etc/apache2

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443 3306
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-dev-configure.sh"]

# Define default command.
CMD ["bash"]
