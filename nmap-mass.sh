#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] mass-nmap
DETAILS="checks for a list of IPs and performs a nmap scan"
# ------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=0.1.0
SUBJECT=mass-nmap-451278784212
USAGE="./$me [options]"


##### Defaults #####


##### Functions #####

warn() {
rows="%-20s %s\n"
blank="\n"

printf "$blank"
printf "Warning:\n"
printf "  No specialized test session was performed reffering the"
printf "$blank"
printf "  safety towards the network hosting device by using this tool."
printf "$blank"
printf "  IT MAY HARM YOUR MODEN"
printf "$blank"
printf "  This tool does not work on Windows OS with Linux Subsystem"
printf "$blank"
printf "$blank"
}

ipaddr() {
blank="\n"
printf "$blank"
printf "  YOUR IP ADDRESS IS:\n"
(ip address | grep -e "inet ")
printf "$blank"
}

help() {
rows="%-20s %s\n"
blank="\n"

warn
printf "$blank"
printf "Details:\n"
printf "$rows" "  $DETAILS"
printf "$blank"
printf "Usage:\n"
printf "$rows" "  $USAGE"
printf "$blank"
printf "Options:\n"
printf "$rows" "  -h" "shows this menu"
printf "$rows" "  -v" "shows the program version"
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
      '-V'|'--version')
        echo $VERSION
        exit 0
      ;;
      '-nW'|'--no-wall')
        nW=true
      ;;
      '-wr'|'--warn')
        warn
        exit 0
      ;;
      '-ip'|'--ipaddr')
        ipaddr
        exit 0
      ;;
      '-Pn')
        Pn=" -Pn"
      ;;
      '-sC')
        sC=" -sC"
      ;;
      '-sV')
        sV=" -sV"
      ;;
      '-sU')
        sU=" -sU"
      ;;
      '-v')
        v=" -v"
      ;;
      '-vv')
        v=" -vv"
      ;;
      '-vvv')
        v=" -vvv"
      ;;
      '-oN')
        oNComm=" -oN"
        oN="/tmp/logs/map-${2}"
        echo "results will be saved in ${oN} file"
        shift
      ;;
      '-t'|'target')
        path=${2}
        shift
      ;;
      '-s'|'--self')
        s=true
      ;;
      *)
        echo "$1: switch unknown"
        echo "To see the help menu, type $me --help."
        exit 1
      ;;

    esac;
    shift;
  done
fi


##### Locks #####

LOCK_FILE=$SUBJECT.lock

if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE


##### Body #####

if [ ! $nW ]; then
  warn
  ipaddr
fi

(cat "/tmp/logs/map-${path}" | grep -e "bytes from" | cut -d 'm' -f 2 | cut -d ':' -f 1 > $LOCK_FILE) # | cut -d '.' -f 1,2,3,4)
(sort -u -n -t. -k1,1 -k2,2 -k3,3 -k4,4 -s --output=$LOCK_FILE $LOCK_FILE)


if [ $oN ]; then
  [ ! -d "/tmp/logs" ] && (mkdir '/tmp/logs')
  (date >> "$oN" && echo "" >> "$oN")
fi

if [ $s ]; then
  ip_self=$(cat $LOCK_FILE)
  echo "  Select which IP to attack:"
  IFS=$'\n' read -r -d '' -a array_self <<< "$ip_self"
  for (( j = 0; j < ${#array_self[@]}; j++ )); do
    echo "    $j: ${array_self[$j]}"
  done
  printf "> _ "
  read -n $(printf "${#array_self[@]}" | wc -m) -s -e self_reply
  target=($(echo "${array_self[$self_reply]}" | tr ";" "\n"))
  printf "\n\n"
  (nmap $sV $sC $sU $Pn $v $oNComm $oN ${target}) 2>&-;
else
  for (( i=0; i <= ${#LOCK_FILE[@]}; i++ )); do
    (nmap $sV $sC $sU $Pn $v $oNComm $oN ${LOCK_FILE[i]}) 2>&-;
  done
fi
