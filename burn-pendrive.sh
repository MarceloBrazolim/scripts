#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] burn-pendrive
	 DETAILS="Automatize the proccess of burning an iso image"
# ------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=0.2.0
USAGE="./$me [OPTIONS] [FILE-TO-BURN] [MEDIA-TO-BURN-TO]"


##### Defaults #####

bs="4M"
status="progress"
whoami=$(whoami)


##### Functions #####

help() {
rows="%-20s %s\n"
blank="\n"

printf "$blank"
printf "$rows" "Version: $VERSION"
printf "Details:\n"
printf "$rows" "  $DETAILS"
printf "$blank"
printf "Usage:\n"
printf "$rows" "  $USAGE"
printf "$blank"
printf "Options:\n"
printf "$rows" "  -st <STATUS>" "type of status to show; default: 'progress'"
printf "$rows" "  -bs <N>" "proccess up to N bytes at a time; default: '4M'"
printf "$blank"
exit
}


##### Switches #####

if [ $1 ]; then
  while [ -n "$1" ]; do
    case $1 in
      '-h'|'--help')
        help
        exit 0
      ;;
      '-st'|'--status')
        status=$2
      ;;
      '-bs')
        bs=$2
      ;;
      *)
        if="$1"
	of="$2"
	shift
      ;;
    esac;
    shift;
  done
else
  help
  exit 1
fi


##### Body #####

if [ $whoami != "root" ]; then
  echo "  This script requires to be executed as root"
  echo "  Use 'sudo' and try again."
  exit 1
fi

(dd if="$if" of="$of" bs="$bs" status="$status") 2>&1
