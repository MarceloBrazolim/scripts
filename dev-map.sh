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

printf "\nWarning:\n"
printf "  No specialized test session was performed reffering the\n\n"
printf "  safety towards the network hosting device by using this tool.\n\n"
printf "  IT MAY HARM YOUR MODEN\n\n"
}

ipaddr() {
printf "\n  YOUR IP ADDRESS IS:\n"
(ip address | grep -e "inet ")
printf "\n"
}

help() {
rows="%-20s %s\n"

warn
printf "\nDetails:\n"
printf "$rows" "  $DETAILS"
printf "\nUsage:\n"
printf "$rows" "  $USAGE"
printf "\nOptions:\n"
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
printf "\n"
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
        (ping -W $W -c $c $var.${i}.${y} | grep "bytes from" >> hosts_test.lock &) 2>&-;
      done
    done
    echo "Discovered Hosts:"
    hosts=$(cat hosts_test.lock | grep "bytes from" | cut -d ':' -f 1 | cut -d 'm' -f 2 | cut -d '.' -f 1,2,3)
    (rm hosts_test.lock)
    echo ""
  fi

  echo "ip_self: $ip_self"
  echo "Select which connection to map:"
  IFS=$'\n' read -r -d '' -a array_self <<< "$ip_self" <<< "$hosts"
  echo "IFS: $IFS"
  for (( j = 0; j < ${#array_self[@]}; j++ )); do
    echo "  $j: ${array_self[$j]}"
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
