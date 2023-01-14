echo "Running Production Configure"

bash /usr/local/bin/tsugi-base-configure.sh return

COMPLETE=/usr/local/bin/tsugi-prod-complete
if [ -f "$COMPLETE" ]; then
    echo "Production configure already has run"
else

echo "Updating build scripts..."
cd /root/tsugi-build
git pull

bash /root/tsugi-build/common/tsugi-common-configure.sh

# if COMPLETE
fi

touch $COMPLETE

echo ""
if [ "$@" == "return" ] ; then
  echo "Tsugi Production Returning..."
  exit
fi

exec bash /usr/local/bin/monitor-apache.sh

# Should never happen
# https://stackoverflow.com/questions/2935183/bash-infinite-sleep-infinite-blocking
echo "Tsugi Production Sleeping forever..."
while :; do sleep 2073600; done
