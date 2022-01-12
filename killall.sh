#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] killall
         DETAILS="Terminates every PID from the specified processes"
# ------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=0.5.0
SUBJECT=killall57445147587549
USAGE="./$me process1 [process2 ...]"


##### Defaults #####

help() {
rows="%-15s %s\n"
blank="\n"

printf "$blank"
printf "killall.sh v$VERSION\n"
printf "$blank"
printf "Details:\n"
printf "$rows" "  $DETAILS"
printf "$blank"
printf "Usage:\n"
printf "$rows" "  $USAGE"
exit
}


##### Locks #####

LOCK_FILE=$SUBJECT.lock

if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE


##### Body #####
pids=""
if [ $1 ]; then
  while [ -n "$1" ]; do
    temp=$(pidof $1)
    if [ -n "$temp" ]; then
      pids+="$temp "
    else
      echo "No process with the name: $1"
    fi
    unset temp
    shift;
  done
  kill $pids
else
  help
  exit 0
fi
