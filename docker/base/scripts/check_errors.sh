# !/bin/sh

source /home/ubuntu/tsugi_env.sh

NOW=`date +%Y%m%d`
YEST=`expr $NOW - 1`
host=$TSUGI_SERVICENAME

echo "Host: $host"


LOGFILE=/var/log/apache2/error.log
OLDERRORS=/tmp/tsugi-$host-old-errors
NEWERRORS=/tmp/tsugi-$host-current-errors
logdate=`stat $LOGFILE | grep Change: | grep -P ' ([0-9-]+) ' -o | sed 's/ //g'`
errdate='2006-01-01'
if [ -e "$OLDERRORS" ]
then
errdate=`stat $OLDERRORS | grep Change: | grep -P ' ([0-9-]+) ' -o | sed 's/ //g'`
fi

echo Dates log $logdate old-errors $errdate
if [ "$logdate" \> "$errdate" ]
then
   echo "Resetting previous errors"
   rm -f $OLDERRORS
   touch $OLDERRORS
fi

rm -f $NEWERRORS

# egrep 'DIE: |PHP Parse error: |PHP Fatal error:|PHP Notice:|PHP Warning:|Grade NOT updated|Grade failure|Failure to store grade|Missing required result data|Missing required session data|Session not set up for grade return|Grade Exception:|Grade read failure:|Fatal XML' $LOGFILE | egrep -v 'Session has expired|This tool should be launched from a learning system using LTI|Session address has expired|POST Content-Length|OAuth validation fail.*error=Expired timestamp|Missing PHPSESSID from POST data|OAuth nonce error' | grep -v 'failure_is_expected' > /tmp/csev-$host-current-errors

# egrep 'DIE: |PHP Parse error: |PHP Fatal error:|PHP Notice:|PHP Warning:|Grade NOT updated|Grade failure|Failure to store grade|Missing required result data|Missing required session data|Session not set up for grade return|Grade Exception:|Grade read failure:|Fatal XML' $LOGFILE > /tmp/csev-$host-current-errors

egrep 'DIE: |SQLSTATE|Token|PHP Parse error:|PHP Fatal error:|PHP Notice:|PHP Warning:|Grade NOT updated|Grade failure|Failure to store grade|Missing required result data|Missing required session data|Session not set up for grade return|Grade Exception:|Grade read failure:|Fatal XML' $LOGFILE | egrep -v 'This tool should be launched from|Session expired|failure_is_expected|Undefined property: MyClass2::.priv|Session in login|Session expired|Heartbeat' > $NEWERRORS

lines=`cat $NEWERRORS | wc -l`
startpos=`cat $OLDERRORS | wc -l`

echo Postions $startpos $lines

if [ "$startpos" -ge "$lines" ]
then
   echo "No new errors"
   exit
fi

startpos=`expr $startpos + 1`  # Add one
message=/tmp/csev-$host-current-message
rm -f $message
echo "Log Errors $NOW" > $message
echo "Starting at line $startpos of $LOGFILE" >> $message
echo "" >> $message
tail -n +$startpos $NEWERRORS >> $message

# curl -i -X POST -H "Content-Type: multipart/form-data" -F "data=@$message" "http://www.dr-chuck.com/relay/index.php?to=csev@umich.edu&api=54321&subject=Errors:+$host"

email='info@learnxp.com';
if [ -n "$TSUGI_OWNEREMAIL" ] ; then
   email=$TSUGI_OWNEREMAIL
fi

from='info@learnxp.com';
if [ -n "$POSTFIX_MAIL_FROM" ] ; then
   from=$POSTFIX_MAIL_FROM
fi


echo Mail sending to $email

mail $email -r $from -s "$host Errors" < $message

cp $NEWERRORS $OLDERRORS

echo Message sent.

