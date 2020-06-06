
# Tsugi plus mysql
# docker build --tag tsugi_mysql .
# docker run -p 8080:80 -p 3306:3306 -e BOB=42 -dit tsugi_mysql:latest

# mysql -u root --host=127.0.0.1 --port=3306 -p

# See: https://gist.github.com/sheikhwaqas/9088872 

FROM tsugi_base:latest

COPY tsugi-mysql-prepare.sh /usr/local/bin
COPY tsugi-mysql-configure.sh /usr/local/bin

# Install.
RUN bash /usr/local/bin/tsugi-mysql-prepare.sh

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

EXPOSE 80 443 3306
ENTRYPOINT ["bash", "/usr/local/bin/tsugi-mysql-configure.sh"]

# Define default command.
CMD ["bash"]
