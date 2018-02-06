#!/bin/bash

if [ ! -e "/.done" ] ; then
   touch /.done
   groupmod -g ${GROUPID} dev
   usermod -u ${USERID} dev
   chown -R ${USERID}:${GROUPID} /home/dev
   chown ${USERID}:${GROUPID} /go
fi

su - dev
