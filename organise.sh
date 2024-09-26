#!/bin/bash
set -e
# case insensitive
PHOTO_EXT=("cr2" "rw2" "mp4" "mov" "jpg" "jpeg" "dng")

if [ "$#" != 2 ];then
	echo "usage: organise.sh <source directory> <destination directory>"
	exit
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
	_DATESTR=$(exiftool -q -q -T -createdate "$_FILEPATH")
	_DIRNAME=$(echo "$_DATESTR" | sed -r 's/^(.+) .+/\1/g' | sed s/:/-/g)
	_YEAR=$(echo "$_DIRNAME" | sed -r 's/^([0-9]+)-.+/\1/')
	_PATH="$DESTPATH/$_YEAR/$_DIRNAME"

	mkdir -p "$_PATH"

	# move everything including sidecars
	_PARENTDIR=$(dirname "$_FILEPATH")
	_BASENAME1=$(basename "$_FILEPATH")
	_BASENAME="${_BASENAME1%.*}"
	
	for file in "$_PARENTDIR/$_BASENAME."*; do
		reset
		echo "###"
		echo "working on $file"
		filename_=$(basename $file)

		if [ -s "$_PATH/$filename_" ];then # destination exists
			echo "destination exists"
			filesize=$(stat -c%s "$file")
			destsize=$(stat -c%s "$_PATH/$filename_")
			if [ $filesize -lt $destsize ];then
				echo "file is smaller, skipping"
				gio trash "$file"
			elif  $(cmp "$file" "$_PATH/$filename_");then
				# md5sum "$file" "$_PATH/$filename_"
				echo "files are identical, skipping"
				gio trash "$file"
			else
				read  -n 1 -p "DESTINATION EXISTS AND IS DIFFERENT >"
				echo "mv $file" "$_PATH/"
				mv --backup=t "$file" "$_PATH/"
			fi
		else
			echo "destination does not exist"
			echo "mv $file" "$_PATH/"
			mv --backup=t "$file" "$_PATH/"
		fi
	done
}

extensions=$(list_to_ext "${PHOTO_EXT[@]}")

export -f move_file
export DESTPATH

find "$SRCPATH" \
	-type f \
	-iregex '.*\.\('"$extensions"'\)$' \
	-size +512c \
	-exec bash -c 'move_file "{}"' \;