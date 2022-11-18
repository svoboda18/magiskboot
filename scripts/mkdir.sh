#!/clang64/xbin/ash
# mkdir-wrapper to create directories only when required
set -e

MKDIR_FLAGS=""
DIRS=""

while [[ $# -gt 0 ]]; do # last arg(s) are/is DIRECTORY(ies)
    case "$1" in
        --help|--version);; # ignored, for production.
        -m) MKDIR_FLAGS="${MKDIR_FLAGS} $1 $2 "; shift;; # pass args accordingly
        -*|--*) MKDIR_FLAGS="${MKDIR_FLAGS} $1 ";;
        *) [ -d "$1" ] || { DIR=${1//$TOPDIR\//}; echo -e "  MKDIR\t    ${DIR}"; DIRS="${DIRS} $1 "; } ;; # this is a file
    esac
    shift
done

[ -n "$DIRS" ] || exit 0

eval mkdir ${MKDIR_FLAGS} ${DIRS}

exit $?