#!/bin/bash
# -------------------------------------------------------------------
# [Hiro Fujisame]
NAME="sendExec"
DETAILS="parses input to be executed, both locally and remotely"
# -------------------------------------------------------------------

me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
VERSION=0.1
USAGE="./$me <option ...> <code>"

### Global Vars ###
toParse=""

help() {
row="%-20s %s\n"

printf "$NAME $VERSION\n"
printf "Details:"
printf "$row" "  $DETAILS"
printf "Usage:"
printf "$row" "  $USAGE"
printf "OPTIONS:\n"
printf "$row" "  -h" "shows this menu"
}

if [ $1 ]; then
	while [ -n "$1" ]; do
		case $1 in
			'-h'|'--help')
				help
				exit 0
			;;
		*)
			toParse+="$1 "
		;;

		esac;
		shift;
	done
else
	help
	exit 0
fi

echo "EXECUTING: $toParse..."

(gnome-terminal -- bash -c "$toPartse; exec bash")
