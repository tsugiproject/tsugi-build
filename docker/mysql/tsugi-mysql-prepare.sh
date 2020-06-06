export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
echo ======= Update 1
apt-get update
echo ======= Install MySQL
echo "mysql-server-5.7 mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server-5.7 mysql-server/root_password_again password root" | debconf-set-selections
apt-get -y install mysql-server-5.7
# echo ======= Securing Installation
# echo -e "root\nn\nY\nY\nY\nY\n" | mysql_secure_installation
echo ======= Cleanup Starting
df
rm -rf /var/lib/apt/lists/*
df
echo ======= Cleanup Done 

#  apt-get install -y mailutils
