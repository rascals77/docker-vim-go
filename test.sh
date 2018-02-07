#!/bin/bash

SELF=$(basename $0)

error() {
   echo $1 >&2
   exit 1
}

checkdir() {
   if [ ! -e "$1" ] ; then
      error "ERROR: $1 does not exist"
   else
      if [ ! -d "$1" ] ; then
         error "ERROR: $1 exists but is not a directory"
      fi
   fi

   if [ -x /usr/sbin/getenforce ] ; then
      if [ "$(/usr/sbin/getenforce)" = "Enforcing" ] ; then
         CONTEXT=$(/bin/ls -dZ "$1" | awk '{print $4}' | cut -d: -f3)
         if [ "${CONTEXT}" != "svirt_sandbox_file_t" ] ; then
            error "ERROR: SELinux context type of $1 is ${CONTEXT} instead of svirt_sandbox_file_t"
         fi
      fi
   fi
}

if [ ! $@ ] ; then
   error "Usage: ${SELF} [path to GOPATH]"
fi

DIR=$(readlink -f $1)

for CHECKME in "${DIR}" "${DIR}/bin" "${DIR}/src" ; do
   checkdir ${CHECKME}
done

sudo docker run -it --rm \
-e USERID=$(id -u) \
-e GROUPID=$(id -g) \
-v ${DIR}/bin:/go/bin \
-v ${DIR}/src:/go/src \
local/vim-go
