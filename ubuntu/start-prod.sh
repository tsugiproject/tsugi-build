
if [ ! -f "ubuntu-env.sh" ] ;
then
    echo "Missing ubuntu-env.sh - copy and edit"
    echo "cp ubuntu-env-dist.sh ubuntu-env.sh"
    exit
fi

source ubuntu-env.sh

bash /usr/local/bin/tsugi-prod-configure.sh return
