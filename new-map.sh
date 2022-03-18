#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] map-icmp
DETAILS="uses ICMP brute force to list connected
  devices in the local network"
# ------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=0.1.0
SUBJECT=subject-name-r4nd0nnumb3r
USAGE="./$me [options]"


##### Defaults #####

rangeA='255'
c='1'
W='2'


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

ipaddr() {
blank="\n"
printf "$blank"
printf "  YOUR IP ADDRESS IS:\n"
(ip address | grep -e "inet ")
printf "$blank"
}

##### Switches #####

if [ $1 ]; then
  while [ -n "$1" ]; do
    case $1 in
      '-h'|'--help')
        help
        exit 0
      ;;
      '-v'|'--version')
        echo $VERSION
        exit 0
      ;;
      '-d'|'--debugg')
        debgg=true
      ;;
      '-rA'|'--rangeA')
        range=$2
        shift
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

warn
ipaddr

# gather and format ip addrs.
ip_self=$(ip address | grep -e "inet " | cut -d '/' -f 1 | cut -d 't' -f 2 | cut -d '.' -f 1,2,3)
echo "  Select which connection to map:"

# creates user query for gathered ip addrs.
ISF=$'\n' read -r -d '' -a array_self <<< "$ip_self"
for ((j = 0; j < ${#array_self[@]}; j++ )); do
    echo "      $j: ${array_self[$j]}"
done
printf ">_"     # parses user query.
read -n $(printf "${#array_self[@]}" | wc -m) -s -e self_reply
target=($(echo "${array_self[$self_reply]}." | tr ";" "\n"))

[ debgg ] && (echo "target var: ${target}")

# main ICMP attack op.
for (( i = 0; i <= $rangeA; i++)); do
    (ping -c $c -W $W ${target[$i]} | grep "bytes from" >> $LOCK_FILE &) 2>&-;
done

# registers to .lock for echoing.
file_lines=$(cat "${LOCK_FILE}" | wc -l < ${LOCK_FILE})
(cat "${LOCK_FILE}")
