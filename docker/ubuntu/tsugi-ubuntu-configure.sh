echo "Running Ubuntu Configure"

COMPLETE=/usr/local/bin/tsugi-base-complete
if [ -f "$COMPLETE" ]; then
    echo "Ubuntu configure already has run"
else
    echo "Not much to configure yet..."
fi

touch $COMPLETE

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


