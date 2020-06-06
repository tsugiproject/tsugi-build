
if [ ! -f "ami-env.sh" ] ;
then
    echo "Missing ami-env.sh - copy and edit"
    echo "cp ami-env-dist.sh ami-env.sh"
    exit
fi

source ami-env.sh

bash /usr/local/bin/tsugi-dev-startup.sh return
