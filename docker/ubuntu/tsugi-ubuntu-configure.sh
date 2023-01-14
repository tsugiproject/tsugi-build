echo "Running Ubuntu Configure"

COMPLETE=/usr/local/bin/tsugi-ubuntu-complete
if [ -f "$COMPLETE" ]; then
    echo "Ubuntu configure already has run"
else
    echo "Not much to configure yet..."
fi

touch $COMPLETE

# Save the Environment Variables for later cron jobs if we are starting from Docker
if [ ! -f "/root/ubuntu-env.sh" ] ; then
    echo "Creating /root/ubuntu-env.sh from docker variables"
    env
    echo "# created from tsugi-ubuntu-configure.sh" > /root/ubuntu-env.sh
    env | sort | grep '^TSUGI' | sed 's/^/export /' >>  /root/ubuntu-env.sh
    env | sort | grep '^POSTFIX' | sed 's/^/export /' >>  /root/ubuntu-env.sh
    env | sort | grep '^MYSQL' | sed 's/^/export /' >>  /root/ubuntu-env.sh
    env | sort > /root/tsugi-env-raw-dump
fi

source /root/ubuntu-env.sh
env

echo "Environment variables:"
env | sort

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Ubuntu Returning..."
  exit
fi

# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Ubuntu Sleeping forever..."
while :; do sleep 2073600; done


