#!/bin/bash
set -e
# case insensitive
PHOTO_EXT=("cr2" "rw2")
# SIDECAR_EXT=("jpg" "xmp" "pp3")

if [ "$#" != 2 ];then
	echo "usage: organise.sh <source directory> <destination directory>"
fi

SRCPATH=$1
DESTPATH=$(realpath "$2")

function list_to_ext {
	# needed to make `find`` queries in the format https://unix.stackexchange.com/questions/15308/how-to-use-find-command-to-search-for-multiple-extensions
	_LIST=( "$@" )
	echo "${_LIST[@]}" | sed 's/ /\\\|/g'
}

function move_file {
	_FILEPATH=$1
	_DATESTR="$(exiftool -T -createdate "$_FILEPATH")"
	_DIRNAME=$(echo "$_DATESTR" | sed -r 's/^(.+) .+/\1/g' | sed s/:/-/g)
	_YEAR=$(echo "$_DIRNAME" | sed -r 's/^([0-9]+)-.+/\1/')
	_PATH="$DESTPATH/$_YEAR/$_DIRNAME"

	mkdir -p "$_PATH"
	
	# move the original
	# mv "$_FILEPATH" "$_PATH/"

	# move everything including sidecars
	_PARENTDIR=$(dirname "$_FILEPATH")
	_BASENAME1=$(basename "$_FILEPATH")
	_BASENAME="${_BASENAME1%.*}"
	# echo "$_BASENAME"
	# echo "$_PARENTDIR"

	mv --backup=t "$_PARENTDIR/$_BASENAME."* "$_PATH/"
}

extensions=$(list_to_ext "${PHOTO_EXT[@]}")

export -f move_file
export DESTPATH

find "$SRCPATH" -type f -iregex '.*\.\('"$extensions"'\)$' -exec bash -c 'move_file "{}"' \;

# move_file dummy
# move_sidecar IMG_0528.CR2

# for ext in $PHOTO_EXT;do

# function move_sidecar {
# 	_FILENAME=$1
# 	_BASENAME="${_FILENAME%.*}"
# 	echo $_BASENAME
# }