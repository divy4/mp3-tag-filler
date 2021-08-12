# MP3 Tag Filler

A tool for automatically filling out MP3 tags based on file structure.

## How it Works

This tool automatically determines genre, author, album, and title based on
file structure. For example, if `<DIR>` is the path passed to the tool,
a file in `<DIR>/A/B/C/D.mp3` would have it's genre set to `A`, it's author
set to `B`, it's album set to `C`, and title set to `D`.

If a smaller number of directories are included in the path,
the album, author, and genre will be given default values in that order.

## Usage

```bash
./fill_tags.sh DIR
```

## Requirements

This tool depends on [kid3](https://kid3.kde.org/)'s CLI.
