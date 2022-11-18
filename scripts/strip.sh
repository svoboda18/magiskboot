#!/bin/bash
# strip-wrapper to generate NEW stripped files out of INPUT
set -e

[[ $DEBUG -eq 1 ]] && exit 0 # target only rel builds

STANDALONE_STRIPPED=false
STRIP_FLAGS=""

$STANDALONE_STRIPPED && eval ${SH} ${MKDIR} ${SRP} # use our mkdir wrapper

while [[ $# -gt 0 ]]; do # last arg(s) are/is file(s)
    #echo "info: arg: $1"
    if [[ -n "$FILE_NAME" && "$1" =~ ^- ]]; then
		echo "strip: invalid arguments"
		exit 1
    fi
    case "$1" in
        -o) shift;; # ignored, we will generate it conditionally.
        -V|--version);; # ignored, for production.
        -K|-N|-R) STRIP_FLAGS="${STRIP_FLAGS} $1 $2 "; shift;; # pass args accordingly
        -*|--*) STRIP_FLAGS="${STRIP_FLAGS} $1 ";;
        *) FILE_NAME="$(basename "$1")"; echo -e "  STRIP     $FILE_NAME"; $STANDALONE_STRIPPED && FILE_NAME="-o ${SRP}/$FILE_NAME $1" || FILE_NAME="$1"; STRIP_FLAGS="${STRIP_FLAGS} $FILE_NAME ";;#eval $TOPDIR/scripts/genpdb.sh "$FILE_NAME
    esac
    shift
done

eval ${STRIP_CMD} ${STRIP_FLAGS}

exit $?
