#!/bin/bash
# ------------------------------------------------------------------
# [Hiro Fujisame] Map-Icmp
DETAILS='Uses ICMP brute force to list connections in the local network'
# ------------------------------------------------------------------

SUBJECT=icmpmap4125142
VERSION=2.0.0
USAGE="Usage: command -hv args"

# -----------------------------------------------------------------
#  FUNCTIONS
# -----------------------------------------------------------------

help () {
  rows="%-20s %s\n"
  blank="\n"

  printf "$blank"
  printf "Details:$blank"
  printf "$rows" "  $DETAILS$blank"
  printf "Usage:$blank"
  printf "$rows" "  $USAGE$blank"
  printf "Options:$blank"
  printf "$rows" "  -h" "Show the help menu"
  printf "$rows" "  -v" "Show the script version"
}

myIp() {
  local __myIpList=$(ip address | grep -e "inet ")
  echo $__myIpList
  local __resultMyIp="$(echo $__myIpList | cut -d " " -f 2,7,9)"
  echo ${__resultMyIp[@]}
}

pingNet() {
  shift
  

  local initialIp=( 192 168 0 1 )
  local limitIp=( 192 168 0 255 )
  echo ${initialIp[@]}
  echo ${limitIp[@]}
  for (( i = 0; i < 4; i++ )); do
    initialIp=( [$i]=$(cut -d "." -f ${i+1}3 <<< $1) )
    limitIp=( [$i]=$(cut -d "." -f ${i+1} <<< $2) )
  done
  for (( d=$initialIp[0]; d <= $limitIp[0]; d++ )); do
    for (( c=$initialIp[1]; c <= $limitIp[1]; c++ )); do
      for (( b=$initialIp[2]; b <= $limitIp[2]; b++ )); do
        for (( a=$initialIp[3]; a <= $limitIp[3]; a++ )); do
          __pingNetList=$(ping -c 1 "${d}.${c}.${b}.${a}" | grep "bytes from" &) 2>&-;
          echo "$d.$c.$b.$a"
          echo $__pingNetList;
        done
      done
    done
  done
}


# --- Option processing --------------------------------------------
if [ $# == 0 ] ; then
    echo $USAGE
    exit 1;
fi

while getopts ":vht" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "h")
        echo $USAGE
        exit 0;
        ;;
      "t")
        myIp;
        pingNet $1 $2 $3 $4 $5 $6 $7 $8;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

param1=$1
param2=$2
# -----------------------------------------------------------------

LOCK_FILE=/tmp/${SUBJECT}.lock

if [ -f "$LOCK_FILE" ]; then
echo "Script is already running"
exit
fi

# -----------------------------------------------------------------
trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE


# -----------------------------------------------------------------
#  LOGIC
# -----------------------------------------------------------------
