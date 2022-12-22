#!/usr/bin/env bash
set -euo pipefail

CACHE_FILE="$(realpath "$(dirname "${BASH_SOURCE[0]}")/cache")"

function main {
  if [[ "$#" -ne 2 ]] || [[ ! -d "$1" ]] || [[ ! "$2" =~ ^(all|new)$ ]]; then
    cat <<EOF
Usage: ${BASH_SOURCE[0]} DIR SUBSET"

Fills in mp3 tags for all new .mp3 files inside DIR. Set SUBSET to 'all' to
run on all files or 'new' for new files compared to the last run.
EOF
    return 1
  fi
  cd "$1"
  get_files "$2" | generate_tags | tag_files
}

# Lists each file that should be tagged
function get_files {
  local cached new
  case "$1" in
  new)
    mapfile -t cached < <(sort "$CACHE_FILE" 2> /dev/null || true);;
  all)
    cached=()
  esac
  mapfile -t new < <(comm -23 \
    <(find . -type f -name '*.mp3' -printf '%P\n' | sort) \
    <(printf '%s\n' "${cached[@]}") \
  )
  # Cache new files
  printf '%s\n' "${cached[@]}" "${new[@]}" | sort > "$CACHE_FILE"
  # Output new files
  if [[ "${#new[@]}" -ne 0 ]]; then
    printf '%s\n' "${new[@]}"
  fi
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
