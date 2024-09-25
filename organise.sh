#!/bin/bash
set -e
# case insensitive
PHOTO_EXT=("cr2" "rw2" "mp4" "mov" "jpg" "jpeg" "dng")
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

	# move everything including sidecars
	_PARENTDIR=$(dirname "$_FILEPATH")
	_BASENAME1=$(basename "$_FILEPATH")
	_BASENAME="${_BASENAME1%.*}"

	echo "$_BASENAME"

	mv --backup=t "$_PARENTDIR/$_BASENAME."* "$_PATH/"
}

extensions=$(list_to_ext "${PHOTO_EXT[@]}")

export -f move_file
export DESTPATH

find "$SRCPATH" -type f -iregex '.*\.\('"$extensions"'\)$' -exec bash -c 'move_file "{}"' \;