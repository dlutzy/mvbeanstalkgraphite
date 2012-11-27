#!/bin/bash
# Minimum viable Beanstalk stats to Graphite script
# David Lutz
# 2012-11-26
# Run from cron like this
# *       *       *       *       *    /opt/mvbeanstalkgraphite/mvbg.sh interestingtube graphite.example.com 1> /dev/null  2> /dev/null 
tube=$1
graphite=$2
friendlyhost=`hostname | sed 's/\./_/g'`
now=`date -u +"%s"`
INFOFILE=`mktemp /tmp/mvbg.XXXXXX`
(echo "stats-tube $tube" ; sleep 1) | telnet localhost 11300 > $INFOFILE                    

for i in  current-jobs-reserved current-jobs-ready current-jobs-delayed current-jobs-buried total-jobs
do
 out=`cat $INFOFILE | grep "$i:" | awk -F ':' '{print $2}' | tr -d '\r' `
 echo "beanstalk.$friendlyhost.$i $out $now" | nc -w 20 $graphite 2003
 echo "beanstalk.$friendlyhost.$i $out $now" 
done

rm $INFOFILE
