#!/usr/bin/env bash
set -euo pipefail

function main {
  local files
  if [[ "$#" -ne 1 ]] || [[ ! -d "$1" ]]; then
    echo "Usage: ${BASH_SOURCE[0]} DIR"
    echo ''
    echo 'Fills in mp3 tags for all .mp3 files inside DIR.'
    return 1
  fi

  cd "$1"
  mapfile -t files < <(find . -type f -name '*.mp3' -printf '%P\n')
  for file in "${files[@]}"; do
    set_tags "$file" \
      "$(get_genre "$file")" \
      "$(get_artist "$file")" \
      "$(get_album "$file")" \
      "$(get_title "$file")"
  done
}

# Outputs the artist of a file (the name of the first level directory) or
# 'unknown' if the file isn't at least 1 directory deep.
function get_genre {
  if [[ "$(get_component_count "$1")" -ge 2 ]]; then
    echo "$1" | awk --field-separator='/' '{print $1}'
  else
    echo 'unknown'
  fi
}

# Outputs the artist of a file (the name of the first level directory) or
# 'unknown' if the file isn't at least 2 directories deep.
function get_artist {
  if [[ "$(get_component_count "$1")" -ge 3 ]]; then
    echo "$1" | awk --field-separator='/' '{print $2}'
  else
    echo 'unknown'
  fi
}

# Outputs the album of a file (the name of the second level directory) or
# 'other' if the file isn't at least 3 directories deep.
function get_album {
  if [[ "$(get_component_count "$1")" -ge 4 ]]; then
    echo "$1" | awk --field-separator='/' '{print $3}'
  else
    echo 'other'
  fi
}

# Outputs the title of a file (the name of the file without .mp3 at the end).
function get_title {
  echo "$1" | awk --field-separator='/' '{print $NF}' | sed 's/\.mp3$//g'
}

function set_tags {
  local file genre artist album title
  file="$1"
  genre="$2"
  artist="$3"
  album="$4"
  title="$5"
  echo "Setting $file: genre=$genre, artist=$artist, album=$album, title=$title"
  kid3-cli \
    -c "set genre '$genre'" \
    -c "set artist '$artist'" \
    -c "set album '$album'" \
    -c "set title '$title'" \
    "$file"
}

function get_component_count {
  echo "$1" | awk --field-separator='/' '{print NF}'
}

main "$@"
