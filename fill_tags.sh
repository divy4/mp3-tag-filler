#!/usr/bin/env bash
set -euo pipefail

function main {
  if [[ "$#" -ne 1 ]] || [[ ! -d "$1" ]]; then
    echo "Usage: ${BASH_SOURCE[0]} DIR"
    echo ''
    echo 'Fills in mp3 tags for all .mp3 files inside DIR.'
    return 1
  fi
  cd "$1"
  get_files | generate_tags | tag_files
}

# Lists each file that should be tagged
function get_files {
  find . -type f -name '*.mp3' -printf '%P\n'
}

# Generates tags for each file
function generate_tags {
  awk -F '/' '{
    file=$0

    if (NF >= 2)
      genre=$1
    else
      genre="unknown"

    if (NF >= 3)
      artist=$2
    else
      artist="unknown"

    if (NF >= 4)
      album=$3
    else
      album="other"

    title=$NF
    gsub(".mp3", "", title)

    print file"|"genre"|"artist"|"album"|"title
  }'
}

# Applies tags to each file
function tag_files {
  local array
  while IFS='|' read -r -a array; do
    file="${array[0]}"
    genre="${array[1]}"
    artist="${array[2]}"
    album="${array[3]}"
    title="${array[4]}"
    echo "Setting $file: genre=$genre, artist=$artist, album=$album, title=$title"
    kid3-cli \
      -c "set genre \"$genre\"" \
      -c "set artist \"$artist\"" \
      -c "set album \"$album\"" \
      -c "set title \"$title\"" \
      "$file"
  done
}

main "$@"
