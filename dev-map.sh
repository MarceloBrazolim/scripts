#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] map-icmp
DETAILS="uses ICMP brute force to list connected
  devices in the local network"
# ------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=1.1.0
SUBJECT=mapicmp57445147587548
USAGE="./$me [options]"


##### Defaults #####

target=("192" "168" "0" "")
range='255'
range1='255'
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
printf "$rows" "  -c <count>" "stop after <count> replies"
printf "$rows" "  -h" "shows this menu"
printf "$rows" "  -l" "queries for localhost"
printf "$rows" "  -t <x.x.x>" "specifies a target range"
printf "$rows" "  -v" "shows the program version"
printf "$rows" "  -W <n>" "time to wait for response"
printf "$rows" "  -a" "searches for every IP parting from class B"
printf "$rows" "  -r <n>" "defines the range to scan the IPs on class A"
printf "$rows" "  -r1 <n>" "defines the range to scan the IPs on class B"
printf "$rows" "  -oN <file>" "saves the output in the specified file, instead of echoing to the terminal"
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
      '-v'|'--version')
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
      '-l'|'--localhost')
        target='localhost'
        l=true
      ;;
      '-t'|'--target')
        var="$2."
        target=($(echo $var | tr ";" "\n"))
        unset var
        shift
      ;;
      '-W'|'--wait')
        W=$2
        shift
      ;;
      '-c'|'--count')
        c=$2
        shift
      ;;
      '-a'|'--all')
        [ $v ] && (echo "Option --all selected, this operation will take longer")
        a=true
      ;;
      '-r'|'--range')
        range=$2
        shift
      ;;
      '-r1'|'--range1')
        range1=$2
        shift
      ;;
      '-d'|'--debugg')
        d=true
      ;;
      '-oN')
        oN="logs/map-${2}"
        [ $v ] && (echo "results will be saved in ${oN} file")
        shift
      ;;
      '-s'|'--self')
        s=true
      ;;
      '-vv')
        v=true
      ;;
      '-hd'|'--host-discovery')
        hd=true
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

if [ $s ]; then
  ip_self=$(ip address | grep -e "inet " | cut -d '/' -f 1 | cut -d "t" -f 2 | cut -d '.' -f 1,2,3)

  if [ $hd ]; then
    whytho=("${target[@]:1}")
    var=$(printf %s "${target[0]}" "${whytho[0]/#/.}")
    [ $v ] && (echo "Discovering hosts.: (${var[@]}.0-${range1}.0-1)")
    for (( i = 0; i <= $range1; i++ )); do
      for (( y = 0; y <= 1; y++ )); do
        (ping -W $W -c $c $var.${i}.${y} | grep "bytes from" > hosts_test &) #2>&-;
      done
    done
    echo "$hosts ++-"
    printf "\n-++ "
    (cat hosts_test)
    [ $v ] && (echo ".")
  fi

  echo "  Select which connection to map:"
  IFS=$'\n' read -r -d '' -a array_self <<< "$ip_self"
  for (( j = 0; j < ${#array_self[@]}; j++ )); do
    echo "    $j: ${array_self[$j]}"
  done
  printf "> _ "
  read -n $(printf "${#array_self[@]}" | wc -m) -s -e self_reply
  target=($(echo "${array_self[$self_reply]}." | tr ";" "\n"))
  printf "\n\n"
fi

if [ $l ] || [ $k ]; then
  [ $v ] &&  (echo "Targeting: ($target)")
  (ping -W $W -c $c $target | grep "bytes from" >> $LOCK_FILE &) 2>&-;
else
  if [ $a ]; then
    whytho=("${target[@]:1}")
    var=$(printf %s "${target[0]}" "${whytho[0]/#/.}")
    [ $v ] && (echo "Targeting: (${var[@]}.0-${range1}.0-${range})")
    for (( i = 0; i <= $range1; i++ )); do
      for (( y = 0; y <= $range; y++ )); do
        (ping -W $W -c $c $var.${i}.${y} | grep "bytes from" >> $LOCK_FILE &) 2>&-;
      done
    done
  else
    whytho=("${target[@]:1}")
    var=$(printf %s "${target[0]}" "${whytho[@]/#/.}")
    [ $v ] && (echo "Targeting: (${var[@]}0-${range})")
    for (( i = 0; i <= $range; i++ )); do
      (ping -W $W -c $c $var${i} | grep "bytes from" >> $LOCK_FILE &) 2>&-;
    done
  fi
fi
sleep $W

(sort -n -t. -k1,1 -k2,2 -k3,3 -k4,4 -s --output=$LOCK_FILE $LOCK_FILE)

if [ $oN ]; then
  [ ! -d "logs" ] && (mkdir 'logs')
  (date >> "$oN" && cat "$LOCK_FILE" > "$oN" && cat "$LOCK_FILE" && echo "" >> "$oN")
else
  (cat $LOCK_FILE)
fi
