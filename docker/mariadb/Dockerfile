
# Tsugi plus mariadb
# docker build --tag tsugi_mariadb .
# docker run -p 8080:80 -p 3306:3306 -e BOB=42 -dit tsugi_mariadb:latest

# mysql -u root --host=127.0.0.1 --port=3306 -p

FROM tsugi_base:latest

COPY tsugi-mariadb-prepare.sh /usr/local/bin
COPY tsugi-mariadb-configure.sh /usr/local/bin

# Install.
RUN bash /usr/local/bin/tsugi-mariadb-prepare.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443 3306
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-mariadb-configure.sh"]

# Define default command.
CMD ["bash"]
