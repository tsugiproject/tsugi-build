export DEBIAN_FRONTEND=noninteractive
export LC_ALL=C.UTF-8
echo ======= Update 1
apt update
echo ======= Install MariaDB
apt-get -y install mariadb-server 
echo ======= Cleanup Starting
df
rm -rf /var/lib/apt/lists/*
df
echo ======= Cleanup Done 

#  apt-get install -y mailutils
