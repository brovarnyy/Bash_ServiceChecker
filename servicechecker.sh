#!/bin/bash
# 
Simple service checker


WORKSPACE=/home/d/Test

# list of services. textkernel english etc.

LISTFILE=$WORKSPACE/serv.lst

# Send mail in case of 0 to. 

EMAILLISTFILE=$WORKSPACE/emails.lst

# Temporary dir

TEMPDIR=$WORKSPACE/cache


# `Quiet` is true when in crontab; 

# crontab -e sets at beginning THIS_IS_CRON=1

# to prevent output email every time runs script

if [ -n "$THIS_IS_CRON" ]; then QUIET=true; else QUIET=false; fi


function test {
   filename=$( echo $1 | cut -f1 -d"/" )
 

  if [ "$QUIET" = false ] ; then echo -n "$p "; fi
	
  if (( $(ps -ef | grep -v grep | grep $p | wc -l) > 0 )) ; then
    # service is working
    if [ "$QUIET" = false ] ; then
      echo -n "$p "; echo -e "\e[32m[ok]\e[0m"
    fi
    # remove .temp file if exist 
    if [ -f $TEMPDIR/$filename ]; then rm -f $TEMPDIR/$filename; fi
  else
    # service is down
    if [ "$QUIET" = false  ] ; then echo -n "$p "; echo -e "\e[31m[DOWN]\e[0m"; fi
    if [ ! -f $TEMPDIR/$filename ]; then
        while read e; do
            #using mailx command
           echo "$p Dear customer, service textkernel is currently DOWN" | mailx -s "$p Service textkernel is Down ( "$p" )" $e
            #using mail command
            #mail -s "$p SERVICE IS DOWN" "$EMAIL"
        done < $EMAILLISTFILE
        echo > $TEMPDIR/$filename
    fi
  fi
}

# main loop
while read p; do
  test $p
done < $LISTFILE
